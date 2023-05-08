//
//  SettingViewController.m
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/1/16.
//

#import "SettingViewController.h"
#import "BabyBluetooth.h"
#import "SDAutoLayout.h"
#import "MBProgressHUD.h"
#import "PaletteViewController.h"
#import "fanscaleViewController.h"
#import "ClockViewController.h"
#import "crc.h"

@interface SettingViewController ()
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setAutoLayout];
}

- (void)viewDidAppear:(BOOL)animated{
    //风量
    baby = [BabyBluetooth shareBabyBluetooth];
    UILabel *label22 = (UILabel *)[self.view viewWithTag:220];
    UILabel *label24 = (UILabel *)[self.view viewWithTag:240];
     if(self.dataRead.wind == 0x00){
         [label22 setTextColor:[UIColor blackColor]];
         [label24 setTextColor:[UIColor grayColor]];
     }else{
         [label22 setTextColor:[UIColor grayColor]];
         [label24 setTextColor:[UIColor blackColor]];
     }
}


//设计布局
- (void) setAutoLayout{
    
    double frameWidth = 288;    //屏幕相对宽度
    double frameHeight = 508;   //屏幕相对高度
    
    double viewX = [UIScreen mainScreen].bounds.size.width;
    double viewY = [UIScreen mainScreen].bounds.size.height;
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    //导航栏
    UIView *titleView = [UIView new];
    [self.view addSubview:titleView];
    [titleView setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138/255.0 blue:214/255.0 alpha:1.0]];
    titleView.sd_layout
        .topEqualToView(self.view)
        .leftEqualToView(self.view)
        .rightEqualToView(self.view)
        .heightRatioToView(self.view, 58.0/frameHeight);
    
    //返回按钮
    UIButton *btReturn = [[UIButton alloc]init];
    [self.view addSubview:btReturn];
    btReturn.sd_layout
        .centerXIs(22.0/frameWidth*viewX)
        .centerYIs(42.0/frameHeight*viewY)
        .widthIs(10.0/frameWidth*viewX)
        .autoHeightRatio(100.0/60);
    [btReturn setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    [btReturn addTarget:self action:@selector(toMain:) forControlEvents:UIControlEventTouchUpInside];
    
    //标题
    UILabel  *labelTitle = [[UILabel alloc]init];
    [titleView addSubview:labelTitle];
    labelTitle.text = @"Settings";
    labelTitle.sd_layout
        .centerXEqualToView(titleView)
        .heightRatioToView(btReturn, 1.0)
        .bottomSpaceToView(titleView, 6.0/frameHeight*viewY);
    [labelTitle setFont:[UIFont fontWithName:@"Arial" size:14.0/frameHeight*viewY]];
    [labelTitle setTextColor:[UIColor whiteColor]];
    [labelTitle setSingleLineAutoResizeWithMaxWidth:200];
    
    /*
     //设置按钮
     UIButton *btSetting = [[UIButton alloc]init];
     [self.view addSubview:btSetting];
     btSetting.sd_layout
     .centerXIs(261.0/frameWidth*viewX)
     .centerYIs(44.0/frameHeight*viewY)
     .widthIs(18.0/frameWidth*viewX)
     .autoHeightRatio(1.0);
     [btSetting setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
     */
    
    //设置区view1
    UIView *view1 = [UIView new];
    [self.view addSubview:view1];
   // [view1 setBackgroundColor:[UIColor colorWithRed:210/255.0 green:235/255.0 blue:250/255.0 alpha:1.0]];
    [view1 setBackgroundColor:[UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0]];
    view1.sd_layout
        .topSpaceToView(titleView, 12.0/frameHeight*viewY)
        .leftSpaceToView(self.view,14.0/frameHeight*viewX)
        .rightSpaceToView(self.view,14.0/frameHeight*viewX)
        .heightRatioToView(self.view,40.0/frameHeight);
    [view1.layer setCornerRadius:8.0];
    
    //语言偏好
    UILabel *label11 = [UILabel new];
    [view1 addSubview:label11];
    label11.text = @"Preferred Language";
    label11.sd_layout
        .leftSpaceToView(view1, 14.0/frameWidth*viewX)
        .topSpaceToView(view1,  12.0/frameHeight*viewY);
    [label11 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    [label11 setSingleLineAutoResizeWithMaxWidth:200];
    
    //语言偏好
    UILabel *label12 = [UILabel new];
    [view1 addSubview:label12];
    label12.text = @"English(UK)";
    label12.sd_layout
        .leftSpaceToView(view1, 174.0/frameWidth*viewX)
        .topSpaceToView(view1,  12.0/frameHeight*viewY);
    [label12 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    [label12 setSingleLineAutoResizeWithMaxWidth:200];
    
    //设置区view2
    UIView *view2 = [UIView new];
    [self.view addSubview:view2];
    //[view2 setBackgroundColor:[UIColor colorWithRed:210/255.0 green:235/255.0 blue:250/255.0 alpha:1.0]];
    [view2 setBackgroundColor:[UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0]];
    view2.sd_layout
        .topSpaceToView(view1, 18.0/frameHeight*viewY)
        .leftSpaceToView(self.view,14.0/frameHeight*viewX)
        .rightSpaceToView(self.view,14.0/frameHeight*viewX)
        .heightRatioToView(self.view,200.0/frameHeight);
    [view2.layer setCornerRadius:8.0];
    
    //吹风1
    UILabel *label21 = [UILabel new];
    [view2 addSubview:label21];
    label21.text = @"Fan";
    [label21 setSingleLineAutoResizeWithMaxWidth:100];
    [label21 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    label21.sd_layout
        .leftSpaceToView(view2, 14.0/frameWidth*viewX)
        .topSpaceToView(view2,  12.0/frameHeight*viewY)
        .heightIs(12.0/frameHeight*viewY)
        .widthIs(178.0/frameWidth*viewX);
    
    //吹风2
    UILabel *label22 = [UILabel new];
    [view2 addSubview:label22];
    label22.text = @"Auto";
    [label22 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    [label22 setSingleLineAutoResizeWithMaxWidth:100];
    label22.sd_layout
        .leftSpaceToView(view2, 174.0/frameWidth*viewX)
        .topSpaceToView(view2,  12.0/frameHeight*viewY)
        .heightIs(12.0/frameHeight*viewY)
        .widthIs(10.0/frameWidth*viewX);
    [label22 setTag:220];
    
    //吹风3
    UILabel *label23 = [UILabel new];
    [view2 addSubview:label23];
    label23.text = @"/";
    [label23 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    [label23 setSingleLineAutoResizeWithMaxWidth:10];
    label23.sd_layout
        .leftSpaceToView(label22, 1.0/frameWidth*viewX)
        .topSpaceToView(view2,  12.0/frameHeight*viewY)
        .heightIs(12.0/frameHeight*viewY);
    
    
    //吹风4
    UILabel *label24 = [UILabel new];
    [view2 addSubview:label24];
    label24.text = @"Manual";
    [label24 setSingleLineAutoResizeWithMaxWidth:100];
    [label24 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    label24.sd_layout
        .leftSpaceToView(label23, 1.0/frameWidth*viewX)
        .topSpaceToView(view2,  12.0/frameHeight*viewY)
        .heightIs(12.0/frameHeight*viewY);
    [label24 setTag:240];
    
    //风量
     if(self.dataRead.wind == 0x00){
         [label22 setTextColor:[UIColor blackColor]];
         [label24 setTextColor:[UIColor grayColor]];
     }else{
         [label22 setTextColor:[UIColor grayColor]];
         [label24 setTextColor:[UIColor blackColor]];
     }
    
    //吹风5
    UIButton *button25 = [UIButton new];
    [view2 addSubview:button25];
    [button25 setBackgroundImage:[UIImage imageNamed:@"detail"] forState: UIControlStateNormal];
    button25.sd_layout
        .rightSpaceToView(view2, 14.0/frameWidth*viewX)
        .topSpaceToView(view2,  12.0/frameHeight*viewY)
        .heightIs(10.0/frameHeight*viewY)
        .autoWidthRatio(60.0/100);
    [button25 addTarget:self action:@selector(setFan:) forControlEvents:UIControlEventTouchUpInside];
    
    //画一条线
    UIView *viewLine2 = [[UIView alloc] init];
    [view2 addSubview:viewLine2];
    //[viewLine1 setBackgroundColor:[UIColor grayColor]];
    [viewLine2 setBackgroundColor:[UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.1]];
    viewLine2.sd_layout
        .leftSpaceToView(view2, 0)
        .rightSpaceToView(view2, 0)
        .centerYIs(40.0/frameHeight*viewY)
        .heightIs(2);
    
    //添加透明按钮
    UIButton *buttonFan = [UIButton new];
    [view2 addSubview:buttonFan];
    [buttonFan setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0]];
    buttonFan.sd_layout
        .leftSpaceToView(view2, 0)
        .rightSpaceToView(view2, 0)
        .topEqualToView(view2)
        .bottomEqualToView(viewLine2);
    [buttonFan addTarget:self action:@selector(setFan:) forControlEvents:UIControlEventTouchUpInside];

    
    //温度单位1
    UILabel *label31 = [UILabel new];
    [view2 addSubview:label31];
    label31.text = @"Temperature Scale";
    [label31 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    [label31 setSingleLineAutoResizeWithMaxWidth:150];
    label31.sd_layout
        .leftSpaceToView(view2, 14.0/frameWidth*viewX)
        .heightIs(12.0/frameHeight*viewY)
        .topSpaceToView(viewLine2,  12.0/frameHeight*viewY);
    
    //温度单位2
    NSArray *array = [NSArray arrayWithObjects:@"­°C",@"℉",nil];
    UISegmentedControl *segment32 = [[UISegmentedControl alloc]initWithItems:array];
   // segment32.selectedSegmentIndex = 0;
    [view2 addSubview:segment32];
    if (@available(iOS 13.0, *)) {
        [segment32 setSelectedSegmentTintColor:[UIColor colorWithRed:22.0/255 green:138/255.0 blue:214/255.0 alpha:1.0]];
    } else {
        // Fallback on earlier versions
    }
    segment32.sd_layout
        .leftSpaceToView(view2, 172.0/frameWidth*viewX)
        .topSpaceToView(viewLine2, 6.0/frameHeight*viewY)
        .rightSpaceToView(view2, 14.0/frameHeight*viewY)
        .heightIs(24.0/frameHeight*viewY);
    [segment32 addTarget:self action:@selector(unitChange) forControlEvents:UIControlEventValueChanged];
    [segment32 setTag:320];
    
    //温度单位
   if(self.dataRead.unit == 0x01){
       segment32.selectedSegmentIndex = 0;
   }else{
       segment32.selectedSegmentIndex = 1;
   }
    
    //画一条线
    UIView *viewLine3 = [[UIView alloc] init];
    [view2 addSubview:viewLine3];
    //[viewLine1 setBackgroundColor:[UIColor grayColor]];
    [viewLine3 setBackgroundColor:[UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.1]];
    viewLine3.sd_layout
        .leftSpaceToView(view2, 0)
        .rightSpaceToView(view2, 0)
        .centerYIs(80.0/frameHeight*viewY)
        .heightIs(2);
    
    //颜色1
    UILabel *label41 = [UILabel new];
    [view2 addSubview:label41];
    label41.text = @"Light";
    label41.sd_layout
        .leftSpaceToView(view2, 14.0/frameWidth*viewX)
        .heightIs(12.0/frameHeight*viewY)
        .topSpaceToView(viewLine3,  12.0/frameHeight*viewY);
    [label41 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    [label41 setSingleLineAutoResizeWithMaxWidth:100];
    
    //颜色2
    UILabel *label42 = [UILabel new];
    [view2 addSubview:label42];
    label42.text = @"Color";
    label42.sd_layout
        .leftSpaceToView(view2, 174.0/frameWidth*viewX)
        .heightIs(12.0/frameHeight*viewY)
        .topSpaceToView(viewLine3,  12.0/frameHeight*viewY);
    [label42 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    [label42 setSingleLineAutoResizeWithMaxWidth:100];
    
    //颜色3
    UIButton *button43 = [UIButton new];
    [view2 addSubview:button43];
    [button43 setBackgroundImage:[UIImage imageNamed:@"detail"] forState: UIControlStateNormal];
    button43.sd_layout
        .rightSpaceToView(view2, 14.0/frameWidth*viewX)
        .topSpaceToView(viewLine3,  12.0/frameHeight*viewY)
        .heightIs(10.0/frameHeight*viewY)
        .autoWidthRatio(60.0/100);
    [button43 addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //画一条线
    UIView *viewLine4 = [[UIView alloc] init];
    [view2 addSubview:viewLine4];
    //[viewLine1 setBackgroundColor:[UIColor grayColor]];
    [viewLine4 setBackgroundColor:[UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.1]];
    viewLine4.sd_layout
        .leftSpaceToView(view2, 0)
        .rightSpaceToView(view2, 0)
        .centerYIs(120.0/frameHeight*viewY)
        .heightIs(2);
    
    //添加透明按钮
    UIButton *buttonColor = [UIButton new];
    [view2 addSubview:buttonColor];
    [buttonColor setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0]];
    buttonColor.sd_layout
        .leftSpaceToView(view2, 0)
        .rightSpaceToView(view2, 0)
        .topEqualToView(viewLine3)
        .bottomEqualToView(viewLine4);
    [buttonColor addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchUpInside];
    
    /*
    //Logo光照1
    UILabel *label51 = [UILabel new];
    [view2 addSubview:label51];
    label51.text = @"Logo Illumination";
    label51.sd_layout
        .leftSpaceToView(view2, 14.0/frameWidth*viewX)
        .heightIs(12.0/frameHeight*viewY)
        .topSpaceToView(viewLine4,  12.0/frameHeight*viewY);
    [label51 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    [label51 setSingleLineAutoResizeWithMaxWidth:150];
    
    //Logo光照2
    UILabel *label52 = [UILabel new];
    [view2 addSubview:label52];
    label52.text = @"OFF";
    label52.sd_layout
        .leftSpaceToView(view2, 174.0/frameWidth*viewX)
        .heightIs(12.0/frameHeight*viewY)
        .topSpaceToView(viewLine4,  12.0/frameHeight*viewY);
    [label52 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    [label52 setSingleLineAutoResizeWithMaxWidth:50];
    [label52 setTag:520];
    
    //Logo光照3
    UISwitch *switch53 = [[UISwitch alloc]init];
    [view2 addSubview:switch53];
    switch53.sd_layout
        .leftSpaceToView(label52, 2.0/frameWidth*viewX)
        .topSpaceToView(viewLine4,  9.0/frameHeight*viewY)
        .widthIs(72.0/frameWidth*viewX)
        .heightIs(24.0/frameHeight*viewY);
    [switch53 addTarget:self action:@selector(switchLogo) forControlEvents:UIControlEventTouchUpInside];
    [switch53 setTag:530];
    
    //Logo光照4
    UILabel *label54 = [UILabel new];
    [view2 addSubview:label54];
    label54.text = @"ON";
    label54.sd_layout
        .leftSpaceToView(switch53, 2.0/frameWidth*viewX)
        .heightIs(12.0/frameHeight*viewY)
        .topSpaceToView(viewLine4, 12.0/frameHeight*viewY);
    [label54 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    [label54 setSingleLineAutoResizeWithMaxWidth:100];
    [label54 setTag:540];
    
    //logo灯
    if(self.dataRead.logo == 0x01){
        [switch53 setOn:YES];
        [label52 setTextColor:[UIColor grayColor]];
        [label54 setTextColor:[UIColor blackColor]];
    }else{
        [switch53 setOn:NO];
        [label52 setTextColor:[UIColor blackColor]];
        [label54 setTextColor:[UIColor grayColor]];
    }
    */
    
    //时钟
    UILabel *label61 = [UILabel new];
    [view2 addSubview:label61];
    label61.text = @"Set Clock";
    [label61 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    [label61 setSingleLineAutoResizeWithMaxWidth:100];
    label61.sd_layout
        .leftSpaceToView(view2, 14.0/frameWidth*viewX)
        .topSpaceToView(viewLine4,  12.0/frameHeight*viewY)
        .heightIs(12.0/frameHeight*viewY);
    
    //时钟2
    UIButton *button63 = [UIButton new];
    [view2 addSubview:button63];
    [button63 setBackgroundImage:[UIImage imageNamed:@"detail"] forState: UIControlStateNormal];
    button63.sd_layout
        .rightSpaceToView(view2, 14.0/frameWidth*viewX)
        .topSpaceToView(viewLine4,  12.0/frameHeight*viewY)
        .heightIs(10.0/frameHeight*viewY)
        .autoWidthRatio(60.0/100);
    

    //画一条线
    UIView *viewLine5 = [[UIView alloc] init];
    [view2 addSubview:viewLine5];
    //[viewLine1 setBackgroundColor:[UIColor grayColor]];
    [viewLine5 setBackgroundColor:[UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.1]];
    viewLine5.sd_layout
        .leftSpaceToView(view2, 0)
        .rightSpaceToView(view2, 0)
        .centerYIs(160.0/frameHeight*viewY)
        .heightIs(2);
    
    /*
    //画一条线
    UIView *viewLine6 = [[UIView alloc] init];
    [view2 addSubview:viewLine6];
    [viewLine6 setBackgroundColor:[UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.1]];
    viewLine6.sd_layout
        .leftSpaceToView(view2, 0)
        .rightSpaceToView(view2, 0)
        .centerYIs(185.0/frameHeight*viewY)
        .heightIs(2);
     */
    
    //添加透明按钮
    UIButton *buttonClock = [UIButton new];
    [view2 addSubview:buttonClock];
    [buttonClock setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0]];
    buttonClock.sd_layout
        .leftSpaceToView(view2, 0)
        .rightSpaceToView(view2, 0)
        .topEqualToView(viewLine4)
        .bottomEqualToView(viewLine5);
    [buttonClock addTarget:self action:@selector(setClock:) forControlEvents:UIControlEventTouchUpInside];

    
    //帮助1
    UILabel *label71 = [UILabel new];
    [view2 addSubview:label71];
    label71.text = @"Help/Troubleshooting";
    [label71 setFont:[UIFont fontWithName:@"Arial" size:12.0/frameWidth*viewX]];
    [label71 setSingleLineAutoResizeWithMaxWidth:200];
    label71.sd_layout
        .leftSpaceToView(view2, 14.0/frameWidth*viewX)
        .topSpaceToView(viewLine5,  12.0/frameHeight*viewY)
        .heightIs(12.0/frameHeight*viewY);;
    
    //帮助1
    UIButton *button72 = [UIButton new];
    [view2 addSubview:button72];
    [button72 setBackgroundImage:[UIImage imageNamed:@"detail"] forState: UIControlStateNormal];
    button72.sd_layout
        .rightSpaceToView(view2, 14.0/frameWidth*viewX)
        .topSpaceToView(viewLine5,  12.0/frameHeight*viewY)
        .heightIs(10.0/frameHeight*viewY)
        .autoWidthRatio(60.0/100);
    
    //设置区view3
    UIButton *button80 = [UIButton new];
    [self.view addSubview:button80];
    //[button80 setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138/255.0 blue:214/255.0 alpha:1.0]];
    [button80 setBackgroundColor:[UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0]];
    [button80 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button80 setTitle:@"Reset to Factory Settings" forState:UIControlStateNormal];
    button80.sd_layout
        .topSpaceToView(view2, 18.0/frameHeight*viewY)
        .leftSpaceToView(self.view,14.0/frameHeight*viewX)
        .rightSpaceToView(self.view,14.0/frameHeight*viewX)
        .heightRatioToView(self.view,40.0/frameHeight);
    [button80 addTarget:self action:@selector(reset:) forControlEvents:UIControlEventTouchUpInside];
    [button80.layer setCornerRadius:8.0];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"setcolor"] ){
        PaletteViewController *paletteViewController = ( PaletteViewController *)[segue destinationViewController];
        paletteViewController.characteristic = self.characteristic;
        paletteViewController.currPeripheral = self.currPeripheral;
        paletteViewController.dataRead = self.dataRead;
    }
    
    if([segue.identifier isEqualToString:@"setfan"] ){
        fanscaleViewController *fanscale = ( fanscaleViewController *)[segue destinationViewController];
        fanscale.characteristic = self.characteristic;
        fanscale.currPeripheral = self.currPeripheral;
        fanscale.dataRead = self.dataRead;
    }
    
    if([segue.identifier isEqualToString:@"setclock"]){
        ClockViewController *clockViewController = (ClockViewController *)[segue destinationViewController];
        clockViewController.characteristic = self.characteristic;
        clockViewController.currPeripheral = self.currPeripheral;
        clockViewController.dataRead = self.dataRead;
    }
}

#pragma mark - 消息处理
-(void)setColor:(id)sender{
    [self performSegueWithIdentifier:@"setcolor" sender:self];
}

-(void)setFan:(id)sender{
    [self performSegueWithIdentifier:@"setfan" sender:self];
}

-(void)setClock:(id)sender{
    [self performSegueWithIdentifier:@"setclock" sender:self];
}

//返回主页
-(void)toMain:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

//切换温度单位
-(void)unitChange{
    if((self.characteristic != nil) && (self.dataRead.power == 0x01)){
        UISegmentedControl *segment = (UISegmentedControl *)[self.view viewWithTag:320];
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x17;
        if(segment.selectedSegmentIndex == 0x00){
            write[2] = 0x00;
        }else{
            write[2] = 0x01;
        }
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    }
}

/*
//切换logo灯
-(void)switchLogo{
    if((self.characteristic != nil) && (self.dataRead.power == 0x01)){
        UISwitch *switchLogo = (UISwitch *)[self.view viewWithTag:530];
        UILabel *labelOff = (UILabel *)[self.view viewWithTag:520];
        UILabel *labelOn = (UILabel *) [self.view viewWithTag:540];
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x18;
        if([switchLogo isOn]){
            write[2] = 0x01;
            [labelOn setTextColor:[UIColor blackColor]];
            [labelOff setTextColor:[UIColor grayColor]];
        }else{
            write[2] = 0x00;
            [labelOn setTextColor:[UIColor grayColor]];
            [labelOff setTextColor:[UIColor blackColor]];
        }
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    }
}
*/

//恢复出厂
-(void)reset:(id)sender{
    if(self.characteristic != nil){
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x1E;
        write[2] = 0x01;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
}

@end
