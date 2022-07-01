//
//  OTAImageTypeManager.h
//  otaclient
//
//  Created by Tang on 2018/6/22.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "DFUDef.h"
#import "OTAConst.h"
@interface OTAImageTypeManager : NSObject

+ (NSString *)getStringFromType:(IMAGE_TYPE)type andIC:(IC_TYPE)ic;

+ (NSString *)formatVersionFromInteger:(uint32_t)ver imageType:(IMAGE_TYPE)type icType:(IC_TYPE)ic;
+ (NSString *)versionToString:(uint32_t)ver;
@end
