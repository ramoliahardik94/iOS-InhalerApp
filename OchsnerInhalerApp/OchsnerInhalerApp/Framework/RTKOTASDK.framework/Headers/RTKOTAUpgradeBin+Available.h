//
//  RTKOTAUpgradeBin+Available.h
//  RTKLEFoundation
//
//  Created by jerome_gu on 2020/9/23.
//  Copyright © 2020 jerome_gu. All rights reserved.
//


#ifdef RTK_SDK_IS_STATIC_LIBRARY
#import "RTKOTAUpgradeBin.h"
#import "RTKOTAPeripheral.h"
#import "RTKOTADeviceInfo.h"
#else
#import <RTKOTASDK/RTKOTAUpgradeBin.h>
#import <RTKOTASDK/RTKOTAPeripheral.h>
#import <RTKOTASDK/RTKOTADeviceInfo.h>
#endif


NS_ASSUME_NONNULL_BEGIN

@interface RTKOTAUpgradeBin (Available)

/*!
 * Return a boolean value indicates whether the SOC this image match with is determined.
 *
 * @discussion Binary object typically come with SOC determined, but sometimes it does not. When ICDetermined return NO, you can call -assertAvailableForPeripheral: to make it available for a specified peripheral, which should be very careful. It's a disaster when upgrade a device with a mismatch image.
 */
@property (nonatomic, readonly) BOOL ICDetermined;


/// Subjectively make the binary available for the passed peripheral object .
///
/// @discussion You should call this method only if ICDetermined property return NO. You should make sure the upgrade Bin matches target peripheral, otherwise, the behaviour is not determined.
- (void)assertAvailableForPeripheral:(RTKOTAPeripheral *)peripheral;

- (void)assertAvailableForPeripheralInfo:(RTKOTADeviceInfo *)info;

@end

NS_ASSUME_NONNULL_END
