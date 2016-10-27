//
//  MainPage.m
//  UVMeter
//
//  Created by JinChun on 16/10/26.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import "MainPage.h"
#import "SetPage.h"
#import "BTPage.h"

@interface MainPage ()

@end

@implementation MainPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @" ";
    self.view.backgroundColor = [UIColor blackColor];
    UIBarButtonItem* _bluetooth = [[UIBarButtonItem alloc] initWithTitle:@"Bluetooth" style:UIBarButtonItemStyleDone target:self action:@selector(pressBluetooth)];
    UIBarButtonItem* _setting = [[UIBarButtonItem alloc] initWithTitle:@"Setting" style:UIBarButtonItemStyleDone target:self action:@selector(pressSetting)];
    //添加占位按钮
    UIBarButtonItem* _space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    _space.width = 150;
    NSArray* _buttonA = [[NSArray alloc] initWithObjects:_bluetooth,_space,_setting,nil];
    //将按钮添加到工具栏
    self.toolbarItems = _buttonA;
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;

    CGFloat _screenW = [[UIScreen mainScreen] bounds].size.width;
    CGFloat _screenH = [[UIScreen mainScreen] bounds].size.height;
    
    UILabel* _uvIndex = [[UILabel alloc] init];
    UILabel* _date = [[UILabel alloc] init];
    _uvIndex.text = @"UV Index";
    _uvIndex.textColor = [UIColor yellowColor];
    _uvIndex.textAlignment = NSTextAlignmentCenter;
    _date.text = @"Date";
    _date.textColor = [UIColor yellowColor];
    _date.textAlignment = NSTextAlignmentCenter;
    _uvIndex.frame = CGRectMake(_screenW/2-50, _screenH/10, 100, 30);
    _date.frame = CGRectMake(_screenW/2-125, _screenH*6/12+10, 250, 30);
    
    UIImage* _bspng = [UIImage imageNamed:@"bs.png"];
    UIImage* _blockpng = [UIImage imageNamed:@"block.png"];
    UIImage* _arrowspng = [UIImage imageNamed:@"arrows.png"];
    UIImage* _rainbowpng = [UIImage imageNamed:@"rainbow.png"];
    
    UIImageView* _bsview = [[UIImageView alloc] initWithImage:_bspng];
    UIImageView* _blockview = [[UIImageView alloc] initWithImage:_blockpng];
    UIImageView* _arrowsview = [[UIImageView alloc] initWithImage:_arrowspng];
    UIImageView* _rainbowview = [[UIImageView alloc] initWithImage:_rainbowpng];
    
    _bsview.frame = CGRectMake(_screenW/16, _screenH/19, _screenW/8, _screenH/11);
    _blockview.frame = CGRectMake(10, _screenH*3/5, _screenW - 20, _screenH*4/11);
    _arrowsview.frame = CGRectMake(_screenW/2-10, _screenH*4/11, 20, _screenH/6);
    _rainbowview.frame = CGRectMake(5,_screenH/7, _screenW-10, _screenH*4/11);
    
    arrows = _arrowsview;
    updatetime = _date;
    arrows.layer.anchorPoint = CGPointMake(0.6, 0.96);
    NSDateFormatter* _formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateStyle:NSDateFormatterShortStyle];
    [_formatter setTimeStyle:NSDateFormatterShortStyle];
    formatter = _formatter;
    _count = 1;
   
    [self.view addSubview:_bsview];
    [self.view addSubview:_blockview];
    [self.view addSubview:_rainbowview];
    [self.view addSubview:_arrowsview];
    [self.view addSubview:_uvIndex];
    [self.view addSubview:_date];
    
     [self rotateImageView:0];
    // Do any additional setup after loading the view.
}


-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(self.navigationController.toolbarHidden == NO)
    {
        [self.navigationController setToolbarHidden:YES animated:TRUE];
    }
    else
    {
        [self.navigationController setToolbarHidden:NO animated:TRUE];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(steper) userInfo:nil repeats:YES];
}

-(void)steper
{
    [self rotateImageView:_count];
    _count ++;
}

-(void)rotateImageView:(NSInteger)index
{
    updatetime.text = [formatter stringFromDate:[[NSDate alloc] init]];
    arrows.layer.transform = CATransform3DMakeRotation(-M_PI*0.45+(M_PI*0.9*index/16.0), 0, 0, 1);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) pressBluetooth
{
    BTPage* _navPage = [[BTPage alloc] init];
    [self.navigationController pushViewController:_navPage animated:TRUE];
}

-(void) pressSetting
{
    SetPage* _navPage = [[SetPage alloc] init];
    [self.navigationController pushViewController:_navPage animated:TRUE];
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
