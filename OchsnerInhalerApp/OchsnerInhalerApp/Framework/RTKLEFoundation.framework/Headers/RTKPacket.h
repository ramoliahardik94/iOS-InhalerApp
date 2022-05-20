//
//  RTKPacket.h
//  RTKLEFoundation
//
//  Created by jerome_gu on 2021/12/7.
//  Copyright © 2022 Realtek. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RTK_PACKET_ID_NULL -1

NS_ASSUME_NONNULL_BEGIN

/**
 * Represents a packet that send to or receive from a communication object.
 *
 * @discussion A packet uses ID and subID to uniquely identifies itself from other packets. 
 */
@interface RTKPacket : NSObject

/**
 * A integer number combine with subID to identify this packet.
 */
@property (readonly) NSInteger ID;

/**
 * A integer number combine with ID to identify this packet.
 */
@property (readonly) NSInteger subID;

/**
 * The data object that is meaningful to some upper-layer process.
 */
@property (readonly, nullable) NSData *payload;

/**
 * The time this packet is created.
 */
@property (readonly) NSDate *time;

/**
 * Initializes receiver with a ID and payload data.
 *
 * @param ID The primary identifier.
 * @param payload A data object that containing meaningful data for upper layer app.
 * @discussion The subID is set to RTK_PACKET_ID_NULL .
 */
- (instancetype)initWithID:(NSInteger)ID payload:(nullable NSData *)payload;

/**
 * Initializes receiver with IDs and payload data.
 *
 * @param ID The primary identifier.
 * @param subID The secondary identifier.
 * @param payload A data object that containing meaningful data for upper layer app.
 */
- (instancetype)initWithID:(NSInteger)ID subID:(NSInteger)subID payload:(nullable NSData *)payload;

@end


/**
 * Represents a special packet that can acknowledge a normal packet.
 */
@interface RTKACKPacket : RTKPacket

/**
 * A integer number that identifies this ACK packet.
 */
@property (readonly) NSInteger ACKID;

/**
 * A data object that containing extra data associate with this packet.
 */
@property (readonly, nullable) NSData *supplement;

/**
 * Initializes a ACK packet with ACK ID and extra data.
 */
- (instancetype)initWithACKID:(NSInteger)ID supplement:(nullable NSData *)data;

- (BOOL)canAcknowledgePacket:(RTKPacket *)packet;

@end


@interface RTKRequestPacket : RTKPacket

@end

NS_ASSUME_NONNULL_END
