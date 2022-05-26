//
//  OTADevInfoManager.h
//  otaclient
//
//  Created by Tang on 2018/6/20.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "OTADeviceFeatureModel.h"
@class OtaDeviceInfo;

@interface OTADevInfoManager : NSObject
- (void)setTargetService:(CBService *)service;
- (OTADeviceFeatureModel *)getFeatures;

+ (OtaDeviceInfo *)parseDeviceInfo:(NSData *)data;
@end
