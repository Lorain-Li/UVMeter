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
@interface MainPage : UIViewController
@property (retain,nonatomic) BasePage       *baseView;
@property (retain,nonatomic) SearchPage     *searchView;
@property (retain,nonatomic) UIBarButtonItem    *button;

@end
