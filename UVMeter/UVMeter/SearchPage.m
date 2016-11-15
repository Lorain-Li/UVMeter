//
//  SearchPage.m
//  UVMeter
//
//  Created by JinChun on 2016/11/15.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import "SearchPage.h"

@implementation SearchPage

-(void)createSubViews
{
    CGFloat sx = self.bounds.size.width;
    CGFloat sy = self.bounds.size.height;
    
    CGFloat LIST_BOX_ORGX = sx/2 - LIST_BOX_WIDTH/2;
    CGFloat LIST_BOX_ORGY = sy/2 - LIST_BOX_HEIGHT/2;
    
    self.backgroundColor = [UIColor colorWithRed:40/255.0F green:40/255.0F blue:40/255.0F alpha:0.6F];
    
    self.listBox = [[UIView alloc] initWithFrame:CGRectMake(LIST_BOX_ORGX, LIST_BOX_ORGY, LIST_BOX_WIDTH  , LIST_BOX_HEIGHT)];
    self.listTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, LIST_BOX_WIDTH, LIST_CELL_HEIGHT)];
    self.blueView = [[UITableView alloc] initWithFrame:CGRectMake(0, LIST_CELL_HEIGHT, LIST_BOX_WIDTH, 3 * LIST_CELL_HEIGHT)];
    
    self.listBox.backgroundColor = [UIColor whiteColor];
    self.listBox.layer.cornerRadius = 20;
    self.listBox.alpha = 0;
    
    self.listTitle.text = @"选择蓝牙设备";
    self.listTitle.font = [UIFont systemFontOfSize:20];
    self.listTitle.textAlignment = NSTextAlignmentCenter;
    self.listTitle.layer.cornerRadius = 20;
    self.listTitle.alpha = 0;
    
    self.blueView.delegate = self;
    self.blueView.dataSource = self;
    self.blueView.layer.cornerRadius = 20;
    self.blueView.alpha = 0;
    
    [self.listBox addSubview:self.listTitle];
    [self.listBox addSubview:self.blueView];
    [self addSubview:self.listBox];
}


-(void) showWithAnimation:(BOOL)ani
{
    if ((ani == TRUE)|(ani == YES)) {
        [self.blueView reloadData];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.alpha = 1;
        self.listBox.alpha = 1;
        self.listTitle.alpha = 1;
        self.blueView.alpha = 1;
        [UIView commitAnimations];
        NSLog(@"appear");
    }
}

-(void)hideWithAnimation:(BOOL)ani
{
    if ((ani == TRUE)|(ani == YES)) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.alpha = 0;
        self.listBox.alpha = 0;
        self.listTitle.alpha = 0;
        self.blueView.alpha = 0;
        [UIView commitAnimations];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
        NSLog(@"disappear");
    }
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%ld",self.blue.bluelist.count);
    return self.blue.bluelist.count;
}

//设置单元格高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LIST_CELL_HEIGHT;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral* peripheral = [self.blue.bluelist objectAtIndex:indexPath.row];
    NSDictionary* advData = [self.blue.advlist objectAtIndex:indexPath.row];
    NSString* ID = [NSString stringWithFormat:@"%@",peripheral.identifier];
    
    UITableViewCell* cell = [self.blueView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.textLabel.text = peripheral.name;
    if (advData[CBAdvertisementDataManufacturerDataKey] != nil) {
        NSString* str = [NSString stringWithFormat:@"Manufacture:%@",advData[CBAdvertisementDataManufacturerDataKey]];
        cell.detailTextLabel.text = str;
    }
    else
    {
        cell.detailTextLabel.text = @"Manufacture:Unknown";
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.blue stopScan];
    [self.blue connectPeripheral:[self.blue.bluelist objectAtIndex:indexPath.row]];
    [self hideWithAnimation:TRUE];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(removeFromSuperview) userInfo:nil repeats:NO];
    
     NSDictionary *advData = [self.blue.advlist objectAtIndex:indexPath.row];
     NSLog(@"selected manu:%@",advData[CBAdvertisementDataManufacturerDataKey]);
}

-(void)didDiscoverNewPeripheral
{
    [self.blueView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
