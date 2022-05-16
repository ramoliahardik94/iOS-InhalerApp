//
//  OTADebugManager.m
//  otaclient
//
//  Created by Tang on 2018/6/21.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "OTADebugManager.h"
DEBUG_LEVEL g_level = LEVEL_DEBUG;

@implementation OTADebugManager
+ (void)setDebugLevel:(DEBUG_LEVEL)level
{
    g_level = level;
}

+ (DEBUG_LEVEL)getDebugLevel
{
    return g_level;
}

+ (NSString *)levelToString:(DEBUG_LEVEL)level
{
    return @[@"DEBUG", @"INFO", @"WARN", @"ERROR", @"FATAL"][level];
}

+ (void)printLog:(DEBUG_LEVEL)level format:(NSString *)format, ...
{
    if (level >= g_level) {
        va_list arglist;
        va_start(arglist,format);
        
//         id eachObject;
//        while ((eachObject = va_arg(arglist, id))) // As many times as we can get an argument of type {
//        {
//            NSLog(@"%@", eachObject);
//        }
        NSString *str = [[NSString alloc]
                         initWithFormat:format arguments:arglist];
        va_end(arglist);
        NSLog(@"[OTA %@]: %@", [OTADebugManager levelToString:level], str);
    }
    
}

@end
