//
//  OTASendDataManager.m
//  otaclient
//
//  Created by Tang on 2018/6/22.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "OTASendDataManager.h"

@implementation OTASendDataManager
- (void)startWithModel:(OTAProcessModel *)model andDevice:(CBPeripheral *)device
{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
}

- (void)recvBufChkResult:(BUFFER_CHK_RESULT *)p{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
}
@end
