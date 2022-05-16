//
//  CoreBle.m
//  otaclient
//
//  Created by Tang on 2018/6/21.
//  Copyright © 2018年 Tang. All rights reserved.
//

#import "CoreBle.h"

//#define NSLog(format, ...)

@interface RTKCharacteristicNotifyEnableWait : NSObject
@property (nonatomic, readonly) NSUUID *peripheralID;
@property (nonatomic, readonly) CBUUID *serviceID;
@property (nonatomic, readonly) CBUUID *characteristicID;

- (instancetype)initWithPeripheral:(NSUUID*)peripheralID service:(CBUUID *)serviceID characteristic:(CBUUID *)characteristicID;
@end

@implementation RTKCharacteristicNotifyEnableWait

- (instancetype)initWithPeripheral:(NSUUID*)peripheralID service:(CBUUID *)serviceID characteristic:(CBUUID *)characteristicID {
    if (self = [super init]) {
        _peripheralID = [peripheralID copy];
        _serviceID = [serviceID copy];
        _characteristicID = [characteristicID copy];
    }
    return self;
}

@end

@interface CoreBle () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) NSMutableArray *devArray;
@property (nonatomic, strong) CBPeripheral *bridge;
@property (nonatomic, strong) CBPeripheral *noBridge;
@property (nonatomic, strong) void (^searchBlock)(CBPeripheral *device, NSDictionary *dic, NSNumber *rssi);
@property (nonatomic, strong) void (^connectBlock)(CBPeripheral *device);
@property (nonatomic, strong) void (^rxBlock)(CBCharacteristic *ch);
@property (nonatomic, strong) void (^stateChangeBlock)(BOOL bOn);
@end
@implementation CoreBle {
    NSMutableArray <RTKCharacteristicNotifyEnableWait*> *_waits;
    
    CBPeripheral *_discoveringPeripheral;
    NSMutableDictionary <CBPeripheral*, NSMutableArray<CBService*> *> *_discoverTasks;
    NSMutableDictionary <CBPeripheral*, NSMutableArray<CBCharacteristic*> *> *_initReadTasks;
    void (^_readyHandle)(BOOL);
}


+ (id)getShareInstance {
    static CoreBle *instance = nil;
    if (instance == nil) {
        instance = [[super allocWithZone:nil] init]; //super 调用allocWithZone
    }
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        dispatch_queue_t queue = dispatch_queue_create("central.queue", DISPATCH_QUEUE_SERIAL);
//        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:@{ CBCentralManagerOptionShowPowerAlertKey:@YES, CBCentralManagerOptionRestoreIdentifierKey:@"com.realtek.centralManager"}];
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:nil];
        _devArray = [[NSMutableArray alloc] init];
        
        _waits = [NSMutableArray arrayWithCapacity:12];
        _discoverTasks = [NSMutableDictionary dictionaryWithCapacity:12];
        _initReadTasks = [NSMutableDictionary dictionaryWithCapacity:12];
    }
    return self;
}

/**
 @brief Get Bluetooth state
 
 @return manager.state Bluetooth's State
 */
- (CBManagerState)bleGetBtState {
    return _manager.state;
}

- (void)setLocalStateChangeBlock:(void (^)(BOOL bOn))block
{
    _stateChangeBlock = block;
}

- (void)setConnChangeBlock:(void (^)(CBPeripheral *device))block
{
    _connectBlock = block;
}

- (void)setRxBlock:(void (^)(CBCharacteristic *ch))block
{
    _rxBlock = block;
}

/**
 
 @brief search ble devices
 @param serviceUUIDs  scan devices which contains service uuid
 */

