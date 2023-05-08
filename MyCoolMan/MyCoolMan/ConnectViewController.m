//
//  ConnectViewController.m
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/2/14.
//

#import "ConnectViewController.h"
#import "BabyBluetooth.h"
#import "SDAutoLayout.h"
#import "MBProgressHUD.h"
#import "MainViewController.h"

@interface ConnectViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain) MBProgressHUD *hud;
@property (nonatomic,retain) NSMutableArray <CBPeripheral*> *devices;;
@property (nonatomic,retain) NSMutableArray *localNames;
@property (nonatomic,retain) UITableView *tableView;
@end

@implementation ConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //屏幕布局
    
    self.devices = [[NSMutableArray alloc] init];
    self.localNames = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setAutoLayout];
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    [self babyDelegate];
    baby.scanForPeripherals().begin();
    /* baby.scanForPeripherals().connectToPeripherals().discoverServices()
        .discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic()
        .readValueForDescriptors().begin();*/
}
-(void) viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
    [self babyDelegate];
}

-(void) setAutoLayout{
    double frameWidth = 248;    //屏幕参考相对宽度
    double frameHeight = 436;   //屏幕参考相对高度
    
    double viewX = [UIScreen mainScreen].bounds.size.width;
    double viewY = [UIScreen mainScreen].bounds.size.height;
    [self.view setBackgroundColor:[UIColor  blackColor]];
    
    //导航栏
    UIView *titleView = [UIView new];
    [self.view addSubview:titleView];
    [titleView setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138/255.0 blue:214/255.0 alpha:1.0]];
    titleView.sd_layout
        .topEqualToView(self.view)
        .leftEqualToView(self.view)
        .rightEqualToView(self.view)
        .heightRatioToView(self.view, 50.0/frameHeight);
    
    //标题
    UIImageView *imageTitle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"type"]];
    [titleView addSubview:imageTitle];
    imageTitle.sd_layout
        .centerXEqualToView(titleView)
        .centerYIs(37.0/frameHeight*viewY)
        .heightIs(18.0/frameWidth*viewX)
        .autoWidthRatio(680.0/102);
    
    [self.view addSubview:self.tableView];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0]];
    [self.tableView.layer setCornerRadius:8.0];
    self.tableView.sd_layout
        .centerXEqualToView(self.view)
        .topSpaceToView(titleView, 12.0/436 * frameHeight)
        .leftSpaceToView(self.view, 0)
        .rightSpaceToView(self.view, 0)
        .heightRatioToView(self.view, 320.0/436);
    
    UIButton *btClear = [[UIButton alloc]init];
    [self.view addSubview:btClear];
    btClear.sd_layout
        .centerXEqualToView(self.view)
        .topSpaceToView(self.tableView, 24.0/436*frameHeight)
        .widthIs(48.0/frameWidth*viewX)
        .autoHeightRatio(0.6);
    [btClear setTitle:@"scan" forState:UIControlStateNormal];
    [btClear setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btClear setBackgroundColor:[UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0]];
    [btClear.layer setCornerRadius:8.0];
    [btClear addTarget:self action:@selector(scan:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.backgroundColor = [UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0];
    
    CBPeripheral *peripheral = [self.devices objectAtIndex:indexPath.row];
    NSString *advertiseName = [self.localNames objectAtIndex:indexPath.row];
    NSLog(@"%@",advertiseName);
    [cell.textLabel setText:advertiseName];
    
   // [cell.textLabel setText:peripheral.name];
   // [cell.textLabel setText:peripheral.identifier.UUIDString];
    NSString *deviceState;
    switch(peripheral.state){
        case 0:deviceState = @"Disconnected"; break;
        case 1:deviceState = @"Connecting";break;
        case 2:deviceState = @"Connected";break;;
        case 3:deviceState = @"Disconnecting";break;
        default:deviceState = @"Unknow";break;
    }
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",deviceState]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [baby.centralManager stopScan];
    //是否需要断开之前连接？
    [baby cancelAllPeripheralsConnection];
    //baby.connectToPeripherals([self.devices objectAtIndex:indexPath.row]);
    [baby.centralManager connectPeripheral:[self.devices objectAtIndex:indexPath.row]  options:nil];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.label.text = @"Connecting to Device......";
    [self.hud showAnimated:YES];
}

#pragma mark - babyDelegate
-(void)babyDelegate{
    __weak typeof(self) weakSelf = self;
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"Device discovered :%@",peripheral.name);
        
//        if(([peripheral.name hasPrefix:@"CCA"]||[peripheral.name hasPrefix:@"GCA"]) && ![self.devices containsObject:peripheral])  {
        NSString *advertiseName = advertisementData[@"kCBAdvDataLocalName"];
        if(([advertiseName hasPrefix:@"CCA"]||[advertiseName hasPrefix:@"GCA"]) && ![self.devices containsObject:peripheral])  {
            [weakSelf.devices addObject:peripheral];
            [weakSelf.localNames addObject:advertiseName];
        }
        [weakSelf.tableView reloadData];
        if([weakSelf.devices count]>10){
            [central stopScan];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *uuidString = [defaults objectForKey:@"UUID"];
        if([peripheral.identifier.UUIDString isEqual:uuidString]){
            [central stopScan];
            [baby cancelAllPeripheralsConnection];
            [central connectPeripheral:peripheral options:nil];
            weakSelf.currPeripheral = peripheral;
        }
    }];
    
    //设置连接设备失败的委托
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        weakSelf.hud.label.text = @"Device connected failed!\nPlease check the bluetooth!";
        [weakSelf.hud setMinShowTime:1];
        [weakSelf.hud showAnimated:YES];
        [weakSelf.hud hideAnimated:YES];
    }];
    
    //设置断开设备的委托
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        weakSelf.hud.mode = MBProgressHUDModeIndeterminate;
        weakSelf.hud.label.text = @"Disconnet devices";
        [weakSelf.hud setMinShowTime:1];
        [weakSelf.hud showAnimated:YES];
    }];
    
    //设置设备连接成功的委托
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [central stopScan];
        NSLog(@"设备：%@--连接成功",peripheral.name);
        weakSelf.currPeripheral = peripheral;
        weakSelf.hud.mode = MBProgressHUDModeText;
        weakSelf.hud.label.text = @"Device connected!";
        [weakSelf.hud setMinShowTime:1];
        [weakSelf.hud hideAnimated:YES];
        [peripheral discoverServices:nil];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"搜索到服务:%@",service.UUID.UUIDString);
            for(CBService *service in peripheral.services){
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }];
    
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
            [peripheral readValueForCharacteristic:c];
        }
    }];
    
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
     //   NSLog(@"read characteristic successfully!");
        
        if([characteristics.UUID.UUIDString isEqualToString:@"FFE1"]){
            weakSelf.characteristic = characteristics;
            weakSelf.currPeripheral = peripheral;
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:peripheral.identifier.UUIDString forKey:@"UUID"];
        [defaults synchronize];
        [weakSelf performSegueWithIdentifier:@"openmain" sender:weakSelf];
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@NO};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    //设置连接的设备的过滤器
    /*
     __block BOOL isFirst = YES;
     [baby setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
     if(isFirst && [advertisementData[@"kCBAdvDataLocalName"] isEqual:@"GCA28-22123456789"]){
     isFirst = NO;
     return YES;
     }
     return NO;
     }]; */
    
    __block BOOL isFirst = YES;
    [baby setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        if(isFirst){
            isFirst = NO;
            return YES;
        }
        return NO;
    }];
}

-(void) scan:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"UUID"];
    baby.scanForPeripherals().begin();
    self.hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.label.text = @"scan for devices";
    [self.hud setMinShowTime:3];
    [self.hud showAnimated:YES];
    [self.hud  hideAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MainViewController *mainViewController = (MainViewController *) segue.destinationViewController;
    mainViewController.currPeripheral = self.currPeripheral;
    mainViewController.characteristic = self.characteristic;
}


@end
