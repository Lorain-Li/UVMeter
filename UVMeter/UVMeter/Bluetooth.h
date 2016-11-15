//
//  Bluetooth.h
//  EasyBLUE
//
//  Created by Lorain on 2016/11/10.
//  Copyright © 2016年 LorainLynies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@protocol BluetoothDelegate <NSObject>

@optional
- (void) bluetoothIsReady;
- (void) didDiscoverNewPeripheral:(CBPeripheral *) peripheral;

@end



////////////////////////////////////////////////////////////////////////////////////
@interface Bluetooth : NSObject
<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (retain,nonatomic) id<BluetoothDelegate> delegate;
@property (retain,nonatomic) NSMutableArray     *bluelist;
@property (retain,nonatomic) NSMutableArray     *advlist;
@property (retain,nonatomic) NSMutableArray     *RSSIs;
@property (retain,nonatomic) CBCentralManager   *manager;
@property (retain,nonatomic) CBPeripheral       *slave;
@property (retain,nonatomic) NSMutableArray     *primaryService;
@property (retain,nonatomic) NSMutableArray     *services;
- (void) startScan;
- (void) stopScan;
- (void) clearnlist;

-(void)connectToPeripheral:(CBPeripheral*)peripheral;

- (instancetype) initWithDelegate:(id<BluetoothDelegate>)delegate;
@end
