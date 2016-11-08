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
    
    _screenW = [[UIScreen mainScreen] bounds].size.width;
    _screenH = [[UIScreen mainScreen] bounds].size.height;
    
    _bletab = [[NSMutableArray alloc] init];
    
    self.title = @" ";
    self.view.backgroundColor = [UIColor blackColor];
    _bluetooth = [[UIBarButtonItem alloc] initWithTitle:@"搜索设备" style:UIBarButtonItemStyleDone target:self action:@selector(pressSearch)];

    //添加占位按钮
    UIBarButtonItem* _space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    NSArray* _buttonA = [[NSArray alloc] initWithObjects:_space,_bluetooth,_space,nil];
    //将按钮添加到工具栏
    self.toolbarItems = _buttonA;
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
 
    UILabel* _uvIndex = [[UILabel alloc] init];
    UILabel* _date = [[UILabel alloc] init];
    _bandstd = [[UILabel alloc] init];
    _uvIndex.text = @"UV Index";
    _uvIndex.textColor = [UIColor yellowColor];
    _uvIndex.textAlignment = NSTextAlignmentCenter;
    _bandstd.text = @"连接断开";
    _bandstd.textColor = [UIColor yellowColor];
    _bandstd.textAlignment = NSTextAlignmentCenter;
    _date.text = @"Date";
    _date.textColor = [UIColor yellowColor];
    _date.textAlignment = NSTextAlignmentCenter;
    _uvIndex.frame = CGRectMake(_screenW/2-50, _screenH/10, 100, 30);
    _date.frame = CGRectMake(_screenW/2-125, _screenH*6/12+10, 250, 30);
    _bandstd.frame =CGRectMake(_screenW/2-125, _screenH*6/12-30, 250, 30);
    
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
    [self.view addSubview:_bandstd];
     [self rotateImageView:0];
    
    _manager = [[CBCentralManager alloc] init];
    _manager.delegate = self;
    
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
    _tpTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(steper) userInfo:nil repeats:YES];
    if (_periheral == nil) {
        NSUserDefaults* _user = [NSUserDefaults standardUserDefaults];
        _periheral = [_user objectForKey:@"band"];
        if (_periheral != nil) {
            [_manager connectPeripheral:_periheral options:nil];
            _bandstd.text = @"正在连接";
        }
    }
}

-(void)steper
{
    [self rotateImageView:_count];
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

- (void) pressSearch
{
    if (_periheral == nil) {
        if ([_manager isScanning]) {
            [_manager stopScan];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            _bletitle.alpha = 0;
            _blelist.alpha = 0;
            _bleback.alpha = 0;
            [UIView commitAnimations];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:0.5];
            [[self.view viewWithTag:10] removeFromSuperview];
            [UIView commitAnimations];
            _bluetooth.title = @"搜索设备";
            _bletab = [[NSMutableArray alloc] init];
            _periheral = nil;
            _bandstd.text = @"连接断开";
        }
        else
        {
            UIView* _alpha = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenW, _screenH)];
            _alpha.backgroundColor = [UIColor colorWithRed:40/255.0F green:40/255.0F blue:40/255.0F alpha:0.5F];
            _alpha.tag = 10;
            _bluetooth.title = @"取消";
            _bandstd.text = @"搜索设备";
            _bleback = [[UIView alloc] initWithFrame:CGRectMake(_screenW/2 - TABVIEW_WIDTH/2, _screenH/2 - TABVIEW_HIGHT/2, TABVIEW_WIDTH  , TABVIEW_HIGHT)];
            _bletitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TABVIEWCELL_WIDTH, TABVIEWCELL_HIGHT)];
            _blelist = [[UITableView alloc] initWithFrame:CGRectMake(0, TABVIEWCELL_HIGHT, TABVIEW_WIDTH, 3*TABVIEWCELL_HIGHT) style:UITableViewStylePlain];
            UILabel* _labtitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, TABVIEWCELL_WIDTH - 40, TABVIEWCELL_HIGHT)];
            
            _labtitle.text = @"选择蓝牙设备";
            _labtitle.font = [UIFont systemFontOfSize:20];
            _labtitle.textAlignment = NSTextAlignmentCenter;
            _bletitle.layer.cornerRadius = 20;
            _bletitle.alpha = 0;
            
            
            _blelist.delegate = self;
            _blelist.dataSource = self;
            _blelist.layer.cornerRadius = 20;
            _blelist.alpha = 0;
            
            _bleback.backgroundColor = [UIColor whiteColor];
            _bleback.layer.cornerRadius = 20;
            _bleback.alpha = 0;
            
            [_bletitle addSubview:_labtitle];
            [_bleback addSubview:_bletitle];
            [_bleback addSubview:_blelist];
            [_alpha addSubview:_bleback];
            [self.view addSubview:_alpha];
            
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            _bletitle.alpha = 1;
            _blelist.alpha = 1;
            _bleback.alpha = 1;
            [UIView commitAnimations];
            
            [_manager scanForPeripheralsWithServices:nil options:nil];
        }
    }else
    {
        [_manager cancelPeripheralConnection:_periheral];
        _bluetooth.title = @"搜索设备";
        _bletab = [[NSMutableArray alloc] init];
        _periheral = nil;
        _bandstd.text = @"连接断开";
        NSUserDefaults* _user = [NSUserDefaults standardUserDefaults];
        [_user setObject:nil forKey:@"band"];
    }
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%ld",_bletab.count);
    return _bletab.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell* _cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"T_T"];
    CBPeripheral* _perh = [_bletab objectAtIndex:indexPath.row];
    _cell.textLabel.text = _perh.name;
    return _cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_manager stopScan];
    [_manager connectPeripheral:[_bletab objectAtIndex:indexPath.row] options:nil];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    _bletitle.alpha = 0;
    _blelist.alpha = 0;
    _bleback.alpha = 0;
    [UIView commitAnimations];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:0.5];
    [[self.view viewWithTag:10] removeFromSuperview];
    [UIView commitAnimations];
}


