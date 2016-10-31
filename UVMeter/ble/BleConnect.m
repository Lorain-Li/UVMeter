//
//  BleConnect.m
//  Pedometer
//
//  Created by jinou on 16/9/19.
//  Copyright © 2016年 com.jinou.Pedometer. All rights reserved.
//
#if 0
#import "BleConnect.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_UUID_FOR_ANTILOSS                @"1802"

#define SERVICE_UUID_FOR_PEDOMETER               @"B370"
#define CHARACTERISTIC_UUID_FOR_ANTILOSS         @"2A06"
#define CHARACTERISTIC_UUID_FOR_PEDOMETER_NOTIFY @"B371"

#define CHARACTERISTIC_UUID_FOR_PEDOMETER_WRITE  @"B372"
#define INQURY_TIMEOUT  5.0
#define CONNECT_TIMEOUT 3.0

#define AntiLost_alarmPhone                     @"xxxxxxx"

const static Byte  byte1[4] = {0x55,0xaa,0x07,0x00};

const static Byte  byte2[4] = {0x55,0xaa,0x08,0x00};

@interface BleConnect()<CBCentralManagerDelegate,CBPeripheralDelegate>

{
    BleCmdType _cmdtype;
    BleErrorType _errortype;
    BOOL _isinqurying;
    BOOL _getList;
}

@property(strong, nonatomic)CBCentralManager *central;
@property(strong, nonatomic)CBPeripheral *peripheral;
@property(strong, nonatomic)NSData *mac;
@property(strong, nonatomic)NSTimer *inqurytimer;
@property(strong, nonatomic)NSTimer *connecttimer;
@property(strong, nonatomic)CBCharacteristic *writecharacteristic_pedo;
@property(strong, nonatomic)CBCharacteristic *writecharacteristic_antiloss;
@property(assign, nonatomic)BOOL didStartDistanceUpdate;
@property(assign, nonatomic)BOOL distanceUpdateLock;

@end

@implementation BleConnect

-(instancetype)initWithDelegate:(id<BleDelegate>)delegate
{
    self = [super init];
    self.delegate = delegate;
    self.central = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey:@"0"}];
    _cmdtype = System_Notification;
    _errortype = BleErrorTypeNone;
    _isinqurying = NO;
    self.didconnected = NO;
    _getList = NO;
    self.didStartDistanceUpdate = NO;
    self.distanceUpdateLock = NO;
    self.distance = 0.0;
    return self;
}

-(BleErrorType)getDeviceList
{
    return [self connectRequest:nil];
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            //NSLog(@"CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
            //NSLog(@"CBCentralManagerStatePoweredOn");
            break;
        default:
            break;
    }
}

-(BleErrorType)connectRequest:(NSData*)mac
{
    if (self.central.state != CBCentralManagerStatePoweredOn)
    {
        return BleErrorTypePoweroff;
    }
    if (self.didconnected)
    {
        return BleErrorTypeHasConnection;
    }
    if (_isinqurying)
    {
        return BleErrorTypeNone;
    }else
    {
        self.mac = mac;
        
        if (mac)
        {
            _getList = NO;
        }else
        {
            _getList = YES;
        }
        
        //开始搜索蓝牙
        NSArray *uuidArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:SERVICE_UUID_FOR_PEDOMETER], nil];
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.central scanForPeripheralsWithServices:uuidArray options:options];
        });
        
        _isinqurying = YES;
        self.inqurytimer = [NSTimer scheduledTimerWithTimeInterval:INQURY_TIMEOUT target:self selector:@selector(cancelInqury)userInfo:nil repeats:NO];
    }
    return BleErrorTypeNone;
}

