//
//  OTAProcess.m
//  otaclient
//
//  Created by Tang on 2018/6/22.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "OTAProcess.h"


@interface OTAProcess()
@property (nonatomic) DFU_DATA_INFO dfuDataInfo;
@end

@implementation OTAProcess

- (instancetype)init{
    if(self = [super init])
    {
        _otaCmd = [OTACommand shareInstance];
        
    }
    return self;
}



- (void)startWithModel:(OTAProcessModel *)model needReset:(BOOL)bReset
{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
}

/**
 @brief ota rx Data parse
 @param respData rx bufffer
 */
- (void)processRecvData:(Byte *)respData {
    DEF_RESPONSE_HEADER *deh = (DEF_RESPONSE_HEADER *) respData;
    if (OPCODE_DFU_RESPONSE_CODE == deh->Opcode) {
        if (OPCODE_DFU_REPORT_RECEIVED_IMAGE_INFO == deh->ReqOpcode) {
            REPORT_RECEIVED_IMAGE_INFO_RESPONSE *p = (REPORT_RECEIVED_IMAGE_INFO_RESPONSE *) (respData);
            if (p->RspValue == ERROR_STATE_SUCCESS) {
                if ( self.model.feature.devInfo.ICType == IC_BEE2) {
#pragma pack(push,1)
                    typedef struct _REPORT_RECEIVED_IMAGE_INFO_RESPONSE2 {
                        uint8_t Opcode;
                        uint8_t ReqOpcode;
                        uint8_t RspValue;
                        uint32_t OriginalFWVersion; //长度为4个字节了
                        uint32_t nImageUpdateOffset; //支持断点续传
                    } REPORT_RECEIVED_IMAGE_INFO_RESPONSE2;
#pragma pack(pop)
                    REPORT_RECEIVED_IMAGE_INFO_RESPONSE2 *p2 = (REPORT_RECEIVED_IMAGE_INFO_RESPONSE2 *) (respData);
                    _dfuDataInfo.CurInfo.OriginalVersion = p2->OriginalFWVersion;//OriginalVersion无用
                    _dfuDataInfo.CurInfo.ImageUpdateOffset = p2->nImageUpdateOffset;
                }
                else
                {
                    _dfuDataInfo.CurInfo.OriginalVersion = p->OriginalFWVersion;
                    _dfuDataInfo.CurInfo.ImageUpdateOffset = p->nImageUpdateOffset;
                }
                
            }
            
            [self recvImageInfo:p->RspValue == ERROR_STATE_SUCCESS];
        } else if (OPCODE_DFU_START_DFU == deh->ReqOpcode) {
            DFU_START_DFU_RESPONSE *p = (DFU_START_DFU_RESPONSE *) (respData);
            [self recvStartDfu:p->RspValue == ERROR_STATE_SUCCESS];
        } else if (OPCODE_DFU_VALIDATE_FW_IMAGE == deh->ReqOpcode) {
            VALIDATE_FW_IMAGE_RESPONSE *p = (VALIDATE_FW_IMAGE_RESPONSE *) (respData);
            [self recvValidateImage:p->RspValue];
        } else if (OPCODE_DFU_BUFFER_CHK_ENABLE == deh->ReqOpcode) {
            [self recvBufChkEnable:(BUFFER_CHK_ENABLE_RSP *) (respData)];
        } else if (OPCODE_DFU_BUFFER_CHK_REQUEST == deh->ReqOpcode) {
            [self recvBufChkResult:(BUFFER_CHK_RESULT *) respData];
        }
        else if (OPCODE_DFU_OPCODE_COPY_IMG == deh->ReqOpcode) {
            COPY_DATA_RESULT *p = (COPY_DATA_RESULT *)respData;
            [self recvCopyData:p->Result];
        }
    }
}


- (void)recvImageInfo:(BOOL)bSuccess
{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
    if (bSuccess) {
        [OTADebugManager printLog:LEVEL_INFO format:@"OTA step3: oTAStartDFU"];
        [_otaCmd oTAStartDFU:_model.feature.devInfo.Aes];
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
            [_delegate imageFinishedWithStatus:ERROR_STATE_OPRERATION_FAILED];
        }
        [OTADebugManager printLog:LEVEL_INFO format:@"%s fail", __func__];
    }
}

