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
    [self.baseView createSubViews];
    [self.searchView createSubViews];
    
    [self.view addSubview:self.baseView];

    self.view.backgroundColor = [UIColor blackColor];
    self.button = [[UIBarButtonItem alloc] initWithTitle:@"搜索设备" style:UIBarButtonItemStyleDone target:self action:@selector(pressSearch)];

    //添加占位按钮
    UIBarButtonItem* _space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    NSArray* _buttonA = [[NSArray alloc] initWithObjects:_space,self.button,_space,nil];
    //将按钮添加到工具栏
    self.toolbarItems = _buttonA;
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
 
    
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
            self.button.title = @"搜索设备";
            _bletab = [[NSMutableArray alloc] init];
            _periheral = nil;
            _bandSTR = nil;
            _bandstd.text = @"连接断开";
        }
        else
        {
     
            
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
        self.button.title = @"搜索设备";
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
    _bandSTR = [_bleadv objectAtIndex:indexPath.row];
    NSLog(@"selected manu:%@",_bandSTR);
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
        if (_periheral == nil) {
            NSUserDefaults* _user = [NSUserDefaults standardUserDefaults];
            _bandSTR = [_user objectForKey:@"band"];
            NSLog(@"read:%@",_bandSTR);
            if (_bandSTR != nil) {
                [_manager scanForPeripheralsWithServices:nil options:nil];
                _bandstd.text = @"正在连接";
                self.button.title = @"取消";
            }
        }
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
    if (_bandSTR != nil) {
        if ([_bandSTR isEqualToString:[NSString stringWithFormat:@"%@",advertisementData[CBAdvertisementDataManufacturerDataKey]]]) {
            [_manager stopScan];
            _periheral = peripheral;
            [_manager connectPeripheral:peripheral options:nil];
            [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(connectExtended) userInfo:nil repeats:NO];
            status = CONNECTTING;
        }
        NSLog(@"扫描到设备：%@ %@",peripheral.name,RSSI);
        NSLog(@"identifer:%@",peripheral.identifier);
        NSLog(@"manuf:%@",advertisementData[CBAdvertisementDataManufacturerDataKey]);
    }
    else
    {
        if ((peripheral.name != nil)&&(advertisementData[CBAdvertisementDataManufacturerDataKey]!=nil)) {
            [_bletab addObject:peripheral];
            [_bleadv addObject:[NSString stringWithFormat:@"%@",advertisementData[CBAdvertisementDataManufacturerDataKey]]];
            NSLog(@"扫描到设备：%@ %@",peripheral.name,RSSI);
            NSLog(@"identifer:%@",peripheral.identifier);
            NSLog(@"manuf:%@",advertisementData[CBAdvertisementDataManufacturerDataKey]);
            [_blelist reloadData];
        }
    }
}

//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    self.title = @"连接成功，扫描信息...";
    NSLog(@"连接: %@ 成功!",peripheral.name);
    _periheral = peripheral;
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    self.button.title = @"断开连接";
    _bandstd.text = @"连接成功";
    status = CONNECTED;
    NSUserDefaults* _user = [NSUserDefaults standardUserDefaults];
    [_user setObject:_bandSTR forKey:@"band"];
    NSLog(@"stored:%@",[_user objectForKey:@"band"]);
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
    NSLog(@"一级服务：\r\n%@",peripheral.services);
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service]; //扫描特征值
    }
}
//扫描到特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error)
    {
        NSLog(@"扫描外设的特征失败！%@->%@-> %@",peripheral.name,service.UUID, [error localizedDescription]);
        self.title = @"find characteristics error.";
        return;
    }
    
    NSLog(@"二级服务:UUID:%@\r\n%@\r\n\r\n",service.UUID,service.characteristics);
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
        }
     
    }
}

//扫描到具体的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if ([characteristic.UUID.UUIDString isEqualToString:@"B381"]) {
        NSLog(@"%@",characteristic.value);
        const char* _v = [characteristic.value bytes];
        NSInteger value = ((_v[2] << 8) | _v[3]) & 0x0000ffff;
        _count = (NSInteger)(0.0187 * ( 0.00391 * value * value + value));
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
