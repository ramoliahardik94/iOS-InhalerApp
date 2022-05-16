//
//  OTABufChkTxManager.m
//  otaclient
//
//  Created by Tang on 2018/6/22.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "OTABufChkTxManager.h"
#import "AESFun.h"
#import "OTACommand.h"

@interface OTABufChkTxManager()
@property (nonatomic, strong) CBPeripheral *device;
@property (nonatomic, strong) CBCharacteristic *dfuDataChar;
@property (nonatomic, strong) CBCharacteristic *dfuControlPointChar;
@property (nonatomic, strong) NSTimer *mTimer;
@property (nonatomic, strong) AESFun *aesFun;
@property (nonatomic, strong) OTACommand *otaCmd;
@property (nonatomic) int mTxFileSize;
@property (nonatomic) BOOL bOtaing;
@property (nonatomic, strong) NSData *reader;
@end
@implementation OTABufChkTxManager
- (void)startWithModel:(OTAProcessModel *)model andDevice:(CBPeripheral *)device
{
    [super startWithModel:model andDevice:device];
    self.model = model;
    [OTADebugManager printLog:LEVEL_DEBUG format:@"%s", __func__];
    
    _bOtaing = false;
    _mTxFileSize = 0;
    _aesFun = [AESFun shareInstance];
    _otaCmd = [OTACommand shareInstance];
    _device = device;
    
    if (_device.services) {
        
        for (CBService *service in _device.services) {
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
    _reader = model.file.data;
    [self txStartWithRetry:false];
}

- (void)txStartWithRetry:(BOOL)bRetry
{
    if (_mTxFileSize == 0) {
        if (!bRetry) {
//            if (self.model.feature.devInfo.ICType == IC_BEE2) {
//                [_otaCmd oTAPushImageToTargetWithOffsetBee2:12];
//            }
//            else{
//                [_otaCmd oTAPushImageToTargetWithOffset:12];
//            }
//
            uint32_t offset = 12;
            if (self.model.feature.devInfo.otaVersion == 1) {
                [_otaCmd oTAReceiveFwImage:self.model.file.header.imageId offset:offset];
            }
            else{
                if (IC_BEE2 == self.model.feature.devInfo.ICType) {
                    [_otaCmd oTAPushImageToTargetWithOffsetBee2:offset];
                }else{
                    [_otaCmd oTAPushImageToTargetWithOffset:offset];
                }
            }
            
            //     [NSThread sleepForTimeInterval:0.020f];
            
            if (_reader.length - _mTxFileSize < self.chkBufUnit) {
               self.chkBufUnit = _reader.length - _mTxFileSize;
            }
            
            uint8_t *buf = malloc(self.chkBufUnit - 12);
            [_reader getBytes:buf range:NSMakeRange(12, self.chkBufUnit - 12)];
            if (self.model.feature.devInfo.Aes) {
                for (int i = 0; i < (self.chkBufUnit - 12) / 16; i++) {
                    [_aesFun aes_encrypt:buf + i * 16 andOutput:buf + i * 16];
                }
            }
            
            for (int i = 0; i < (self.chkBufUnit - 12) / self.sendUnit; i++) {
                NSData *data2 = [[NSData alloc] initWithBytes:buf + i * self.sendUnit length:self.sendUnit];
                [_device writeValue:data2 forCharacteristic:_dfuDataChar type:CBCharacteristicWriteWithoutResponse];
                // NSLog(@"tx: %@", data2);
            }
            
            NSInteger restByte = (self.chkBufUnit - 12) - self.sendUnit * ((self.chkBufUnit - 12) / self.sendUnit);
            if (restByte > 0) {
                NSData *data2 = [[NSData alloc] initWithBytes:buf + ((self.chkBufUnit - 12) / self.sendUnit) * self.sendUnit length:restByte];
                
                [_device writeValue:data2 forCharacteristic:_dfuDataChar type:CBCharacteristicWriteWithoutResponse];
                //    NSLog(@"tx: %@", data2);
            }
            
            //   [NSThread sleepForTimeInterval:10.000f];
            [_otaCmd oTABufChkSize:self.chkBufUnit-12 buf:buf];
            //   [self oTABufChkSize:_sendUnit - 12 crc:[self crc16:buf size:_sendUnit - 12]];
            free(buf);
            
        } else {
            uint8_t *buf = malloc(self.chkBufUnit);
            [_reader getBytes:buf range:NSMakeRange(0, self.chkBufUnit)];
            if (self.model.feature.devInfo.Aes) {
                for (int i = 0; i < (self.chkBufUnit) / 16; i++) {
                    [_aesFun aes_encrypt:buf + i * 16 andOutput:buf + i * 16];
                }
            }
            
            for (int i = 0; i < self.chkBufUnit / self.sendUnit; i++) {
                NSData *data2 = [[NSData alloc] initWithBytes:buf + i * self.sendUnit length:self.sendUnit];
                [_device writeValue:data2 forCharacteristic:_dfuDataChar type:CBCharacteristicWriteWithoutResponse];
            }
            
            [_otaCmd oTABufChkSize:self.chkBufUnit buf:buf];
            //   [self oTABufChkSize:_sendUnit crc:[self crc16:buf size:_sendUnit]];
            free(buf);
        }
        
    } else if (_mTxFileSize == 12) {
        
        uint8_t *buf = malloc(self.chkBufUnit - 12);
        [_reader getBytes:buf range:NSMakeRange(12, self.chkBufUnit - 12)];
        if (self.model.feature.devInfo.Aes) {
            for (int i = 0; i < (self.chkBufUnit - 12) / 16; i++) {
                [_aesFun aes_encrypt:buf + i * 16 andOutput:buf + i * 16];
            }
            //   NSData *data2 = [[NSData alloc]initWithBytes:buf+i*16 length:16];
            //  [self.devicePeripheral writeValue:data2 forCharacteristic:_dfuDataChar type:CBCharacteristicWriteWithoutResponse];
            //  NSLog(@"tx: %@", data2);
        }
        
        for (int i = 0; i < (self.chkBufUnit - 12) / self.sendUnit; i++) {
            NSData *data2 = [[NSData alloc] initWithBytes:buf + i * self.sendUnit length:self.sendUnit];
            [_device writeValue:data2 forCharacteristic:_dfuDataChar type:CBCharacteristicWriteWithoutResponse];
            // NSLog(@"tx: %@", data2);
        }
        
        NSInteger restByte = (self.chkBufUnit - 12) - self.sendUnit * ((self.chkBufUnit - 12) / self.sendUnit);
        if (restByte > 0) {
            NSData *data2 = [[NSData alloc] initWithBytes:buf + ((self.chkBufUnit - 12) / self.sendUnit) * self.sendUnit length:restByte];
            
            [_device writeValue:data2 forCharacteristic:_dfuDataChar type:CBCharacteristicWriteWithoutResponse];
            //  NSLog(@"tx: %@", data2);
        }
        
        //  [NSThread sleepForTimeInterval:10.00f];
        
        [_otaCmd oTABufChkSize:self.chkBufUnit-12 buf:buf];
        //    [self oTABufChkSize:_sendUnit - 12 crc:[self crc16:buf size:_sendUnit - 12]];
        free(buf);
        
        _mTxFileSize = 0;
    } else {
        
        if (_reader.length - _mTxFileSize < self.chkBufUnit) {
            self.chkBufUnit = _reader.length - _mTxFileSize;
        }
        uint8_t *buf = malloc(self.chkBufUnit);
        [_reader getBytes:buf range:NSMakeRange(_mTxFileSize, self.chkBufUnit)];
        if (self.model.feature.devInfo.Aes) {
            for (int i = 0; i < self.chkBufUnit / 16; i++) {
                [_aesFun aes_encrypt:buf + i * 16 andOutput:buf + i * 16];
            }
        }
        
        for (int i = 0; i < self.chkBufUnit / self.sendUnit; i++) {
            NSData *data2 = [[NSData alloc] initWithBytes:buf + i * self.sendUnit length:self.sendUnit];
            [_device writeValue:data2 forCharacteristic:_dfuDataChar type:CBCharacteristicWriteWithoutResponse];
        }
        
        NSInteger restByte = self.chkBufUnit - self.sendUnit * (self.chkBufUnit / self.sendUnit);
        if (restByte > 0) {
            
            NSData *data2 = [[NSData alloc] initWithBytes:buf + (self.chkBufUnit / self.sendUnit) * self.sendUnit length:restByte];
            [_device writeValue:data2 forCharacteristic:_dfuDataChar type:CBCharacteristicWriteWithoutResponse];
            //  NSLog(@"tx: %@", data2);
        }
        //  [NSThread sleepForTimeInterval:10.100f];
        [_otaCmd oTABufChkSize:self.chkBufUnit buf:buf];
        //  [self oTABufChkSize:_sendUnit crc:[self crc16:buf size:_sendUnit]];
        free(buf);
    }
}



- (void)recvBufChkResult:(BUFFER_CHK_RESULT *)p
{
    [super recvBufChkResult:p];
    if (p->Result == ERROR_STATE_SUCCESS) { //success
        _mTxFileSize += self.chkBufUnit;
        int DataLen = (int) [_reader length];
        if ([self.delegate respondsToSelector:@selector(txSendAUnit:andFileSize:)]) {
            [self.delegate txSendAUnit:_mTxFileSize andFileSize:DataLen];
        }

        if (_mTxFileSize >= DataLen) {
            _mTxFileSize = 0;
            [OTADebugManager printLog:LEVEL_DEBUG format:@"OTA step5: oTAValidFW"];
            //   [_otaCmd oTAValidFW];
//            if (self.model.feature.devInfo.ICType==IC_BEE2) {
//                [_otaCmd oTAValidFWBee2];
//            }
//            else
//            {
//                [_otaCmd oTAValidFW];
//            }
            
            if (self.model.feature.devInfo.otaVersion==1) {
                [self.otaCmd oTAValidFWWithSignature:self.model.file.header.imageId];
            }
            else{
                if (IC_BEE2 == self.model.feature.devInfo.ICType) {
                    [self.otaCmd oTAValidFWBee2];
                }
                else
                {
                    [self.otaCmd oTAValidFW];
                }
            }
        } else {
            [self txStartWithRetry:false];
        }

        if (_device.state != CBPeripheralStateConnected) {
            //            _bOtaing = false;
            //            _mTxFileSize = 0;
            //            //  _devicePeripheral.delegate = _deviceOldDelegate;
//                _step = STEP_FINISHED;
//                [self oTAClearStatus];
            if ([self.delegate respondsToSelector:@selector(txFinishedSuccess:)]) {
                [self.delegate txFinishedSuccess:ERROR_STATE_DISCONNECTED];
            }
        }
    } else if (p->Result == ERROR_STATE_CRC_ERROR || p->Result == ERROR_STATE_BUFCHK_LENGTH_ERROR || p->Result == ERROR_STATE_FLASH_WRITE_ERROR) { //resend
        _mTxFileSize = p->ReTxAddress;
        [self txStartWithRetry:true];
    } else if (p->Result == ERROR_STATE_FLASH_ERASE_ERROR) { //stop
        //        _bOtaing = false;
        //        _mTxFileSize = 0;
        //        //  _devicePeripheral.delegate = _deviceOldDelegate;
//            _step = STEP_FINISHED;
//            [self oTAClearStatus];
        if ([self.delegate respondsToSelector:@selector(txFinishedSuccess:)]) {
            [self.delegate txFinishedSuccess:ERROR_STATE_OPRERATION_FAILED];
        }

        [_otaCmd oTAImmediatelyReset];
    }
}
@end
