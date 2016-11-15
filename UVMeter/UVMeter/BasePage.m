//
//  BasePage.m
//  UVMeter
//
//  Created by JinChun on 2016/11/15.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import "BasePage.h"

@implementation BasePage

-(void)createSubViews
{
    CGFloat sx = self.bounds.size.width;
    CGFloat sy = self.bounds.size.height;
    /////////////////////////////////////////////////////////////////////////////////////////
    //View never change
    UILabel* _uvIndex = [[UILabel alloc] initWithFrame:CGRectMake(sx/2-50, sy/10, 100, 30)];
    
    _uvIndex.text = @"UV Index";
    _uvIndex.textColor = [UIColor yellowColor];
    _uvIndex.textAlignment = NSTextAlignmentCenter;
    
    UIImage* _bspng = [UIImage imageNamed:@"bs.png"];
    UIImage* _blockpng = [UIImage imageNamed:@"block.png"];
    UIImage* _arrowspng = [UIImage imageNamed:@"arrows.png"];
    UIImage* _rainbowpng = [UIImage imageNamed:@"rainbow.png"];
    
    UIImageView* _bsview = [[UIImageView alloc] initWithImage:_bspng];
    UIImageView* _blockview = [[UIImageView alloc] initWithImage:_blockpng];
    UIImageView* _arrowsview = [[UIImageView alloc] initWithImage:_arrowspng];
    UIImageView* _rainbowview = [[UIImageView alloc] initWithImage:_rainbowpng];
    
    _bsview.frame = CGRectMake(sx/16, sy/19, sx/8, sy/11);
    _blockview.frame = CGRectMake(10, sy*3/5, sx - 20, sy*4/11);
    _arrowsview.frame = CGRectMake(sx/2-10, sy*4/11, 20, sy/6);
    _rainbowview.frame = CGRectMake(5,sy/7, sx-10, sy*4/11);
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //View need change
    self.UVband = [[UILabel alloc] initWithFrame:CGRectMake(sx/2-125, sy * 6/12-30, 250, 30)];
    self.dateTime = [[UILabel alloc] initWithFrame:CGRectMake(sx/2-125, sy*6/12+10, 250, 30)];
    self.formatter = [[NSDateFormatter alloc] init];
    
    self.UVband.text = @"连接断开";
    self.UVband.textColor = [UIColor yellowColor];
    self.UVband.textAlignment = NSTextAlignmentCenter;
    
    self.dateTime.text = @"Date";
    self.dateTime.textColor = [UIColor yellowColor];
    self.dateTime.textAlignment = NSTextAlignmentCenter;
    
    [self.formatter setDateStyle:NSDateFormatterShortStyle];
    [self.formatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.arrow = _arrowsview;
    self.arrow.layer.anchorPoint = CGPointMake(0.6, 0.96);
    ///////////////////////////////////////////////////////////////////////////////////////////

    [self addSubview:_bsview];
    [self addSubview:_blockview];
    [self addSubview:_rainbowview];
    [self addSubview:_arrowsview];
    [self addSubview:_uvIndex];
    [self addSubview:self.dateTime];
    [self addSubview:self.UVband];
    [self rotateImageView:0];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeAndDate) userInfo:nil repeats:YES];
}

- (void)updateTimeAndDate
{
    self.dateTime.text = [self.formatter stringFromDate:[[NSDate alloc] init]];
}

- (void)updateUVband:(NSString *)str
{
    self.UVband.text = str;
}

-(void)rotateImageView:(float)index
{
    self.arrow.layer.transform = CATransform3DMakeRotation(-M_PI*0.45+(M_PI*0.9*index/16.0), 0, 0, 1);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
