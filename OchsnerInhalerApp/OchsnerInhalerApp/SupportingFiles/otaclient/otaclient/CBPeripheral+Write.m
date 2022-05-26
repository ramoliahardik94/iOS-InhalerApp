//
//  CBPeripheral+Write.m
//  RtkBand
//
//  Created by Tang on 2017/6/8.
//  Copyright © 2017年 Tang. All rights reserved.
//

#import "CBPeripheral+Write.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#import "OTADebugManager.h"

/**
 所有调用writeValue发送数据，增加log，使用runtime实现。
 */
@implementation CBPeripheral (Write)

+ (void)load {
    /** 获取原始writeValue方法 */
    Method originalM = class_getInstanceMethod([self class], @selector(writeValue:forCharacteristic:type:));

    /** 获取自定义的writeValue方法 */
    Method exchangeM = class_getInstanceMethod([self class], @selector(ex_writeValue:forCharacteristic:type:));

    /** 交换方法 */
    method_exchangeImplementations(originalM, exchangeM);
}

/** 自定义的方法 */
- (void)ex_writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type {
    if (characteristic == nil) {
         NSLog(@"[BLE]: %s characteristic==nil", __func__);
        return;
    }
    if (type == CBCharacteristicWriteWithResponse)
    {
        NSLog(@"[BLE]: tx REQUEST---->(%@) %lu: %@", characteristic.UUID.UUIDString, (unsigned long) data.length, data);
    }
    else{
      //  NSLog(@"[BLE]: tx COMMAND---->(%@) %lu: %@", characteristic.UUID.UUIDString, (unsigned long) data.length, data);
    }
   
    /**
     1. 此时调用的方法 'write' 相当于调用系统的 'write' 方法,原因是在load方法中进行了方法交换.
     2. 注意:此处并没有递归操作.
     */
    [self ex_writeValue:data forCharacteristic:characteristic type:type];
}

@end
