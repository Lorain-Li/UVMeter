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
            UISwitch* _chnSW = [[UISwitch alloc] initWithFrame:CGRectMake(_scWidth - 40, 10, 0, 0)];
            _chnSW.tag = 10 + indexPath.row;
            [_cell addSubview:_chnSW];
        }
        else
        {
            UIStepper* _ch5ST = [[UIStepper alloc] initWithFrame:CGRectMake(20, 10, _scWidth - 40 , 40)];

        }
    }
    else
    {
        
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
