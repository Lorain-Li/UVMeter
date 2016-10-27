//
//  BTPage.m
//  UVMeter
//
//  Created by JinChun on 16/10/26.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import "BTPage.h"

@interface BTPage ()

@end

@implementation BTPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"蓝牙连接";
    self.view.backgroundColor = [UIColor grayColor];
    
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
