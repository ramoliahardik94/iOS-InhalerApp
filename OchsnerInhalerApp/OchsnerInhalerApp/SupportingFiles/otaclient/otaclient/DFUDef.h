/*********************************************************************

Copyright @ Realtek Semiconductor Corp. All Rights Reserved.

THIS CODE AND INFORMATION IS PROVIDED [AS] [IS] WITHOUT WARRANTY OF ANY
KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
PURPOSE.


\file :     DFUdef.h

\brief  :   Implementation of DFU Client

Rui Huang

Environment:    IOS only

Comment:



Revision History:
When            Who                         What                   
-------------   ------------------------    -----------------------
2014/10/27      THOMSON
********************************************************************/

#ifndef DFU_DEF_H_
#define DFU_DEF_H_

#ifndef IN
#define IN
#endif

#ifndef OUT
#define OUT
#endif

// Bluetooth SIG assigned number

#define AN_DEVICE_DFU_DATA @"00006387-3C17-D293-8E48-14FE2E4DA212"
///DFU Control Point
#define AN_DEVICE_FIRMWARE_UPDATE_CHAR @"00006487-3C17-D293-8E48-14FE2E4DA212"

#define SERVICE_DFU                     @"00006287-3C17-D293-8E48-14FE2E4DA212"
#define AN_DEVICE_DFU_DATA              @"00006387-3C17-D293-8E48-14FE2E4DA212"
///DFU Control Point
#define AN_DEVICE_FIRMWARE_UPDATE_CHAR  @"00006487-3C17-D293-8E48-14FE2E4DA212"
#define SERVICE_OTA_INTERFACE           @"0000d0ff-3C17-D293-8E48-14FE2E4DA212"

#define SERVICE_DEVICE_INFO     @"180A"
#define CHAR_DI_SYS                     @"2A23"
#define CHAR_DI_MODEL                   @"2A24"
#define CHAR_DI_SERIAL                  @"2A25"
#define CHAR_DI_FW                      @"2A26"
#define CHAR_DI_HW                      @"2A27"
#define CHAR_DI_SW                      @"2A28"
#define CHAR_DI_MANU                    @"2A29"
#define CHAR_DI_IEEE                    @"2A2A"
#define CHAR_DI_PNP                     @"2A50"

#define CHAR_OTA_ENTER                  @"FFD1"
#define CHAR_OTA_BDADDR                 @"FFD2"
#define GATT_UUID_CHAR_DEVICE_INFO      @"FFF1"
#define CHAR_OTA_LINK_KEY   @"FFC0"
#define CHAR_OTA_PATCH_VERSION @"FFD3"
#define CHAR_OTA_APP_VERSION @"FFD4"

// DFU Opcode
#define OPCODE_DFU_START_DFU 0x01
#define OPCODE_DFU_RECEIVE_FW_IMAGE 0x02
#define OPCODE_DFU_VALIDATE_FW_IMAGE 0x03
#define OPCODE_DFU_ACTIVE_IMAGE_RESET 0x04
#define OPCODE_DFU_RESET_SYSTEM 0x05
#define OPCODE_DFU_REPORT_RECEIVED_IMAGE_INFO 0x06
#define OPCODE_DFU_PACKET_RECEIPT_NOTIFICATION_REQUEST 0x07

#define OPCODE_DFU_BUFFER_CHK_ENABLE    0x09
#define OPCODE_DFU_BUFFER_CHK_REQUEST   0x0a
#define OPCODE_DFU_OPCODE_COPY_IMG      0x0c

#define OPCODE_DFU_RESPONSE_CODE 0x10
#define OPCODE_DFU_PACKET_RECEIPT_NOTIFICATION 0x11


//#define BIT(a)                                  (0x1<<a)
//#define BIT0                                    (0x1<<0)
//#define BIT1                                    (0x1<<1)
//#define BIT2                                    (0x1<<2)
//#define BIT3                                    (0x1<<3)
//#define BIT4                                    (0x1<<4)
//#define BIT5                                    (0x1<<5)
//#define BIT6                                    (0x1<<6)
//#define BIT7                                    (0x1<<7)
//#define BIT8                                    (0x1<<8)
//#define BIT9                                    (0x1<<9)