//当前蓝牙主设备状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state==CBCentralManagerStatePoweredOn) {
        self.title = @"蓝牙已就绪";
    }else
    {
        self.title = @"蓝牙未准备好";
        switch (central.state) {
            case CBCentralManagerStateUnknown:
                NSLog(@">>>CBCentralManagerStateUnknown");
                break;
            case CBCentralManagerStateResetting:
                NSLog(@">>>CBCentralManagerStateResetting");
                break;
            case CBCentralManagerStateUnsupported:
                NSLog(@">>>CBCentralManagerStateUnsupported");
                break;
            case CBCentralManagerStateUnauthorized:
                NSLog(@">>>CBCentralManagerStateUnauthorized");
                break;
            case CBCentralManagerStatePoweredOff:
                NSLog(@">>>CBCentralManagerStatePoweredOff");
                break;
            default:
                break;
        }
    }
}

//扫描到设备会进入方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"扫描连接外设：%@ %@",peripheral.name,RSSI);
    if (peripheral.name != nil) {
        [_bletab addObject:peripheral];
        NSLog(@"%@",peripheral.name);
        NSLog(@"%@",advertisementData[CBAdvertisementDataManufacturerDataKey]);
        [_blelist reloadData];
    }
}

//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    self.title = @"连接成功，扫描信息...";
    NSLog(@"连接外设成功！%@",peripheral.name);
    _periheral = peripheral;
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];          //扫描服务
    NSLog(@"开始扫描外设服务 %@...",peripheral.name);
    _bluetooth.title = @"断开连接";
    _bandstd.text = @"连接成功";
    //NSUserDefaults* _user = [NSUserDefaults standardUserDefaults];
    //[_user setObject:_tmpA forKey:@"band"];
}
//连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"连接到外设 失败！%@ %@",[peripheral name],[error localizedDescription]);
    self.title = @"连接失败";
}

//扫描到服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error)
    {
        NSLog(@"扫描外设服务出错：%@-> %@", peripheral.name, [error localizedDescription]);
        self.title = @"find services error.";
    
        return;
    }
    NSLog(@"扫描到外设服务：%@ -> %@",peripheral.name,peripheral.services);
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service]; //扫描特征值
    }
    NSLog(@"开始扫描外设服务的特征 %@...",peripheral.name);
    
}
//扫描到特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error)
    {
        NSLog(@"扫描外设的特征失败！%@->%@-> %@",peripheral.name,service.UUID, [error localizedDescription]);
        self.title = @"find characteristics error.";
        return;
    }
    
    NSLog(@"扫描到外设服务特征有：%@->%@->%@",peripheral.name,service.UUID,service.characteristics);
    //获取Characteristic的值
    
    for (CBCharacteristic *characteristic in service.characteristics){
        {
            if ([characteristic.UUID.UUIDString isEqualToString:@"B381"]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
            if ([characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
                _batc = characteristic;
                [peripheral readValueForCharacteristic:characteristic];
            }
            //[peripheral setNotifyValue:YES forCharacteristic:characteristic];
            NSLog(@"fined UUID:%@",characteristic.UUID.UUIDString);
        }
     
    }
}

//扫描到具体的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if ([characteristic.UUID.UUIDString isEqualToString:@"B381"]) {
        NSLog(@"%@",characteristic.value);
        const char* _v = [characteristic.value bytes];
        _count = _v[3];
        if ((_v[0] & 0x80) == 0x80) {
            _bandstd.text = @"正在充电";
        }
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatebat) userInfo:nil repeats:NO];
        NSLog(@"value is %ld",_count);
    }
    if ([characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
        const char* _v = [characteristic.value bytes];
        NSInteger bat = _v[0];
        if (bat < 10) {
            NSString* _str = [NSString stringWithFormat:@"电量过低：%ld%%",bat];
            _bandstd.text = _str;
        }
        else
        {
            NSString* _str = [NSString stringWithFormat:@"手环电量：%ld%%",bat];
            _bandstd.text = _str;
        }
        NSLog(@"bat value:%ld%%",bat);
    }
}

-(void)updatebat
{
    if (_periheral != nil) {
        if (_batc != nil) {
            [_periheral readValueForCharacteristic:_batc];
        }
    }
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