- (void)bleSearchDevice:(NSArray *)serviceUUIDs block:(void (^)(CBPeripheral *device, NSDictionary *dic, NSNumber *rssi))block
{
    NSLog(@"[BLE]: %s %@", __func__, serviceUUIDs);
    [_devArray removeAllObjects];
    _searchBlock = block;
    if (serviceUUIDs) {
        NSArray<CBPeripheral *> *arry = [_manager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
        for (CBPeripheral *peripheral in arry) {
            if (_searchBlock) {
                _searchBlock(peripheral, nil, nil);
            }
            
        }
        
    }
    [_manager scanForPeripheralsWithServices:serviceUUIDs options:nil]; ////@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

/// stop search
- (void)bleStopSearchDevice {
    [_manager stopScan];
    // delegate.updateDevices(deviceArry)
    //  delegate.updateDevices(advDeviceArry)
}

//- (void)ConnectTimeout:(NSTimer *)timer {
//    // NSLog(@"device count1=%d", _nDevices.count);
//    CBPeripheral *per = timer.userInfo;
//    if (per.state != CBPeripheralStateConnected) {
//        [self bleDisconnectDevice:per];
//    }
//}

- (void)connectTimeout:(CBPeripheral *)peripheral{
    //   [manager cancelPeripheralConnection:peripheral];
    if (_connectBlock) {
        _connectBlock(false);
    }
    
    NSLog(@"[BLE]: connect timer out");
}

/**
 connect device
 
 @param peripheral device to connect
 */
- (void)bleConnectDevice:(CBPeripheral *)peripheral{
    NSLog(@"[BLE]: %s %@", __func__, peripheral);
    if (_bridge && _bridge.state == CBPeripheralStateConnected && _bridge != peripheral) {
        [_manager cancelPeripheralConnection:_bridge];
    }
    [_manager connectPeripheral:peripheral options:nil];
    //    connTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(ConnectTimeout:) userInfo:peripheral repeats:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(connectTimeout:) withObject:peripheral afterDelay: 15];
    });
}

- (void)bleConnectNoBridgeDevice:(CBPeripheral *)peripheral
{
    _noBridge = peripheral;
    [_manager connectPeripheral:peripheral options:nil];
    //    connTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(ConnectTimeout:) userInfo:peripheral repeats:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(connectTimeout:) withObject:peripheral afterDelay: 15];
    });
}

- (void)bleDisconnectDevice:(CBPeripheral *)peripheral {
    NSLog(@"[BLE]: %s %@", __func__, peripheral);
    [_manager cancelPeripheralConnection:peripheral];
}

- (CBPeripheral *)bleGetBridge {
    return _bridge;
}

- (CBPeripheral *)bleGetPeripheralFromUUID:(NSString *)uuid
{
    NSArray *array = [_manager retrievePeripheralsWithIdentifiers:@[[[NSUUID alloc]initWithUUIDString:uuid]]];
    if (array.count > 0) {
        return array.firstObject;
    }
    
    return nil;
}

- (void)bleGetCharForService:(CBPeripheral *)peripheral service:(CBService *)service {
    [peripheral discoverCharacteristics:nil forService:service];
}

- (void)bleReadCharValue:(CBPeripheral *)peripheral char:(CBCharacteristic *)characteristic {
    [peripheral readValueForCharacteristic:characteristic];
}

- (void)bleSetNotifyValue:(CBPeripheral *)peripheral char:(CBCharacteristic *)characteristic enabled:(BOOL)e {
    [peripheral setNotifyValue:e forCharacteristic:characteristic];
}

- (void)bleWriteValueForChar:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral data:(NSData *)data type:(CBCharacteristicWriteType)type {
    if (!characteristic || !peripheral) {
        return;
    }
    NSLog(@"[DEBUG]peripheral write to Characteristic[%@] with value[%@] ", characteristic.UUID.UUIDString, data);
    [peripheral writeValue:data forCharacteristic:characteristic type:type];
}

- (void)bleWriteValueToPeripheral:(CBPeripheral *)peripheral serviceUuidString:(NSString *)serviceUuidString charUuidString:(NSString *)charUuidString data:(NSData *)data type:(CBCharacteristicWriteType)type {
    CBCharacteristic *characteristic = [self getCharFromPeripheral:peripheral serviceUuidString:serviceUuidString charUuidString:charUuidString];
    if (characteristic) {
        NSLog(@"[DEBUG]peripheral write to Characteristic[%@] with value[%@] ", characteristic.UUID.UUIDString, data);
        [peripheral writeValue:data forCharacteristic:characteristic type:type];
    } else {
        NSLog(@"characteristic=null");
    }
}

- (BOOL)bleSetNotifyValue:(BOOL)value peripheral:(CBPeripheral *)peripheral serviceUuidString:(NSString *)serviceUuidString charUuidString:(NSString *)charUuidString
{
    NSLog(@"[BLE]: %s %@", __func__, peripheral);
    CBCharacteristic *characteristic = [self getCharFromPeripheral:peripheral serviceUuidString:serviceUuidString charUuidString:charUuidString];
    if (characteristic) {
        if (characteristic.properties & CBCharacteristicPropertyNotify) {
            NSLog(@"[BLE]: 准备打开%@的Notify", characteristic);
            [peripheral setNotifyValue:value forCharacteristic:characteristic];
            return true;
        } else
            NSLog(@"[BLE]: 打开%@的Notify失败, characteristic不支持Notify", characteristic);
    } else {
        NSLog(@"[BLE]: Characteristic[%@]没有discovered，加入到等候队伍中", charUuidString);
        
        [self enqueueWaitForPeripheral:peripheral.identifier service:[CBUUID UUIDWithString:serviceUuidString] characteristic:[CBUUID UUIDWithString:charUuidString]];
    }
    return false;
}


