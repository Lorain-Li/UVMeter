//
//  MainPage.h
//  UVMeter
//
//  Created by JinChun on 16/10/26.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainPage : UIViewController
{
    int _count;
    UIView* arrows;
    UILabel* updatetime;
    NSDateFormatter* formatter;
    CGFloat _screenH,_screenW;
    NSTimer* _tpTimer;
}
@end
