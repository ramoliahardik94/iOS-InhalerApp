//
//  AESFun.m
//  otaclient
//
//  Created by Tang on 2017/12/25.
//  Copyright © 2017年 Tang. All rights reserved.
//

#import "AESFun.h"
#import "AESDef.h"

@interface AESFun()
@property (nonatomic) aes_context ctx;
@end

@implementation AESFun
+ (id)shareInstance {
    static AESFun *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init{
    if ([super init]) {
        [self aesInit:3];
    }
    return self;
}

- (void)aesInit:(int)mode {
    uint8_t key[32] = {0};
    int n = mode - 1;
    memcpy(key, secret_key, 16 + n * 8);
    // aes_set_key( &ctx, key, 128 + n * 64);
    [self aes_set_key:key andBits:128 + n * 64];
 //   [self aes_set_key:&_ctx andKey:key andBits:128 + n * 64]; // aes_set_key( &ctx, key, 128 + n * 64);
}

/* AES key scheduling routine */
//int aes_set_key( aes_context *ctx, uint8_t *key, int nbits )
- (int)aes_set_key:(uint8_t *)key andBits:(int)nbits {
//- (int)aes_set_key:(aes_context *)ctx andKey:(uint8_t *)key andBits:(int)nbits {
    int i;
    uint32_t *RK, *SK;
    
    uint32_t KT0[256];
    uint32_t KT1[256];
    uint32_t KT2[256];
    uint32_t KT3[256];
    
    switch (nbits) {
        case 128:
            _ctx.nr = 10;
            break;
        case 192:
            _ctx.nr = 12;
            break;
        case 256:
            _ctx.nr = 14;
            break;
        default:
            return (1);
    }
    
    RK = _ctx.erk;
    
    for (i = 0; i < (nbits >> 5); i++) {
        GET_UINT32(RK[i], key, i * 4);
    }
    
    /* setup encryption round keys */
    
    switch (nbits) {
        case 128:
            
            for (i = 0; i < 10; i++, RK += 4) {
                RK[4] = RK[0] ^ RCON[i] ^
                (FSb[(uint8_t)(RK[3] >> 16)] << 24) ^
                (FSb[(uint8_t)(RK[3] >> 8)] << 16) ^
                (FSb[(uint8_t)(RK[3])] << 8) ^
                (FSb[(uint8_t)(RK[3] >> 24)]);
                
                RK[5] = RK[1] ^ RK[4];
                RK[6] = RK[2] ^ RK[5];
                RK[7] = RK[3] ^ RK[6];
            }
            break;
            
        case 192:
            
            for (i = 0; i < 8; i++, RK += 6) {
                RK[6] = RK[0] ^ RCON[i] ^
                (FSb[(uint8_t)(RK[5] >> 16)] << 24) ^
                (FSb[(uint8_t)(RK[5] >> 8)] << 16) ^
                (FSb[(uint8_t)(RK[5])] << 8) ^
                (FSb[(uint8_t)(RK[5] >> 24)]);
                
                RK[7] = RK[1] ^ RK[6];
                RK[8] = RK[2] ^ RK[7];
                RK[9] = RK[3] ^ RK[8];
                RK[10] = RK[4] ^ RK[9];
                RK[11] = RK[5] ^ RK[10];
            }
            break;
            
        case 256:
            
            for (i = 0; i < 7; i++, RK += 8) {
                RK[8] = RK[0] ^ RCON[i] ^
                (FSb[(uint8_t)(RK[7] >> 16)] << 24) ^
                (FSb[(uint8_t)(RK[7] >> 8)] << 16) ^
                (FSb[(uint8_t)(RK[7])] << 8) ^
                (FSb[(uint8_t)(RK[7] >> 24)]);
                
                RK[9] = RK[1] ^ RK[8];
                RK[10] = RK[2] ^ RK[9];
                RK[11] = RK[3] ^ RK[10];
                
                RK[12] = RK[4] ^
                (FSb[(uint8_t)(RK[11] >> 24)] << 24) ^
                (FSb[(uint8_t)(RK[11] >> 16)] << 16) ^
                (FSb[(uint8_t)(RK[11] >> 8)] << 8) ^
                (FSb[(uint8_t)(RK[11])]);
                
                RK[13] = RK[5] ^ RK[12];
                RK[14] = RK[6] ^ RK[13];
                RK[15] = RK[7] ^ RK[14];
            }
            break;
    }
    
    /* setup decryption round keys */
    
    for (i = 0; i < 256; i++) {
        KT0[i] = RT0[FSb[i]];
        KT1[i] = RT1[FSb[i]];
        KT2[i] = RT2[FSb[i]];
        KT3[i] = RT3[FSb[i]];
    }
    
    SK = _ctx.drk;
    
    *SK++ = *RK++;
    *SK++ = *RK++;
    *SK++ = *RK++;
    *SK++ = *RK++;
    
    for (i = 1; i < _ctx.nr; i++) {
        RK -= 8;
        
        *SK++ = KT0[(uint8_t)(*RK >> 24)] ^
        KT1[(uint8_t)(*RK >> 16)] ^
        KT2[(uint8_t)(*RK >> 8)] ^
        KT3[(uint8_t)(*RK)];
        RK++;
        
        *SK++ = KT0[(uint8_t)(*RK >> 24)] ^
        KT1[(uint8_t)(*RK >> 16)] ^
        KT2[(uint8_t)(*RK >> 8)] ^
        KT3[(uint8_t)(*RK)];
        RK++;
        
        *SK++ = KT0[(uint8_t)(*RK >> 24)] ^
        KT1[(uint8_t)(*RK >> 16)] ^
        KT2[(uint8_t)(*RK >> 8)] ^
        KT3[(uint8_t)(*RK)];
        RK++;
        
        *SK++ = KT0[(uint8_t)(*RK >> 24)] ^
        KT1[(uint8_t)(*RK >> 16)] ^
        KT2[(uint8_t)(*RK >> 8)] ^
        KT3[(uint8_t)(*RK)];
        RK++;
    }
    
    RK -= 8;
    
    *SK++ = *RK++;
    *SK++ = *RK++;
    *SK++ = *RK++;
    *SK++ = *RK++;
    
    return (0);
}

/* AES 128-bit block encryption routine */
//void aes_encrypt( aes_context *ctx, uint8_t input[16], uint8_t output[16] )
- (void)aes_encrypt:(uint8_t *)input andOutput:(uint8_t *)output {
    uint32_t *RK, X0, X1, X2, X3, Y0, Y1, Y2, Y3;
    
    RK = _ctx.erk;
    
    GET_UINT32(X0, input, 0);
    X0 ^= RK[0];
    GET_UINT32(X1, input, 4);
    X1 ^= RK[1];
    GET_UINT32(X2, input, 8);
    X2 ^= RK[2];
    GET_UINT32(X3, input, 12);
    X3 ^= RK[3];
    
#define AES_FROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3) \
{                                              \
RK += 4;                                   \
\
X0 = RK[0] ^ FT0[(uint8_t)(Y0 >> 24)] ^    \
FT1[(uint8_t)(Y1 >> 16)] ^            \
FT2[(uint8_t)(Y2 >> 8)] ^             \
FT3[(uint8_t)(Y3)];                   \
\
X1 = RK[1] ^ FT0[(uint8_t)(Y1 >> 24)] ^    \
FT1[(uint8_t)(Y2 >> 16)] ^            \
FT2[(uint8_t)(Y3 >> 8)] ^             \
FT3[(uint8_t)(Y0)];                   \
\
X2 = RK[2] ^ FT0[(uint8_t)(Y2 >> 24)] ^    \
FT1[(uint8_t)(Y3 >> 16)] ^            \
FT2[(uint8_t)(Y0 >> 8)] ^             \
FT3[(uint8_t)(Y1)];                   \
\
X3 = RK[3] ^ FT0[(uint8_t)(Y3 >> 24)] ^    \
FT1[(uint8_t)(Y0 >> 16)] ^            \
FT2[(uint8_t)(Y1 >> 8)] ^             \
FT3[(uint8_t)(Y2)];                   \
}
    
    AES_FROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 1 */
    AES_FROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3); /* round 2 */
    AES_FROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 3 */
    AES_FROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3); /* round 4 */
    AES_FROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 5 */
    AES_FROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3); /* round 6 */
    AES_FROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 7 */
    AES_FROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3); /* round 8 */
    AES_FROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 9 */
    
    if (_ctx.nr > 10) {
        AES_FROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3); /* round 10 */
        AES_FROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 11 */
    }
    
    if (_ctx.nr > 12) {
        AES_FROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3); /* round 12 */
        AES_FROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 13 */
    }
    
    /* last round */
    
    RK += 4;
    
    X0 = RK[0] ^ (FSb[(uint8_t)(Y0 >> 24)] << 24) ^
    (FSb[(uint8_t)(Y1 >> 16)] << 16) ^
    (FSb[(uint8_t)(Y2 >> 8)] << 8) ^
    (FSb[(uint8_t)(Y3)]);
    
    X1 = RK[1] ^ (FSb[(uint8_t)(Y1 >> 24)] << 24) ^
    (FSb[(uint8_t)(Y2 >> 16)] << 16) ^
    (FSb[(uint8_t)(Y3 >> 8)] << 8) ^
    (FSb[(uint8_t)(Y0)]);
    
    X2 = RK[2] ^ (FSb[(uint8_t)(Y2 >> 24)] << 24) ^
    (FSb[(uint8_t)(Y3 >> 16)] << 16) ^
    (FSb[(uint8_t)(Y0 >> 8)] << 8) ^
    (FSb[(uint8_t)(Y1)]);
    
    X3 = RK[3] ^ (FSb[(uint8_t)(Y3 >> 24)] << 24) ^
    (FSb[(uint8_t)(Y0 >> 16)] << 16) ^
    (FSb[(uint8_t)(Y1 >> 8)] << 8) ^
    (FSb[(uint8_t)(Y2)]);
    
    PUT_UINT32(X0, output, 0);
    PUT_UINT32(X1, output, 4);
    PUT_UINT32(X2, output, 8);
    PUT_UINT32(X3, output, 12);
}

