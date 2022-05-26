//
//  OTACommand.h
//  otaclient
//
//  Created by Tang on 2017/12/26.
//  Copyright © 2017年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DFUDef.h"
@interface OTACommand : NSObject
+ (id)shareInstance;
- (void)setDevice:(CBPeripheral *)device imageHeader:(IMAGE_HEADER)imgHdr;

- (void)oTABufChkEnable;
- (void)oTABufChkSize:(UInt16)size buf:(uint8_t *)buf;
- (void)oTAGetTargetImageInfo;
- (void)oTAPushImageToTargetWithOffset:(uint32_t)offset;
- (void)oTAReceiveFwImage:(uint16_t)signature offset:(uint32_t)offset;
- (void)oTAValidFWWithSignature:(uint16_t)signature;
- (void)oTAStartDFU:(BOOL)bAES;
- (void)oTAValidFW;
- (void)oTAActiveAndReset:(uint8_t)type;
- (void)oTAImmediatelyReset;

- (void)oTAValidFWBee2;
- (void)oTAPushImageToTargetWithOffsetBee2:(uint32_t)offset;
- (void)oTAGetTargetImageInfoBee2;
- (NSData *)oTAGenCopyCmdBee2:(uint16_t)signature size:(uint32_t)size addr:(uint32_t)addr;
- (void)oTASendRawData:(NSData *)data;
@end
