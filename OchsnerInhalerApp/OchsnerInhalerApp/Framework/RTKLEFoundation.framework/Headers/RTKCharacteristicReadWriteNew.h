//
//  RTKCharacteristicReadWriteNew.h
//  RTKBTFoundation
//
//  Created by jerome_gu on 2021/11/2.
//  Copyright © 2022 Realtek. All rights reserved.
//

#ifdef RTK_SDK_IS_STATIC_LIBRARY
#import "RTKPacketTransport.h"
#import "RTKCharacteristicOperate.h"
#import "RTKConnectionUponGATT.h"
#else
#import <RTKLEFoundation/RTKPacketTransport.h>
#import <RTKLEFoundation/RTKCharacteristicOperate.h>
#import <RTKLEFoundation/RTKConnectionUponGATT.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface RTKCharacteristicReadWriteNew : RTKPacketTransport <RTKCharacteristicNotificationRecept, RTKCharacteristicWrite>

- (instancetype)initWithGATTConnection:(RTKConnectionUponGATT*)connection
                  characteristicToRead:(nullable CBCharacteristic *)readCharacteristic
                 characteristicToWrite:(nullable CBCharacteristic *)writeCharacteristic;

@property (class, readonly) BOOL writeReliably;

@end


@interface RTKCharacteristicReadWriteArbitrarilyNew : RTKCharacteristicReadWriteNew

@end

NS_ASSUME_NONNULL_END
