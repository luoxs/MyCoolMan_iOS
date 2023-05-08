//
//  MainViewController.m
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/1/13.
//

#import "MainViewController.h"
#import "BabyBluetooth.h"
#import "SDAutoLayout.h"
#import "MBProgressHUD.h"
#import "SettingViewController.h"
#import "ConnectViewController.h"
//#import "DataWrite.h"
#import "crc.h"

@interface MainViewController ()
@property (nonatomic,retain) MBProgressHUD *hud;
@property Boolean fanSelected;
@property Boolean lightSelected;
@property Boolean unitSelected;
@property Boolean modeSelected;
@property Boolean timerSelected;
@property Boolean quiteSelected;
@property Boolean turboSelected;
//------------------------------
@end
@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataRead = [[DataRead alloc]init];
    //屏幕布局
    [self setAutoLayout];
    //注册通知，接收风扇调整小谢
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fanScaleAjust:) name:@"fanScaleNotify" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorAjust:) name:@"colorNotify" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeAjust:) name:@"timeNotify" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sleepAjust:) name:@"timescaleNotify" object:nil];
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    //设置蓝牙委托
    [self babyDelegate];
    /*
     baby.scanForPeripherals().connectToPeripherals().discoverServices()
     .discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic()
     .readValueForDescriptors().begin();*/
    
}

-(void)viewDidAppear:(BOOL)animated{
    // NSLog(@"viewDidAppear");
    baby = [BabyBluetooth shareBabyBluetooth];
    /*
     if(self.currPeripheral == nil || self.dataRead.unit == 3 ){
     self.hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
     self.hud.mode = MBProgressHUDModeIndeterminate;
     self.hud.label.text = @"Connecting to Device......";
     [self.hud showAnimated:YES];
     
     baby.scanForPeripherals().connectToPeripherals().discoverServices()
     .discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic()
     .readValueForDescriptors().begin();
     }else{*/
    [self getStatus];
    //}
    //  self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getStatus) userInfo:nil repeats:NO];
    //[self.view setNeedsLayout];
}