-(void)cancelInqury
{
    [self.central stopScan];
    if (!_getList && self.inqurytimer != nil)
    {
        [self.inqurytimer invalidate];
        self.inqurytimer = nil;
        [self.delegate didconnectedSuccess:NO];
    }
    _isinqurying = NO;
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSData *macaddr = advertisementData[CBAdvertisementDataManufacturerDataKey];
    NSString *name = advertisementData[CBAdvertisementDataLocalNameKey];
    if (_getList)
    {
        [self.delegate didDiscoverDevice:@{@"mac":macaddr,@"name":name}];
        return;
    }
    //比较mac
    if (![macaddr isEqualToData:self.mac])
    {
        return;
    }
    self.peripheral = peripheral;
    [self.peripheral setDelegate:self];
    [self.inqurytimer invalidate];
    self.inqurytimer = nil;
    [self cancelInqury];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.central connectPeripheral:self.peripheral options:nil];
    });
    
    self.connecttimer = [NSTimer scheduledTimerWithTimeInterval:CONNECT_TIMEOUT target:self selector:@selector(cancelConnect)userInfo:nil repeats:NO];
}


-(void)cancelConnect
{
    if (self.peripheral == nil)
    {
        [self.delegate didDisconnected];
        return;
    }
    [self.central cancelPeripheralConnection:self.peripheral];
}

/*********************连接回调**********************/

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    NSArray *uuidArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:SERVICE_UUID_FOR_PEDOMETER],[CBUUID UUIDWithString:SERVICE_UUID_FOR_ANTILOSS],nil];
    [self.peripheral discoverServices:uuidArray];
}

/*********************断开回调**********************/

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self.delegate didDisconnected];
    self.peripheral = nil;
    self.didconnected = NO;
}

/*********************连接失败回调**********************/

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self.connecttimer invalidate];
    self.connecttimer = nil;
    
    [self.delegate didconnectedSuccess:NO];
    self.peripheral = nil;
    self.didconnected = NO;
}

/*********************搜索服务成功回调**********************/

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    if (!error)
    {
        for (CBService *service in peripheral.services)
        {
            if ([service.UUID.UUIDString isEqualToString:SERVICE_UUID_FOR_PEDOMETER])
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self.peripheral discoverCharacteristics:nil forService:service];
                });
                
            }
            if ([service.UUID.UUIDString isEqualToString:SERVICE_UUID_FOR_ANTILOSS])
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self.peripheral discoverCharacteristics:nil forService:service];
                });
                
            }
            
        }
    }else
    {
        //断开连接
        self.didconnected = NO;
        [self.central cancelPeripheralConnection:peripheral];
    }
}

/*********************搜索特征值成功回调**********************/

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (!error)
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            if ([characteristic.UUID.UUIDString isEqualToString:CHARACTERISTIC_UUID_FOR_PEDOMETER_NOTIFY])
            {
                if (characteristic.properties & CBCharacteristicPropertyNotify)
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
            if ([characteristic.UUID.UUIDString isEqualToString:CHARACTERISTIC_UUID_FOR_PEDOMETER_WRITE])
            {
                self.writecharacteristic_pedo = characteristic;
                
            }
            if ([characteristic.UUID.UUIDString isEqualToString:CHARACTERISTIC_UUID_FOR_ANTILOSS])
            {
                self.writecharacteristic_antiloss = characteristic;
                [self.delegate didconnectedSuccess:YES];
                self.didconnected = YES;
                [self.connecttimer invalidate];
                self.connecttimer = nil;
            }
            
        }
        
    }else
    {
        //断开连接
        self.didconnected = NO;
        [self.central cancelPeripheralConnection:peripheral];
        
    }
}

/*********************didUpdateValue回调**********************/

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error)
    {
        NSData *telphone = [NSData dataWithBytes:byte1 length:4];
        NSData *photo = [NSData dataWithBytes:byte2 length:4];
        if ([characteristic.value isEqualToData:telphone])
        {
            if ([NSUserDefaults objectForKey:AntiLost_alarmPhone] == nil)
            {
                return;
            }
            if ([[NSUserDefaults objectForKey:AntiLost_alarmPhone] isEqualToString:@""])
            {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
            
                NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",[NSUserDefaults objectForKey:AntiLost_alarmPhone]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            });
            
            return;
        }
        if ([characteristic.value isEqualToData:photo])
        {
            [self.delegate didRecieveTakePhotoEvent];
            return;
        }
        
        [self.delegate didRecieveData:characteristic.value];
        
    }
    
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error)
    {
        [self.delegate didSendDataSuccess:YES];
    }else
    {
        [self.delegate didSendDataSuccess:NO];
    }
}

