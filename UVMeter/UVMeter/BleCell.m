//
//  BleCell.m
//  UVMeter
//
//  Created by JinChun on 16/10/31.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import "BleCell.h"

@implementation BleCell
@synthesize strname = _strname;
@synthesize intadr = _intadr;
- (void)awakeFromNib {
    // Initialization code
    UIView* _background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 50)];
    _background.layer.cornerRadius = 5;
    UILabel* _showname = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 230, 30)];
    UILabel* _showadr = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 230, 20)];
    _showname.text = _strname;
    NSMutableString* _stradr = [[NSMutableString alloc] init];
    for (int i = 0; i < 6; i++) {
        int tmp = _intadr % 16;
        if(tmp < 10)
        {
                [_stradr appendFormat:@"%c",'0'+tmp];
        }
        else
        {
                [_stradr appendFormat:@"%c",'A'+tmp - 10];
        }
        if (i == 1 || i == 3 || i == 5) {
            [_stradr appendFormat:@":"];
        }
        _intadr = _intadr / 16;
    }
    _showadr.text = _strname;
    //[_background addSubview:_showname];
    //[_background addSubview:_showadr];
    
    [self addSubview:_background];
    [self addSubview:_showname];
    [self addSubview:_showadr];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
