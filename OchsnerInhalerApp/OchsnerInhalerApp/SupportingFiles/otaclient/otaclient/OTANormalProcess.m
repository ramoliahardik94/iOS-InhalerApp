//
//  OTANormalProcess.m
//  otaclient
//
//  Created by Tang on 2018/6/22.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "OTANormalProcess.h"
#import "DFUDef.h"
#import "CoreBle.h"
#import "OTADebugManager.h"
#import "AESFun.h"
#import "OTACommand.h"

typedef NS_ENUM(uint8_t, NormalOTAStep) {
    NORMAL_STEP_NONE = 0X0,
    NORMAL_STEP_ENTER,
    NORMAL_STEP_RECONNECTING,
    NORMAL_STEP_RECONNECTED,
    NORMAL_STEP_TXING,
    NORMAL_STEP_FINISHED,
};
@interface OTANormalProcess()<SendDataDelegate>
@property (nonatomic, strong)CoreBle *ble;
@property (nonatomic, strong)CBPeripheral *dufDevice;
@property (nonatomic) NormalOTAStep step;
@end
@implementation OTANormalProcess
- (void)startWithModel:(OTAProcessModel *)model needReset:(BOOL)bReset
{
    [super startWithModel:model needReset:bReset];
    self.model = model;
    if (model.feature.devInfo.BufferCheck) {
        self.txManager = [[OTABufChkTxManager alloc]init];
    }
    else{
        self.txManager = [[OTANoBufChkTxManager alloc]init];
    }
    self.txManager.delegate = self;
    _ble = [CoreBle getShareInstance];
    __weak typeof(self)weakSelf = self;
    [_ble setLocalStateChangeBlock:^(BOOL bOn) {
        if (!bOn) {
            weakSelf.step = NORMAL_STEP_FINISHED;
            if ([weakSelf.delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
                [weakSelf.delegate imageFinishedWithStatus:ERROR_STATE_POWER_OFF];
            }
        }
    }];
    
    [_ble setConnChangeBlock:^(CBPeripheral *device) {
        if (device.state == CBPeripheralStateDisconnected) {
            if (weakSelf.step == NORMAL_STEP_ENTER ) {
                
                [weakSelf.ble bleSearchDevice:@[[CBUUID UUIDWithString:SERVICE_DFU]] block:^(CBPeripheral *device, NSDictionary *dic, NSNumber *rssi) {
                    NSData *data = dic[@"kCBAdvDataManufacturerData"];
                    if (data.length >= 8) {
                        UInt64 addr = [OTANormalProcess getBdAddrFromAdvData:data];
                        if (weakSelf.model.feature.bdAddr == addr) {
                            weakSelf.step = NORMAL_STEP_RECONNECTING;
                            if (device.state == CBPeripheralStateDisconnected) {
                                [weakSelf.ble bleConnectDevice:device];
                            }
                            
                            dispatch_async(kMainThread, ^{
                            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(scanTimeout) object:nil];
                            });
                        }
                    }
                }];
                
                // 15 seconds timer for scaning device under ota mode
                dispatch_async(kMainThread, ^{
                    [weakSelf performSelector:@selector(scanTimeout) withObject:nil afterDelay: 15];
                });
                
            }
            else if(weakSelf.step == NORMAL_STEP_TXING || weakSelf.step == NORMAL_STEP_RECONNECTED){
                if ([weakSelf.delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
                    [weakSelf.delegate imageFinishedWithStatus:ERROR_STATE_DISCONNECTED];
                }
            }
            
        }
        else if (device.state == CBPeripheralStateConnected)
        {
            if (weakSelf.step == NORMAL_STEP_NONE) {
                [weakSelf makeDeviceToOtaMode:model.device];
            }
            else if (weakSelf.step == NORMAL_STEP_RECONNECTING){
                weakSelf.step = NORMAL_STEP_RECONNECTED;
                weakSelf.dufDevice = device;
                
                [weakSelf setNotificationEnable];
            }
        }
        
    }];
    [_ble setRxBlock:^(CBCharacteristic *ch) {
        if ([ch.UUID isEqual:[CBUUID UUIDWithString:AN_DEVICE_FIRMWARE_UPDATE_CHAR]]) {
            dispatch_async(kGlobalThread, ^{
                [weakSelf processRecvData:(uint8_t *)ch.value.bytes];
            });
            
        }
    }];
    
    _step = NORMAL_STEP_NONE;
    
    if ([_ble bleGetBtState] == CBCentralManagerStatePoweredOn) {
        
        if (model.device.state == CBPeripheralStateConnected) {
            [self makeDeviceToOtaMode:model.device];
        }
        else{
            if (!bReset) {
                if (_dufDevice)
                {
                    if (_dufDevice.state == CBPeripheralStateConnected) {
                        [self getImageInfo];
                    }
                    else{
                        _step = NORMAL_STEP_RECONNECTING;
                     //   [_ble bleConnectDevice:_dufDevice];
                        [weakSelf.ble bleSearchDevice:@[[CBUUID UUIDWithString:SERVICE_DFU]] block:^(CBPeripheral *device, NSDictionary *dic, NSNumber *rssi) {
                            NSData *data = dic[@"kCBAdvDataManufacturerData"];
                            if (data.length >= 8) {
                                UInt64 addr = [OTANormalProcess getBdAddrFromAdvData:data];
                                if (weakSelf.model.feature.bdAddr == addr) {
                                    weakSelf.step = NORMAL_STEP_RECONNECTING;
                                    if (device.state == CBPeripheralStateDisconnected) {
                                        [weakSelf.ble bleConnectDevice:device];
                                    }
                                    
                                    dispatch_async(kMainThread, ^{
                                        [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(scanTimeout) object:nil];
                                    });
                                }
                            }
                        }];
                        
                    }
                }
                
            }
            else{
                [_ble bleConnectDevice:model.device];
            }
        }
    }
    else{
        if ([self.delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
            [self.delegate imageFinishedWithStatus:ERROR_STATE_POWER_OFF];
        }
    }
}

- (void)scanTimeout{
    [OTADebugManager printLog:LEVEL_WARN format:@"[BLE]: scan timeout"];
    [self.ble bleStopSearchDevice];
    if ([self.delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
        [self.delegate imageFinishedWithStatus:ERROR_STATE_DEVICE_RECONNECTION_FAIL];
    }
}


+ (UInt64) getBdAddrFromAdvData:(NSData *)data
{
    UInt64 value = 0;
    //   data.getBytes(&value, range: NSRange(location: 2, length: 6))
    for(int i=2; i<8; i++)
    {
        UInt8 k = 0;
        [data getBytes:&k range:NSMakeRange(i, 1) ];
        value = (value << 8) + k;
    }
    return value;
}

- (BOOL)makeDeviceToOtaMode:(CBPeripheral *)device{
    CBCharacteristic *charEnterOta = nil;
    for (CBService *service in device.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_OTA_INTERFACE]]) {
            for (CBCharacteristic *c in service.characteristics) {
                if ([c.UUID isEqual:[CBUUID UUIDWithString:CHAR_OTA_ENTER]]) {
                    charEnterOta = c;
                }
            }
        }
    }
    if (charEnterOta && device) {
        UInt8 level = 1;
        NSData *data = [[NSData alloc] initWithBytes:&level length:sizeof(level)];
        [device writeValue:data forCharacteristic:charEnterOta type:CBCharacteristicWriteWithoutResponse];
        [OTADebugManager printLog:LEVEL_INFO format:@"make device to ota mode"];
        _step = NORMAL_STEP_ENTER;
        return true;
    }
    return false;
}


