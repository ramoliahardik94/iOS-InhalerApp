//
//  OTADebugManager.h
//  otaclient
//
//  Created by Tang on 2018/6/21.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTAClient1.h"

@interface OTADebugManager : NSObject
+ (void)setDebugLevel:(DEBUG_LEVEL)level;
+ (void)printLog:(DEBUG_LEVEL)level format:(NSString *)format, ...;
@end
