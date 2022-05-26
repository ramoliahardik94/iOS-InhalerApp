//
//  OTANoBufChkTxManager.m
//  otaclient
//
//  Created by Tang on 2018/6/22.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "OTANoBufChkTxManager.h"
#import "OTADebugManager.h"
#import "OTAFileManager.h"
#import "AESFun.h"
#import "OTACommand.h"
@interface OTANoBufChkTxManager()
@property (nonatomic, strong) CBPeripheral *device;
@property (nonatomic, strong) CBCharacteristic *dfuDataChar;
@property (nonatomic, strong) CBCharacteristic *dfuControlPointChar;
@property (nonatomic, strong) NSTimer *mTimer;
@property (nonatomic, strong) AESFun *aesFun;
@property (nonatomic, strong) OTACommand *otaCmd;
@property (nonatomic) int mTxFileSize;
@property (nonatomic) BOOL bOtaing;
@end
@implementation OTANoBufChkTxManager
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
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(txThread) object:nil];
    thread.name = @"otatxthread";
    [thread start];
}

- (void)txThread {
    _mTimer = [NSTimer scheduledTimerWithTimeInterval:0.020
                                                   target:self
                                                 selector:@selector(sendData)
                                                 userInfo:nil
                                                  repeats:YES];
   
    _bOtaing = true;
    while (_bOtaing) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    if ([_mTimer isValid]) {
        [_mTimer invalidate];
        _mTimer = nil;
    }
}

- (void)sendData {
    BOOL bIsBand = [[NSUserDefaults standardUserDefaults]boolForKey:@"isWristBand"];
    NSData *_txData = [self.model.file.data subdataWithRange:NSMakeRange(sizeof(IMAGE_HEADER), self.model.file.data.length-sizeof(IMAGE_HEADER))];
    if (bIsBand) {
        _txData = [self.model.file.data subdataWithRange:NSMakeRange(0, self.model.file.data.length)];
    }
    
    NSUInteger DataLen = _txData.length;
    const NSUInteger ATT_MTU = 20;
    NSUInteger sendUnit = ATT_MTU;
    
//    if (_otaMode == 1 || _otaMode == 3){
        if (_mTxFileSize + ATT_MTU > DataLen) {
            sendUnit = DataLen - _mTxFileSize;
        } else {
            sendUnit = ATT_MTU;
        }
//    } else if (_otaMode == 2)
//    {
//        if (_mTxFileSize + ATT_MTU > DataLen) {
//            if (_mTxFileSize % 256 == 240) {
//                if (DataLen - _mTxFileSize > 16) {
//                    sendUnit = 16;
//                } else {
//                    sendUnit = DataLen - _mTxFileSize;
//                }
//            } else {
//                sendUnit = DataLen - _mTxFileSize;
//            }
//
//        } else {
//            if (_mTxFileSize % 256 == 240) {
//                sendUnit = 16;
//            } else {
//                sendUnit = ATT_MTU;
//            }
//        }
//    }

    uint8_t buf[sendUnit];
    [_txData getBytes:buf range:NSMakeRange(_mTxFileSize, sendUnit)];
    
    if (self.model.feature.devInfo.Aes) {
        if (sendUnit >= 16) {
            [_aesFun aes_encrypt:buf andOutput:buf];
            //     [self aes_encrypt:&_ctx andInput:buf andOutput:buf];
        }
    }
    
    NSData *data2 = [[NSData alloc] initWithBytes:buf length:sendUnit];
    [_device writeValue:data2 forCharacteristic:_dfuDataChar type:CBCharacteristicWriteWithoutResponse];
    
    _mTxFileSize += sendUnit;
    //  NSLog(@"已发送 :%d bytes", _mTxFileSize);
   // _step = STEP_TRANSFERING;
    if ([self.delegate respondsToSelector:@selector(txSendAUnit:andFileSize:)]) {
        [self.delegate txSendAUnit:_mTxFileSize andFileSize:DataLen];
    }
    
    if (_mTxFileSize >= DataLen) {
        if ([_mTimer isValid]) {
            [_mTimer invalidate];
            _mTimer = nil;
        }
        // _bOtaing = false;
        _mTxFileSize = 0;
        if ([self.delegate respondsToSelector:@selector(txFinishedSuccess:)]) {
            [self.delegate txFinishedSuccess:ERROR_STATE_SUCCESS];
        }
    }
    
    if (_device.state != CBPeripheralStateConnected) {
        if ([_mTimer isValid]) {
            [_mTimer invalidate];
            _mTimer = nil;
        }
        _bOtaing = false;
        _mTxFileSize = 0;
        //    _devicePeripheral.delegate = _deviceOldDelegate;
      //  _step = STEP_FINISHED;
//        if ([self.delegate respondsToSelector:@selector(txFinishedSuccess:)]) {
//            [self.delegate txFinishedSuccess:ERROR_STATE_DISCONNECTED];
//        }
    }
}

@end
