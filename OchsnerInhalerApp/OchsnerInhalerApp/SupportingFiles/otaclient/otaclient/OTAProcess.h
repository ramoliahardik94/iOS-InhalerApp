//
//  OTAProcess.h
//  otaclient
//
//  Created by Tang on 2018/6/22.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTAProcessModel.h"
#import "OTABufChkTxManager.h"
#import "OTANoBufChkTxManager.h"
#import "OTACommand.h"
#import "OTAClient1.h"

@protocol ProcessDelegate<NSObject>
@optional
- (NSInteger)imageFinishedWithStatus:(OTAError)status;
- (void)imageSendSize:(uint64_t)size TotalSize:(uint64_t)totalSize;
@end

@interface OTAProcess : NSObject
@property (nonatomic, weak) id<ProcessDelegate> delegate;
@property (nonatomic, strong) OTAProcessModel *model;
@property (nonatomic, strong) OTACommand *otaCmd;
@property (nonatomic, strong) OTASendDataManager *txManager;
//- (void)startWithModel:(OTAProcessModel *)model;
- (void)startWithModel:(OTAProcessModel *)model needReset:(BOOL)bReset;
- (void)processRecvData:(Byte *)respData;
- (void)txStart;
- (void)clear;
- (void)txStartWithBufChk:(uint16_t)sendMtu andChkBufUnit:(uint16_t)chkBufUnit;

- (void)recvStartDfu:(BOOL)bSuccess;
- (void)recvCopyData:(uint8_t)RspValue;
- (void)recvBufChkEnable:(BUFFER_CHK_ENABLE_RSP *)p;
- (void)recvBufChkResult:(BUFFER_CHK_RESULT *)p;
@end
