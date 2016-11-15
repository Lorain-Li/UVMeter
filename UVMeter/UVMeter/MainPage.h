//
//  MainPage.h
//  UVMeter
//
//  Created by JinChun on 16/10/26.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bluetooth.h"
#import "BasePage.h"
#import "SearchPage.h"


typedef enum : NSUInteger {
    BluetoothStateDisconnect = 0,
    BluetoothStateScanning,
    BluetoothStateConnecting,
    BluetoothStateConnected,
} BlueState;


@interface MainPage : UIViewController
<BluetoothDelegate,SearchPageDelegate>
@property (retain,nonatomic) BasePage       *baseView;
@property (retain,nonatomic) SearchPage     *searchView;
@property (retain,nonatomic) UIBarButtonItem    *button;
@property (retain,nonatomic) Bluetooth      *blue;
@property (nonatomic)        BlueState      state;
@end
