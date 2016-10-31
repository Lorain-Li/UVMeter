//
//  MainPage.h
//  UVMeter
//
//  Created by JinChun on 16/10/26.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainPage : UIViewController
<UITableViewDelegate,UITableViewDataSource>
{
    int _count;
    UIView* arrows;
    UILabel* updatetime;
    NSDateFormatter* formatter;
    CGFloat _screenH,_screenW;
    NSTimer* _tpTimer;
    NSMutableArray* _bletab;
}

#define TABVIEWCELL_HIGHT   (50)
#define TABVIEWCELL_WIDTH   (240)
#define TABVIEW_HIGHT       (200)
#define TABVIEW_WIDTH       (240)

@end
