//
//  OTADevInfoManager.m
//  otaclient
//
//  Created by Tang on 2018/6/20.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "OTADevInfoManager.h"
#import "OTAImageTypeManager.h"
#import "DFUDef.h"

#define BIT0                                    (0x1<<0)
#define BIT1                                    (0x1<<1)
#define BIT2                                    (0x1<<2)
#define BIT3                                    (0x1<<3)
#define BIT4                                    (0x1<<4)
#define BIT5                                    (0x1<<5)
#define BIT6                                    (0x1<<6)
#define BIT7                                    (0x1<<7)
#define BIT8                                    (0x1<<8)
#define BIT9                                    (0x1<<9)

@interface OTADevInfoManager()
@property (nonatomic, strong) OTADeviceFeatureModel *model;
@end

@implementation OTADevInfoManager
+ (OtaDeviceInfo *)parseDeviceInfo:(NSData *)data
{
    if (!data) {
        return nil;
    }
    OtaDeviceInfo *info = [[OtaDeviceInfo alloc]init];
//    info.AppBank = 0xf;
//    info.PatchBank = 0xf;
    info.freeBank = 0xf;

    info.cpyImg = 0x0;
    info.Aes = true;
    info.updateMultiImages = 0;
    info.otaVersion = 0;
    NSInteger length = data.length;
#define BEE1_DEVICEINFO_LEN 1
#define V0_DEVICEINFO_LEN 14
#define V1_DEVICEINFO_LEN 12
    if (length == BEE1_DEVICEINFO_LEN) {
        info.ICType = IC_BEE;
        info.Aes = true;
        info.BufferCheck = false;
        uint8_t *buf = (uint8_t *)data.bytes;
        info.freeBank = buf[0];
        return info;
    }
    else {
        uint8_t *buf = (uint8_t *)data.bytes;
        uint8_t ota_version = buf[1];
        if (ota_version == 1) {
#pragma pack(push, 1)
            typedef struct _DEVICE_INFO_CHAR {
                uint8_t ictype;
                uint8_t ota_version;
                uint8_t secure_version;
                union
                {
                    uint8_t value;
                    struct
                    {
                        uint8_t buffercheck: 1; // 1:support,  0:don't support
                        uint8_t aesflg: 1;      // 1:aes encrypt when ota,  0:not encrypt
                        uint8_t aesmode: 1;     // 1:all data is encrypted, 0:only encrypt 16byte
                        uint8_t copy_img:1;     //1:support ,0:don't support
                        uint8_t multi_img:1;    //1:support(update multi img at a time) ,0:don't support(one img at a time)
                        uint8_t rsvd: 3;
                    };
                } mode;
                
                uint16_t maxbuffersize;
                uint8_t tempBufSize;
                uint8_t res;
                uint32_t img_indicator;
            } DEVICE_INFO_CHAR;
            
#pragma pack(pop)
            DEVICE_INFO_CHAR *value = (DEVICE_INFO_CHAR *) data.bytes;
            info.ICType = value->ictype;
            //    info.freeBank = _freeBank = value->freebank;
            info.BufferCheck =  (value->mode.buffercheck);
            info.Aes =  value->mode.aesflg;
            info.EncryptionMode  = value->mode.aesmode;
            info.MaxBufSize  = value->maxbuffersize;
            info.cpyImg  = value->mode.copy_img;
            info.TempBufferSize = value->tempBufSize * 1024 * 4;
            info.updateMultiImages = value->mode.multi_img;
            info.imagesVersion = value->img_indicator;
            info.MaxBufSize =  value->maxbuffersize;
            info.otaVersion = value->ota_version;
            
      //      info.updateMultiImages = 0;
      
            int count00 = 0;
            int count01 = 0;
            int count10 = 0;
            int count11 = 0;
      
            for (int i=0; i<16; i++) {
                int k = (info.imagesVersion >> (i*2)) & 0x3;
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
                    info.freeBank = 0xf;
                }
                else{
                    info.freeBank = 0xcc;
                    [OTADebugManager printLog:LEVEL_ERROR format:@"dev info error: %d, %d, %d", count01, count10, count11];
                }
            }
            else
            {
                if(count10 > count01) {
                    info.freeBank = 0;
                }
                else if(count10 < count01) {
                    info.freeBank = 1;
                }
                else{
                    info.freeBank = 0xcc;
                    [OTADebugManager printLog:LEVEL_ERROR format:@"dev info error: %d, %d, %d", count01, count10, count11];
                }
            }
        }
        else{
#pragma pack(push, 1)
            typedef struct _DEVICE_INFO_CHAR {
                UInt8 ICType;
                UInt8 Reserved;
                UInt8 AppBank : 4;
                UInt8 PatchBank : 4;
                UInt8 Mode;
                UInt16 MaxBufSize;
            } DEVICE_INFO_CHAR;
#pragma pack(pop)
            DEVICE_INFO_CHAR *value = (DEVICE_INFO_CHAR *) data.bytes;
            info.freeBank =  0x0;
            info.ICType = value->ICType;
            info.appFreeBank =  value->AppBank;
            info.patchFreeBank =  value->PatchBank;
            info.BufferCheck = (value->Mode & BIT0);
            info.Aes = (value->Mode & BIT1) >> 1;
            info.EncryptionMode = (value->Mode & BIT2) >> 2;
            info.MaxBufSize =  value->MaxBufSize;
        }
    }
    
    return info;
}