- (void)recvStartDfu:(BOOL)bSuccess
{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
    if (bSuccess) {
        if (_model.feature.devInfo.BufferCheck) {
            [OTADebugManager printLog:LEVEL_INFO format:@"OTA step4: oTABufChkEnable"];
            [_otaCmd oTABufChkEnable];
        } else {
            [OTADebugManager printLog:LEVEL_INFO format:@"OTA step4: oTAPushImageToTarget"];
          //  _otaMode = 3;
            uint32_t offset = _dfuDataInfo.CurInfo.ImageUpdateOffset != 0 ? _dfuDataInfo.CurInfo.ImageUpdateOffset : 12;
//            if (_otaMode == 2) {
//                offset2 = 0;
//            }
            if (_model.feature.devInfo.otaVersion == 1) {
                [_otaCmd oTAReceiveFwImage:_model.file.header.imageId offset:offset];
            }
            else{
                if (IC_BEE2 ==_model.feature.devInfo.ICType) {
                    [_otaCmd oTAPushImageToTargetWithOffsetBee2:offset];
                }else{
                    BOOL bIsBand = [[NSUserDefaults standardUserDefaults]boolForKey:@"isWristBand"];
                    if (bIsBand) {
                        [_otaCmd oTAPushImageToTargetWithOffset:0];
                    }
                    else{
                        [_otaCmd oTAPushImageToTargetWithOffset:offset];
                    } 
                }
            }
    
            [self txStart];
           
        }
    }
    else
    {
        if ([_delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
            [_delegate imageFinishedWithStatus:ERROR_STATE_OPRERATION_FAILED];
        }
        [OTADebugManager printLog:LEVEL_INFO format:@"%s fail", __func__];
    }
}


- (void)txStart{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
}

- (void)txStartWithBufChk:(uint16_t)sendMtu andChkBufUnit:(uint16_t)chkBufUnit
{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
}

- (void)clear
{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
}

- (void)recvValidateImage:(uint8_t)RspValue
{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
    if (RspValue == 1) {
        if ([_delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
            NSInteger ret = [_delegate imageFinishedWithStatus:RspValue];
            if (ret == 1) {
                [OTADebugManager printLog:LEVEL_INFO format:@"OTA step6: oTAActiveAndReset，all files sent"];
                [_otaCmd oTAActiveAndReset:0];
            }
            else if (ret == 2) {
                [OTADebugManager printLog:LEVEL_INFO format:@"OTA step6: oTAActiveAndReset，> tempsize files will sent"];
                [_otaCmd oTAActiveAndReset:1];
            }
        }
    }
    else{
        if ([_delegate respondsToSelector:@selector(imageFinishedWithStatus:)]) {
            [_delegate imageFinishedWithStatus:RspValue];
        }
    }
}


- (void)recvCopyData:(uint8_t)RspValue
{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
}

- (uint16_t)getMaxTxUnitFromMtu:(uint16_t)mtu {
    uint16_t unit = 16;
    while (mtu / unit > 1) {
        unit *= 2;
    }
    return unit;
}


- (void)recvBufChkEnable:(BUFFER_CHK_ENABLE_RSP *)p
{
    _model.feature.devInfo.BufferCheck = p->Support == 1;
    if (_model.feature.devInfo.BufferCheck) {
        _model.feature.devInfo.MaxBufSize = p->MaxBufferSize;
        uint16_t _sendMtu = [self getMaxTxUnitFromMtu:p->mtu - 3];
        //                if (_bufferSize >= 256) {//不能超过256bytes
        //                    _sendUnit = 256;
        //                }
        //  _sendUnit = _sendMtu * 16 <= _bufferSize ? _sendMtu * 16 : _bufferSize;
        uint16_t _chkBufUnit = _model.feature.devInfo.MaxBufSize/_sendMtu * _sendMtu;

        // _sendUnit = 256;
        [OTADebugManager printLog:LEVEL_INFO format:@"_sendMtu=%d, _chkBufUnit=%d", _sendMtu, _chkBufUnit];
        if (_model.feature.devInfo.ICType == IC_BEE2) {
            [_otaCmd oTAPushImageToTargetWithOffsetBee2:12];
        }
        else{
            [_otaCmd oTAPushImageToTargetWithOffset:12];
        }
        
        [self txStartWithBufChk:_sendMtu andChkBufUnit:_chkBufUnit];
   //     [self oTAPushImageToTarget_BufChk:false];
    } else {

        [OTADebugManager printLog:LEVEL_INFO format:@"OTA step4: oTAPushImageToTarget"];
        [self txStart];
    }
}


- (void)recvBufChkResult:(BUFFER_CHK_RESULT *)p
{
    [OTADebugManager printLog:LEVEL_INFO format:@"%s", __func__];
}

@end
