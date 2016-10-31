//
//  BleCell.h
//  UVMeter
//
//  Created by JinChun on 16/10/31.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BleCell : UITableViewCell
{
    NSString* _strname;
    NSInteger _intadr;
}
@property (retain,nonatomic) NSString* strname;
@property (assign,nonatomic) NSInteger intadr;
@end