/* AES 128-bit block decryption routine */
//void aes_decrypt( aes_context *ctx, uint8_t input[16], uint8_t output[16] )
- (void)aes_decrypt:(uint8_t *)input andOutput:(uint8_t *)output {
    uint32_t *RK, X0, X1, X2, X3, Y0, Y1, Y2, Y3;
    
    RK = _ctx.drk;
    
    GET_UINT32(X0, input, 0);
    X0 ^= RK[0];
    GET_UINT32(X1, input, 4);
    X1 ^= RK[1];
    GET_UINT32(X2, input, 8);
    X2 ^= RK[2];
    GET_UINT32(X3, input, 12);
    X3 ^= RK[3];
    
#define AES_RROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3) \
{                                              \
RK += 4;                                   \
\
X0 = RK[0] ^ RT0[(uint8_t)(Y0 >> 24)] ^    \
RT1[(uint8_t)(Y3 >> 16)] ^            \
RT2[(uint8_t)(Y2 >> 8)] ^             \
RT3[(uint8_t)(Y1)];                   \
\
X1 = RK[1] ^ RT0[(uint8_t)(Y1 >> 24)] ^    \
RT1[(uint8_t)(Y0 >> 16)] ^            \
RT2[(uint8_t)(Y3 >> 8)] ^             \
RT3[(uint8_t)(Y2)];                   \
\
X2 = RK[2] ^ RT0[(uint8_t)(Y2 >> 24)] ^    \
RT1[(uint8_t)(Y1 >> 16)] ^            \
RT2[(uint8_t)(Y0 >> 8)] ^             \
RT3[(uint8_t)(Y3)];                   \
\
X3 = RK[3] ^ RT0[(uint8_t)(Y3 >> 24)] ^    \
RT1[(uint8_t)(Y2 >> 16)] ^            \
RT2[(uint8_t)(Y1 >> 8)] ^             \
RT3[(uint8_t)(Y0)];                   \
}
    
    AES_RROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 1 */
    AES_RROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3); /* round 2 */
    AES_RROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 3 */
    AES_RROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3); /* round 4 */
    AES_RROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 5 */
    AES_RROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3); /* round 6 */
    AES_RROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 7 */
    AES_RROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3); /* round 8 */
    AES_RROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 9 */
    
    if (_ctx.nr > 10) {
        AES_RROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3); /* round 10 */
        AES_RROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 11 */
    }
    
    if (_ctx.nr > 12) {
        AES_RROUND(X0, X1, X2, X3, Y0, Y1, Y2, Y3); /* round 12 */
        AES_RROUND(Y0, Y1, Y2, Y3, X0, X1, X2, X3); /* round 13 */
    }
    
    /* last round */
    
    RK += 4;
    
    X0 = RK[0] ^ (RSb[(uint8_t)(Y0 >> 24)] << 24) ^
    (RSb[(uint8_t)(Y3 >> 16)] << 16) ^
    (RSb[(uint8_t)(Y2 >> 8)] << 8) ^
    (RSb[(uint8_t)(Y1)]);
    
    X1 = RK[1] ^ (RSb[(uint8_t)(Y1 >> 24)] << 24) ^
    (RSb[(uint8_t)(Y0 >> 16)] << 16) ^
    (RSb[(uint8_t)(Y3 >> 8)] << 8) ^
    (RSb[(uint8_t)(Y2)]);
    
    X2 = RK[2] ^ (RSb[(uint8_t)(Y2 >> 24)] << 24) ^
    (RSb[(uint8_t)(Y1 >> 16)] << 16) ^
    (RSb[(uint8_t)(Y0 >> 8)] << 8) ^
    (RSb[(uint8_t)(Y3)]);
    
    X3 = RK[3] ^ (RSb[(uint8_t)(Y3 >> 24)] << 24) ^
    (RSb[(uint8_t)(Y2 >> 16)] << 16) ^
    (RSb[(uint8_t)(Y1 >> 8)] << 8) ^
    (RSb[(uint8_t)(Y0)]);
    
    PUT_UINT32(X0, output, 0);
    PUT_UINT32(X1, output, 4);
    PUT_UINT32(X2, output, 8);
    PUT_UINT32(X3, output, 12);
}
@end
