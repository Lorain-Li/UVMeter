//
//  SetPage.h
//  UVMeter
//
//  Created by JinChun on 16/10/26.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetPage : UIViewController
<UITableViewDelegate,UITableViewDataSource>
{
    UITableView* _setTable;
    NSMutableArray* _linetxt;
    CGFloat _scWidth,_scHight;
}
@end