typedef NS_ENUM(uint8_t, IMAGE_FORMAT){
    IMAGE_NONE = 0,
    IMAGE_BANK0 = 1,
    IMAGE_BANK1 = 2,
    IMAGE_NO_BANK_SWITCH = 3,
};

#pragma pack(push, 1)
// DFU Response Header
typedef struct _DEF_RESPONSE_HEADER {
    uint8_t Opcode;
    uint8_t ReqOpcode;
    uint8_t RspValue;
} DEF_RESPONSE_HEADER;

// DFU Op structure
// OPCODE_DFU_START_DFU
typedef struct _DFU_START_DFU {
    uint8_t Opcode;
//    UINT16 offset;
//    UINT16 signature;
//    UINT16 version;
//    UINT16 checksum;
//    UINT16 length;
//    UINT8 ota_flag;   // default: 0xff
//    UINT8 reserved_8; // default: 0xff
//    UINT32 ReservedForAes;
    
    uint8_t ic_type;
    uint8_t ota_flag;
    uint16_t signature;
    uint16_t version;
    uint16_t crc16;
    uint32_t image_length;
    
    uint32_t ReservedForAes;
} DFU_START_DFU;

typedef struct _DFU_START_DFU_RESPONSE {
    uint8_t Opcode;
    uint8_t ReqOpcode;
    uint8_t RspValue;
} DFU_START_DFU_RESPONSE;

// OPCODE_DFU_RECEIVE_FW_IMAGE
typedef struct _RECEIVE_FW_IMAGE {
    uint8_t Opcode;
    uint16_t nSignature;
    uint32_t nImageUpdateOffset;
} RECEIVE_FW_IMAGE;

typedef struct _RECEIVE_FW_IMAGE_RESPONSE {
    uint8_t Opcode;
    uint8_t ReqOpcode;
    uint8_t RspValue;
} RECEIVE_FW_IMAGE_RESPONSE;

// OPCODE_DFU_VALIDATE_FW_IMAGE
typedef struct _VALIDATE_FW_IMAGE {
    uint8_t Opcode;
    uint16_t nSignature;
} VALIDATE_FW_IMAGE;

typedef struct _VALIDATE_FW_IMAGE_RESPONSE {
    uint8_t Opcode;
    uint8_t ReqOpcode;
    uint8_t RspValue;
} VALIDATE_FW_IMAGE_RESPONSE;

//OPCODE_DFU_ACTIVE_IMAGE_RESET
typedef struct _ACTIVE_IMAGE_RESET {
    uint8_t Opcode;
    uint8_t type;
} ACTIVE_IMAGE_RESET;

//OPCODE_DFU_ACTIVE_IMAGE_RESET
typedef struct _RESET_SYSTEM {
    uint8_t Opcode;
} RESET_SYSTEM;

typedef struct _BUF_CHK_ENABLE {
    uint8_t Opcode;
} BUF_CHK_ENABLE;

typedef struct _BUF_CHK_REQ {
    uint8_t Opcode;
    uint16_t Size;
    uint16_t crc;
} BUF_CHK_REQ;

// OPCODE_DFU_REPORT_RECEIVED_IMAGE_INFO
typedef struct _REPORT_RECEIVED_IMAGE_INFO {
    uint8_t Opcode;
    uint16_t nSignature;
} REPORT_RECEIVED_IMAGE_INFO;

typedef struct _REPORT_RECEIVED_IMAGE_INFO_RESPONSE {
    uint8_t Opcode;
    uint8_t ReqOpcode;
    uint8_t RspValue;
    uint16_t OriginalFWVersion;
    uint32_t nImageUpdateOffset; //支持断点续传
} REPORT_RECEIVED_IMAGE_INFO_RESPONSE;