- (void)setTargetService:(CBService *)service
{
  //  _otaService = service;
    uint32_t versions[16] = {0};
    _model = [[OTADeviceFeatureModel alloc]init];
    
    // 默认SOC信息，在有Device Info情况下进行覆写
    OtaDeviceInfo *info = [[OtaDeviceInfo alloc]init];
    info.ICType = IC_BEE;
    info.Aes = true;
    info.BufferCheck = false;
    info.freeBank = 0xf;
    info.cpyImg = 0x0;
    info.updateMultiImages = 0;
    info.otaVersion = 0;
    _model.devInfo = info;
    
    _model.dis = [NSMutableArray array];
    int count = 0;
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:CHAR_OTA_BDADDR]) {
            if (characteristic.value && characteristic.value.length == 6) {
                uint8_t *buf = (uint8_t *) characteristic.value.bytes;
                uint64_t ullAddr = (uint64_t) buf[0] * 0x10000000000 + (uint64_t) buf[1] * 0x100000000 + (uint64_t) buf[2] * 0x1000000 + (uint64_t) buf[3] * 0x10000 + (uint64_t) buf[4] * 0x100 + (uint64_t) buf[5];
                
                [OTADebugManager printLog:LEVEL_INFO format:@"BD address = 0x%llx", ullAddr];
                _model.bdAddr = ullAddr;
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:GATT_UUID_CHAR_DEVICE_INFO]]) {
            _model.devInfo = [OTADevInfoManager parseDeviceInfo:characteristic.value];
            [OTADebugManager printLog:LEVEL_INFO format:@"devinfo: %@", _model.devInfo];
        }
        
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHAR_OTA_LINK_KEY]]){
            NSString *str = @"";
            for (int i=0; i<characteristic.value.length; i++) {
                uint8_t *buf = (uint8_t *)characteristic.value.bytes;
                NSString *str1 = [NSString stringWithFormat:@"%02x", buf[i]];
                str = [str stringByAppendingString:str1];
            }
            _model.linkKey = str;
            [OTADebugManager printLog:LEVEL_INFO format:@"linkkey: %@", _model.linkKey];
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHAR_OTA_PATCH_VERSION]]) {
            UInt16 v = 0;
            [characteristic.value getBytes:&v length:2];
            _model.patchVer = v;
            NSLog(@"PATCH VERSION = %d", v);
            
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHAR_OTA_APP_VERSION]]) {
            UInt16 v = 0;
            [characteristic.value getBytes:&v length:2];
            _model.appVer = v;
            NSLog(@"APP VERSION = %d", v);
        }
        else{
            for (int i=0; i<0x10; i++) {
                NSString *strUUID = [NSString stringWithFormat:@"%x", 0xffe0+i];
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:strUUID]]) {
                    uint32_t *buf = (uint32_t *)characteristic.value.bytes;
                    for (int j=0; j<characteristic.value.length/4; j++) {
                        versions[j+5*i] = buf[j];
                        count++;
                    }
                }
            }
            
        }
    }
    
    
    uint32_t types[16] = {0};
    int index = 0;
    for (int i=0; i<16; i++) {
        int k = (_model.devInfo.imagesVersion >> (i*2)) & 0x3;
        if (k > 0) {
            types[index] = i;
            index++;
        }
    }
    
    [OTADebugManager printLog:LEVEL_INFO format:@"char %d version, devinfo %d version", count, index];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0; i<count; i++) {
        OTADeviceImageVersion *v = [[OTADeviceImageVersion alloc]init];
        v.imageType = types[i];
        v.imageVersion = versions[i];
        v.versionString = [OTAImageTypeManager formatVersionFromInteger:versions[i] imageType:types[i] icType:_model.devInfo.ICType];
        v.typeString = [OTAImageTypeManager getStringFromType:types[i] andIC:_model.devInfo.ICType];
        [arr addObject:v];
    }
    _model.versions = arr;
    [OTADebugManager printLog:LEVEL_INFO format:@"versions: %@", arr];
}

- (OTADeviceFeatureModel *)getFeatures
{
    return _model;
}

@end
