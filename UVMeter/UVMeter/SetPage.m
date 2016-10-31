//
//  SetPage.m
//  UVMeter
//
//  Created by JinChun on 16/10/26.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import "SetPage.h"

@interface SetPage ()

@end

@implementation SetPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _linetxt = [[NSMutableArray alloc] init];
    [_linetxt addObject:@"UV"];
    [_linetxt addObject:@"Med W"];
    [_linetxt addObject:@"Small W"];
    [_linetxt addObject:@"Med IR"];
    [_linetxt addObject:@"Small IR"];
    
    _scWidth = [[UIScreen mainScreen] bounds].size.width;
    _scHight = [[UIScreen mainScreen] bounds].size.height;
    
    self.title = @"设置";
    self.view.backgroundColor = [UIColor grayColor];
    _setTable = [[UITableView alloc] initWithFrame:[self.view bounds] style:UITableViewStyleGrouped];
    _setTable.delegate =self;
    _setTable.dataSource = self;
    [self.view addSubview:_setTable];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
    //设置透明度，默认透明，通过此项设置为不透明
    self.navigationController.navigationBar.translucent = NO;
    //默认风格为白色
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row < 5) {
            return 40;
        }
        else
        {
            return 60;
        }
    }
    else
    {
        return 50;
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [NSString stringWithFormat:@"功能设定"];
    }
    else
    {
        return [NSString stringWithFormat:@"更新频率"];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 6;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* _cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"T_T"];
    if(indexPath.section == 0)
    {
        if(indexPath.row < 5)
        {
            _cell.textLabel.text = [_linetxt objectAtIndex:indexPath.row];
            UISwitch* _chnSW = [[UISwitch alloc] initWithFrame:CGRectMake(_scWidth - 60, 5, 0, 0)];
            _chnSW.tag = 10 + indexPath.row;
            [_cell addSubview:_chnSW];
        }
        else
        {
            UISegmentedControl* _ch5SG = [[UISegmentedControl alloc] initWithFrame:CGRectMake(20, 10, _scWidth - 40 , 40)];
            [_ch5SG insertSegmentWithTitle:@"UV Deep" atIndex:0 animated:TRUE];
            [_ch5SG insertSegmentWithTitle:@"  " atIndex:1 animated:TRUE];
            [_ch5SG insertSegmentWithTitle:@"Large IR" atIndex:2 animated:TRUE];
            _ch5SG.selectedSegmentIndex = 1;
            [_cell addSubview:_ch5SG];
        }
    }
    else
    {
        UIStepper* _upSteper = [[UIStepper alloc] initWithFrame:CGRectMake(_scWidth - 100, 10, 0, 40)];
        _upSteper.minimumValue = 1;
        _upSteper.maximumValue = 60;
        _upSteper.stepValue = 1;
        _upSteper.value = 10;
        _upSteper.autorepeat = YES;
        _upSteper.continuous = YES;
        UILabel* _timTxt = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 50)];
        _timTxt.text = @"次/分";
        [_cell addSubview:_upSteper];
        [_cell addSubview:_timTxt];
    }
    return _cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