- (BOOL)isReadyOfPeripheral:(CBPeripheral *)peripheral {
    if (peripheral.state == CBPeripheralStateConnected) {
        NSMutableArray *discoveringServices = _discoverTasks[peripheral];
        NSMutableArray *readingCharacteristics = _initReadTasks[peripheral];
        return !_discoveringPeripheral && (discoveringServices.count == 0) && (readingCharacteristics.count == 0);
    }
    return NO;
}

- (void)waitForReadyOfPeripheral:(CBPeripheral *)peripheral completion:(void(^)(BOOL))handle {
    _readyHandle = [handle copy];
}

#pragma mark -
/* characteristic等待discovered后的Notification set */
- (RTKCharacteristicNotifyEnableWait *)cachedWaitWithPeripheral:(NSUUID *)peripheralID service:(CBUUID *)serviceID characteristic:(CBUUID *)characteristicID {
    RTKCharacteristicNotifyEnableWait *foundWait;
    for (RTKCharacteristicNotifyEnableWait *wait in _waits) {
        if ([wait.peripheralID isEqual:peripheralID] &&
            [wait.serviceID isEqual:serviceID] &&
            [wait.characteristicID isEqual:characteristicID]) {
            foundWait = wait;
            break;
        }
    }
    return foundWait;
}

- (void)enqueueWaitForPeripheral:(NSUUID *)peripheralID service:(CBUUID *)serviceID characteristic:(CBUUID *)characteristicID {
    if (![self cachedWaitWithPeripheral:peripheralID service:serviceID characteristic:characteristicID]) {
        [_waits addObject: [[RTKCharacteristicNotifyEnableWait alloc] initWithPeripheral:peripheralID service:serviceID characteristic:characteristicID]];
    }
}

