//
//  OTAFileModel.h
//  otaclient
//
//  Created by Tang on 2018/6/26.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTAConst.h"
@interface OTASubBinHeaderModel : NSObject

@property (nonatomic) uint8_t otaVersion;
@property (nonatomic) uint16_t imageId;
@property (nonatomic) uint32_t imageVersion;
@property (nonatomic) uint16_t secVersion;
@property (nonatomic) uint32_t dataLength;

@property (nonatomic) uint32_t flashAddr;
@property (nonatomic) uint16_t binID;
@end


@interface OTASubFileModel: NSObject
@property (nonatomic) uint8_t imageType;
@property (nonatomic, strong) NSString *typeString;
@property (nonatomic, strong) NSString *versionString;
@property (nonatomic, strong) OTASubBinHeaderModel *header;
@property (nonatomic, strong) NSData *data;
@end

@interface OTAFileModel : NSObject
@property (nonatomic, strong) NSMutableArray<OTASubFileModel *> *filesArray;
@property (nonatomic) BOOL bPackBin;
@property (nonatomic) OTAError fileStatus;
@end
