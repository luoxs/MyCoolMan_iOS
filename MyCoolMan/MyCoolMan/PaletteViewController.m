//
//  paletteViewController.m
//  
//
//  Created by 罗路雅 on 2023/2/4.
//

#import "PaletteViewController.h"
#import "SDAutoLayout.h"
#import "viewCenter.h"
#import "crc.h"

@interface PaletteViewController ()
@property (nonatomic,retain)  UITapGestureRecognizer *gestureTap;
@property (nonatomic,retain)  UIPanGestureRecognizer *gesturePan;
@property (nonatomic,retain)  UITapGestureRecognizer *gesture;
@property float red;
@property float green;
@property float blue;
@property (nonatomic, strong) UIButton *btUpRadio;
@property (nonatomic, strong) UIButton *btDownRadio;
@property (nonatomic, strong) UIButton *selectedBt;  // 选中按钮
@end

@implementation PaletteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.red = 0;
    self.green = 1.0;
    self.blue = 0;
    //baby = [BabyBluetooth shareBabyBluetooth];
    [self setAutoLayout];
}

/*
//懒加载
-(UIButton *)btUpRadio{
    if(!self.btUpRadio){
        self.btUpRadio = [[UIButton alloc]init];
    }
    return self.btUpRadio;
}

-(UIButton *)btDownRadio{
    if(!self.btDownRadio){
        self.btDownRadio = [[UIButton alloc]init];
    }
    return self.btDownRadio;
}
*/