- (void)inspectNewDiscoveredCharacteristic:(CBCharacteristic *)characteristic {
    RTKCharacteristicNotifyEnableWait *cachedWait = [self cachedWaitWithPeripheral:characteristic.service.peripheral.identifier service:characteristic.service.UUID characteristic:characteristic.UUID];
    
    if (cachedWait && characteristic.properties & CBCharacteristicPropertyNotify) {
        [characteristic.service.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        [_waits removeObject:cachedWait];
    }
}

- (void)removeWaitOfPeripheral:(NSUUID *)peripheralID {
    NSMutableArray *waitsForPeriphral = [NSMutableArray arrayWithCapacity:12];
    for (RTKCharacteristicNotifyEnableWait *wait in _waits) {
        if ([wait.peripheralID isEqual:peripheralID]) {
            [waitsForPeriphral addObject:wait];
            break;
        }
    }
    [_waits removeObjectsInArray:waitsForPeriphral];
}

#pragma mark -
- (BOOL)bleGetCharValue:(BOOL)value peripheral:(CBPeripheral *)peripheral serviceUuidString:(NSString *)serviceUuidString charUuidString:(NSString *)charUuidString
{
    NSLog(@"[BLE]: %s %@", __func__, peripheral);
    CBCharacteristic *characteristic = [self getCharFromPeripheral:peripheral serviceUuidString:serviceUuidString charUuidString:charUuidString];
    if ((characteristic)) {
        if (characteristic.properties & CBCharacteristicPropertyRead) {
            [peripheral readValueForCharacteristic:characteristic];
            return true;
        }
    }
    return false;
}

- (CBCharacteristic *)getCharFromPeripheral:(CBPeripheral *)peripheral serviceUuidString:(NSString *)serviceUuidString charUuidString:(NSString *)charUuidString {
    if (peripheral.services) {
        
        for (CBService *service in peripheral.services) {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:serviceUuidString]]) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:charUuidString]]) {
                        
                        return characteristic;
                    }
                }
            }
        }
    }
    return nil;
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    NSLog(@"central manager will restore state: %@", dict);
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    if (peripherals && peripherals.count > 0)
        _bridge = peripherals.firstObject;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"[BLE]: bt Powered off");
           
            _bridge = nil;
            if (_stateChangeBlock) {
                _stateChangeBlock(false);
            }
            
            break;
            
        case CBCentralManagerStatePoweredOn:
            NSLog(@"[BLE]: bt Powered oN");

            if (_stateChangeBlock) {
                _stateChangeBlock(true);
            }
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (_searchBlock) {
        _searchBlock(peripheral, advertisementData, RSSI);
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"[BLE]: connected to %@", peripheral.name);
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectTimeout:) object:peripheral];
    });
    
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    _discoveringPeripheral = peripheral;
    
    [self bleStopSearchDevice];
   
    if (peripheral != _noBridge) {
        _bridge = peripheral;
    }
    
  
    __weak typeof(self) weakSelf = self;
    // FIXME: 连上后等待2s，造成连接状态的刷新较实际延迟，可能导致状态不一致问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.connectBlock) {
            weakSelf.connectBlock(peripheral);
        }
    });
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"[BLE]: disconnected to %@ (%@)", peripheral.name, error);
    if (_bridge == peripheral) {
        _bridge = nil;
    }
    
    [self removeWaitOfPeripheral:peripheral.identifier];
    
    // FIXME: 下面的操作依赖于只连接一个外设的情况下，不适用于多个外设的连接
    if ((_discoveringPeripheral || _initReadTasks.count > 0 || _discoverTasks.count > 0) && _readyHandle) {
        _discoveringPeripheral = nil;
        [_discoverTasks removeAllObjects];
        [_initReadTasks removeAllObjects];
        _readyHandle(NO);
    }
    
    
    if (_connectBlock) {
        _connectBlock(peripheral);
    }
    
    /* 对于非主动断开的连接，进行重新连接 */
    // 这里仅对错误为nil来判断是否为意外断开，需进一步确认
    // TODO: 注意是否会造成"断开->再连接"的往复循环
    /*
     BBpro 关机后的error: (Error Domain=CBErrorDomain Code=6 "The connection has timed out unexpectedly." UserInfo={NSLocalizedDescription=The connection has timed out unexpectedly.})
     iPhone关闭BREDR连接后， (Error Domain=CBErrorDomain Code=7 "The specified device has disconnected from us." UserInfo={NSLocalizedDescription=The specified device has disconnected from us.})
     */
    /*
    if ([error.domain isEqualToString:CBErrorDomain] && error.code == 6) {
        NSLog(@"[DEBUG]LE连接意外断开，重新连接");
        [central connectPeripheral:peripheral options:nil];
    }
     */
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    if (_discoveringPeripheral == peripheral)
        _discoveringPeripheral = nil;
    
    if (peripheral.services) {
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
        
        NSMutableArray *services = _discoverTasks[peripheral];
        if (services) {
            [services addObjectsFromArray:peripheral.services];
        } else {
            _discoverTasks[peripheral] = [NSMutableArray arrayWithArray:peripheral.services];
        }
    } else {
        if (_readyHandle && !_discoveringPeripheral)
            _readyHandle(YES);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    NSLog(@"[BLE]: find characteristics:%@ of %@", service.characteristics, service);
    
    NSMutableArray *discoveringServices = _discoverTasks[peripheral];
    NSMutableArray *readingCharacteristics = _initReadTasks[peripheral];
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        [self inspectNewDiscoveredCharacteristic:characteristic];
        
        if (characteristic.properties & CBCharacteristicPropertyRead) {
             NSLog(@"read value of %@", characteristic.UUID);
            [peripheral readValueForCharacteristic:characteristic];
            
            if (!readingCharacteristics) {
                readingCharacteristics = [NSMutableArray arrayWithCapacity:12];
                _initReadTasks[peripheral] = readingCharacteristics;
            }
            [readingCharacteristics addObject:characteristic];
        }
    }
    
    if (discoveringServices)
        [discoveringServices removeObject:service];
    
    if (!_discoveringPeripheral && discoveringServices.count == 0 && readingCharacteristics.count == 0 && _readyHandle) {
        _readyHandle(YES);
        _readyHandle = nil;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"[BLE]notification state updated: %@", characteristic);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"[BLE]: rx<--- %@ - %@", characteristic.UUID.UUIDString, characteristic.value);
    
    NSMutableArray *discoveringServices = _discoverTasks[peripheral];
    NSMutableArray *readingCharacteristics = _initReadTasks[peripheral];
    if (readingCharacteristics) {
        [readingCharacteristics removeObject:characteristic];
    
        if (!_discoveringPeripheral && discoveringServices.count == 0 && readingCharacteristics.count == 0 && _readyHandle) {
            _readyHandle(YES);
            _readyHandle = nil;
        }
    }

    
    if (_rxBlock) {
        _rxBlock(characteristic);
    }  
}
@end
