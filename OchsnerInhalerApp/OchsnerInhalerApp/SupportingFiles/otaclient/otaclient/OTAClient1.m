//
//  OTAClient1.m
//  otaclient
//
//  Created by Tang on 2018/6/21.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "OTAClient1.h"
#import "DFUDef.h"
#import "AESFun.h"
#import "OTACommand.h"
#import "CBPeripheral+Write.h"
#import "OTADevInfoManager.h"
#import "OTAFileManager.h"
#import "OTADebugManager.h"
#import "OTAProcessGroupManager.h"
#import "OTAImageTypeManager.h"

@interface OTAClient1()<ProcessGroupDelegate>
@property (nonatomic, strong) OTAProcessGroupManager *processGroup;
@property (nonatomic, strong) CBPeripheral *targetDevice;
@property (nonatomic, strong) OTADeviceFeatureModel *featureModel;
@property (nonatomic, strong) OTAFileModel *fileModel;
@end

@implementation OTAClient1
+ (id)shareInstance {
    static OTAClient1 *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (NSString *)version
{
    return @"1.1.2";
}

- (instancetype)init {
    self = [super init];
    if (self) {
      //  _ble = [CoreBle getShareInstance];
    }
    return self;
}


- (void)selectOtaMode{
    BOOL bSilent = true;
    NSInteger modes = [self getOtaMode:_targetDevice];
    if (modes == 2) {
        if ([_delegate respondsToSelector:@selector(onSelectSilentMode)]) {
#define kGlobalThread dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(kGlobalThread, ^{
                BOOL bSilent = [self.delegate onSelectSilentMode];
                [self oTAUseSilentMode:bSilent];
            });
            return;
        }
        else
        {
            bSilent = true;
        }
    }
    else{
        bSilent = false;
    }
    
    [self oTAUseSilentMode:bSilent];
}

- (void)oTAUseSilentMode:(BOOL)bSilent
{
    NSLog(@"%s, %d", __func__, bSilent);
    _processGroup = [[OTAProcessGroupManager alloc]initWithDev:_targetDevice feature:_featureModel files:_fileModel silentOTA:bSilent];
    _processGroup.delegate = self;
    if ([_delegate respondsToSelector:@selector(onStart)]) {
        [_delegate onStart];
    }
    [_processGroup start];
}

- (void)oTATxProgress:(float)progress andImageIndex:(NSInteger)index
{
    if ([_delegate respondsToSelector:@selector(onTxProgress:andImageIndex:)]) {
        [_delegate onTxProgress:progress andImageIndex:index];
    }
}

- (void)oTAFinishedWithStatus:(OTAError)status andSpeed:(float)speed
{
    if ([_delegate respondsToSelector:@selector(onFinishedWithStatus:andSpeed:)]) {
        [_delegate onFinishedWithStatus:status andSpeed:speed];
    }
}

#pragma mark public method
-(void)oTAStart
{
    [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"isWristBand"];
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
    [self selectOtaMode];
}

- (void)oTAWristBandStart
{
    if (_featureModel.devInfo.ICType == IC_BEE) {
        [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"isWristBand"];
    }
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
    [self selectOtaMode];
}

- (void)oTASetDebugLevel:(DEBUG_LEVEL)level
{
    [OTADebugManager setDebugLevel:level];
}

- (void)oTASetTargetDevice:(CBPeripheral *)targetDevice
{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
    CoreBle *ble = [CoreBle getShareInstance];
    _targetDevice = [ble bleGetPeripheralFromUUID:targetDevice.identifier.UUIDString];
    if (targetDevice != _targetDevice) {
        [ble bleConnectDevice:_targetDevice];
    }
    
    /* 检查点：  - characteristic discovered;
                - characteristic value readed */
    if ([ble isReadyOfPeripheral:_targetDevice]) {
        [self parseInfoOfPeripheral:_targetDevice];
    } else {
        [ble waitForReadyOfPeripheral:_targetDevice completion:^(BOOL finished) {
            if (finished)
                [self parseInfoOfPeripheral:_targetDevice];
        }];
    }
}

- (void)parseInfoOfPeripheral:(CBPeripheral *)targetDevice {
    OTADevInfoManager *mgr = [[OTADevInfoManager alloc]init];
    
    for (CBService *service in targetDevice.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_OTA_INTERFACE]]) {
            [mgr setTargetService:service];
            break;
        }
    }
    
    _featureModel = [mgr getFeatures];
    
    if ([self.delegate respondsToSelector:@selector(didFinishParseDeviceInfo:)]) {
        [self.delegate didFinishParseDeviceInfo:targetDevice];
    }
    
    for (CBService *service in targetDevice.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_DEVICE_INFO]]) {
            
            for (CBCharacteristic *characteristic in service.characteristics) {
                BleDIS *di = [[BleDIS alloc]init];
                NSString *str;
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHAR_DI_PNP]]) {
                    
#pragma pack(push, 1)
                    typedef struct _PNP_INFO {
                        uint8_t vidSouce;
                        uint16_t vid;
                        uint16_t pid;
                        uint16_t pv;
                    }PNP_INFO;
#pragma pack(pop)
                    PNP_INFO *p = (PNP_INFO *)characteristic.value.bytes;
                    str = [NSString stringWithFormat:@"VS(0x%x), VID(0x%x), PID(0x%x), PV(0x%x)", p->vidSouce, p->vid, p->pid, p->pv];
                }
                else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHAR_DI_FW]]
                         || [characteristic.UUID isEqual:[CBUUID UUIDWithString:CHAR_DI_HW]]
                         || [characteristic.UUID isEqual:[CBUUID UUIDWithString:CHAR_DI_SW]]
                         || [characteristic.UUID isEqual:[CBUUID UUIDWithString:CHAR_DI_MANU]]
                         || [characteristic.UUID isEqual:[CBUUID UUIDWithString:CHAR_DI_MODEL]]
                         || [characteristic.UUID isEqual:[CBUUID UUIDWithString:CHAR_DI_IEEE]]
                         || [characteristic.UUID isEqual:[CBUUID UUIDWithString:CHAR_DI_SERIAL]]) {
                    str = [NSString stringWithUTF8String:characteristic.value.bytes];
                    
                }
                
                else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHAR_DI_SYS]]) {
#pragma pack(push, 1)
                    typedef struct _SYS_ID{
                        uint64_t ManufacturerIdentifier:40;
                        uint64_t OrganizationallyUniqueIdentifier:24;
                    }SYS_ID;
#pragma pack(pop)
                    SYS_ID *p = (SYS_ID *)characteristic.value.bytes;
                    str = [NSString stringWithFormat:@"MI(0x%llx), OUI(0x%06x)", p->ManufacturerIdentifier, p->OrganizationallyUniqueIdentifier];
                    
                }
                
                di.title = [NSString stringWithFormat:@"%@", characteristic.UUID];
                di.value = str;
                [_featureModel.dis addObject:di];
            }
        }
    }
}

- (OTADeviceFeatureModel *)getDeviceFeature{
    return _featureModel;
}

- (OTAFileModel *)oTASetTargetFile:(NSString *)fileName {
    
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
    _fileModel = [OTAFileManager loadFileWithPath:fileName devFeature:_featureModel];
    

    return _fileModel;
}


- (NSInteger)getOtaMode:(CBPeripheral *)device
{
    NSInteger _otaMode = 0;
    if (device.services) {
        for (CBService *service in device.services) {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_DFU]]) {
                _otaMode++;
            } else if ([service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_OTA_INTERFACE]]) {
                _otaMode++;
            }
        }
    }
    return _otaMode;
}
@end
