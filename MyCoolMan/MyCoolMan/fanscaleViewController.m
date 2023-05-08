//
//  fanscaleViewController.m
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/2/14.
//

#import "fanscaleViewController.h"
#import "SDAutoLayout.h"
#import "crc.h"

@interface fanscaleViewController()<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) UITableView *tableView;
@end

@implementation fanscaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc]init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60;
    
    //初始化BabyBluetooth 蓝牙库
   // baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    [self setAutoLayout];
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
    
    //返回按钮
    UIButton *btReturn = [[UIButton alloc]init];
    [btReturn setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    [self.view addSubview:btReturn];
    btReturn.sd_layout
        .centerXIs(20.0/248*viewX)
        .centerYIs(37.0/436*viewY)
        .widthIs(10.0/248*viewX)
        .autoHeightRatio(100.0/60);
    [btReturn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.tableView];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0]];
    [self.tableView.layer setCornerRadius:8.0];
    self.tableView.sd_layout
        .topSpaceToView(titleView, 50)
        .leftSpaceToView(self.view, 12)
        .rightSpaceToView(self.view, 12)
        .heightIs(300);
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UIScreen mainScreen].bounds.size.height/10.0;
}*/
/*
-(void)babyDelegate{
    __weak typeof(self) weakSelf = self;
   
    //设置读取characteristic的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        // NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        NSLog(@"read characteristic successfully!");
        if([characteristics.UUID.UUIDString isEqualToString:@"FFE1"]){
            weakSelf.characteristic = characteristics;
            NSData *data = characteristics.value;
            Byte r[23] = {0};
            if(data.length == 23){
                memcpy(r, [data bytes], 23);
                // NSLog(@"copy data successfully!");
                weakSelf.dataRead.start = r[0]; //通讯开始
                weakSelf.dataRead.power = r[1]; //0x01开机，0x00关机
                weakSelf.dataRead.tempSetting = r[2];  //设定温度
                weakSelf.dataRead.tempReal = r[3];  //实时温度
                weakSelf.dataRead.mode = r[4];  //工作模式
                weakSelf.dataRead.wind = r[5];  //风速档位 0-自动 1-4 是手动风速
                weakSelf.dataRead.turbo = r[6];  //强冷模式开关
                weakSelf.dataRead.sleep = r[7];  //睡眠模式开关
                weakSelf.dataRead.unit = r[8];   //温度单位 0-摄氏度 1-华氏度
                weakSelf.dataRead.countdown = r[9];  //倒计时关机时间
                weakSelf.dataRead.logo = r[10];  //LOGO 灯开关
                weakSelf.dataRead.atmosphere = r[11];  //氛围灯模式或氛围灯变化时间
                weakSelf.dataRead.red = r[12];   //R(红色数据值)
                weakSelf.dataRead.green = r[13];  //G(绿色数值)
                weakSelf.dataRead.blue = r[14];   //B(蓝色数值)
                weakSelf.dataRead.brightness = r[15];  //氛围灯亮度
                weakSelf.dataRead.errcode = r[16];  //故障代码
                weakSelf.dataRead.version = r[17];  //空调版本 0-国内版 1-国外版
                weakSelf.dataRead.reserve1 = r[18];  //备用
                weakSelf.dataRead.reserve2 = r[19];  //备用
                weakSelf.dataRead.crcH = r[20];  //CRC 校验高八位
                weakSelf.dataRead.crcL = r[21];  //CRC 校验高八位
                weakSelf.dataRead.end = r[22];  //通讯结束
            }
        }
    }];
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:ID];
    }
    cell.backgroundColor =  [UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0];
    NSArray *arrScale = [NSArray arrayWithObjects:
        @"Auto",@"Speed 1",@"Speed 2",@"Speed 3",@"Speed 4",@"Speed 5",nil];
    
    cell.textLabel.text = [arrScale objectAtIndex:indexPath.row];
    if(indexPath.row == self.dataRead.wind){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    if((self.characteristic != nil) && (self.dataRead.power == 0x01)){
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x12;
        write[2] = indexPath.row;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fanScaleNotify" object:nil userInfo: @{@"fanScale" : [NSString stringWithFormat:@"%ld",indexPath.row]}];
        
        for(int i=0;i<5;i++){
            UITableViewCell *cellpro = [tableView.visibleCells objectAtIndex:i];
            cellpro.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)goBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

@end
