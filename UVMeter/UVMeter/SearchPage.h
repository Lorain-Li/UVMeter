//
//  SearchPage.h
//  UVMeter
//
//  Created by JinChun on 2016/11/15.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bluetooth.h"

@protocol SearchPageDelegate <NSObject>

@optional
- (void) didSelectACell;
@end

@interface SearchPage : UIView
<UITableViewDelegate,UITableViewDataSource,BluetoothDelegate>
@property (retain,nonatomic) id<SearchPageDelegate> delegate;
@property (retain,nonatomic) UIView   *listBox;
@property (retain,nonatomic) UILabel    *listTitle;
@property (retain,nonatomic) UITableView   *blueView;
@property (retain,nonatomic) Bluetooth      *blue;

- (void) createSubViews;
- (void) showWithAnimation:(BOOL) ani;
- (void) hideWithAnimation:(BOOL) ani;
@end

#define LIST_BOX_WIDTH      200
#define LIST_BOX_HEIGHT     160
#define LIST_CELL_HEIGHT    40