typedef struct _BUFFER_CHK_ENABLE_RSP {
    uint8_t Opcode;
    uint8_t ReqOpcode;
    uint8_t Support;
    uint16_t MaxBufferSize;
    uint16_t mtu;
} BUFFER_CHK_ENABLE_RSP;

typedef struct _BUFFER_CHK_RESULT {
    uint8_t Opcode;
    uint8_t ReqOpcode;
    uint8_t Result;
    uint32_t ReTxAddress;
} BUFFER_CHK_RESULT;

typedef struct _DFU_COPY_DATA {
    uint8_t Opcode;
    uint16_t Signature;
    uint32_t Address;
    uint32_t Size;
} DFU_COPY_DATA;

typedef struct _COPY_DATA_RESULT {
    uint8_t Opcode;
    uint8_t ReqOpcode;
    uint8_t Result;
} COPY_DATA_RESULT;

typedef struct _DFU_FW_IMAGE_INFO {
    // Image file info
    uint16_t FWImageSize;
    uint16_t FWVersion;

    // Remote device info
    uint16_t OriginalVersion;
    uint32_t ImageUpdateOffset;
} DFU_FW_IMAGE_INFO;

typedef struct _DFU_DATA_INFO {
    uint8_t Flag;                // ???
    DFU_FW_IMAGE_INFO CurInfo; // read from OPCODE_DFU_REPORT_RECEIVED_IMAGE_INFO
    DFU_FW_IMAGE_INFO ImgInfo; // patch info loaded from file
} DFU_DATA_INFO;



typedef struct _IMAGE_HEADER {
//    UINT16 offset;
//    UINT16 signature;
//    UINT16 version;
//    UINT16 checksum;
//    UINT16 length;
//    UINT8 ota_flag;   // default: 0xff
//    UINT8 reserved_8; // default: 0xff
    
    
    uint8_t    ic_type;
    uint8_t    ota_flag;
    uint16_t   signature;
    uint16_t   version;
    uint16_t   crc16;
    uint32_t   length;

} IMAGE_HEADER;


typedef struct _IMAGE_HEADER_BEE2 {
    
//    uint8_t    ic_type;
//    uint8_t    ota_flag;
//    uint16_t   signature;
//    uint16_t   version;
//    uint16_t   crc16;
//    uint32_t   length;
    
    uint8_t ic_type;
    uint8_t secure_version;
    union
    {
        uint16_t value;
        struct
        {
            uint16_t xip: 1; // payload is executed on flash
            uint16_t enc: 1; // all the payload is encrypted
            uint16_t load_when_boot: 1; // load image when boot
            uint16_t enc_load: 1; // encrypt load part or not
            uint16_t enc_key_select: 3; // referenced to ENC_KEY_SELECT
            uint16_t not_ready : 1; //for copy image in ota
            uint16_t not_obsolete : 1; //for copy image in ota
            uint16_t rsvd: 7;
        };
    } ctrl_flag;
    uint16_t image_id;
    uint16_t crc16;
    uint32_t payload_len;
    
} IMAGE_HEADER_BEE2;

typedef struct _PACK_HEADER {
    uint16_t    signature;
    uint32_t    size;
    uint8_t     checkSum[32];
    uint16_t    extension;
    uint32_t    indicator;
} PACK_HEADER;


typedef struct _SUB_FILE_HEADER {
    uint32_t    downloadAddress;
    uint32_t    size;
    uint32_t    reserved;
} SUB_FILE_HEADER;

//typedef struct _IMAGE_HEADER2{
//    UINT8  ICType;
//    UINT8  ota_flag;    // default: 0xff
//    UINT16 signature;
//    UINT16 version;
//    UINT16 checksum;
//    UINT32 length;
//
//   // UINT8  reserved_8;  // default: 0xff
//
//}IMAGE_HEADER2;

//typedef struct
//{
//    uint32_t erk[64]; /* encryption round keys */
//    uint32_t drk[64]; /* decryption round keys */
//    int nr;           /* number of rounds */
//} aes_context;
#pragma pack(pop)

#endif
