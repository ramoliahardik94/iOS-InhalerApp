//
//  OTAClient1.h
//  otaclient
//
//  Created by Tang on 2018/6/21.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreBle.h"
#import "OTADeviceFeatureModel.h"
#import "OTAFileModel.h"
#import "OTAConst.h"

/**
 @brief notify upper level with OTA status
 */
@protocol OTA1Delegate<NSObject>

/**
 @return BOOL value, if true, use silent OTA mode, otherwise use normal OTA mode
 */
- (BOOL)onSelectSilentMode;


/**
 * 完成device的信息解析时调用，此后可以启动OTA升级
 */
- (void)didFinishParseDeviceInfo:(CBPeripheral *)device;

/**
 @brief OTA has started
 */
- (void)onStart;

/**
 @brief OTA finished
 @param status Success or fail
 @param speed Tx speed, if OTA fail, it is uesless.
 */
- (void)onFinishedWithStatus:(OTAError)status andSpeed:(float)speed;

/**
 @brief OTA Txing
 @param progress progress, (0-100)
 @param index the image index which is being transfered
 */
- (void)onTxProgress:(float)progress andImageIndex:(NSInteger)index;
@end

@interface OTAClient1 : NSObject
@property (nonatomic, weak)id<OTA1Delegate> delegate;
/**
 @brief get an OTAClient1 single instance
 */
+ (id)shareInstance;

/**
 @brief get OTA library version
 @return OTA library version
 */
+ (NSString *)version;

/**
 @brief set OTA library debug level
 @param level debug level:
 */
- (void)oTASetDebugLevel:(DEBUG_LEVEL)level;

/**
 @brief set OTA target device
 @param targetDevice device
 */
- (void)oTASetTargetDevice:(CBPeripheral *)targetDevice;

/**
 @brief get deivce feature
 @return device feature
 */
- (OTADeviceFeatureModel *)getDeviceFeature;

/**
 @brief set target file
 @param fileName file name
 @return file information
 */
- (OTAFileModel *)oTASetTargetFile:(NSString *)fileName;

/**
 @brief OTA Start
 */
- (void)oTAStart;

/**
 @brief OTA Start
 */
- (void)oTAWristBandStart;
@end
