//
//  RTKBBproEQSetting.h
//  RTKBBproSDK
//
//  Created by jerome_gu on 2019/2/25.
//  Copyright © 2019 Realtek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef float RTKEQGain;

typedef NS_ENUM(NSUInteger, RTKEQFrequency) {
    RTKEQFrequency_32,
    RTKEQFrequency_64,
    RTKEQFrequency_125,
    RTKEQFrequency_250,
    RTKEQFrequency_500,
    RTKEQFrequency_1000,
    RTKEQFrequency_2000,
    RTKEQFrequency_4000,
    RTKEQFrequency_8000,
    RTKEQFrequency_16000,
};


@interface RTKBBproEQSetting : NSObject {
    @protected
    RTKEQGain _gains[10];
    NSUInteger _gainCount;
}

+ (instancetype)FlatEQSetting;
+ (instancetype)AcousticEQSetting;
+ (instancetype)BassBoosterEQSetting;
+ (instancetype)BassReducerEQSetting;
+ (instancetype)ClassicalEQSetting;
+ (instancetype)HipHopEQSetting;
+ (instancetype)JazzEQSetting;
+ (instancetype)RockEQSetting;

@property (readonly) NSString *name;
//@property (readonly) NSString *localizedName;

- (instancetype)initWithName:(NSString *)name;

@property (readonly, nonatomic) NSUInteger gainCount;
- (void)setGain:(RTKEQGain)gain ofFrequency:(RTKEQFrequency)freq;
- (RTKEQGain)gainOfFrequency:(RTKEQFrequency)freq;

- (void)reset;

- (NSData *)serializedData;

- (NSData *)serializedDataAt44P1KFrequency;
- (NSData *)serializedDataAt48KFrequency;


/* Cache & Restore */
- (void)cacheWith:(NSUUID *)peripheralID;

+ (nullable instancetype)cachedEQSettingOf:(NSUUID *)peripheralID;

@end

NS_ASSUME_NONNULL_END