#pragma  mark  - 界面布局
- (void) setAutoLayout{
    
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
    
    //返回按钮
    UIButton *btReturn = [[UIButton alloc]init];
    [self.view addSubview:btReturn];
    btReturn.sd_layout
        .centerXIs(20.0/frameWidth*viewX)
        .centerYIs(37.0/frameHeight*viewY)
        .widthIs(10.0/frameWidth*viewX)
        .autoHeightRatio(100.0/60);
    [btReturn setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    [btReturn addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
    [btReturn setTag:001];
    
    //标题
    UIImageView *imageTitle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"type"]];
    [titleView addSubview:imageTitle];
    imageTitle.sd_layout
        .centerXEqualToView(titleView)
        .centerYIs(37.0/frameHeight*viewY)
        .heightIs(18.0/frameWidth*viewX)
        .autoWidthRatio(680.0/102);
    
    //设置按钮
    UIButton *btSetting = [[UIButton alloc]init];
    [self.view addSubview:btSetting];
    btSetting.sd_layout
        .centerXIs(224.0/frameWidth*viewX)
        .centerYIs(37.0/frameHeight*viewY)
        .widthIs(16.0/frameWidth*viewX)
        .autoHeightRatio(1.0);
    [btSetting setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [btSetting addTarget:self action:@selector(setting) forControlEvents:UIControlEventTouchUpInside];
    
    //状态区
    UIView *statusView = [UIView new];
    [self.view addSubview:statusView];
    [statusView setBackgroundColor:[UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0]];
    statusView.sd_layout
        .topSpaceToView(titleView, 12.0/frameHeight*viewY)
        .leftSpaceToView(self.view,12.0/frameHeight*viewX)
        .rightSpaceToView(self.view,12.0/frameHeight*viewX)
        .heightRatioToView(self.view,248.0/frameHeight);
    [statusView.layer setCornerRadius:8.0];
    
    
    //模式A
    UIImageView *imageA = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"modeA"]];
    [statusView addSubview:imageA];
    imageA.sd_layout
        .leftSpaceToView(statusView, 12.0/frameWidth*viewX)
        .centerYIs(27.0/436*viewY)
        .widthIs(168.0/5/frameWidth*viewX) //相对于statusView,非self.view
        .heightEqualToWidth();
    [imageA setTag:101];
    
    //风机
    UIImageView *imageWindmachine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"windmachine"]];
    [statusView addSubview:imageWindmachine];
    imageWindmachine.sd_layout
        .leftSpaceToView(imageA, 10.0/frameWidth*viewX)
        .centerYEqualToView(imageA)
        .widthRatioToView(imageA, 1.0)
        .heightEqualToWidth();
    [imageWindmachine setTag:102];
    
    //制冷
    UIImageView *imageCool = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cool"]];
    [statusView addSubview:imageCool];
    imageCool.sd_layout
        .leftSpaceToView(imageWindmachine, 10.0/frameWidth*viewX)
        .centerYEqualToView(imageA)
        .widthRatioToView(imageA, 1.0)
        .heightEqualToWidth();
    [imageCool setTag:103];
    
    //制热
    UIImageView *imageWarm = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"warm"]];
    [statusView addSubview:imageWarm];
    imageWarm.sd_layout
        .leftSpaceToView(imageCool, 10.0/frameWidth*viewX)
        .centerYEqualToView(imageA)
        .widthRatioToView(imageA, 1.0)
        .heightEqualToWidth();
    [imageWarm setTag:104];
    
    //湿度
    UIImageView *imageHumidity = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"humidity"]];
    [statusView addSubview:imageHumidity];
    imageHumidity.sd_layout
        .leftSpaceToView(imageWarm, 10.0/frameWidth*viewX)
    // .rightSpaceToView(statusView, 12.0/frameWidth*viewX)
        .centerYEqualToView(imageA)
        .widthRatioToView(imageA, 1.0)
        .heightEqualToWidth();
    [imageHumidity setTag:105];
    
    //划一条线
    UIView *viewLine1 = [[UIView alloc] init];
    [statusView addSubview:viewLine1];
    [viewLine1 setBackgroundColor:[UIColor blackColor]];
    viewLine1.sd_layout
        .leftSpaceToView(statusView, 12.0/frameWidth*viewX)
        .rightSpaceToView(statusView, 12.0/frameHeight*viewY)
        .centerYIs(52.0/436*viewY)
        .heightIs(3);
    [viewLine1 setTag:10];
    
    //灯
    UIImageView *imageLight = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"light"]];
    [statusView addSubview:imageLight];
    imageLight.sd_layout
        .leftSpaceToView(statusView, 12.0/frameWidth*viewX)
        .centerYIs(82.0/436*viewY)
        .widthIs(36/frameWidth*viewX)
        .heightEqualToWidth();
    [imageLight setTag:201];
    
    //睡眠
    UIImageView *imageSleep = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sleep"]];
    [statusView addSubview:imageSleep];
    imageSleep.sd_layout
        .centerXEqualToView(imageLight)
        .widthRatioToView(imageLight, 1.0)
        .centerYIs(128.0/436*viewY)             //相对于statusView,非self.view
        .heightEqualToWidth(1);
    [imageSleep setTag:202];
    
    //温度单位
    UIImageView *imageUnint = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"celsius"]];
    [statusView addSubview:imageUnint];
    imageUnint.sd_layout
        .rightSpaceToView(statusView, 12.0/frameWidth*viewX)
        .widthRatioToView(imageLight, 1.0)
        .centerYEqualToView(imageLight)
        .heightEqualToWidth();
    [imageUnint setTag:203];
    
    //转换
    UIImageView *imageChange = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"change"]];
    [statusView addSubview:imageChange];
    imageChange.sd_layout
        .centerXEqualToView(imageUnint)
        .widthRatioToView(imageUnint, 1.0)
        .centerYIs(128.0/436*viewY)             //相对于statusView,非self.view
        .heightEqualToWidth(1);
    [imageChange setTag:204];
    
    //温度十位
    UIImageView *imageTemperatureHigh = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"big8"]];
    [imageTemperatureHigh setContentMode:UIViewContentModeScaleAspectFit];
    [statusView addSubview:imageTemperatureHigh];
    imageTemperatureHigh.sd_layout
        .centerXIs(92.0/frameWidth*viewX)
        .centerYIs(106.0/frameHeight*viewY)
        .widthRatioToView(self.view, 46.0/248)
        .autoHeightRatio(496.0/284.0);
    [imageTemperatureHigh setTag:205];
    
    
    //温度个位
    UIImageView *imageTemperatureLow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"big8"]];
    [imageTemperatureLow setContentMode:UIViewContentModeScaleAspectFit];
    [statusView addSubview:imageTemperatureLow];
    imageTemperatureLow.sd_layout
        .centerXIs(148.0/frameWidth*viewX)
        .centerYEqualToView(imageTemperatureHigh)
        .widthRatioToView(imageTemperatureHigh, 1.0)
        .heightRatioToView(imageTemperatureHigh, 1.0);
    [imageTemperatureLow setTag:206];
    
    //安静模式
    UIImageView *imageQuiet = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"quiet"]];
    [statusView addSubview:imageQuiet];
    imageQuiet.sd_layout
        .centerXIs(38.0/frameWidth*viewX)
        .centerYIs(167.0/frameHeight*viewY)
        .widthIs(52.0/frameWidth*viewX)
        .autoHeightRatio(80.0/316);
    [imageQuiet setTag:207];
    
    //正常模式
    UIImageView *imageNormal = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"normal"]];
    [statusView addSubview:imageNormal];
    imageNormal.sd_layout
        .centerXIs(115.0/frameWidth*viewX)
        .centerYEqualToView(imageQuiet)
        .widthIs(72.0/frameWidth*viewX)
        .heightRatioToView(imageQuiet,1.0);
    [imageNormal setTag:208];
    
    //强力模式
    UIImageView *imageTurbo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"turbo"]];
    [statusView addSubview:imageTurbo];
    imageTurbo.sd_layout
        .centerXIs(194.0/frameWidth*viewX)
        .centerYEqualToView(imageQuiet)
        .widthIs(57.0/frameWidth*viewX)
        .heightRatioToView(imageQuiet,1.0);
    [imageTurbo setTag:209];
    
    //再划一条线
    UIView *viewLine2 = [[UIView alloc] init];
    [statusView addSubview:viewLine2];
    [viewLine2 setBackgroundColor:[UIColor blackColor]];
    viewLine2.sd_layout
        .leftSpaceToView(statusView, 12.0/frameWidth*viewX)
        .rightSpaceToView(statusView, 12.0/frameWidth*viewX)
        .centerYIs(186.0/436*viewY)
        .heightIs(3);
    [viewLine2 setTag:20];
    
    //送风挡
    UIImageView *imageWind = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wind5"]];
    [imageWind setContentMode:UIViewContentModeScaleAspectFit];
    [statusView addSubview:imageWind];
    imageWind.sd_layout
        .centerXIs(38.0/frameWidth*viewX)
        .centerYIs(216.0/frameHeight*viewY)
        .widthIs(50.0/frameWidth*viewX)
        .autoHeightRatio(242.0/312);
    [imageWind setTag:301];
    
    //定时十位
    UIImageView *imageTimerHigh = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"small8"]];
    [imageTimerHigh setContentMode:UIViewContentModeScaleAspectFit];
    [statusView addSubview:imageTimerHigh];
    imageTimerHigh.sd_layout
        .centerXIs(84.0/frameWidth*viewX)
        .centerYEqualToView(imageWind)
        .heightRatioToView(imageWind, 1.0)
        .autoWidthRatio(138.0/243);
    [imageTimerHigh setTag:302];
    
    //定时个位
    UIImageView *imageTimerLow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"small8"]];
    [imageTimerLow setContentMode:UIViewContentModeScaleAspectFit];
    
    [statusView addSubview:imageTimerLow];
    imageTimerLow.sd_layout
        .centerXIs(110.0/frameWidth*viewX)
        .centerYEqualToView(imageWind)
        .heightRatioToView(imageWind, 1.0)
        .autoWidthRatio(138.0/243);
    [imageTimerLow setTag:303];
    
    //小数点
    UIView *viewDot = [[UIView alloc] init];
    [statusView addSubview:viewDot];
    [viewDot setBackgroundColor:[UIColor blackColor]];
    viewDot.sd_layout
        .centerXIs(128.0/frameWidth*viewX)
        .centerYIs(228.0/frameHeight*viewY)
        .heightIs(6.0/frameHeight *viewY)
        .widthIs(5.0/frameWidth *viewX);
    [viewDot setTag:304];
    
    //定时小数位
    UIImageView *imageTimerDecimal = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"small8"]];
    [statusView addSubview:imageTimerDecimal];
    imageTimerDecimal.sd_layout
        .centerXIs(146.0/frameWidth*viewX)
        .centerYEqualToView(imageWind)
        .heightRatioToView(imageWind, 1.0)
        .autoWidthRatio(138.0/243);
    [imageTimerDecimal setTag:305];
    
    //定时显示
    UIView *imageTimer = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"timershow"]];
    [statusView addSubview:imageTimer];
    imageTimer.sd_layout
        .centerXIs(190.0/frameWidth*viewX)
        .centerYEqualToView(imageWind)
        .widthIs(48.0/frameWidth*viewX)
        .autoHeightRatio(242.0/302);
    [imageTimer setTag:306];
    
    //按钮区
    //开关
    UIButton *btPower = [[UIButton alloc] init];
    [self.view addSubview:btPower];
    
    btPower.layer.cornerRadius = 8.0;
    btPower.clipsToBounds = true;
    //[btPower setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
    [btPower setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    btPower.sd_layout
        .centerXIs(32.0/frameWidth*viewX)
        .centerYIs(340.0/frameHeight*viewY)
        .widthIs(40.0/frameWidth*viewX)
        .heightEqualToWidth();
    [btPower setImage:[UIImage imageNamed:@"btpower"] forState:UIControlStateNormal];
    
    [btPower setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btPower.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btPower setTag:401];
    [btPower addTarget:self action:@selector(power:) forControlEvents:UIControlEventTouchUpInside];
    
    //送风
    UIButton *btWind = [[UIButton alloc] init];
    [self.view addSubview:btWind];
    btWind.layer.cornerRadius = 8.0;
    btWind.clipsToBounds = true;
    // [btWind setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
    [btWind setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    btWind.sd_layout
        .centerXIs(78.0/frameWidth*viewX)
        .centerYIs(340.0/frameHeight*viewY)
        .widthIs(40.0/frameWidth*viewX)
        .heightEqualToWidth();
    [btWind setImage:[UIImage imageNamed:@"btwind"] forState:UIControlStateNormal];
    [btWind setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btWind.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btWind setTag:402];
    [btWind addTarget:self action:@selector(setWind:) forControlEvents:UIControlEventTouchUpInside];
    
    //增加
    UIButton *btAdd = [[UIButton alloc] init];
    [self.view addSubview:btAdd];
    btAdd.layer.cornerRadius = 8.0;
    btAdd.clipsToBounds = true;
    // [btAdd setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
    [btAdd setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    btAdd.sd_layout
        .centerXIs(124.0/frameWidth*viewX)
        .centerYIs(340.0/frameHeight*viewY)
        .widthIs(40.0/frameWidth*viewX)
        .heightEqualToWidth();
    [btAdd setImage:[UIImage imageNamed:@"btadd"] forState:UIControlStateNormal];
    [btAdd setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btAdd.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btAdd setTag:403];
    [btAdd addTarget:self action:@selector(setAdd:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //开灯
    UIButton *btLight = [[UIButton alloc] init];
    [self.view addSubview:btLight];
    btLight.layer.cornerRadius = 8.0;
    btLight.clipsToBounds = true;
    // [btLight setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
    [btLight setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    btLight.sd_layout
        .centerXIs(170.0/frameWidth*viewX)
        .centerYIs(340.0/frameHeight*viewY)
        .widthIs(40.0/frameWidth*viewX)
        .heightEqualToWidth();
    [btLight setImage:[UIImage imageNamed:@"btlight"] forState:UIControlStateNormal];
    [btLight setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btLight.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btLight setTag:404];
    [btLight addTarget:self action:@selector(setLight:) forControlEvents:UIControlEventTouchUpInside];
    
    //单位
    UIButton *btUnit = [[UIButton alloc] init];
    [self.view addSubview:btUnit];
    btUnit.layer.cornerRadius = 8.0;
    btUnit.clipsToBounds = true;
    //[btUnit setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
    [btUnit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    btUnit.sd_layout
        .centerXIs(216.0/frameWidth*viewX)
        .centerYIs(340.0/frameHeight*viewY)
        .widthIs(40.0/frameWidth*viewX)
        .heightEqualToWidth();
    [btUnit setImage:[UIImage imageNamed:@"btunit"] forState:UIControlStateNormal];
    [btUnit setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btUnit.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btUnit setTag:405];
    [btUnit addTarget:self action:@selector(setUnit:) forControlEvents:UIControlEventTouchUpInside];
    
    //模式
    UIButton *btMode = [[UIButton alloc] init];
    [self.view addSubview:btMode];
    btMode.layer.cornerRadius = 8.0;
    btMode.clipsToBounds = true;
    [btMode setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
    [btMode setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    btMode.sd_layout
        .centerXIs(32.0/frameWidth*viewX)
        .centerYIs(383.0/frameHeight*viewY)
        .widthIs(40.0/frameWidth*viewX)
        .heightEqualToWidth();
    [btMode setImage:[UIImage imageNamed:@"btmode"] forState:UIControlStateNormal];
    [btMode setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btMode.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btMode setTag:406];
    [btMode addTarget:self action:@selector(setMode:) forControlEvents:UIControlEventTouchUpInside];
    
    //定时
    UIButton *btTimer = [[UIButton alloc] init];
    [self.view addSubview:btTimer];
    btTimer.layer.cornerRadius = 8.0;
    btTimer.clipsToBounds = true;
    //[btTimer setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
    [btTimer setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    btTimer.sd_layout
        .centerXIs(78.0/frameWidth*viewX)
        .centerYIs(383.0/frameHeight*viewY)
        .widthIs(40.0/frameWidth*viewX)
        .heightEqualToWidth();
    [btTimer setImage:[UIImage imageNamed:@"bttimer"] forState:UIControlStateNormal];
    [btTimer setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btTimer.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btTimer setTag:407];
    [btTimer addTarget:self action:@selector(setTime:) forControlEvents:UIControlEventTouchUpInside];
    
    //调低
    UIButton *btMinus = [[UIButton alloc] init];
    [self.view addSubview:btMinus];
    btMinus.layer.cornerRadius = 8.0;
    btMinus.clipsToBounds = true;
    //[btMinus setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
    [btMinus setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    btMinus.sd_layout
        .centerXIs(124.0/frameWidth*viewX)
        .centerYIs(383.0/frameHeight*viewY)
        .widthIs(40.0/frameWidth*viewX)
        .heightEqualToWidth();
    [btMinus setImage:[UIImage imageNamed:@"btminus"] forState:UIControlStateNormal];
    [btMinus setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [btMinus.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btMinus setTag:408];
    [btMinus addTarget:self action:@selector(setMinus:) forControlEvents:UIControlEventTouchUpInside];
    
    //睡眠
    UIButton *btQuit = [[UIButton alloc] init];
    [self.view addSubview:btQuit];
    btQuit.layer.cornerRadius = 8.0;
    btQuit.clipsToBounds = true;
    //[btQuit setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
    [btQuit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    btQuit.sd_layout
        .centerXIs(170.0/frameWidth*viewX)
        .centerYIs(383.0/frameHeight*viewY)
        .widthIs(40.0/frameWidth*viewX)
        .heightEqualToWidth();
    [btQuit setImage:[UIImage imageNamed:@"btquiet"] forState:UIControlStateNormal];
    [btQuit setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btQuit.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btQuit setTag:409];
    [btQuit addTarget:self action:@selector(setQuiet:) forControlEvents:UIControlEventTouchUpInside];
    
    //跳转
    UIButton *btturbo = [[UIButton alloc] init];
    [self.view addSubview:btturbo];
    btturbo.layer.cornerRadius = 8.0;
    btturbo.clipsToBounds = true;
    //[btturbo setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
    [btturbo setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    btturbo.sd_layout
        .centerXIs(216.0/frameWidth*viewX)
        .centerYIs(383.0/frameHeight*viewY)
        .widthIs(40.0/frameWidth*viewX)
        .heightEqualToWidth();
    [btturbo setImage:[UIImage imageNamed:@"btturbo"] forState:UIControlStateNormal];
    [btturbo setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btturbo.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btturbo setTag:410];
    [btturbo addTarget:self action:@selector(setTurbo:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma  mark - 蓝牙委托
-(void) babyDelegate{
    __weak typeof(self) weakSelf = self;
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"Device discovered :%@",peripheral.name);
        //早期版本
        
        /*
         if([[advertisementData  objectForKey:@"kCBAdvDataLocalName"] isEqual:@"GCA28-22123456789"]){
         [central stopScan];
         weakSelf.currPeripheral = peripheral;
         }
         
         if([[advertisementData  objectForKey:@"kCBAdvDataLocalName"] isEqual:@"GCA30-555987"]){
         [central stopScan];
         weakSelf.currPeripheral = peripheral;
         }
         */
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *uuidString = [defaults objectForKey:@"UUID"];
        if([peripheral.identifier.UUIDString isEqual:uuidString]){
            [central stopScan];
            weakSelf.currPeripheral = peripheral;
        }
        
        /*
         if([[advertisementData  objectForKey:@"kCBAdvDataLocalName"] hasPrefix:@"GCA30"]){
         [central stopScan];
         weakSelf.currPeripheral = peripheral;
         }*/
        
        /*
         if([peripheral.name isEqualToString:@"GCA30-555987"]){
         [central stopScan];
         weakSelf.currPeripheral = peripheral;
         baby.connectToPeripherals().begin();
         }*/
    }];
    
    //设置设备连接成功的委托
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"设备：%@--连接成功",peripheral.name);
        
        weakSelf.hud.mode = MBProgressHUDModeText;
        weakSelf.hud.label.text = @"Device connected!";
        [weakSelf.hud setMinShowTime:2];
        [weakSelf.hud showAnimated:YES];
        [weakSelf.hud hideAnimated:YES];
        //禁止返回按钮
        UIButton *btReturn = (UIButton *)[weakSelf.view viewWithTag:001];
        [btReturn setEnabled:YES];
    }];
    
    //设置连接设备失败的委托
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        weakSelf.hud.label.text = @"Device connected failed!\nPlease check the bluetooth!";
        [weakSelf.hud setMinShowTime:1];
        [weakSelf.hud showAnimated:YES];
        [weakSelf.hud hideAnimated:YES];
    }];
    
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry,device disconnected!" message:@"Would you like to connect the device again?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [baby cancelAllPeripheralsConnection];
            baby.scanForPeripherals().connectToPeripherals().discoverServices()
                .discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic()
                .readValueForDescriptors().begin();
            //[central connectPeripheral:self.currPeripheral options:nil];
            
            weakSelf.hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            weakSelf.hud.mode = MBProgressHUDModeIndeterminate;
            weakSelf.hud.label.text = @"Connecting to Device......";
            [weakSelf.hud showAnimated:YES];
        }];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIButton *btReturn = (UIButton *)[self.view viewWithTag:001];
            [btReturn setEnabled:YES];
        }];
        [alert addAction:actionOK];
        [alert addAction:actionCancel];
        [weakSelf presentViewController:alert animated:YES completion:^{
            ;
        }];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"Service discoverd:%@",service.UUID.UUIDString);
            //  NSLog(@"===service name:%@",service.UUID);
        }
    }];
    
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
        }
    }];
    
    //设置读取characteristics的委托
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
                [weakSelf updateStatus];
            }
        }
    }];
    
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
        [weakSelf getStatus];
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置写入数据成功的委托
    [baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        // NSLog(@"Write data successfully!");
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    //设置连接的设备的过滤器
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uuidString = [defaults objectForKey:@"UUID"];
    
    __block BOOL isFirst = YES;
    
    [baby setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        if(isFirst && [peripheralName isEqual:self.currPeripheral]){
            isFirst = NO;
        }
        return YES;
    }];
    //  return NO;
    //  }];
    //   */
    /*
     [baby setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
     if( [peripheralName isEqual:@"GCA30-555987"]){
     return YES;
     }
     return NO;
     }];*/
    
    /*
     [baby setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
     
     if( [peripheralName hasPrefix:@"GCA30"]){
     return YES;
     }
     return NO;
     }];*/
    
}

