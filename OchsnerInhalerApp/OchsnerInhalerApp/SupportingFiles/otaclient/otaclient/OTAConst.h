//
//  OTAConst.h
//  otaclient
//
//  Created by Tang on 2018/6/26.
//  Copyright © 2018年 Tang. All rights reserved.
//

#ifndef OTAConst_h
#define OTAConst_h

typedef NS_ENUM(uint8_t, DEBUG_LEVEL)
{
    LEVEL_DEBUG = 0X0,
    LEVEL_INFO,
    LEVEL_WARN,
    LEVEL_ERROR,
    LEVEL_FATAL,
    LEVEL_NONE,
};

typedef NS_ENUM(uint8_t, OTAError)
{
    /** upgrade error code
     */
    ERROR_STATE_SUCCESS = 0x01,
    ERROR_STATE_INVALID_PARA = 0x02,
    ERROR_STATE_OPRERATION_FAILED = 0x03,
    ERROR_STATE_DATA_SIZE_EXCEEDS = 0x04,
    ERROR_STATE_CRC_ERROR = 0x05,
    ERROR_STATE_BUFCHK_LENGTH_ERROR = 0x06,
    ERROR_STATE_FLASH_WRITE_ERROR = 0x07,
    ERROR_STATE_FLASH_ERASE_ERROR = 0x08,
    ERROR_STATE_DISCONNECTED = 0x09,
    
    /** other error code
     */
    ERROR_STATE_POWER_OFF = 0x20,
    ERROR_STATE_NO_DEVICE = 0X21,
    ERROR_STATE_DEVINFO = 0X22,
    ERROR_STATE_FILE_OTA_HEADER = 0X23,
    ERROR_STATE_FILE_BANK = 0X24,
    ERROR_STATE_FILE_OTA_HEADER2 = 0X25,
    ERROR_STATE_FILE_NOT_SUPPORT = 0X26,
    ERROR_STATE_DEVICE_RECONNECTION_FAIL = 0x27,
};

typedef NS_ENUM(uint8_t, IC_TYPE)
{
    IC_BEE = 3,
    IC_BBPRO = 4,
    IC_BEE2 = 5,
};

typedef NS_ENUM(uint8_t, IMAGE_TYPE){
    SOCV_CFG = 0,
    SYSTEM_CONFIG = 1,
    OTA_HEADER = 2,
    SECURE_BOOT_LOADER = 3,
    ROM_PATCH =  4,
    APP_IMG = 5,
    APP_DATA1 = 6,
    APP_DATA2 = 7,
    APP_DATA3 = 8,
    APP_DATA4 = 9,
    APP_DATA5 = 10,
    
    DSP_SYSTEM = 6,
    DSP_APP = 7,
    DSP_UI_PARAMETER = 8,
    APP_UI_PARAMETER = 9,
    EXT_IMAGE0 = 10,
    EXT_IMAGE1 = 11,
    EXT_IMAGE2 = 12,
    EXT_IMAGE3 = 13,
    FACTORY_IMAGE = 14,
    BACKUP_DATA = 15,
};

#endif /* OTAConst_h */