-(BleErrorType)sendDataToPerWithcmdType:(BleCmdType)type
{
    if (!self.didconnected) {
        return BleErrorTypeSendDataFail;
    }
    if (self.writecharacteristic_pedo == nil || self.writecharacteristic_antiloss == nil)
    {
        return BleErrorTypeSendDataFail;
    }
    NSData *data = [NSData data];
    switch (type) {
        case BleCmdType_Pedo_Start:
        {
            Byte byte[4] = {0x55,0xAA,0x00,0x00};
            data = [NSData dataWithBytes:byte length:4];
            [self.peripheral writeValue:data forCharacteristic:self.writecharacteristic_pedo type:CBCharacteristicWriteWithResponse];
        }
            break;
            
            
        case BleCmdType_Pedo_Stop:
        {
            Byte byte[4] = {0x55,0xAA,0x02,0x00};
            data = [NSData dataWithBytes:byte length:4];
            [self.peripheral writeValue:data forCharacteristic:self.writecharacteristic_pedo type:CBCharacteristicWriteWithResponse];
        }
            break;
            
        case BleCmdType_Pedo_Inqury:
        {
            Byte byte[4] = {0x55,0xAA,0x03,0x00};
            data = [NSData dataWithBytes:byte length:4];
            [self.peripheral writeValue:data forCharacteristic:self.writecharacteristic_pedo type:CBCharacteristicWriteWithResponse];
        }
            break;
            
        case BleCmdType_Pedo_Clear:
        {
            Byte byte[4] = {0x55,0xAA,0x04,0x00};
            data = [NSData dataWithBytes:byte length:4];
            [self.peripheral writeValue:data forCharacteristic:self.writecharacteristic_pedo type:CBCharacteristicWriteWithResponse];
        }
            break;
            
        case System_Notification:
        {
            
        }
            break;
            
        case BleCmdType_AntiLoss_Alert_Clear:
        {
            NSLog(@"clear alert");
            Byte byte[1] = {0x00};
            data = [NSData dataWithBytes:byte length:1];
            [self.peripheral writeValue:data forCharacteristic:self.writecharacteristic_antiloss type:CBCharacteristicWriteWithoutResponse];
        }
            break;
        case BleCmdType_AntiLoss_Alert_Normal:
        {
            Byte byte[1] = {0x01};
            data = [NSData dataWithBytes:byte length:1];
            [self.peripheral writeValue:data forCharacteristic:self.writecharacteristic_antiloss type:CBCharacteristicWriteWithoutResponse];
        }
            break;
        case BleCmdType_AntiLoss_Alert_Rapid:
        {
            NSLog(@"start alert");
            Byte byte[1] = {0x02};
            data = [NSData dataWithBytes:byte length:1];
            [self.peripheral writeValue:data forCharacteristic:self.writecharacteristic_antiloss type:CBCharacteristicWriteWithoutResponse];
        }
            break;
        default:
            break;
    }
    return BleErrorTypeNone;
}

-(BleErrorType)getDistance
{
    if (self.peripheral == nil)
    {
        return BleErrorTypePoweroff;
    }
    if (self.didStartDistanceUpdate)
    {
        return BleErrorTypeNone;
    }
    self.didStartDistanceUpdate = YES;
    self.distanceUpdateLock = NO;
    [self.peripheral readRSSI];
    return BleErrorTypeNone;
}

-(BleErrorType)stoppdateDistance
{
    self.distanceUpdateLock = YES;
    self.didStartDistanceUpdate = NO;
    return BleErrorTypeNone;
}

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    if (!error)
    {
        
        self.distance = [self rssiToDistance:RSSI];
        if (self.distanceUpdateLock)
        {
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.peripheral readRSSI];
        });
    }
}

//根据信号估算距离
-(CGFloat) rssiToDistance:(NSNumber *)RSSI
{
    NSLog(@"%@",RSSI);
    int rssi = abs([RSSI intValue]);
    CGFloat ci = (rssi - 70) / (10 * 4.0);
    
    return pow(10, ci);
}

@end

#endif