//获取设备状态（发送）
-(void) getStatus{
    if(self.characteristic != nil){
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x01;
        write[2] = 0x00;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
        //[self updateStatus];
    }
}

//进入设置页面
- (void) setting{
    [self performSegueWithIdentifier:@"setting" sender:self];
}

//进入连接页面
- (void) connect{
    [baby cancelAllPeripheralsConnection];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"UUID"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 更新界面状态（接收）
- (void) updateStatus{
    //两条线
    UIImageView *viewLine1 = (UIImageView *)[self.view viewWithTag:10];
    UIImageView *viewLine2 = (UIImageView *)[self.view viewWithTag:20];
    //模式A
    UIImageView *imageA = (UIImageView *)[self.view viewWithTag:101];
    //风机
    UIImageView *imageWindmachine = (UIImageView *) [self.view viewWithTag:102];
    //制冷
    UIImageView *imageCool = ( UIImageView *) [self.view viewWithTag:103];
    //制热
    UIImageView *imageWarm = (UIImageView *) [self.view viewWithTag:104];
    //湿度
    UIImageView *imageHumidity = (UIImageView *) [self.view viewWithTag:105];
    //灯
    UIImageView *imageLight = (UIImageView *) [self.view viewWithTag:201];
    //睡眠
    UIImageView *imageSleep = (UIImageView *) [self.view viewWithTag:202];
    //温度单位
    UIImageView *imageUnint = (UIImageView *) [self.view viewWithTag:203];
    //转换
    UIImageView *imageChange = (UIImageView *) [self.view viewWithTag:204];
    //温度十位
    UIImageView *imageTemperatureHigh = (UIImageView *) [self.view viewWithTag:205];
    //温度个位
    UIImageView *imageTemperatureLow = (UIImageView *) [self.view viewWithTag:206];
    //安静模式
    UIImageView *imageQuiet = (UIImageView *) [self.view viewWithTag:207];
    //正常模式
    UIImageView *imageNormal = (UIImageView *) [self.view viewWithTag:208];
    //强力模式
    UIImageView *imageTurbo = (UIImageView *) [self.view viewWithTag:209];
    //送风挡
    UIImageView *imageWind =  (UIImageView *)[self.view viewWithTag:301];
    //定时十位
    UIImageView *imageTimerHigh =(UIImageView *) [self.view viewWithTag:302];
    //定时个位
    UIImageView *imageTimerLow = (UIImageView *)[self.view viewWithTag:303];
    //小数点
    UIView *viewDot = (UIView *)[self.view viewWithTag:304];
    //定时小数位
    UIImageView *imageTimerDecimal = (UIImageView *)[self.view viewWithTag:305];
    //定时显示
    UIView *imageTimer = (UIImageView *)[self.view viewWithTag:306];
    //按钮区
    /*
     //开关
     UIButton *btPower = (UIButton *)[self.view viewWithTag:401];
     */
    //送风
    UIButton *btWind = (UIButton *)[self.view viewWithTag:402];
    
    //增加
    UIButton *btAdd = (UIButton *)[self.view viewWithTag:403];
    //开灯
    UIButton *btLight = (UIButton *)[self.view viewWithTag:404];
    //单位
    UIButton *btUnit = (UIButton *)[self.view viewWithTag:405];
    //模式
    UIButton *btMode = (UIButton *)[self.view viewWithTag:406];
    //定时
    UIButton *btTimer = (UIButton *)[self.view viewWithTag:407];
    //调低
    UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
    
    //睡眠
    UIButton *btQuit = (UIButton *)[self.view viewWithTag:409];
    //跳转
    UIButton *btTurbo = (UIButton *)[self.view viewWithTag:410];
    
    
    //关机状态下，除温度和单位外，其它都隐藏
    [viewLine1 setHidden:YES];
    [viewLine2 setHidden:YES];
    
    [imageA setHidden:YES];
    [imageWindmachine setHidden:YES];
    [imageCool setHidden:YES];
    [imageWarm setHidden:YES];
    [imageHumidity setHidden:YES];
    
    [imageLight setHidden:NO];
    [imageSleep setHidden:YES];
    [imageUnint setHidden:NO];
    [imageChange setHidden:YES];
    
    [imageTemperatureHigh setHidden:NO];
    [imageTemperatureLow setHidden:NO];
    
    [imageQuiet setHidden:YES];
    [imageNormal setHidden:YES];
    [imageTurbo setHidden:YES];
    
    [imageWind setHidden:YES];
    [imageTimerHigh setHidden:YES];
    [imageTimerLow setHidden:YES];
    [viewDot setHidden:YES];
    [imageTimerDecimal setHidden:YES];
    [imageTimer setHidden:YES];
    
    [btQuit setEnabled:YES];
    [btTurbo setEnabled:YES];
    [btWind setEnabled:YES];
    
    //1.显示设置（实时）温度和单位
    int temperatureHigh,temperatureLow;   //十位数，个位数
    if(self.dataRead.unit == 0x01){
        [imageUnint setImage:[UIImage imageNamed:@"celsius"]];  //摄氏
    }else{
        [imageUnint setImage:[UIImage imageNamed:@"fahrenheit"]];   //华氏
    }
    
    if(self.dataRead.logo == 0x01){
        [imageLight setHidden:NO];
    }else{
        [imageLight setHidden:YES];
    }
    
    temperatureHigh = self.dataRead.tempSetting/10; //-----------
    temperatureLow = self.dataRead.tempSetting%10;  //----------
    NSString *iconNameHigh = [NSString stringWithFormat:@"big%d",temperatureHigh];
    NSString *iconNameLow = [NSString stringWithFormat:@"big%d",temperatureLow];
    [imageTemperatureHigh setImage:[UIImage imageNamed:iconNameHigh]];
    [imageTemperatureLow setImage:[UIImage imageNamed:iconNameLow]];
    if (temperatureHigh>0) {
        [imageTemperatureHigh setHidden:NO];
    }else{
        [imageTemperatureHigh setHidden:YES];
    }
    // NSLog(@"设定温度：%d，实际温度%d",self.dataRead.tempSetting,self.dataRead.tempReal);
    
    //2.其它显示
    if(self.dataRead.power == 0x00){
        // NSLog(@"关机状态");
        [btWind setEnabled:NO];
        [btAdd  setEnabled:NO];
        [btUnit setEnabled:NO];
        [btMode setEnabled:NO];
        [btTimer setEnabled:NO];
        [btMinus setEnabled:NO];
        [btQuit setEnabled:NO];
        [btTurbo setEnabled:NO];
        
    }else{
        //  NSLog(@"开机状态");
        [btWind setEnabled:YES];
        [btAdd  setEnabled:YES];
        [btUnit setEnabled:YES];
        [btMode setEnabled:YES];
        [btTimer setEnabled:YES];
        [btMinus setEnabled:YES];
        [btQuit setEnabled:YES];
        [btTurbo setEnabled:YES];
        [viewLine1 setHidden:NO];
        [viewLine2 setHidden:NO];
        //2.1显示工作模式
        switch (self.dataRead.mode) {
            case 0x04:{    //自动模式睡眠和Turbo功能关闭，风速不可调
                [imageA setHidden:NO];
                [btQuit setEnabled:NO];
                [btTurbo setEnabled:NO];
                [btWind setEnabled:NO];
                break;
            }
            case 0x02:[imageWindmachine setHidden:NO];break;
            case 0x00:[imageCool setHidden:NO];break;
            case 0x03:[imageWarm setHidden:NO];break;
            case 0x01:{
                [imageHumidity setHidden:NO];
                [btQuit setEnabled:NO];
                [btTurbo setEnabled:NO];
                [btWind setEnabled:NO];
                break;
            }
            default:break;
        }
        //2.2显示设置风量
        [imageWind setHidden:NO];
        NSString *iconWindName = [NSString stringWithFormat:@"wind%d",self.dataRead.wind ];
        if ([iconWindName isEqualToString:@"wind0" ]) {
            iconWindName = @"autowind";
        }
        [imageWind setImage:[UIImage imageNamed:iconWindName]];
        
        //2.3显示安静或强力模式
        if(self.dataRead.sleep == 0x01){
            [imageQuiet setHidden:NO];
            [imageSleep setHidden:NO];
        }else if(self.dataRead.turbo == 0x01){
            [imageTurbo setHidden:NO];
            [imageChange setHidden:NO];
        }else{
            [imageNormal setHidden:NO];
            [imageSleep setHidden:YES];
            [imageChange setHidden:YES];
        }
        //2.4设置logo灯
        /*
        if(self.dataRead.logo == 0x01){
            [imageLight setHidden:NO];
        }else{
            [imageLight setHidden:YES];
        }*/
        //2.5显示定时
        if(self.dataRead.countdown == 0x00){
            //关闭定时
            [imageTimerHigh setHidden:YES];
            [imageTimerLow setHidden:YES];
            [viewDot setHidden:YES];
            [imageTimerDecimal setHidden:YES];
            [imageTimer setHidden:YES];
        }else{
            //开启定时
            [imageTimerLow setHidden:NO];
            [viewDot setHidden:NO];
            [imageTimerDecimal setHidden:NO];
            [imageTimer setHidden:NO];
            
            int timerHigh,timerLow,timerDecimal;   //十位数，个位数
            timerHigh = self.dataRead.countdown/10/10;
            timerLow = self.dataRead.countdown/10%10;
            timerDecimal = self.dataRead.countdown/5%2*5;
            NSString *iconNameHigh = [NSString stringWithFormat:@"small%d",timerHigh];
            NSString *iconNameLow = [NSString stringWithFormat:@"small%d",timerLow];
            NSString *iconDecimal = [NSString stringWithFormat:@"small%d",timerDecimal];
            if(timerHigh>0){
                [imageTimerHigh setHidden:NO];
                [imageTimerHigh setImage:[UIImage imageNamed:iconNameHigh]];
            }
            [imageTimerLow setImage:[UIImage imageNamed:iconNameLow]];
            [imageTimerDecimal setImage:[UIImage imageNamed:iconDecimal]];
        }
    }
    [self.view setNeedsDisplay];
}

#pragma mark - 按钮事件
//开关机
- (void) power:(id)sender{
//    UIButton *btPower = (UIButton *)[self.view viewWithTag:401];
//    [btPower setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //送风
//    UIButton *btWind = (UIButton *)[self.view viewWithTag:402];
//    [btWind setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //增加
//    UIButton *btAdd = (UIButton *)[self.view viewWithTag:403];
//    [btAdd setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //开灯
//    UIButton *btLight = (UIButton *)[self.view viewWithTag:404];
//    [btLight setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //单位
//    UIButton *btUnit = (UIButton *)[self.view viewWithTag:405];
//    [btUnit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //模式
//    UIButton *btMode = (UIButton *)[self.view viewWithTag:406];
//    [btMode setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //定时
//    UIButton *btTimer = (UIButton *)[self.view viewWithTag:407];
//    [btTimer setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //调低
//    UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
//    [btMinus setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //睡眠
//    UIButton *btQuit = (UIButton *)[self.view viewWithTag:409];
//    [btQuit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //跳转
//    UIButton *btturbo = (UIButton *)[self.view viewWithTag:410];
//    [btturbo setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    self.fanSelected = NO;
//    self.lightSelected = NO;
//    self.unitSelected = NO;
//    self.modeSelected = NO;
//    self.timerSelected = NO;
//    self.quiteSelected = NO;
//    self.turboSelected = NO;
    
    if(self.characteristic != nil){
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x10;
        if(self.dataRead.power == 0x00){
            write[2] = 0x01;
            [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
        }else{
            write[2] = 0x00;
        }
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
}

//设置风量
-(void) setWind:(id)sender{
    
//    UIButton *btPower = (UIButton *)[self.view viewWithTag:401];
//    [btPower setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //送风
//    UIButton *btWind = (UIButton *)[self.view viewWithTag:402];
//    [btWind setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
//    //增加
//    UIButton *btAdd = (UIButton *)[self.view viewWithTag:403];
//    [btAdd setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //减低
//    UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
//    [btMinus setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //开灯
//    UIButton *btLight = (UIButton *)[self.view viewWithTag:404];
//    [btLight setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //单位
//    UIButton *btUnit = (UIButton *)[self.view viewWithTag:405];
//    [btUnit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //模式
//    UIButton *btMode = (UIButton *)[self.view viewWithTag:406];
//    [btMode setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //定时
//    UIButton *btTimer = (UIButton *)[self.view viewWithTag:407];
//    [btTimer setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    /*
//     //调低
//     UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
//     [btMinus setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
//     */
//    //睡眠
//    UIButton *btQuit = (UIButton *)[self.view viewWithTag:409];
//    [btQuit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //跳转
//    UIButton *btturbo = (UIButton *)[self.view viewWithTag:410];
//    [btturbo setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    
//    self.fanSelected = YES;
//    self.lightSelected = NO;
//    self.unitSelected = NO;
//    self.modeSelected = NO;
//    self.timerSelected = NO;
//    self.quiteSelected = NO;
//    self.turboSelected = NO;
    
    if((self.characteristic != nil) && (self.dataRead.power == 0x01)){
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x12;
        write[2] = (self.dataRead.wind + 1)%5;   //五档？
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    }
}


//按钮加
-(void) setAdd:(id)sender{
    //睡眠
//    UIButton *btQuit = (UIButton *)[self.view viewWithTag:409];
//    [btQuit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //跳转
//    UIButton *btturbo = (UIButton *)[self.view viewWithTag:410];
//    [btturbo setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    UIButton *btPower = (UIButton *)[self.view viewWithTag:401];
//    [btPower setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //送风
//    UIButton *btWind = (UIButton *)[self.view viewWithTag:402];
//    [btWind setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //增加
//    UIButton *btAdd = (UIButton *)[self.view viewWithTag:403];
//    if(self.dataRead.power == 0x01){
//        [btAdd setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
//    }else{
//        [btAdd setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    }
//
//     //开灯
//     UIButton *btLight = (UIButton *)[self.view viewWithTag:404];
//    [btLight setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //单位
//    UIButton *btUnit = (UIButton *)[self.view viewWithTag:405];
//    [btUnit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //模式
//    UIButton *btMode = (UIButton *)[self.view viewWithTag:406];
//    [btMode setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //定时
//    UIButton *btTimer = (UIButton *)[self.view viewWithTag:407];
//    [btTimer setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//     //调低
//     UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
//     [btMinus setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    
    Byte  write[6];
    write[0] = 0xAA;
    write[1] = 0x11;
    write[2] = self.dataRead.tempSetting + 1;
    //write[2] = 23;
    write[4] = 0xFF & CalcCRC(&write[1], 2);
    write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
    write[5] = 0x55;
    NSData *data = [[NSData alloc]initWithBytes:write length:6];
    [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    // }
    
    /*
     //2.模式选择按钮打开
     if((self.characteristic != nil) && (self.dataRead.power == 0x01)&&self.modeSelected){
     Byte  write[6];
     write[0] = 0xAA;
     write[1] = 0x13;
     write[2] = (self.dataRead.mode + 3)%5;   //4~2~0~3~1 自动-排风-制冷-制热-除湿
     write[4] = 0xFF & CalcCRC(&write[1], 2);
     write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
     write[5] = 0x55;
     
     NSData *data = [[NSData alloc]initWithBytes:write length:6];
     [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
     }
     
     //3.风量按钮打开
     if((self.characteristic != nil) && (self.dataRead.power == 0x01)&&self.fanSelected){
     Byte  write[6];
     write[0] = 0xAA;
     write[1] = 0x12;
     write[2] = (self.dataRead.wind + 1)%5;   //五档？
     write[4] = 0xFF & CalcCRC(&write[1], 2);
     write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
     write[5] = 0x55;
     
     NSData *data = [[NSData alloc]initWithBytes:write length:6];
     [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
     }
     
     //4.定时按钮打开
     if((self.characteristic != nil) && (self.dataRead.power == 0x01) && self.timerSelected){
     Byte  write[6];
     write[0] = 0xAA;
     write[1] = 0x16;
     write[2] = (self.dataRead.countdown + 5)%260;
     write[4] = 0xFF & CalcCRC(&write[1], 2);
     write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
     write[5] = 0x55;
     
     NSData *data = [[NSData alloc]initWithBytes:write length:6];
     [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
     }
     
     //5.Logo灯按钮打开
     if((self.characteristic != nil) && (self.dataRead.power == 0x01) && self.lightSelected && self.dataRead.brightness<9){
     Byte  write[6];
     write[0] = 0xAA;
     write[1] = 0x1D;
     write[2] = self.dataRead.brightness + 1;
     write[4] = 0xFF & CalcCRC(&write[1], 2);
     write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
     write[5] = 0x55;
     
     NSData *data = [[NSData alloc]initWithBytes:write length:6];
     [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
     }
     */
}

//按钮减
-(void) setMinus:(id)sender{
    //睡眠
//    UIButton *btQuit = (UIButton *)[self.view viewWithTag:409];
//    [btQuit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //跳转
//    UIButton *btturbo = (UIButton *)[self.view viewWithTag:410];
//    [btturbo setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    UIButton *btPower = (UIButton *)[self.view viewWithTag:401];
//    [btPower setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //送风
//    UIButton *btWind = (UIButton *)[self.view viewWithTag:402];
//    [btWind setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //增加
//    UIButton *btAdd = (UIButton *)[self.view viewWithTag:403];
//    [btAdd setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //减低
//    UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
//    if(self.dataRead.power == 0x01){
//        [btMinus setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
//    }else{
//        [btMinus setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    }
//
//    //开灯
//     UIButton *btLight = (UIButton *)[self.view viewWithTag:404];
//    [btLight setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //单位
//    UIButton *btUnit = (UIButton *)[self.view viewWithTag:405];
//    [btUnit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //模式
//    UIButton *btMode = (UIButton *)[self.view viewWithTag:406];
//    [btMode setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //定时
//    UIButton *btTimer = (UIButton *)[self.view viewWithTag:407];
//    [btTimer setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
    

    Byte  write[6];
    write[0] = 0xAA;
    write[1] = 0x11;
    write[2] = self.dataRead.tempSetting - 1;
    write[4] = 0xFF & CalcCRC(&write[1], 2);
    write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
    write[5] = 0x55;
    NSData *data = [[NSData alloc]initWithBytes:write length:6];
    [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    //}
    /*
     //2.模式选择按钮打开
     if((self.characteristic != nil) && (self.dataRead.power == 0x01)&&self.modeSelected){
     Byte  write[6];
     write[0] = 0xAA;
     write[1] = 0x13;
     write[2] = (self.dataRead.mode + 2 )%5;   //4~2~0~3~1 自动-排风-制冷-制热-除湿
     write[4] = 0xFF & CalcCRC(&write[1], 2);
     write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
     write[5] = 0x55;
     
     NSData *data = [[NSData alloc]initWithBytes:write length:6];
     [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
     }
     //3.风量按钮打开
     if((self.characteristic != nil) && (self.dataRead.power == 0x01)&&self.fanSelected){
     Byte  write[6];
     write[0] = 0xAA;
     write[1] = 0x12;
     write[2] = (self.dataRead.wind + 4)%5;   //五档？
     write[4] = 0xFF & CalcCRC(&write[1], 2);
     write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
     write[5] = 0x55;
     
     NSData *data = [[NSData alloc]initWithBytes:write length:6];
     [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
     }
     //4.定时按钮打开
     if((self.characteristic != nil) && (self.dataRead.power == 0x01) && self.timerSelected){
     Byte  write[6];
     write[0] = 0xAA;
     write[1] = 0x16;
     write[2] = (self.dataRead.countdown - 5)%260;
     write[4] = 0xFF & CalcCRC(&write[1], 2);
     write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
     write[5] = 0x55;
     
     NSData *data = [[NSData alloc]initWithBytes:write length:6];
     [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
     }
     //5.Logo灯按钮打开
     if((self.characteristic != nil) && (self.dataRead.power == 0x01) && self.lightSelected && self.dataRead.brightness>0){
     Byte  write[6];
     write[0] = 0xAA;
     write[1] = 0x1D;
     write[2] = self.dataRead.brightness - 1;
     write[4] = 0xFF & CalcCRC(&write[1], 2);
     write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
     write[5] = 0x55;
     
     NSData *data = [[NSData alloc]initWithBytes:write length:6];
     [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
     }
     */
}


//设置亮度
-(void) setLight:(id)sender{
//    UIButton *btPower = (UIButton *)[self.view viewWithTag:401];
//    [btPower setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //送风
//    UIButton *btWind = (UIButton *)[self.view viewWithTag:402];
//    [btWind setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //增加
//    UIButton *btAdd = (UIButton *)[self.view viewWithTag:403];
//    [btAdd setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //减低
//    UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
//    [btMinus setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //开灯
//    UIButton *btLight = (UIButton *)[self.view viewWithTag:404];
//    [btLight setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
//
//    //单位
//    UIButton *btUnit = (UIButton *)[self.view viewWithTag:405];
//    [btUnit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //模式
//    UIButton *btMode = (UIButton *)[self.view viewWithTag:406];
//    [btMode setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //定时
//    UIButton *btTimer = (UIButton *)[self.view viewWithTag:407];
//    [btTimer setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //睡眠
//    UIButton *btQuit = (UIButton *)[self.view viewWithTag:409];
//    [btQuit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //跳转
//    UIButton *btturbo = (UIButton *)[self.view viewWithTag:410];
//    [btturbo setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//
//    self.fanSelected = NO;
//    self.lightSelected = YES;
//    self.unitSelected = NO;
//    self.modeSelected = NO;
//    self.timerSelected = NO;
//    self.quiteSelected = NO;
//    self.turboSelected = NO;
//
    
    if(self.characteristic != nil){
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x18;
        write[2] = (self.dataRead.logo + 1)%2;   //开logo灯时开氛围灯
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    }
}

//设置单位
-(void) setUnit:(id)sender{
    //电源
//    UIButton *btPower = (UIButton *)[self.view viewWithTag:401];
//    [btPower setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //送风
//    UIButton *btWind = (UIButton *)[self.view viewWithTag:402];
//    [btWind setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //增加
//    UIButton *btAdd = (UIButton *)[self.view viewWithTag:403];
//    [btAdd setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //减低
//    UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
//    [btMinus setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //开灯
//    UIButton *btLight = (UIButton *)[self.view viewWithTag:404];
//    [btLight setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //单位
//    UIButton *btUnit = (UIButton *)[self.view viewWithTag:405];
//    [btUnit setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
//
//    //模式
//    UIButton *btMode = (UIButton *)[self.view viewWithTag:406];
//    [btMode setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //定时
//    UIButton *btTimer = (UIButton *)[self.view viewWithTag:407];
//    [btTimer setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //睡眠
//    UIButton *btQuit = (UIButton *)[self.view viewWithTag:409];
//    [btQuit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //跳转
//    UIButton *btturbo = (UIButton *)[self.view viewWithTag:410];
//    [btturbo setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//
//    self.fanSelected = NO;
//    self.lightSelected = NO;
//    self.unitSelected = YES;
//    self.modeSelected = NO;
//    self.timerSelected = NO;
//    self.quiteSelected = NO;
//    self.turboSelected = NO;
    
    
    if((self.characteristic != nil) && (self.dataRead.power == 0x01)){
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x17;
        write[2] = self.dataRead.unit;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    }
}

//设置工作模式
-(void) setMode:(id)sender{
    //开关
//    UIButton *btPower = (UIButton *)[self.view viewWithTag:401];
//    [btPower setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //送风
//    UIButton *btWind = (UIButton *)[self.view viewWithTag:402];
//    [btWind setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//     //增加
//     UIButton *btAdd = (UIButton *)[self.view viewWithTag:403];
//    [btAdd setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //开灯
//    UIButton *btLight = (UIButton *)[self.view viewWithTag:404];
//    [btLight setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //单位
//    UIButton *btUnit = (UIButton *)[self.view viewWithTag:405];
//    [btUnit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //模式
//    UIButton *btMode = (UIButton *)[self.view viewWithTag:406];
//    [btMode setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
//
//    //定时
//    UIButton *btTimer = (UIButton *)[self.view viewWithTag:407];
//    [btTimer setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//     //调低
//     UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
//    [btMinus setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //睡眠
//    UIButton *btQuit = (UIButton *)[self.view viewWithTag:409];
//    [btQuit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //跳转
//    UIButton *btturbo = (UIButton *)[self.view viewWithTag:410];
//    [btturbo setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    self.fanSelected = NO;
//    self.lightSelected = NO;
//    self.unitSelected = NO;
//    self.modeSelected = YES;
//    self.timerSelected = NO;
//    self.quiteSelected = NO;
//    self.turboSelected = NO;
    
    
    if((self.characteristic != nil) && (self.dataRead.power == 0x01)){
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x13;
        write[2] = (self.dataRead.mode + 3)%5;   //4~2~0~3~1 自动-排风-制冷-制热-除湿
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    }
}

//设置定时
-(void) setTime:(id)sender{
    //名字不能叫做setTimer,可能系统已使用
//    UIButton *btPower = (UIButton *)[self.view viewWithTag:401];
//    [btPower setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //送风
//    UIButton *btWind = (UIButton *)[self.view viewWithTag:402];
//    [btWind setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //增加
//    UIButton *btAdd = (UIButton *)[self.view viewWithTag:403];
//    [btAdd setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //减低
//    UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
//    [btMinus setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//    //开灯
//    UIButton *btLight = (UIButton *)[self.view viewWithTag:404];
//    [btLight setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //单位
//    UIButton *btUnit = (UIButton *)[self.view viewWithTag:405];
//    [btUnit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //模式
//    UIButton *btMode = (UIButton *)[self.view viewWithTag:406];
//    [btMode setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //定时
//    UIButton *btTimer = (UIButton *)[self.view viewWithTag:407];
//    [btTimer setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
//    /*
//     //调低
//     UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
//     [btMinus setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
//     */
//    //睡眠
//    UIButton *btQuit = (UIButton *)[self.view viewWithTag:409];
//    [btQuit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //跳转
//    UIButton *btturbo = (UIButton *)[self.view viewWithTag:410];
//    [btturbo setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//
//    self.fanSelected = NO;
//    self.lightSelected = NO;
//    self.unitSelected = NO;
//    self.modeSelected = NO;
//    self.timerSelected = YES;
//    self.quiteSelected = NO;
//    self.turboSelected = NO;
//
    
    if((self.characteristic != nil) && (self.dataRead.power == 0x01)){
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x16;
        write[2] = (self.dataRead.countdown + 5) % 125;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    }
}

//设置安静模式
-(void) setQuiet:(id)sender{
//    UIButton *btPower = (UIButton *)[self.view viewWithTag:401];
//    [btPower setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //送风
//    UIButton *btWind = (UIButton *)[self.view viewWithTag:402];
//    [btWind setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //增加
//    UIButton *btAdd = (UIButton *)[self.view viewWithTag:403];
//    [btAdd setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //开灯
//    UIButton *btLight = (UIButton *)[self.view viewWithTag:404];
//    [btLight setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //单位
//    UIButton *btUnit = (UIButton *)[self.view viewWithTag:405];
//    [btUnit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //模式
//    UIButton *btMode = (UIButton *)[self.view viewWithTag:406];
//    [btMode setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //定时
//    UIButton *btTimer = (UIButton *)[self.view viewWithTag:407];
//    [btTimer setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //调低
//    UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
//    [btMinus setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //睡眠
//    UIButton *btQuit = (UIButton *)[self.view viewWithTag:409];
//    [btQuit setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
//    //跳转
//    UIButton *btturbo = (UIButton *)[self.view viewWithTag:410];
//    [btturbo setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//
//
//    self.fanSelected = NO;
//    self.lightSelected = NO;
//    self.unitSelected = NO;
//    self.modeSelected = NO;
//    self.timerSelected = NO;
//    self.quiteSelected = NO;
//    self.turboSelected = NO;
//
    
    if((self.characteristic != nil) && (self.dataRead.power == 0x01)){
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x15;
        write[2] = (self.dataRead.sleep + 1)%2;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    }
}

//设置增强模式
-(void) setTurbo:(id)sender{
//    UIButton *btPower = (UIButton *)[self.view viewWithTag:401];
//    [btPower setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //送风
//    UIButton *btWind = (UIButton *)[self.view viewWithTag:402];
//    [btWind setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //增加
//    UIButton *btAdd = (UIButton *)[self.view viewWithTag:403];
//    [btAdd setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //开灯
//    UIButton *btLight = (UIButton *)[self.view viewWithTag:404];
//    [btLight setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //单位
//    UIButton *btUnit = (UIButton *)[self.view viewWithTag:405];
//    [btUnit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //模式
//    UIButton *btMode = (UIButton *)[self.view viewWithTag:406];
//    [btMode setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //定时
//    UIButton *btTimer = (UIButton *)[self.view viewWithTag:407];
//    [btTimer setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //调低
//    UIButton *btMinus = (UIButton *)[self.view viewWithTag:408];
//    [btMinus setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //睡眠
//    UIButton *btQuit = (UIButton *)[self.view viewWithTag:409];
//    [btQuit setBackgroundColor:[UIColor colorWithRed:35.0/255 green:34.0/255 blue:31.0/255 alpha:1.0]];
//    //跳转
//    UIButton *btturbo = (UIButton *)[self.view viewWithTag:410];
//    [btturbo setBackgroundColor:[UIColor colorWithRed:22.0/255 green:138.0/255 blue:214.0/255 alpha:1.0]];
//
//
//    self.fanSelected = NO;
//    self.lightSelected = NO;
//    self.unitSelected = NO;
//    self.modeSelected = NO;
//    self.timerSelected = NO;
//    self.quiteSelected = NO;
//    self.turboSelected = NO;
    
    
    if((self.characteristic != nil) && (self.dataRead.power == 0x01)){
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x14;
        write[2] = (self.dataRead.turbo + 1)%2;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    }
}

-(void)fanScaleAjust:(NSNotification *) notify{
    NSDictionary *dic = [notify userInfo];
    NSString *str = [dic valueForKey:@"fanScale"];
    self.dataRead.wind = [str intValue];
    [self updateStatus];
    [self.view setNeedsLayout];
}

-(void)colorAjust:(NSNotification *) notify{
    NSDictionary *dic = [notify userInfo];
    NSString *strRed = [dic valueForKey:@"red"];
    NSString *strGreen = [dic valueForKey:@"green"];
    NSString *strBlue = [dic valueForKey:@"blue"];
    self.dataRead.red = [strRed intValue];
    self.dataRead.green = [strGreen intValue];
    self.dataRead.blue = [strBlue intValue];
    [self updateStatus];
    [self.view setNeedsLayout];
}

-(void)timeAjust:(NSNotification *) notify{
    NSDictionary *dic = [notify userInfo];
    NSString *str = [dic valueForKey:@"time"];
    self.dataRead.atmosphere = [str intValue];
    [self updateStatus];
    [self.view setNeedsLayout];
    NSLog(@"atmosphere changed to %d", [str intValue]);
}


-(void)sleepAjust:(NSNotification *) notify{
    NSDictionary *dic = [notify userInfo];
    NSString *str = [dic valueForKey:@"timescale"];
    self.dataRead.sleep = [str intValue];
    [self updateStatus];
    [self.view setNeedsLayout];
    NSLog(@"sleep timer changed to %d", [str intValue]);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //  segue.destinationViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    if([segue.identifier isEqualToString:@"setting"]){
        SettingViewController *settingViewController = ( SettingViewController *)[segue destinationViewController];
        settingViewController.characteristic = self.characteristic;
        settingViewController.currPeripheral = self.currPeripheral;
        settingViewController.dataRead = self.dataRead;
    }
    
    if([segue.identifier isEqualToString:@"connect"]){
        ConnectViewController *connectViewController = (ConnectViewController *)[segue destinationViewController];
        connectViewController.characteristic = self.characteristic;
        connectViewController.currPeripheral = self.currPeripheral;
        connectViewController.dataRead = self.dataRead;
    }
    
    
}

@end
