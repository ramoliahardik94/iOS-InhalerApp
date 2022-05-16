//
//  CoreBle.h
//  otaclient
//
//  Created by Tang on 2018/6/21.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface CoreBle : NSObject
/*!
 @brief Get instance
 
 
 To use it, simply call @c[CoreBle getShareInstance];
 
 @return id CoreBle Singleton Instance
 */
+ (id)getShareInstance;

- (void)setLocalStateChangeBlock:(void (^)(BOOL bOn))block;
- (void)setConnChangeBlock:(void (^)(CBPeripheral *device))block;
- (void)setRxBlock:(void (^)(CBCharacteristic *ch))block;
/*!
 @brief Get local bluetooth state
 @return CBManagerState Bluetooth State.
 */
- (CBManagerState)bleGetBtState;

/*!
 @brief start search ble devices
 */

- (void)bleSearchDevice:(NSArray *)serviceUUIDs block:(void (^)(CBPeripheral *device, NSDictionary *dic, NSNumber *rssi))block;

/*!
 @brief connect a ble device
 */
- (void)bleConnectDevice:(CBPeripheral *)peripheral;

/*!
 @brief get connected device
 */
- (CBPeripheral *)bleGetBridge;

/*!
 @brief stop scan device
 */
- (void)bleStopSearchDevice;

/*!
 @brief disconenct to device
 */
- (void)bleDisconnectDevice:(CBPeripheral *)peripheral;

/*!
 @brief get Peripheral from uuid
 */
- (CBPeripheral *)bleGetPeripheralFromUUID:(NSString *)uuid;


/* 检查外设是否已经完成准备工作（discover，read readable characteristic）*/
- (BOOL)isReadyOfPeripheral:(CBPeripheral *)peripheral;
- (void)waitForReadyOfPeripheral:(CBPeripheral *)peripheral completion:(void(^)(BOOL))handle;


/*!
 @brief write value to a device's characteristic
 */
- (void)bleWriteValueToPeripheral:(CBPeripheral *)peripheral serviceUuidString:(NSString *)serviceUuidString charUuidString:(NSString *)charUuidString data:(NSData *)data type:(CBCharacteristicWriteType)type;

/*!
 @brief set notification enable/disable
 */
- (BOOL)bleSetNotifyValue:(BOOL)value peripheral:(CBPeripheral *)peripheral serviceUuidString:(NSString *)serviceUuidString charUuidString:(NSString *)charUuidString;


/**/
- (void)enableNotifyWhenDiscoveredOfCharacteristic:(NSString *)charUUID inService:(NSString *)serviceUUID ofPeripheral:(CBPeripheral *)peri;


/*!
 @brief read value of characteristic
 */
- (BOOL)bleGetCharValue:(BOOL)value peripheral:(CBPeripheral *)peripheral serviceUuidString:(NSString *)serviceUuidString charUuidString:(NSString *)charUuidString;


/*!
 @brief connect a ble device, the device is not a bridge
 */
- (void)bleConnectNoBridgeDevice:(CBPeripheral *)peripheral;
@end
