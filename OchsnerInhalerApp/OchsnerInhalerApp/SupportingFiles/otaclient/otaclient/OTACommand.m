//
//  OTACommand.m
//  otaclient
//
//  Created by Tang on 2017/12/26.
//  Copyright © 2017年 Tang. All rights reserved.
//

#import "OTACommand.h"
#import "AESFun.h"
#import "CBPeripheral+Write.h"
@interface OTACommand()
@property (nonatomic) IMAGE_HEADER imageHeader;
@property (nonatomic, strong) CBPeripheral *devicePeripheral;
@property (nonatomic, strong) CBCharacteristic *dfuDataChar;
@property (nonatomic, strong) CBCharacteristic *dfuControlPointChar;
@end

extern BOOL g_isDebug;

#define NSLog(format, ...) if(g_isDebug) {                                             \
fprintf(stderr, "[otaclient] <%s : %d>",                                           \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__);                                                        \
(NSLog)((format), ##__VA_ARGS__);                                           \
fprintf(stderr, "\n");                                               \
}


@implementation OTACommand
+ (id)shareInstance {
    static OTACommand *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)setDevice:(CBPeripheral *)device imageHeader:(IMAGE_HEADER)imgHdr
{
    _devicePeripheral = device;
    memcpy(&_imageHeader, &imgHdr, sizeof(IMAGE_HEADER));
 //   _devicePeripheral.delegate = self;
    
    if (_devicePeripheral.services) {
        
        for (CBService *service in _devicePeripheral.services) {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_DFU]]) {
                for (CBCharacteristic *c in service.characteristics) {
                    if ([c.UUID isEqual:[CBUUID UUIDWithString:AN_DEVICE_DFU_DATA]]) {
                        _dfuDataChar = c;
                    } else if ([c.UUID isEqual:[CBUUID UUIDWithString:AN_DEVICE_FIRMWARE_UPDATE_CHAR]]) {
                        _dfuControlPointChar = c;
                    }
                }
            }
        }
    }
}


