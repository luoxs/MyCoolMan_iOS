//
//  ClockViewController.m
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/4/25.
//

#import "ClockViewController.h"
#import "SDAutoLayout.h"
#import "crc.h"

@interface ClockViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,retain) UIPickerView *picker;
@property (nonatomic,retain) NSArray *times;
@property NSInteger timescale;
@end

@implementation ClockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.picker = [[UIPickerView alloc] init];
    self.timescale = 0;
    self.picker.delegate = self;
    self.picker.dataSource = self;
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
   // [btReturn setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    [btReturn setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.view addSubview:btReturn];
    btReturn.sd_layout
        .centerXIs(20.0/248*viewX)
        .centerYIs(37.0/436*viewY)
        .widthIs(40.0/248*viewX)
        .autoHeightRatio(100.0/60);
    [btReturn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    //设置按钮
    UIButton *btOK = [[UIButton alloc]init];
    [btOK setTitle:@"OK" forState:UIControlStateNormal];
    [self.view addSubview:btOK];
    btOK.sd_layout
        .centerXIs(224.0/frameWidth*viewX)
        .centerYIs(37.0/frameHeight*viewY)
        .widthIs(30.0/frameWidth*viewX)
        .autoHeightRatio(1.0);
    //[btSetting setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [btOK addTarget:self action:@selector(setClock:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:self.picker];
    [self.picker setBackgroundColor:[UIColor colorWithRed:204/255.0 green:208/255.0 blue:195/255.0 alpha:1.0]];
    [self.picker.layer setCornerRadius:8.0];
    self.picker.sd_layout
        .topSpaceToView(titleView, 50)
        .leftSpaceToView(self.view, 12)
        .rightSpaceToView(self.view, 12)
        .heightIs(300);
}

#pragma - mark delegate


-(void)goBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

-(void)setClock:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        if((self.characteristic != nil) && (self.dataRead.power == 0x01)){
            Byte  write[6];
            write[0] = 0xAA;
            write[1] = 0x16;
            write[2] = self.timescale * 5;
            write[4] = 0xFF & CalcCRC(&write[1], 2);
            write[3] = 0xFF & (CalcCRC(&write[1], 2)>>8);
            write[5] = 0x55;
            
            NSData *data = [[NSData alloc]initWithBytes:write length:6];
            [self.currPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
            //  [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"timerNotify" object:nil userInfo: @{@"timescale" : [NSString stringWithFormat:@"%ld",self.timescale*5]}];
            
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 25;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%.1f",row*0.5];
   
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 200.0;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return  30.0;
}

/*
- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSAttributedString *attr =
}*/

/*
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view{
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    v.backgroundColor = [UIColor redColor];
    return v;
}
*/

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.timescale = row;
    NSLog(@"%ld",(long)self.timescale);
}

@end
