//
//  OTAFileManager.h
//  otaclient
//
//  Created by Tang on 2018/6/20.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTADeviceFeatureModel.h"
#import "OTAFileModel.h"

@interface OTAFileManager : NSObject
+ (OTAFileModel *)loadFileWithPath:(NSString *)path devFeature:(OTADeviceFeatureModel *)devFeature;
@end