- (void) setAutoLayout{
    
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
        .heightRatioToView(self.view, 50.0/436);
    
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
    
    //标题
    UIImageView *imageTitle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"type"]];
    [titleView addSubview:imageTitle];
    imageTitle.sd_layout
        .centerXEqualToView(titleView)
        .centerYIs(37.0/436*viewY)
        .heightIs(18.0/248*viewX)
        .autoWidthRatio(680.0/102);
    
    //色环区
    UIView *paletteView = [UIView new];
    [self.view addSubview:paletteView];
    
    [paletteView setBackgroundColor:[UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0]];
    //[paletteView setBackgroundColor:[UIColor whiteColor]];
    paletteView.sd_layout
        .topSpaceToView(titleView, 12.0/436*viewY)
        .leftSpaceToView(self.view,12.0/436*viewX)
        .rightSpaceToView(self.view,12.0/436*viewX)
        .heightRatioToView(self.view,180.0/436);
    [paletteView.layer setCornerRadius:8.0];
    paletteView.userInteractionEnabled = YES;     //视图支持交互
    self.gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handle:)];
    self.gestureTap.numberOfTouchesRequired = 1;
    [paletteView addGestureRecognizer:self.gestureTap];
    
    self.gesturePan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector((handle:))];
    [paletteView addGestureRecognizer:self.gesturePan];
    
    //圆环
    UIImageView *imageCircle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle"]];
    //[imageCircle setBackgroundColor:[UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0]];
    [paletteView addSubview:imageCircle];
    imageCircle.sd_layout
        .centerXEqualToView(paletteView)
        .centerYEqualToView(paletteView)
        .widthRatioToView(paletteView, 0.618)
        .heightEqualToWidth();
    
    //中心圆
    ViewCenter *viewCenter = [[ViewCenter alloc] init];
    viewCenter.backgroundColor = [UIColor colorWithRed:0 green:0.9 blue:0 alpha:0];
    [paletteView addSubview:viewCenter];
    viewCenter.sd_layout
        .centerXEqualToView(paletteView)
        .centerYEqualToView(paletteView)
        .widthRatioToView(paletteView, 0.4)
        .heightEqualToWidth();

    viewCenter.greenValue = self.dataRead.red;
    viewCenter.redValue = self.dataRead.green;
    viewCenter.blueValue = self.dataRead.blue;
    [viewCenter setTag:101];
    
    //单选按钮
    self.btUpRadio = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btUpRadio setSelected:YES];
    [paletteView addSubview:self.btUpRadio];
    self.btUpRadio.layer.cornerRadius = 10.0; // 按钮的边框弧度
    self.btUpRadio.clipsToBounds = YES;
    self.btUpRadio.sd_layout
        .leftSpaceToView(paletteView, 30.0/248*viewX)
        .bottomSpaceToView(paletteView, 12.0/436*viewY)
        .heightIs(20)
        .widthIs(20);
    if(self.dataRead.atmosphere == 0){
        [self.btUpRadio setBackgroundColor:[UIColor blackColor]];
    }else{
        self.btUpRadio.backgroundColor = [UIColor whiteColor];
    }
    
    //文字在按钮右边
    UILabel *labelUp = [UILabel new];
    labelUp.text = @"manual";
    [paletteView addSubview:labelUp];
    labelUp.sd_layout
        .centerYEqualToView(self.btUpRadio)
        .leftSpaceToView(self.btUpRadio, 10)
        .heightIs(20)
        .widthIs(200);
    
    //滑块区
    UIView *slideView = [UIView new];
    [self.view addSubview:slideView];
    [slideView setBackgroundColor:[UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0]];
    slideView.sd_layout
        .topSpaceToView(paletteView, 12.0/436*viewY)
        .leftSpaceToView(self.view,8.0/248*viewX)
        .rightSpaceToView(self.view,12.0/436*viewX)
        .heightRatioToView(self.view,80.0/436);
        //.bottomSpaceToView(self.view, 8.0/248*viewY);
    [slideView.layer setCornerRadius:8.0];
    
    self.gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handle1:)];
    self.gesture.numberOfTouchesRequired = 1;
    [slideView addGestureRecognizer:self.gesture];
    
    //单选按钮
    self.btDownRadio = [UIButton buttonWithType:UIButtonTypeCustom];
    [slideView addSubview:self.btDownRadio];
    self.btDownRadio.layer.cornerRadius = 10.0; // 按钮的边框弧度
    self.btDownRadio.clipsToBounds = YES;
    self.btDownRadio.sd_layout
        .leftSpaceToView(slideView, 30.0/248*viewX)
        .topSpaceToView(slideView, 12.0/436*viewY)
        .heightIs(20)
        .widthIs(20);
    if(self.dataRead.atmosphere == 0){
        [self.btDownRadio setBackgroundColor:[UIColor whiteColor]];
    }else{
        self.btDownRadio.backgroundColor = [UIColor blackColor];
    }
    
    //文字在按钮右边
    UILabel *labelDown = [UILabel new];
    labelDown.text = @"automatic";
    [slideView addSubview:labelDown];
    labelDown.sd_layout
        .centerYEqualToView(self.btDownRadio)
        .leftSpaceToView(self.btDownRadio, 10)
        .heightIs(20)
        .widthIs(150);
    
    //时间显示
    UILabel *labelTime = [UILabel new];
    [slideView addSubview:labelTime];
    labelTime.text = [NSString stringWithFormat:@"Time: %ds",self.dataRead.atmosphere];
    if(self.dataRead.atmosphere ==0 ){
        labelTime.text = [NSString stringWithFormat:@"Time: 5s"];
    }
    labelTime.sd_layout
        .centerYEqualToView(labelDown)
        .heightRatioToView(labelDown, 1)
        .rightSpaceToView(slideView, 20);
    [labelTime setSingleLineAutoResizeWithMaxWidth:200];
    [labelTime setTag:100];
    
    //滑块
    UISlider *slideTime = [UISlider new];
    [slideView addSubview:slideTime];
    slideTime.sd_layout
        .topSpaceToView(labelTime, 16.0/436*viewY)
        .leftSpaceToView(slideView,30.0/248*viewX)
        .rightSpaceToView(slideView,30.0/248*viewX);
    [slideView setTag:500];
    [slideTime addTarget:self action:@selector(chgTime:) forControlEvents:UIControlEventTouchUpInside];
    [slideTime setValue:0];
    [slideTime setContinuous:YES];
    [slideTime setTag:205];
    if(self.dataRead.atmosphere >0){
        [slideTime setEnabled:YES];
        [slideTime setValue:self.dataRead.atmosphere/10.0];
    }else{
        [slideTime setEnabled:NO];
        [slideTime setValue:0.5];
    }
    
    //灯光调整区
    UIView *lightView = [UIView new];
    [self.view addSubview:lightView];
    [lightView setBackgroundColor:[UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0]];
    lightView.sd_layout
        .topSpaceToView(slideView, 12.0/436*viewY)
        .leftSpaceToView(self.view,8.0/248*viewX)
        .rightSpaceToView(self.view,12.0/436*viewX)
        .heightRatioToView(self.view, 80.0/436);
    [lightView.layer setCornerRadius:8.0];
    
    /*
    self.gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handle1:)];
    self.gesture.numberOfTouchesRequired = 1;
    [lightView addGestureRecognizer:self.gesture];*/
    
    //文字在左边
    UILabel *labelLight = [UILabel new];
    labelLight.text = @"brightness";
    [lightView addSubview:labelLight];
    labelLight.sd_layout
        .topSpaceToView(lightView, 12.0/436*viewY)
        .leftSpaceToView(lightView, 30.0/248*viewX)
        .heightIs(20)
        .widthIs(100);
    
    //亮度显示
    UILabel *labelBright = [UILabel new];
    [lightView addSubview:labelBright];
    labelBright.text = [NSString stringWithFormat:@": %d",self.dataRead.brightness];
    if(self.dataRead.brightness ==0 ){
        labelBright.text = [NSString stringWithFormat:@": 5"];
    }
    labelBright.sd_layout
        .centerYEqualToView(labelLight)
        .heightRatioToView(labelLight, 1)
        .leftSpaceToView(labelLight, 2.0);
    [labelBright setSingleLineAutoResizeWithMaxWidth:150];
    [labelBright setTag:201];
    
    //滑块
    UISlider *slideLight = [UISlider new];
    [lightView addSubview:slideLight];
    slideLight.sd_layout
        .topSpaceToView(labelLight, 16.0/436*viewY)
        .leftSpaceToView(lightView,30.0/248*viewX)
        .rightSpaceToView(lightView,30.0/248*viewX);
    [slideLight setTag:600];
    [slideLight addTarget:self action:@selector(chgLight:) forControlEvents:UIControlEventTouchUpInside];
    [slideLight setValue:0];
    [slideLight setContinuous:YES];
    [slideLight setTag:305];
    if(self.dataRead.brightness>0){
        [slideLight setValue:self.dataRead.brightness/10.0*1.11];
    }else{
        [slideLight setValue:0.5];
    }
}


