//
//  BasePage.h
//  UVMeter
//
//  Created by JinChun on 2016/11/15.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasePage : UIView
@property (retain,nonatomic) UIView     *arrow;
@property (retain,nonatomic) UILabel    *UVband;
@property (retain,nonatomic) UILabel    *dateTime;
@property (retain,nonatomic) NSDateFormatter    *formatter;

- (void)createSubViews;
- (void)updateUVband:(NSString *)str;
- (void)rotateImageView:(float)index;
@end
