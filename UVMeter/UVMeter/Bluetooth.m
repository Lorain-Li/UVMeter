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
    self.RSSIs = [[NSMutableArray alloc] init];
    return self;
}

- (void) startScan
{
    [self.manager scanForPeripheralsWithServices:nil options:[NSDictionary dictionaryWithObjectsAndKeys:@"CBCentralManagerScanOptionAllowDuplicatesKey",@"TRUE", nil]];
}

- (void) stopScan
{
    [self.manager stopScan];
}

- (void) clearnlist
{
    self.bluelist = [[NSMutableArray alloc] init];
    self.advlist = [[NSMutableArray alloc] init];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self.delegate bluetoothIsReady];
    }
    else
    {
        NSLog(@"CBCentralManagerStatePower error!");
    }
}


- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    BOOL norepeat = TRUE;
    for (NSInteger i = 0; i < self.bluelist.count; i++) {
        CBPeripheral* tmpblue = [self.bluelist objectAtIndex:i];
        if (peripheral.identifier == tmpblue.identifier) {
            [self.RSSIs setObject:RSSI atIndexedSubscript:i];
            norepeat = FALSE;
            break;
        }
    }
    if (norepeat) {
        NSLog(@"%@",peripheral.identifier);
        NSLog(@"%@",advertisementData);
        [self.bluelist addObject:peripheral];
        [self.advlist addObject:advertisementData];
        [self.RSSIs addObject:RSSI];
        [self.delegate didDiscoverNewPeripheral:peripheral];
    }
}

-(void)connectToPeripheral:(CBPeripheral *)peripheral
{
    [self stopScan];
    self.primaryService = [[NSMutableArray alloc] init];
    [self.manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObjectsAndKeys:@"CBConnectPeripheralOptionNotifyOnDisconnectionKey", @"TRUE",nil]];
}


-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"succssed");
    self.slave = peripheral;
    self.slave.delegate = self;
    [self.slave discoverServices:nil];
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"%@",peripheral.services);
    for (CBService *service in peripheral.services) {
        [self.primaryService addObject:service.UUID.UUIDString];
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        [peripheral setNotifyValue:TRUE forCharacteristic:characteristic];
        NSLog(@"%@",characteristic.UUID.UUIDString);
    }
}
@end
