//
//  AESFun.h
//  otaclient
//
//  Created by Tang on 2017/12/25.
//  Copyright © 2017年 Tang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AESFun : NSObject
+ (id)shareInstance;
- (void)aesInit:(int)mode;
- (int)aes_set_key:(uint8_t *)key andBits:(int)nbits;
- (void)aes_encrypt:(uint8_t *)input andOutput:(uint8_t *)output;
@end
