//
//  RTKCharacteristicOperate.h
//  RTKLEFoundation
//
//  Created by jerome_gu on 2021/11/2.
//  Copyright © 2022 Realtek. All rights reserved.
//

#ifndef RTKCharacteristicOperate_h
#define RTKCharacteristicOperate_h

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTKCharacteristicRead <NSObject>
@property (readonly) CBCharacteristic *readCharacteristic;

- (void)characteristicDidReadValue:(CBCharacteristic *)characteristic;
- (void)characteristicCannotReadValue:(CBCharacteristic *)characteristic withError:(NSError *)error;
@end


@protocol RTKCharacteristicNotificationRecept <NSObject>
@property (readonly) CBCharacteristic *notifyCharacteristic;

- (void)characteristicDidUpdateNotificationState:(CBCharacteristic *)characteristic;
- (void)characteristicDidFailToUpdateNotificationState:(CBCharacteristic *)characteristic withError:(NSError *)error;

- (void)characteristicDidUpdateValue:(CBCharacteristic *)characteristic;
@end


@protocol RTKCharacteristicWrite <NSObject>
@property (readonly) CBCharacteristic *writeCharacteristic;

- (void)characteristicDidWriteValue:(CBCharacteristic *)characteristic;
- (void)characteristicDidFailToWriteValue:(CBCharacteristic *)characteristic error:(NSError *)error;
@end


NS_ASSUME_NONNULL_END

#endif /* RTKCharacteristicOperate_h */