- (void)oTAGetTargetImageInfo {
    REPORT_RECEIVED_IMAGE_INFO targetImageInfo;
    targetImageInfo.Opcode = OPCODE_DFU_REPORT_RECEIVED_IMAGE_INFO;
    targetImageInfo.nSignature = _imageHeader.signature;
    NSData *data = [[NSData alloc] initWithBytes:&targetImageInfo length:sizeof(REPORT_RECEIVED_IMAGE_INFO)];
    
    [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
}

- (void)oTAGetTargetImageInfoBee2 {
    REPORT_RECEIVED_IMAGE_INFO targetImageInfo;
    targetImageInfo.Opcode = OPCODE_DFU_REPORT_RECEIVED_IMAGE_INFO;
    targetImageInfo.nSignature = _imageHeader.version;
    NSData *data = [[NSData alloc] initWithBytes:&targetImageInfo length:sizeof(REPORT_RECEIVED_IMAGE_INFO)];
    
    [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
}

- (void)oTAStartDFU:(BOOL)bAES {    
    DFU_START_DFU startDfu;
    startDfu.Opcode = OPCODE_DFU_START_DFU;
    startDfu.crc16 = _imageHeader.crc16;
    startDfu.image_length = _imageHeader.length;
    startDfu.ic_type = _imageHeader.ic_type;
    startDfu.ota_flag = _imageHeader.ota_flag;
    startDfu.signature = _imageHeader.signature;
    startDfu.version = _imageHeader.version;
    // startDfu.reserved_8 = _imageHeader.reserved_8;
//    startDfu.ReservedForAes = 0;
    if (bAES) {
        startDfu.ReservedForAes = 0;
        uint8_t *pAesData = (uint8_t *) &startDfu + 1;
        NSData *dataBeforeAES = [[NSData alloc] initWithBytes:&startDfu length:sizeof(DFU_START_DFU)];
        [[AESFun shareInstance] aes_encrypt:pAesData andOutput:(uint8_t *)pAesData];
        //  [self aes_encrypt:&_ctx andInput:pAesData andOutput:pAesData];
        NSData *data = [[NSData alloc] initWithBytes:&startDfu length:sizeof(DFU_START_DFU)];
        [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
    }else{
        startDfu.ReservedForAes = 0;
        NSData *data = [[NSData alloc] initWithBytes:&startDfu length:sizeof(DFU_START_DFU)];
        [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
    }

    
    
}

- (void)oTAPushImageToTargetWithOffset:(uint32_t)offset {
    RECEIVE_FW_IMAGE ReceiveImg;
    ReceiveImg.Opcode = OPCODE_DFU_RECEIVE_FW_IMAGE;
    ReceiveImg.nSignature = _imageHeader.signature;
    ReceiveImg.nImageUpdateOffset = offset;
    
    NSData *data = [[NSData alloc] initWithBytes:&ReceiveImg length:sizeof(RECEIVE_FW_IMAGE)];
    [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
}


- (void)oTAReceiveFwImage:(uint16_t)signature offset:(uint32_t)offset{
    RECEIVE_FW_IMAGE ReceiveImg;
    ReceiveImg.Opcode = OPCODE_DFU_RECEIVE_FW_IMAGE;
    ReceiveImg.nSignature =  signature;
    ReceiveImg.nImageUpdateOffset = offset;
    
    NSData *data = [[NSData alloc] initWithBytes:&ReceiveImg length:sizeof(RECEIVE_FW_IMAGE)];
    [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
}

- (void)oTAValidFWWithSignature:(uint16_t)signature{
    VALIDATE_FW_IMAGE validImage;
    validImage.Opcode = OPCODE_DFU_VALIDATE_FW_IMAGE;
    validImage.nSignature = signature;
    
    NSData *data = [[NSData alloc] initWithBytes:&validImage length:sizeof(VALIDATE_FW_IMAGE)];
    [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
}



- (void)oTABufChkEnable {
    
    BUF_CHK_ENABLE targetImageInfo;
    targetImageInfo.Opcode = OPCODE_DFU_BUFFER_CHK_ENABLE;
    
    NSData *data = [[NSData alloc] initWithBytes:&targetImageInfo length:sizeof(BUF_CHK_ENABLE)];
    
    [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
}

- (void)oTABufChkSize:(UInt16)size buf:(uint8_t *)buf {
    BUF_CHK_REQ targetImageInfo;
    targetImageInfo.Opcode = OPCODE_DFU_BUFFER_CHK_REQUEST;
    targetImageInfo.Size = size;
    targetImageInfo.crc = [self crc16:buf size:size];
    
    NSData *data = [[NSData alloc] initWithBytes:&targetImageInfo length:sizeof(BUF_CHK_REQ)];
    
    [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
  //  NSLog(@"chk buffer size:%d, crc:%x", size, targetImageInfo.crc);
}

- (uint16_t)crc16:(UInt8 *)buf size:(UInt16)length {
    UInt16 *p16 = (UInt16 *) buf;
    UInt16 checksum16 = 0;
    for (int i = 0; i < length / 2; ++i) {
        checksum16 = checksum16 ^ (*p16);
     //   NSLog(@"i=%d, checkSum16=%x, *p16=%x", i, checksum16, *p16);
        ++p16;
    }
    checksum16 = htons(checksum16);
    return checksum16;
}

- (void)oTAValidFWBee2 {
    VALIDATE_FW_IMAGE validImage;
    validImage.Opcode = OPCODE_DFU_VALIDATE_FW_IMAGE;
    validImage.nSignature = _imageHeader.version;
    
    NSData *data = [[NSData alloc] initWithBytes:&validImage length:sizeof(VALIDATE_FW_IMAGE)];
    [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
}

- (void)oTAPushImageToTargetWithOffsetBee2:(uint32_t)offset {
    RECEIVE_FW_IMAGE ReceiveImg;
    ReceiveImg.Opcode = OPCODE_DFU_RECEIVE_FW_IMAGE;
    ReceiveImg.nSignature = _imageHeader.version;
    ReceiveImg.nImageUpdateOffset = offset;
    
    NSData *data = [[NSData alloc] initWithBytes:&ReceiveImg length:sizeof(RECEIVE_FW_IMAGE)];
    [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
}

- (NSData *)oTAGenCopyCmdBee2:(uint16_t)signature size:(uint32_t)size addr:(uint32_t)addr
{
    DFU_COPY_DATA dcd;
    dcd.Opcode = OPCODE_DFU_OPCODE_COPY_IMG;
    dcd.Address = addr;
    dcd.Size = size;
    dcd.Signature = signature;
    return [NSData dataWithBytes:&dcd length:sizeof(DFU_COPY_DATA)];
}

- (void)oTAValidFW {
    VALIDATE_FW_IMAGE validImage;
    validImage.Opcode = OPCODE_DFU_VALIDATE_FW_IMAGE;
    validImage.nSignature = _imageHeader.signature;
    
    NSData *data = [[NSData alloc] initWithBytes:&validImage length:sizeof(VALIDATE_FW_IMAGE)];
    [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
}

- (void)oTAActiveAndReset:(uint8_t)type{
    if (type == 0) {
        uint8_t opcode = OPCODE_DFU_ACTIVE_IMAGE_RESET;
        NSData *data = [[NSData alloc] initWithBytes:&opcode length:sizeof(uint8_t)];
        
        [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
    }
    else
    {
        ACTIVE_IMAGE_RESET activeReset;
        activeReset.Opcode = OPCODE_DFU_ACTIVE_IMAGE_RESET;
        activeReset.type = type;
        NSData *data = [[NSData alloc] initWithBytes:&activeReset length:sizeof(ACTIVE_IMAGE_RESET)];
        
        [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
    }
}

- (void)oTAImmediatelyReset {

    RESET_SYSTEM activeReset;
    activeReset.Opcode = OPCODE_DFU_RESET_SYSTEM;

    NSData *data = [[NSData alloc] initWithBytes:&activeReset length:sizeof(RESET_SYSTEM)];

    [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
}

- (void)oTASendRawData:(NSData *)data
{
    [self.devicePeripheral writeValue:data forCharacteristic:_dfuControlPointChar type:CBCharacteristicWriteWithResponse];
}
@end
