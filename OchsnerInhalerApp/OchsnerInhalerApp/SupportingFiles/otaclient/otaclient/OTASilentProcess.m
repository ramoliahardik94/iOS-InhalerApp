//
//  OTASilentProcess.m
//  otaclient
//
//  Created by Tang on 2018/6/22.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "OTASilentProcess.h"

typedef NS_ENUM(uint8_t, SilentOTAStep) {
    SILENT_STEP_NONE = 0X0,
    SILENT_STEP_TXING,
    SILENT_STEP_FINISHED,
};
@interface OTASilentProcess()<SendDataDelegate>
@property (nonatomic, strong)CoreBle *ble;
//@property (nonatomic, strong)CBPeripheral *dufDevice;
@property (nonatomic) SilentOTAStep step;
@end
@implementation OTASilentProcess

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
            weakSelf.step = SILENT_STEP_FINISHED;
            if ([weakSelf.delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
                [weakSelf.delegate imageFinishedWithStatus:ERROR_STATE_POWER_OFF];
            }
        }
    }];
    
    [_ble setConnChangeBlock:^(CBPeripheral *device) {
        if (device.state == CBPeripheralStateDisconnected) {
            if (SILENT_STEP_TXING == weakSelf.step) {
                if ([weakSelf.delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
                    [weakSelf.delegate imageFinishedWithStatus:ERROR_STATE_DISCONNECTED];
                }
            }
            else{
                
            }
            
        }
   
        else{
            [weakSelf setNotificationEnable:weakSelf.model.device];
        }
        
    }];
    
    [_ble setRxBlock:^(CBCharacteristic *ch) {
        if ([ch.UUID isEqual:[CBUUID UUIDWithString:AN_DEVICE_FIRMWARE_UPDATE_CHAR]]) {
            dispatch_async(kGlobalThread, ^{
                [weakSelf processRecvData:(uint8_t *)ch.value.bytes];
            });
            
        }
    }];
    
    _step = SILENT_STEP_NONE;
    if (self.model.device.state == CBPeripheralStateConnected) {
        [self setNotificationEnable:self.model.device];
    }
    else{
        [self.ble bleConnectDevice:self.model.device];
    }
}



- (void)setNotificationEnable:(CBPeripheral *)device{

    for (CBService *service in device.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_DFU]]) {
            for (CBCharacteristic *c in service.characteristics) {
                if ([c.UUID isEqual:[CBUUID UUIDWithString:AN_DEVICE_DFU_DATA]]) {
                    
                } else if ([c.UUID isEqual:[CBUUID UUIDWithString:AN_DEVICE_FIRMWARE_UPDATE_CHAR]]) {
                    //   _dfuControlPointChar = c;
                    [device setNotifyValue:true forCharacteristic:c];
                    [self getImageInfo];
                    break;
                }
            }
            
        }
    }
}

- (void)getImageInfo
{
    self.step = SILENT_STEP_TXING;
    NSData *_reader = self.model.file.data;
    IMAGE_HEADER _imageHeader;
    [_reader getBytes:&_imageHeader length:sizeof(IMAGE_HEADER)];

    [self.otaCmd setDevice:self.model.device imageHeader:_imageHeader];

    if (IC_BEE2 == self.model.feature.devInfo.ICType)
    {
        [self.otaCmd oTAGetTargetImageInfoBee2];
    }
    else {
        [self.otaCmd oTAGetTargetImageInfo];
    }
    [OTADebugManager printLog:LEVEL_INFO format:@"silent OTA step2: oTAGetTargetImageInfo"];
}

- (void)txStartWithBufChk:(uint16_t)sendMtu andChkBufUnit:(uint16_t)chkBufUnit
{
    [super txStartWithBufChk:sendMtu andChkBufUnit:chkBufUnit];
    self.txManager.chkBufUnit = chkBufUnit;
    self.txManager.sendUnit = sendMtu;
    [self.txManager startWithModel:self.model andDevice:self.model.device];
}

- (void)txStart
{
    [super txStart];
    if ([_ble bleGetBtState] == CBCentralManagerStatePoweredOn) {
        [self.txManager startWithModel:self.model andDevice:self.model.device];
    }
    else{
        if ([self.delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
            [self.delegate imageFinishedWithStatus:ERROR_STATE_POWER_OFF];
        }
    }
    
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
    
    self.step = SILENT_STEP_FINISHED;
    [OTADebugManager printLog:LEVEL_INFO format:@"%s %d", __func__, status];
    if (status == ERROR_STATE_SUCCESS) {
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
}

- (void)txSendAUnit:(UInt64)totalSendSize andFileSize:(UInt64)fileSize
{
    if ([self.delegate respondsToSelector:@selector(imageSendSize:TotalSize:)]) {
        [self.delegate imageSendSize:totalSendSize TotalSize:fileSize];
    }
}
@end
