//
//  OTAFileManager.m
//  otaclient
//
//  Created by Tang on 2018/6/20.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "OTAFileManager.h"
#import "DFUDef.h"
#import "OTAImageTypeManager.h"
#define BIT(a)                                  (0x1<<a)
#define MP_HEADER_LEN                           512

typedef NS_ENUM(uint16_t, SUB_BIN_HEADER_TYPE)
{
    TYPE_BIN_ID = 0X1,
    TYPE_VER = 0X2,
    TYPE_PART_NUM = 0X3,
    TYPE_LENGTH = 0X4,
    TYPE_OTA_VERSIOIN = 0X11,
    TYPE_IMAGE_ID = 0X12,
    TYPE_FLASH_ADDR = 0X13,
    TYPE_IMAGE_SIZE = 0X14,
    TYPE_SEC_VERSION = 0X15,
    TYPE_IMAGE_VERSION = 0X16,
    
};




@implementation OTAFileManager

+ (OTASubBinHeaderModel *)parseMpHeader:(uint8_t *)buffer
{
   // NSMutableArray *array = [NSMutableArray array];
    int offset = 0;
    OTASubBinHeaderModel *model = [[OTASubBinHeaderModel alloc]init];
    model.otaVersion = 0;
    BOOL imageVersionSetted = NO;
    while (offset+3 < 512) {
        uint16_t type = *(uint16_t *)buffer;
        if (type == 0 || type == 0xffff) {
            break;
        }
        uint8_t len = buffer[2];
        if (offset + 3 + len <= 512) {
            NSData *context = [NSData dataWithBytes:buffer+3 length:len];
           
          //  NSLog(@"SUB_BIN_HEADER_TYPE = 0x%04x (%@)", type, context);
            switch (type) {
                    case TYPE_BIN_ID:
                {
                    model.binID = *(uint16_t *)context.bytes;
                }
                    break;
                case TYPE_FLASH_ADDR: {
                    model.flashAddr = *(uint32_t *)context.bytes;
                }
                    break;
                case TYPE_IMAGE_VERSION:
                case TYPE_VER:
                {
                    if (imageVersionSetted)
                        break;
                    
                    if (len == 4) {
                        model.imageVersion = type == TYPE_VER ? *(uint32_t *)context.bytes : CFSwapInt32(*(uint32_t *)context.bytes);
                    } else if (len == 2)
                        model.imageVersion = type == TYPE_VER ? *(uint16_t *)context.bytes : CFSwapInt16(*(uint16_t *)context.bytes);
                    
                    if (type == TYPE_IMAGE_VERSION) {
                        imageVersionSetted = YES;
                    }
                }
                    break;
                case TYPE_OTA_VERSIOIN:
                    model.otaVersion = *(uint8_t *)context.bytes;
                    break;
                case TYPE_SEC_VERSION:
                    model.secVersion = *(uint16_t *)context.bytes;
                    break;
                case TYPE_IMAGE_SIZE:
                case TYPE_LENGTH:
                    model.dataLength = *(uint32_t *)context.bytes;
                    break;
                case TYPE_IMAGE_ID:
                    model.imageId = *(uint16_t *)context.bytes;
                    break;
                default:
                    break;
            }
            offset += (3 + len);
            buffer += (3 + len);
        }
        else{
            break;
        }
    }
    return model;
}

