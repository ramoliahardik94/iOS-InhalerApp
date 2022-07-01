//
//  OTAProcessModel.h
//  otaclient
//
//  Created by Tang on 2018/6/22.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTADeviceFeatureModel.h"
#import "OTAFileManager.h"
#import "OTASendDataManager.h"

@interface OTAProcessModel : NSObject
@property (nonatomic, strong) CBPeripheral *device;
@property (nonatomic, strong) OTADeviceFeatureModel *feature;
@property (nonatomic, strong) OTASubFileModel *file;
@end
