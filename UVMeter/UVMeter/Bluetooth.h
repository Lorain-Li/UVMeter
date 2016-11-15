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
- (void) didDiscoverNewPeripheral;
- (void) changeStateScanning;
- (void) changeStateConnecting;
- (void) changeStateConnected;
- (void) changeStateDisconnect;
- (void) uvbandMsg:(NSString *)msg;
- (void) uvIndexValue:(float)index;
@end



////////////////////////////////////////////////////////////////////////////////////
@interface Bluetooth : NSObject
<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (retain,nonatomic) id<BluetoothDelegate> delegate;
@property (retain,nonatomic) NSMutableArray     *bluelist;
@property (retain,nonatomic) NSMutableArray     *advlist;
@property (retain,nonatomic) CBCentralManager   *manager;
@property (retain,nonatomic) CBPeripheral       *slave;
@property (retain,nonatomic) CBCharacteristic   *batc;
@property (retain,nonatomic) NSUUID             *boundID;
- (void) startScan;
- (void) stopScan;
- (void) cleanlist;
- (void) cleanBoundID;

-(void)connectPeripheral:(CBPeripheral*)peripheral;
-(void)cancelConnect;

- (instancetype) initWithDelegate:(id<BluetoothDelegate>)delegate;
@end
