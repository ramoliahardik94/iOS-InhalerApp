//
//  RTKAccessorySessionTransport.h
//  RTKBTFoundation
//
//  Created by jerome_gu on 2020/3/3.
//  Copyright © 2022 Realtek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

#ifdef RTK_SDK_IS_STATIC_LIBRARY
#import "RTKPacketTransport.h"
#else
#import <RTKLEFoundation/RTKPacketTransport.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 * A communication channel with an remote accessory.
 */
@interface RTKAccessorySessionTransport : RTKPacketTransport

/**
 * The communication protocol.
 */
@property (nonatomic, readonly) NSString *protocolString;

/**
 * Initialize the communication object with specific accessory and protocol.
 */
- (instancetype)initWithAccessory:(EAAccessory *)accessory forProtocol:(nonnull NSString *)protocolString;

/**
 * The communication end point.
 */
@property (nonatomic, readonly) EAAccessory *accessory;

@end

NS_ASSUME_NONNULL_END