- (void)setNotificationEnable{
    BOOL bFound = false;
    __weak typeof(self)weakSelf = self;
    for (CBService *service in weakSelf.dufDevice.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_DFU]]) {
            for (CBCharacteristic *c in service.characteristics) {
                if ([c.UUID isEqual:[CBUUID UUIDWithString:AN_DEVICE_DFU_DATA]]) {
                    
                } else if ([c.UUID isEqual:[CBUUID UUIDWithString:AN_DEVICE_FIRMWARE_UPDATE_CHAR]]) {
                 //   _dfuControlPointChar = c;
                    bFound = true;
                    [weakSelf.dufDevice setNotifyValue:true forCharacteristic:c];
                    [weakSelf getImageInfo];
                    break;
                }
            }
         
        }
    }
    
    if (!bFound) {
        if ([self.delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
            [self.delegate imageFinishedWithStatus:ERROR_STATE_NO_DEVICE];
        }
    }
}

- (void)getImageInfo
{
    self.step = NORMAL_STEP_TXING;
    NSData *_reader = self.model.file.data;
    IMAGE_HEADER _imageHeader;
    [_reader getBytes:&_imageHeader length:sizeof(IMAGE_HEADER)];
    //    if (_ICType == IC_BEE)
    //    {
    //        _imageHeader.length =  (_imageHeader.length & 0XFFFF);
    //    }
    //
    [self.otaCmd setDevice:_dufDevice imageHeader:_imageHeader];
    
    
 //   NSLog(@"Image Info:  \n\tsignature(0x%x), \n\tversion(0x%x), \n\tchecksum(0x%x)", imageHeader.signature, _imageHeader.version, _imageHeader.crc16);
    
    // [_oTADelegate onGetFileVersion:_imageHeader.version andSize:_imageHeader.length*4];
    if (IC_BEE2 == self.model.feature.devInfo.ICType)
    {
        [self.otaCmd oTAGetTargetImageInfoBee2];
    }
    else {
        [self.otaCmd oTAGetTargetImageInfo];
    }
    [OTADebugManager printLog:LEVEL_INFO format:@"normal OTA step2: oTAGetTargetImageInfo"];
  
}