+ (OTAFileModel *)loadFileWithPath:(NSString *)path devFeature:(OTADeviceFeatureModel *)devFeature
{
    OTAFileModel *model = [[OTAFileModel alloc]init];
    NSData *_reader = [NSData dataWithContentsOfFile:path];
    model.bPackBin = false;
    model.fileStatus = ERROR_STATE_SUCCESS;
    model.filesArray = [NSMutableArray array];
    PACK_HEADER packHeader = {0};
    [_reader getBytes:&packHeader length:sizeof(PACK_HEADER)];
    uint8_t freeBank = 0xf;
    
    if (devFeature.devInfo.otaVersion == 1) {
        uint32_t imagesVersion = devFeature.devInfo.imagesVersion;
        int count00 = 0;
        int count01 = 0;
        int count10 = 0;
        int count11 = 0;
        for (int i=0; i<16; i++) {
            int k = (imagesVersion >> (i*2)) & 0x3;
            if (k == 0) {
                count00++;
            }
            else if (k == 1) {
                count01++;
            }
            else if (k == 2) {
                count10++;
            }
            else if (k == 3) {
                count11++;
            }
        }
        
        
        if (count11 > 0)
        {
            if(count10 == 0 && count01 == 0) {
                freeBank = 0xf;
            }
            else{
                [OTADebugManager printLog:LEVEL_ERROR format:@"error, bank switch error"];
                model.fileStatus = ERROR_STATE_DEVINFO;
                return model;
            }
        }
        else
        {
            if(count10 > count01) {
                freeBank = 0;
            }
            else if(count10 < count01) {
                freeBank = 1;
            }
            else{
                [OTADebugManager printLog:LEVEL_ERROR format:@"error, bank switch error"];
                model.fileStatus = ERROR_STATE_DEVINFO;
                return model;
            }
        }
    }
    else if(devFeature.devInfo.otaVersion == 0)
    {
        freeBank = devFeature.devInfo.freeBank;
    }

    if (packHeader.signature == 0x4d47) {
        model.bPackBin = true;
        int fileNum = 0;
       
       IC_TYPE ic = (uint8_t)(packHeader.extension>>8);
        NSMutableArray *array = [NSMutableArray array];
        for (int i=0; i<32; i++) {
            int k = (packHeader.indicator & BIT(i)) >> i;
            if (k == 1) {
                NSLog(@"file type: %d", i);
                [array addObject:@(i)];
                fileNum++;
            }
        }

        uint8_t *fileBuf = (uint8_t *)_reader.bytes;
        uint32_t tempTotalSize = sizeof(PACK_HEADER)+fileNum*sizeof(SUB_FILE_HEADER);
        for (int i=0; i<fileNum; i++) {
            SUB_FILE_HEADER sfh;
            memcpy(&sfh, fileBuf+sizeof(PACK_HEADER)+i*sizeof(SUB_FILE_HEADER), sizeof(SUB_FILE_HEADER));
            NSData *data = [NSData dataWithBytes:fileBuf+tempTotalSize length:sfh.size];
            NSNumber *num = array[i];
            if(freeBank == 1)
            {
                if (num.intValue >= 16) {
                  //  [_files addObject:data];
                    OTASubFileModel *model1 = [[OTASubFileModel alloc]init];
                    model1.header = [OTAFileManager parseMpHeader:(uint8_t *)data.bytes];
                    model1.imageType = num.intValue-16;
                    model1.data = [data subdataWithRange:NSMakeRange(MP_HEADER_LEN, model1.header.dataLength)];
                    [model.filesArray addObject:model1];
                }
            }
            else {
                if (num.intValue < 16) {
                    OTASubFileModel *model1 = [[OTASubFileModel alloc]init];
                    model1.header = [OTAFileManager parseMpHeader:(uint8_t *)data.bytes];
                    model1.imageType = num.intValue;
                    model1.data = [data subdataWithRange:NSMakeRange(MP_HEADER_LEN, model1.header.dataLength)];
                    [model.filesArray addObject:model1];
                }
            }

            tempTotalSize += sfh.size;
            if (freeBank == 0xf && num.intValue==OTA_HEADER) {
                [OTADebugManager printLog:LEVEL_WARN format:@"freeBank is off, file contain ota_header"];
                model.fileStatus = ERROR_STATE_FILE_OTA_HEADER;
                return model;
            }
        }
        
        if (model.filesArray.count == 0) {
            [OTADebugManager printLog:LEVEL_WARN format:@"pack images no file"];
            model.fileStatus = ERROR_STATE_FILE_BANK;
            return model;
        }
        
        
        if (freeBank != 0xf) {
            BOOL bFound = false;
            for (OTASubFileModel *model1 in model.filesArray) {
                if (model1.imageType == OTA_HEADER) {
                    bFound = true;
                    break;
                }
            }
            if (!bFound) {
                model.fileStatus = ERROR_STATE_FILE_OTA_HEADER2;
                return model;
            }
        }
        
        for (OTASubFileModel *model1 in model.filesArray) {
//            model1.typeString = [OTAImageTypeManager getStringFromType:model1.imageType andIC:devFeature.devInfo.ICType];
            
            model1.typeString = [OTAImageTypeManager getStringFromType:model1.imageType andIC:ic];
            model1.versionString = [OTAImageTypeManager formatVersionFromInteger:model1.header.imageVersion imageType:model1.imageType icType:ic];
        }
    }
    else
    {
        model.bPackBin = false;
        if (devFeature.devInfo.otaVersion == 1 && freeBank != 0xf) {
            model.fileStatus = ERROR_STATE_FILE_NOT_SUPPORT;
            return model;
        }
        
        if (devFeature.devInfo.ICType > IC_BEE) {
            OTASubFileModel *model1 = [[OTASubFileModel alloc]init];
            model1.header = [OTAFileManager parseMpHeader:(uint8_t *)_reader.bytes];
            switch (model1.header.binID) {
                case 0x0101:
                    model1.imageType = SOCV_CFG;
                    break;
                case 0x0100:
                    model1.imageType = SYSTEM_CONFIG;
                    break;
                case 0x0200:
                    model1.imageType = ROM_PATCH;
                    break;
                case 0x0300:
                    model1.imageType = APP_IMG;
                    break;
                case 0x0400:
                    model1.imageType = APP_UI_PARAMETER;
                    break;
                case 0x0410:
                    model1.imageType = DSP_UI_PARAMETER;
                    break;
                case 0x0500:
                    model1.imageType = DSP_SYSTEM;
                    break;
                case 0x0700:
                    model1.imageType = SECURE_BOOT_LOADER;
                    break;
                case 0x0800:
                    model1.imageType = OTA_HEADER;
                    break;
                default:
                    break;
            }
            model1.data = [_reader subdataWithRange:NSMakeRange(MP_HEADER_LEN, model1.header.dataLength)];
            model1.typeString = [OTAImageTypeManager getStringFromType:model1.imageType andIC:devFeature.devInfo.ICType];
            model1.versionString = [OTAImageTypeManager formatVersionFromInteger:model1.header.imageVersion imageType:model1.imageType icType:devFeature.devInfo.ICType];
            [model.filesArray addObject:model1];
        } else {
            uint8_t *buffer = (uint8_t *) _reader.bytes;
            if (buffer[0] == IC_BEE || buffer[0] == IC_BEE2 || buffer[0] == IC_BBPRO) {
                OTASubFileModel *model1 = [[OTASubFileModel alloc]init];
                OTASubBinHeaderModel *model2 = [[OTASubBinHeaderModel alloc]init];
                model2.dataLength = (uint32_t)_reader.length;
                uint16_t *buf = (uint16_t *)[[_reader subdataWithRange:NSMakeRange(4, 2)]bytes];
                model2.imageVersion = *buf;
                model1.data = _reader;
                model1.header = model2;
                model1.versionString = [NSString stringWithFormat:@"%u", model2.imageVersion];
                model1.typeString = NSLocalizedString(@"Upgrade to version", nil);
                [model.filesArray addObject:model1];
            }
            else{
                OTASubFileModel *model1 = [[OTASubFileModel alloc]init];
                model1.header = [OTAFileManager parseMpHeader:(uint8_t *)_reader.bytes];
                // model1.imageType = num.intValue;
                model1.data = [_reader subdataWithRange:NSMakeRange(MP_HEADER_LEN, model1.header.dataLength)];
                //            model1.versionString = [NSString stringWithFormat:@"%u", model1.header.imageVersion];
                model1.versionString = [OTAImageTypeManager versionToString:model1.header.imageVersion];
                model1.typeString = NSLocalizedString(@"Upgrade to version", nil);
                [model.filesArray addObject:model1];
            }
        }
    }
    
    
    return model;
}
@end
