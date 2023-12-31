//
//  RTKOTABin.h
//  RTKOTASDK
//
//  Created by jerome_gu on 2019/4/16.
//  Copyright © 2019 Realtek. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * Represents the type of a image.
 *
 * @discussion RTKOTAImageType is designed to support different SOC platform. The case value is reused for different SOC platform. So when be used to compare, the SOC platform is required.
 */
typedef NS_ENUM(NSUInteger, RTKOTAImageType) {
    RTKOTAImageType_Unknown = 0,
    
    /* Bee */
    RTKOTAImageType_Bee_Patch                       = 0x01<<0,      ///< Path
    RTKOTAImageType_Bee_AppBank0                    = 0x01<<1,      ///< App in bank 0
    RTKOTAImageType_Bee_AppBank1                    = 0x01<<2,      ///< App in bank 1
    RTKOTAImageType_Bee_Data                        = 0x01<<3,      ///< Data
    RTKOTAImageType_Bee_PatchExt                    = 0x01<<4,      ///< Patch extension
    RTKOTAImageType_Bee_Config                      = 0x01<<6,      ///< Configuration
    
    /* Bee 2 */
    RTKOTAImageType_Bee2_SOCV_CFG                   = 0x01<<0,      ///< SOCV Configuration
    RTKOTAImageType_Bee2_SystemConfig               = 0x01<<1,      ///< System Configuration
    RTKOTAImageType_Bee2_OTAHeader                  = 0x01<<2,      ///< OTA Header
    RTKOTAImageType_Bee2_Secure_Boot_Loader         = 0x01<<3,      ///< Secure Boot Loader
    RTKOTAImageType_Bee2_ROM_PATCH                  = 0x01<<4,      ///< ROM Patch
    RTKOTAImageType_Bee2_APP_IMG                    = 0x01<<5,      ///< App
    RTKOTAImageType_Bee2_APP_DATA1                  = 0x01<<6,      ///< App Data 1
    RTKOTAImageType_Bee2_APP_DATA2                  = 0x01<<7,      ///< App Data 2
    RTKOTAImageType_Bee2_APP_DATA3                  = 0x01<<8,      ///< App Data 3
    RTKOTAImageType_Bee2_APP_DATA4                  = 0x01<<9,      ///< App Data 4
    RTKOTAImageType_Bee2_APP_DATA5                  = 0x01<<10,     ///< App Data 5
    RTKOTAImageType_Bee2_APP_DATA6                  = 0x01<<11,     ///< App Data 6
    RTKOTAImageType_Bee2_APP_DATA7                  = 0x01<<12,     ///< App Data 7
    RTKOTAImageType_Bee2_APP_DATA8                  = 0x01<<13,     ///< App Data 8
    RTKOTAImageType_Bee2_APP_DATA9                  = 0x01<<14,     ///< App Data 9
    RTKOTAImageType_Bee2_APP_DATA10                 = 0x01<<15,     ///< App Data 10
    
    /* SBee 2 (Bee3) */
    RTKOTAImageType_SBee2_SOCV_CFG                   = 0x01<<0,     ///< SOCV Configuration
    RTKOTAImageType_SBee2_SystemConfig               = 0x01<<1,     ///< System Configuration
    RTKOTAImageType_SBee2_OTAHeader                  = 0x01<<2,     ///< OTA Header
    RTKOTAImageType_SBee2_Secure_Boot_Loader         = 0x01<<3,     ///< Secure Boot Loader
    RTKOTAImageType_SBee2_ROM_PATCH                  = 0x01<<4,     ///< ROM Patch
    RTKOTAImageType_SBee2_APP_IMG                    = 0x01<<5,     ///< App
    RTKOTAImageType_SBee2_APP_DATA1                  = 0x01<<6,     ///< App Data 1
    RTKOTAImageType_SBee2_APP_DATA2                  = 0x01<<7,     ///< App Data 2
    RTKOTAImageType_SBee2_APP_DATA3                  = 0x01<<8,     ///< App Data 3
    RTKOTAImageType_SBee2_APP_DATA4                  = 0x01<<9,     ///< App Data 4
    RTKOTAImageType_SBee2_APP_DATA5                  = 0x01<<10,    ///< App Data 5
    RTKOTAImageType_SBee2_APP_DATA6                  = 0x01<<11,    ///< App Data 6
    RTKOTAImageType_SBee2_UPPERSTACK                 = 0x01<<12,    ///< Upper Stack
    RTKOTAImageType_SBee2_APP_DATA8                  = 0x01<<13,    ///< App Data 8
    RTKOTAImageType_SBee2_APP_DATA9                  = 0x01<<14,    ///< App Data 9
    RTKOTAImageType_SBee2_APP_DATA10                 = 0x01<<15,    ///< App Data 10
    
    /* BBpro (including BBLite, BBpro 2) */
    RTKOTAImageType_BBpro_SOCV_CFG                  = 1,      ///< SOCV Configuration
    RTKOTAImageType_BBpro_SystemConfig              = 2,      ///< System Configuration
    RTKOTAImageType_BBpro_OTAHeader                 = 3,      ///< OTA Header
    RTKOTAImageType_BBpro_Secure_Boot_Loader        = 4,      ///< Secure Boot Loader
    RTKOTAImageType_BBpro_ROM_PATCH                 = 5,      ///< ROM Patch
    RTKOTAImageType_BBpro_APP_IMG                   = 6,      ///< App
    RTKOTAImageType_BBpro_DSP_System                = 7,      ///< DSP System
    RTKOTAImageType_BBpro_DSP_APP                   = 8,      ///< DSP App
    RTKOTAImageType_BBpro_DSP_UI_PARAMETER          = 9,      ///< DSP UI Parameter (DSP Configure)
    RTKOTAImageType_BBpro_APP_UI_PARAMETER          = 10,     ///< App UI Parameter (APP Configure)
    RTKOTAImageType_BBpro_EXT_IMAGE0                = 11,     ///< Extension Image 0 (ANC)
    RTKOTAImageType_BBpro_EXT_IMAGE1                = 12,     ///< Extension Image 1
    RTKOTAImageType_BBpro_EXT_IMAGE2                = 13,     ///< Extension Image 2 (Sensor)
    RTKOTAImageType_BBpro_EXT_IMAGE3                = 14,     ///< Extension Image 3
    RTKOTAImageType_BBpro_FACTORY_IMAGE             = 15,     ///< Factory Image
    RTKOTAImageType_BBpro_BACKUP_DATA               = 16,     ///< Backup Data
    RTKOTAImageType_BBpro_BACKUP_DATA2              = 17,     ///< Backup Data 2
    RTKOTAImageType_BBpro_Platform_Img              = 18,     ///< Platform Image
    RTKOTAImageType_BBpro_Lower_Stack_Img           = 19,     ///< Lower Stack
    RTKOTAImageType_BBpro_Upper_Stack_Img           = 20,     ///< Upper Stack
    RTKOTAImageType_BBpro_Framework_Img             = 21,     ///< Framework Image
    RTKOTAImageType_BBpro_PreSys_Patch_Img          = 22,     ///< Pre_platform Image
    RTKOTAImageType_BBpro_PreStack_Patch_Img        = 23,
    RTKOTAImageType_BBpro_PreUpper_Stack_Img        = 24,     ///< Pre_upperstack Image
    RTKOTAImageType_BBpro_Voice_Prompt_Data_Img     = 25,     ///< Voice Prompt Data
    RTKOTAImageType_BBpro_UserData1                 = 26,     ///< User Data
    RTKOTAImageType_BBpro_UserData2                 = 27,
    RTKOTAImageType_BBpro_UserData3                 = 28,
    RTKOTAImageType_BBpro_UserData4                 = 29,
    RTKOTAImageType_BBpro_UserData5                 = 30,
    RTKOTAImageType_BBpro_UserData6                 = 31,
    RTKOTAImageType_BBpro_UserData7                 = 32,
    RTKOTAImageType_BBpro_UserData8                 = 33,
};


NS_ASSUME_NONNULL_BEGIN

/**
 * An abstract class that represents an image binary.
 *
 * @discussion The RTKOTABin class is an abstract base class that defines common behavior for objects representing image binary, regardless of whther it is installed at peripheral. There are @c RTKOTAInstalledBin which represent a image reside in a real device and @c RTKOTAUpgradeBin subclass which represent a image to upgrade.
 * You typically don’t create instances of either RTKOTABin or its concrete subclasses. Instead, the SDK creates them for you when peripheral information settle or extracted from archive file.
 */
@interface RTKOTABin : NSObject

/**
 * The image type this binary is.
 */
@property (readonly) RTKOTAImageType type;


/**
 * Return a integer version number of the binary object.
 */
@property (readonly) uint32_t version;


/**
 * The name of the binary object.
 */
@property (readonly) NSString *name;

/**
 * Return a human-readable version string.
 */
@property (readonly) NSString *versionString;

/**
 * Compare version and return result of this binary object and a passed binary object.
 *
 * @discussion The method used to compare may be different for different image type.
 */
- (NSComparisonResult)compareVersionWith:(RTKOTABin *)anotherBin;


@end


NS_ASSUME_NONNULL_END
