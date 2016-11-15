//
//  MainPage.m
//  UVMeter
//
//  Created by JinChun on 16/10/26.
//  Copyright © 2016年 Jinoux. All rights reserved.
//

#import "MainPage.h"
@interface MainPage ()

@end

@implementation MainPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = [UIScreen mainScreen].bounds;

    self.baseView = [[BasePage alloc] initWithFrame:rect];
    self.searchView = [[SearchPage alloc] initWithFrame:rect];
    self.searchView.delegate = self;
    self.state = BluetoothStateDisconnect;
    
    [self.baseView createSubViews];
    [self.searchView createSubViews];
    [self.view addSubview:self.baseView];

    self.view.backgroundColor = [UIColor blackColor];
    self.button = [[UIBarButtonItem alloc] initWithTitle:@"搜索设备" style:UIBarButtonItemStyleDone target:self action:@selector(pressSearch)];
    UIBarButtonItem* btnSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSArray* buttons = [[NSArray alloc] initWithObjects:btnSpace,self.button,btnSpace,nil];
    self.toolbarItems = buttons;
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
 
    self.blue = [[Bluetooth alloc] initWithDelegate:self];
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) pressSearch
{
    switch (self.state) {
        case BluetoothStateScanning:{
            [self.blue stopScan];
            self.state = BluetoothStateDisconnect;
            [self.searchView hideWithAnimation:TRUE];
            self.button.title = @"搜索蓝牙";
            NSLog(@"pressed stoped scanning");
        }
            break;
        case BluetoothStateDisconnect:{
            [self.blue startScan];
            self.state = BluetoothStateScanning;
            self.button.title = @"停止搜索";
            
            self.searchView.blue = self.blue;
            [self.view addSubview:self.searchView];
            [self.searchView showWithAnimation:TRUE];
            
            NSLog(@"pressed start scanning");
        }
            break;
        case BluetoothStateConnecting:{
            [self.blue cancelConnect];
            self.state = BluetoothStateDisconnect;
            self.button.title = @"搜索蓝牙";
            NSLog(@"pressed stoped connecting");
        }
            break;
        case BluetoothStateConnected:{
            [self.blue cancelConnect];
            self.state = BluetoothStateDisconnect;
            self.button.title = @"搜索蓝牙";
            NSLog(@"pressed disconnect");
        }
            break;
        default:
            break;
    }
}

- (void)changeStateScanning
{
    self.state = BluetoothStateScanning;
    self.baseView.UVband.text = @"正在搜索";
    self.button.title = @"取消";
}

-(void)changeStateConnecting
{
    self.state = BluetoothStateConnecting;
    self.baseView.UVband.text = @"正在连接";
    self.button.title = @"停止搜索";
    self.blue.delegate = self;
}

- (void)changeStateConnected
{
    self.state = BluetoothStateConnected;
    self.baseView.UVband.text = @"连接成功";
    self.button.title = @"断开连接";
}

-(void)changeStateDisconnect
{
    self.state = BluetoothStateDisconnect;
    self.baseView.UVband.text = @"连接断开";
    self.button.title = @"搜索设备";
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