- (void)txStart
{
    [super txStart];
    if ([_ble bleGetBtState] == CBCentralManagerStatePoweredOn) {
        [self.txManager startWithModel:self.model andDevice:_dufDevice];
    }
    else{
        if ([self.delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
            [self.delegate imageFinishedWithStatus:ERROR_STATE_POWER_OFF];
        }
    }
    
}

- (void)txStartWithBufChk:(uint16_t)sendMtu andChkBufUnit:(uint16_t)chkBufUnit
{
    [super txStartWithBufChk:sendMtu andChkBufUnit:chkBufUnit];
    self.txManager.chkBufUnit = chkBufUnit;
    self.txManager.sendUnit = sendMtu;
    [self.txManager startWithModel:self.model andDevice:_dufDevice];
}

- (void)recvBufChkResult:(BUFFER_CHK_RESULT *)p
{
    [super recvBufChkResult:p];
    [self.txManager recvBufChkResult:p];
}

- (void)clear
{
    [super clear];
    [_ble setRxBlock:nil];
    [_ble setConnChangeBlock:nil];
    [_ble setLocalStateChangeBlock:nil];
}

- (void)txFinishedSuccess:(OTAError)status
{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s %d", __func__, status];
    if (status == ERROR_STATE_SUCCESS) {
//        if (IC_BEE2 == self.model.feature.devInfo.ICType) {
//            [self.otaCmd oTAValidFWBee2];
//        }
//        else
//        {
//            [self.otaCmd oTAValidFW];
//        }
        
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
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
            [self.delegate imageFinishedWithStatus:status];
        }
    }
}

- (void)txSendAUnit:(UInt64)totalSendSize andFileSize:(UInt64)fileSize
{
    if ([self.delegate respondsToSelector:@selector(imageSendSize:TotalSize:)]) {
        [self.delegate imageSendSize:totalSendSize TotalSize:fileSize];
    }
}


@end
