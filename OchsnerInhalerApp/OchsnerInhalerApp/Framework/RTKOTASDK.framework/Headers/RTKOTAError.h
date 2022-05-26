//
//  RTKOTAError.h
//  RTKLEFoundation
//
//  Created by jerome_gu on 2019/1/30.
//  Copyright © 2019 Realtek. All rights reserved.
//

#ifndef RTKOTAError_h
#define RTKOTAError_h

#import <Foundation/Foundation.h>

/// The domain for OTA errors.
extern NSErrorDomain const RTKOTAErrorDomain;

/// RTKOTAErrorDomain Error code
typedef NS_ENUM(NSInteger, RTKOTAErrorCode) {
    RTKOTAErrorUnknown,                                     ///< Unknown error
    
    RTKOTAErrorCommunicationNotOpen,                        ///< Operation cannot be executed because of communication not open.
    
    RTKOTAErrorScaningBusy,                                 ///< There is a pending scan task, you may retry later.
    RTKOTAErrorScanForPeripheralTimeout,                    ///< Cannot discover a specific peripheral within a specific duration.
    
    RTKOTAErrorServiceNotDetermined,                        ///< Service (and containing characterisitc) is not discovered or not installed.
    
    RTKOTAErrorOTAInfoReadTimeOut,                          ///< Read OTA device information time out.
    
    RTKOTAErrorOTAServiceInconsistency,                     ///< The info readed from peripheral is inconsisitent, OTA upgrade can't be started.
    
    RTKOTAErrorOTAModePeripheralScanning,                   ///< Scan for peripheral in OTA mode fail.
    RTKOTAErrorPeripheralReconnection,                      ///< Reconnect to peripheral failed while upgrade silently.
    
    RTKOTAErrorUserCancelled,                               ///< User (app) canceled upgrade.
    
    RTKOTAErrorDFUImageMismatch,                            ///< Image is not match with SOC
    
    RTKOTAErrorDFUGetImageInfo,                             ///< Get target image info failed.
    RTKOTAErrorDFUStartDFU,                                 ///< Send start DFU message failed.
    RTKOTAErrorDFURequestReceiveFailure,                    ///< Request peripheral to receive image failed.
    RTKOTAErrorDFUImageSendFailure,                         ///< Send image data failed.
    RTKOTAErrorDFUBufferCheckFailure,                       ///< Buffer check failed.
    RTKOTAErrorDFUValidate,                                 ///< Image validate failed.
    RTKOTAErrorDFUActive,                                   ///< Image active failed.
    RTKOTAErrorDFUReset,                                    ///< Image reset failed.
    RTKOTAErrorDFUCopyImage,                                ///< Copy image failed. (used in dual bank)
    RTKOTAErrorDFUImageExistState,                          ///< Get image exist state failed.
    RTKOTAErrorDFUDisconnectionWait,                        ///< Wait for LE disconnection failed during upgrade.
    
    RTKOTAErrorBinFileNotExist,                             ///< The specified file does not exist.
    RTKOTAErrorBinFileFormatInvalid,                        ///< The passed in bin file format is invalid.
    
    
    RTKOTAErrorDFUCommunication,
    
    RTKOTAErrorPrepareFailed,
    
    RTKOTAErrorDFUConnParameterUpdateFailure,               ///< Connection Parameter Update Failed
    
    RTKOTAErrorAdvDataNotComplete,                          ///< Adv Data does not have enough info
    RTKOTAErrorDFUNoAvailableImage,
    RTKOTAErrorDFUUpgradeMethodUnavailable,
    RTKOTAErrorDFUSendImageVersion,                        ///< Send image version failed
};

#endif /* RTKOTAError_h */
