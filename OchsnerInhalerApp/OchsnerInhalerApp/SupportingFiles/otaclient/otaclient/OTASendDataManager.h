//
//  OTASendDataManager.h
//  otaclient
//
//  Created by Tang on 2018/6/22.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTAProcessModel.h"
#import "DFUDef.h"
@class OTAProcessModel;

@protocol SendDataDelegate<NSObject>
@optional
- (void)txFinishedSuccess:(OTAError)bSuccess;
- (void)txSendAUnit:(UInt64)totalSendSize andFileSize:(UInt64)fileSize;
@end

@interface OTASendDataManager : NSObject
@property (nonatomic, weak) id<SendDataDelegate>delegate;
@property (nonatomic, strong) OTAProcessModel *model;
@property (nonatomic) uint16_t sendUnit;
@property (nonatomic) uint16_t chkBufUnit;
- (void)startWithModel:(OTAProcessModel *)model andDevice:(CBPeripheral *)device;
- (void)recvBufChkResult:(BUFFER_CHK_RESULT *)p;
@end
