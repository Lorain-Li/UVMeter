//
//  Bluetooth.m
//  EasyBLUE
//
//  Created by Lorain on 2016/11/10.
//  Copyright © 2016年 LorainLynies. All rights reserved.
//

#import "Bluetooth.h"

@implementation Bluetooth
- (instancetype) initWithDelegate:(id<BluetoothDelegate>)delegate
{
    self = [super init];
    self.delegate = delegate;
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.bluelist = [[NSMutableArray alloc] init];
    self.advlist = [[NSMutableArray alloc] init];
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    NSString* boundstr = [user objectForKey:@"boundID"];
    if (boundstr != nil) {
        self.boundID = [[NSUUID alloc] initWithUUIDString:boundstr];
    }
    else
    {
        self.boundID = nil;
    }
    return self;
}

- (void) startScan
{
    [self cleanlist];
    [self.manager scanForPeripheralsWithServices:nil options:nil];
    [self.delegate changeStateScanning];
    if (self.extTimer != nil) {
        [self.extTimer invalidate];
    }
    self.extTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(reStartScan) userInfo:nil repeats:NO];
    NSLog(@"start scanning");
}

- (void) stopScan
{
    [self.manager stopScan];
    self.boundID = nil;
    [self.delegate changeStateDisconnect];
    if (self.extTimer != nil) {
        [self.extTimer invalidate];
    }
    NSLog(@"stop scanning");
}

- (void) cleanlist
{
    self.bluelist = [[NSMutableArray alloc] init];
    self.advlist = [[NSMutableArray alloc] init];
}

- (void) cleanBoundID
{
    self.boundID = nil;
}

- (void) storeBoundID:(NSUUID *)ID
{
    self.boundID = ID;
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    NSString* boundstr = [NSString stringWithFormat:@"%@",self.boundID];
    [user setObject:boundstr forKey:@"boundID"];
    NSLog(@"stored ID:%@",ID);
}

-(void)connectPeripheral:(CBPeripheral *)peripheral
{
    self.slave = peripheral;
    [self.manager connectPeripheral:peripheral options:nil];
    [self.delegate changeStateConnecting];
    if (self.extTimer != nil) {
        [self.extTimer invalidate];
    }
    self.extTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(reconnectPeripheral) userInfo:nil repeats:YES];
    NSLog(@"connecting");
}

-(void) reStartScan
{
    [self stopScan];
    [self startScan];
    NSLog(@"time extended,rescanning");
}

-(void) reconnectPeripheral
{
    [self cancelConnect];
    [self.manager connectPeripheral:self.slave options:nil];
    NSLog(@"time extended,reconnecting");
}

-(void)cancelConnect
{
    [self.manager cancelPeripheralConnection:self.slave];
    NSLog(@"canceling connect");
}
//////////////////////////////////////////////////////////////////////////////////蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self.delegate bluetoothIsReady];
        if (self.boundID != nil) {
            [self startScan];
            NSLog(@"boundID:%@",self.boundID);
        }
        NSLog(@"Bluetooth is ok");
    }
    else
    {
        NSLog(@"CBCentralManagerStatePower error!");
    }
}

///////////////////////////////////////////////////////////////////////////////////扫描到设备
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (self.boundID == nil) {
        BOOL norepeat = TRUE;
        for (NSInteger i = 0; i < self.bluelist.count; i++) {
            CBPeripheral* tmpblue = [self.bluelist objectAtIndex:i];
            if (peripheral.identifier == tmpblue.identifier) {
                norepeat = FALSE;
                break;
            }
        }
        if (norepeat) {
            if (/*advertisementData[CBAdvertisementDataManufacturerDataKey] != nil && */peripheral.name != nil) {
                [self.bluelist addObject:peripheral];
                [self.advlist addObject:advertisementData];
                [self.delegate didDiscoverNewPeripheral];
                NSLog(@"name:%@",peripheral.name);
                NSLog(@"ID:%@",peripheral.identifier);
            }
        }
    }
    else
    {
        if ([[NSString stringWithFormat:@"%@",peripheral.identifier] isEqualToString:[NSString stringWithFormat:@"%@",self.boundID]]) {
            [self stopScan];
            [self connectPeripheral:peripheral];
            [self.delegate changeStateConnecting];
            NSLog(@"connecting");
        }
    }
}


-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (self.extTimer != nil) {
        [self.extTimer invalidate];
    }
    self.slave = peripheral;
    self.slave.delegate = self;
    [self.delegate changeStateConnected];
    [self.slave discoverServices:nil];
    NSLog(@"connected");
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{

    [self.delegate changeStateDisconnect];
    
    NSLog(@"disconnect successed");
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
        NSLog(@"fined service:%@",service.UUID.UUIDString);
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"didDiscoverCharacteristics error");
    }
    for (CBCharacteristic *characteristic in service.characteristics){
        {
            if ([characteristic.UUID.UUIDString isEqualToString:@"B381"]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
            if ([characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
                [peripheral readValueForCharacteristic:characteristic];
                self.batc = characteristic;
            }
            NSLog(@"fined uuid:%@",characteristic.UUID.UUIDString);
        }
    }
}

//扫描到具体的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if ([characteristic.UUID.UUIDString isEqualToString:@"B381"]) {
        
        const char* _v = [characteristic.value bytes];
        NSInteger value = ((_v[2] << 8) | _v[3]) & 0x0000ffff;
        float uvI = (0.0187 * ( 0.00391 * value * value + value));
        if ((_v[0] & 0x80) == 0x80) {
            NSString* str = [NSString stringWithFormat:@"正在充电"];
            [self.delegate uvbandMsg:str];
        }
        if ((_v[0] & 0x0F) != 0x00) {
            NSString* str = [NSString stringWithFormat:@"手环故障:%d",(_v[0]&0x0f)];
            [self.delegate uvbandMsg:str];
        }
        if (_v[1] != 0x00) {
            [self.delegate uvIndexValue:uvI];
        }
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateBatteryValue) userInfo:nil repeats:NO];
        NSLog(@"%@",characteristic.value);
        NSLog(@"UV I:%f",uvI);
    }
    if ([characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
        const char* _bat = [characteristic.value bytes];
        if (_bat[0] < 10) {
            NSString* str = [NSString stringWithFormat:@"电量过低：%d%%",_bat[0]];
            [self.delegate uvbandMsg:str];
        }
        else
        {
            NSString* str = [NSString stringWithFormat:@"手环电量：%d%%",_bat[0]];
            [self.delegate uvbandMsg:str];
        }
        NSLog(@"bat value:%d%%",_bat[0]);
    }
}



-(void)updateBatteryValue
{
    if (self.slave != nil) {
        if (self.batc != nil) {
            [self.slave readValueForCharacteristic:self.batc];
        }
    }
}
@end
