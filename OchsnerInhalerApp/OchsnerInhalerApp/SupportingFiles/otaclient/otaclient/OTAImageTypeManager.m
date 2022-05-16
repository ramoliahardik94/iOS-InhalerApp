//
//  OTAImageTypeManager.h
//  otaclient
//
//  Created by Tang on 2018/6/22.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "OTAImageTypeManager.h"

#pragma pack(push, 1)

union VersionFormatNormal {
    uint32_t numberValue;
    struct {
        uint32_t major: 8;
        uint32_t minor: 8;
        uint32_t revision: 8;
        uint32_t build: 8;
    } component;
};

union VersionFormatBee2 {
    uint32_t numberValue;
    struct {
        uint32_t major: 4;
        uint32_t minor: 8;
        uint32_t revision: 15;
        uint32_t build: 5;
    } component;
};

union VersionFormatBBproApp {
    uint32_t numberValue;
    struct {
        uint32_t major: 4;
        uint32_t minor: 8;
        uint32_t revision: 9;
        uint32_t build: 11;
    } component;
};

union VersionFormatBBproPatch {
    uint32_t numberValue;
    struct {
        uint32_t major: 4;
        uint32_t minor: 8;
        uint32_t revision: 15;
        uint32_t build: 5;
    } component;
};

union VersionFormatOTA {
    uint32_t numberValue;
    struct {
        uint32_t build: 8;
        uint32_t revision: 8;
        uint32_t minor: 8;
        uint32_t major: 8;
    } component;
};

union VersionFormatDSP {
    uint32_t numberValue;
    struct {
        uint32_t rsv: 16;
        uint8_t major: 8;
        uint8_t minor: 8;
    } component;
};

#pragma pack(pop)

@implementation OTAImageTypeManager
+ (NSString *)getStringFromType:(IMAGE_TYPE)type andIC:(IC_TYPE)ic
{
    NSString *str = @"Unkwown";
    if (ic == IC_BEE2) {
        str = @[@"SOCV_CFG",
                @"SYSTEM_CONFIG ",
                @"OTA_HEADER",
                @"SECURE_BOOT_LOADER",
                @"ROM_PATCH",
                @"APP_IMG",
                @"APP_DATA1",
                @"APP_DATA2",
                @"APP_DATA3",
                @"APP_DATA4",
                @"APP_DATA5",
                @"APP_DATA6",
                @"Unkwown",
                @"Unkwown",
                @"Unkwown",
                @"Unkwown",
                ][type];
    }
    else  if (ic == IC_BBPRO) {
        str = @[@"SOCV_CFG",
                @"SYSTEM_CONFIG ",
                @"OTA_HEADER",
                @"SECURE_BOOT_LOADER",
                @"ROM_PATCH",
                @"APP_IMG",
                @"DSP_SYSTEM",
                @"DSP_APP",
                @"DSP_UI_PARAMETER",
                @"APP_UI_PARAMETER",
                @"EXT_IMAGE0",
                @"EXT_IMAGE1",
                @"EXT_IMAGE2",
                @"EXT_IMAGE3",
                @"FACTORY_IMAGE",
                @"BACKUP_DATA",
                ][type];
    }
    return str;
}

+ (NSString *)versionToString:(uint32_t)ver {
    return [NSString stringWithFormat:@"%d.%d.%d.%d", ver&0xff, (ver>>8)&0xff, (ver>>16)&0xff, (ver>>24)&0xff];
}

+ (NSString *)formatVersionFromInteger:(uint32_t)ver imageType:(IMAGE_TYPE)type icType:(IC_TYPE)ic {
    if (ic == IC_BEE) {
        return [NSString stringWithFormat:@"%d", ver];
    } else if (ic == IC_BEE2) {
        if (type == OTA_HEADER) {
            union VersionFormatOTA otaVersion;
            otaVersion.numberValue = ver;
            return [NSString stringWithFormat:@"%d.%d.%d.%d", otaVersion.component.major, otaVersion.component.minor, otaVersion.component.revision, otaVersion.component.build];
        } else {
            union VersionFormatBee2 version;
            version.numberValue = ver;
            return [NSString stringWithFormat:@"%d.%d.%d.%d", version.component.major, version.component.minor, version.component.revision, version.component.build];
        }
    } else if (ic == IC_BBPRO) {
        if (type == APP_IMG) {
            union VersionFormatBBproApp bbproVer;
            bbproVer.numberValue = ver;
            return [NSString stringWithFormat:@"%d.%d.%d.%d", bbproVer.component.major, bbproVer.component.minor, bbproVer.component.revision, bbproVer.component.build];
        } else if (type == ROM_PATCH) {
            union VersionFormatBBproPatch bbproVer;
            bbproVer.numberValue = ver;
            return [NSString stringWithFormat:@"%d.%d.%d.%d", bbproVer.component.major, bbproVer.component.minor, bbproVer.component.revision, bbproVer.component.build];
        } else if (type == OTA_HEADER) {
            union VersionFormatOTA otaVersion;
            otaVersion.numberValue = ver;
            return [NSString stringWithFormat:@"%d.%d.%d.%d", otaVersion.component.major, otaVersion.component.minor, otaVersion.component.revision, otaVersion.component.build];
        } else if (type >= DSP_SYSTEM && type <= DSP_UI_PARAMETER) {
            union VersionFormatDSP dspVersion;
            dspVersion.numberValue = ver;
            return [NSString stringWithFormat:@"0.0.%d.%d", dspVersion.component.major, dspVersion.component.minor];
        } else {
            union VersionFormatNormal version;
            version.numberValue = ver;
            return [NSString stringWithFormat:@"%d.%d.%d.%d", version.component.major, version.component.minor, version.component.revision, version.component.build];
        }
    }
    
    
    return @"N/A";
}

@end
