//
//  OtaProcessManager.h
//  otaclient
//
//  Created by Tang on 2018/6/20.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTADeviceFeatureModel.h"
#import "OTAFileManager.h"
#import "OTAClient1.h"

@protocol ProcessGroupDelegate<NSObject>
@optional
- (void)oTATxProgress:(float)progress andImageIndex:(NSInteger)index;
- (void)oTAFinishedWithStatus:(OTAError)status andSpeed:(float)speed;
@end

@interface OTAProcessGroupManager : NSObject
@property (nonatomic, weak)id<ProcessGroupDelegate> delegate;
- (instancetype)initWithDev:(CBPeripheral *)device feature:(OTADeviceFeatureModel *)feature files:(OTAFileModel *)files silentOTA:(BOOL)silent;
- (void) start;
//- (void) processRecvData:(NSData *)data;
@end
