//
//  OtaProcessManager.m
//  otaclient
//
//  Created by Tang on 2018/6/20.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "OTAProcessGroupManager.h"
#import "OTAProcess.h"
#import "OTANormalProcess.h"
#import "OTASilentProcess.h"

@interface OTAProcessGroupManager()<ProcessDelegate>

@property (nonatomic, strong)CBPeripheral *device;
@property (nonatomic, strong)OTAProcess *process;
@property (nonatomic, strong)OTAFileModel *fileModel;
@property (nonatomic, strong)OTADeviceFeatureModel *featureModel;
@property (nonatomic, strong)NSDate *startTime;
@property (nonatomic)BOOL bSilent;
@property (nonatomic)NSInteger index;
@property (nonatomic)uint64_t totalSize;
@property (nonatomic)uint64_t sentSize;

@end

@implementation OTAProcessGroupManager
- (instancetype)initWithDev:(CBPeripheral *)device feature:(OTADeviceFeatureModel *)feature files:(OTAFileModel *)files silentOTA:(BOOL)silent;
{
    if (self = [super init]) {
        NSLog(@"%s, %d", __func__, silent);
        _bSilent = silent;
        if (silent) {
            _process = [[OTASilentProcess alloc]init];
            
        }
        else{
            _process = [[OTANormalProcess alloc]init];
        }
        _process.delegate = self;
        _featureModel = feature;
        _fileModel = files;
        _device = device;
        _totalSize = 0;
        _sentSize = 0;
        for (OTASubFileModel *m in _fileModel.filesArray) {
            _totalSize += m.data.length;
        }
    }
    return self;
}

- (void)start
{
    _index = 0;
    if (_fileModel.filesArray.count == 0) {
        if([_delegate respondsToSelector:@selector(oTAFinishedWithStatus:andSpeed:)])
        {
            [_delegate oTAFinishedWithStatus:ERROR_STATE_FILE_BANK andSpeed:0];
        }
    }
    else{
        _startTime = [NSDate date];
        [self startToSendNextImage:false];
    }
}


- (void)startToSendNextImage:(BOOL)bReset{
    OTAProcessModel *model = [[OTAProcessModel alloc]init];
    model.device = _device;
    model.feature = _featureModel;
   
    model.file = _fileModel.filesArray[_index];
    [OTADebugManager printLog:LEVEL_INFO format:@"tx image size: %d", model.file.header.dataLength];
    [_process startWithModel:model needReset:bReset];
}


- (NSInteger)imageFinishedWithStatus:(OTAError)status;
{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
    if (status == ERROR_STATE_SUCCESS) {
        {
            OTASubFileModel *m =_fileModel.filesArray[_index];
            _sentSize += m.data.length;
            [OTADebugManager printLog:LEVEL_INFO format:@"have sent size: %d", _sentSize];
        }
        
        _index++;
        
        if( _fileModel.filesArray.count > _index)
        {
            BOOL bReset = false;
            if (_featureModel.devInfo.updateMultiImages == 1) {
                if (_featureModel.devInfo.TempBufferSize > 0) {
                    OTASubFileModel *m =_fileModel.filesArray[_index];
                    [OTADebugManager printLog:LEVEL_INFO format:@"will sent size: %d", m.data.length];
                    
                    if (_sentSize + m.data.length > _featureModel.devInfo.TempBufferSize) {
                        [_process clear];
                        __weak typeof(self) weakSelf = self;
                        [[CoreBle getShareInstance]setConnChangeBlock:^(CBPeripheral *device) {
                            if (device.state == CBPeripheralStateDisconnected) {
                                [OTADebugManager printLog:LEVEL_INFO format:@"disconnected, continue to sent size: %d", m.data.length];
                                [weakSelf startToSendNextImage:false];
                            }
                        }];
                        _sentSize = 0;
                        return 2;
                    }
                }
            }
            else{
                bReset = true;
            }
            
       //     bReset = bReset ? bReset : !_bSilent;
            
            if (!bReset)
            {
                [self startToSendNextImage:bReset];
            }
            else{
                [_process clear];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), kGlobalThread, ^{
                     [self startToSendNextImage:bReset];
                });
              
                return 1;
            }
        }
        else{
            NSTimeInterval time = [[NSDate date]timeIntervalSinceDate:_startTime];
            float speed = _totalSize / 1024.0 / time;
            //  [OTADebugManager printLog:LEVEL_DEBUG format:@"%d/%f", _totalSize, time];
            if([_delegate respondsToSelector:@selector(oTAFinishedWithStatus:andSpeed:)])
            {
                [_delegate oTAFinishedWithStatus:ERROR_STATE_SUCCESS andSpeed:speed];
            }
            [_process clear];
            return 1;
        }
        
    }
    else{
        [_process clear];
        if([_delegate respondsToSelector:@selector(oTAFinishedWithStatus:andSpeed:)])
        {
            [_delegate oTAFinishedWithStatus:status andSpeed:0];
        }
    }
    
    return 0;
}

- (void)imageSendSize:(uint64_t)size TotalSize:(uint64_t)totalSize
{
    float p = (float) size / (float) totalSize;
    static int progress = 0;
    
    if (p*100 - progress >= 1) {
        progress = floor(p*100);
        if ([_delegate respondsToSelector:@selector(oTATxProgress:andImageIndex:)]) {
            [_delegate oTATxProgress:progress andImageIndex:_index];
        }
        if (progress == 100) {
            progress = 0;
        }
    }
}

@end