#pragma mark - 处理点击和拖动事件
-(void) handle:(UITapGestureRecognizer *)recognizer{
    [self.btUpRadio setBackgroundColor:[UIColor blackColor]];
    [self.btDownRadio setBackgroundColor:[UIColor whiteColor]];
    UISlider *slideTime = [self.view viewWithTag:205];
    [slideTime setEnabled:NO];
    
    CGFloat pi = 3.14159;
    CGPoint pointTap = [recognizer locationInView:self.view];
    //圆心坐标
    CGFloat coordX = self.view.width * 0.5;
    CGFloat coordY = self.view.height * (62+248/2)/436;
    
    //arc为从原点算起的角度，0～pi
    CGFloat value = (pointTap.x-coordX)/sqrtf((pointTap.x-coordX) * (pointTap.x-coordX)+ (pointTap.y-coordY) * (pointTap.y-coordY));
    
    CGFloat arc = acosf(value);
    
    //绿色通道值
    if(arc < 2.0/3.0 * pi){
        self.green = (pi*2.0/3.0 - arc)/(pi * 2.0/3.0);
    }else{
        self.green = 0;
    }
    
    //红色通道值
    if(pointTap.y > coordY && arc<2.0/3.0 *pi ){
        self.red = 0.0;
    }else if(pointTap.y <coordY){
        self.red = 1.0 - fabs((arc - pi * 2.0/3.0)/(pi * 2.0/3.0));
    }else{
        self.red = fabs((arc - pi * 2.0/3.0)/(pi * 2.0/3.0));
    }
    
    //蓝色通道值
    if( pointTap.y < coordY && arc<2.0/3.0 *pi){
        self.blue = 0;
    }else if(pointTap.y <coordY){
        self.blue = fabs((arc - pi * 2.0/3.0)/(pi * 2.0/3.0));
    }else{
        self.blue = 1.0 - fabs((arc - pi * 2.0/3.0)/(pi * 2.0/3.0));
    }
    //输出值
    //   NSLog(@"green:%f--red:%f--blue:%f",self.green,self.red,self.blue);
    ViewCenter *viewCenter = (ViewCenter *)[self.view viewWithTag:101];
    viewCenter.greenValue = self.green;
    viewCenter.redValue = self.red;
    viewCenter.blueValue = self.blue;
    [viewCenter setNeedsDisplay];
    
    //首次接触颜色面板,发送命令使得颜色可调
    if(self.characteristic != nil){
        Byte  write[6];
        write[0] = 0xAA;
        write[1] = 0x19;
        write[2] = 0x00;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
    [NSThread sleepForTimeInterval:0.1];
    
    if (recognizer.state == UIGestureRecognizerStateEnded && self.characteristic != nil){
        Byte  write[6];
        //设置红色
        write[0] = 0xAA;
        write[1] = 0x1A;
        write[2] = (uint8_t)(self.red * 100) ;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        [NSThread sleepForTimeInterval:0.1];
        //设置绿色
        write[0] = 0xAA;
        write[1] = 0x1B;
        write[2] = (uint8_t)(self.green * 100) ;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        [NSThread sleepForTimeInterval:0.1];
        //设置蓝色
        write[0] = 0xAA;
        write[1] = 0x1C;
        write[2] = (uint8_t)(self.blue * 100) ;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    }
}

-(void) handle1:(UITapGestureRecognizer *)recognizer{
    [self.btDownRadio setBackgroundColor:[UIColor blackColor]];
    [self.btUpRadio setBackgroundColor:[UIColor whiteColor]];
    UISlider *slideTime = [self.view viewWithTag:205];
    [slideTime setEnabled:YES];
    
    if( self.characteristic != nil){
        Byte  write[6];
        //设置红色
        write[0] = 0xAA;
        write[1] = 0x19;
        write[2] = 0x05;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
}

//改变时间
-(void) chgTime:(UISlider *)slider{
    UILabel *labelTime = (UILabel *)[self.view viewWithTag:100];
    NSInteger sec = (int)(slider.value * 9 + 1);
    labelTime.text = [NSString stringWithFormat:@"Alternating time: %ld s",sec];
    
    if( self.characteristic != nil){
        Byte  write[6];
        //设置红色
        write[0] = 0xAA;
        write[1] = 0x19;
        write[2] = sec;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"timeNotify" object:nil userInfo: @{@"time" : [NSString stringWithFormat:@"%ld",sec]}];
    }
}

//改变亮度
-(void) chgLight:(UISlider *)slider{
    UILabel *labelBright = (UILabel *)[self.view viewWithTag:201];
    NSInteger bright = (int)(slider.value * 9);
    labelBright.text = [NSString stringWithFormat:@"%ld",bright];
    
    if( self.characteristic != nil){
        Byte  write[6];
        //设置红色
        write[0] = 0xAA;
        write[1] = 0x1D;
        write[2] = bright;
        write[4] = 0xFF & CalcCRC(&write[1], 2);
        write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
        write[5] = 0x55;
        
        NSData *data = [[NSData alloc]initWithBytes:write length:6];
        [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BrightNotify" object:nil userInfo: @{@"bright" : [NSString stringWithFormat:@"%ld",bright]}];
    }
    
}

//返回上一页
-(void) goBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    /*
     if(self.characteristic != nil){
     Byte  write[6];
     //设置红色
     write[0] = 0xAA;
     write[1] = 0x1A;
     write[2] = (uint8_t)(self.red * 100) ;
     write[4] = 0xFF & CalcCRC(&write[1], 2);
     write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
     write[5] = 0x55;
     
     NSData *data = [[NSData alloc]initWithBytes:write length:6];
     [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
     sleep(0.1);
     //设置绿色
     write[0] = 0xAA;
     write[1] = 0x1B;
     write[2] = (uint8_t)(self.green * 100) ;
     write[4] = 0xFF & CalcCRC(&write[1], 2);
     write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
     write[5] = 0x55;
     
     data = [[NSData alloc]initWithBytes:write length:6];
     [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
     sleep(0.1);
     //设置蓝色
     write[0] = 0xAA;
     write[1] = 0x1C;
     write[2] = (uint8_t)(self.blue * 100) ;
     write[4] = 0xFF & CalcCRC(&write[1], 2);
     write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
     write[5] = 0x55;
     
     data = [[NSData alloc]initWithBytes:write length:6];
     [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
     //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
     }
     */
}

/*
 -(void)setColor:(id)sender{
 [self dismissViewControllerAnimated:YES completion:^{
 if(self.characteristic != nil){
 Byte  write[6];
 //设置红色
 write[0] = 0xAA;
 write[1] = 0x1A;
 write[2] = (uint8_t)(self.red * 100) ;
 write[4] = 0xFF & CalcCRC(&write[1], 2);
 write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
 write[5] = 0x55;
 
 NSData *data = [[NSData alloc]initWithBytes:write length:6];
 [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
 sleep(0.1);
 //设置绿色
 write[0] = 0xAA;
 write[1] = 0x1B;
 write[2] = (uint8_t)(self.green * 100) ;
 write[4] = 0xFF & CalcCRC(&write[1], 2);
 write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
 write[5] = 0x55;
 
 data = [[NSData alloc]initWithBytes:write length:6];
 [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
 sleep(0.1);
 //设置蓝色
 write[0] = 0xAA;
 write[1] = 0x1C;
 write[2] = (uint8_t)(self.blue * 100) ;
 write[4] = 0xFF & CalcCRC(&write[1], 2);
 write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
 write[5] = 0x55;
 
 data = [[NSData alloc]initWithBytes:write length:6];
 [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
 
 //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
 }
 }];
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
