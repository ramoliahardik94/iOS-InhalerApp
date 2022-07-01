//
//  OTADeviceFeatureModel.h
//  otaclient
//
//  Created by Tang on 2018/6/22.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTAConst.h"

@interface OtaDeviceInfo: NSObject
@property (nonatomic) IC_TYPE ICType;

@property (nonatomic) uint16_t MaxBufSize;

@property (nonatomic) uint8_t freeBank;

@property (nonatomic) uint8_t BufferCheck;
@property (nonatomic) uint8_t Aes;
@property (nonatomic) uint8_t EncryptionMode;
@property (nonatomic) uint8_t cpyImg;
@property (nonatomic) uint8_t updateMultiImages;


@property (nonatomic) uint8_t otaVersion;
@property (nonatomic) uint8_t securityVersion;
@property (nonatomic) uint32_t TempBufferSize;
@property (nonatomic) uint32_t imagesVersion;

@property (nonatomic) uint8_t appFreeBank;
@property (nonatomic) uint8_t patchFreeBank;
@end


@interface OTADeviceImageVersion: NSObject
@property (nonatomic) uint8_t imageType;
@property (nonatomic, strong) NSString * typeString;
@property (nonatomic) uint32_t imageVersion;
@property (nonatomic, strong) NSString * versionString;
@end

@interface BleDIS: NSObject
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * value;
@end

@interface OTADeviceFeatureModel : NSObject
@property (nonatomic, strong) OtaDeviceInfo *devInfo;
@property (nonatomic) UInt64 bdAddr;
@property (nonatomic, strong) NSString *linkKey;
@property (nonatomic) uint16_t appVer;
@property (nonatomic) uint16_t patchVer;
@property (nonatomic) NSArray<OTADeviceImageVersion *> *versions;
@property (nonatomic) NSMutableArray<BleDIS *> *dis;
@end
