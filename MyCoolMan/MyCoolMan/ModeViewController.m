//
//  ModeViewController.m
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/1/16.
//

#import "ModeViewController.h"
#import "BabyBluetooth.h"
#import "SDAutoLayout.h"
#import "MBProgressHUD.h"
@interface ModeViewController ()

@end

@implementation ModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setAutoLayout];
}
- (void) setAutoLayout{
    double frameWidth = 288;    //屏幕相对宽度
    double frameHeight = 508;   //屏幕相对高度
    
    double viewX = [UIScreen mainScreen].bounds.size.width;
    double viewY = [UIScreen mainScreen].bounds.size.height;
    
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
    
    //标题
    UILabel  *labelTitle = [[UILabel alloc]init];
    [titleView addSubview:labelTitle];
    labelTitle.text = @"Mode";
    labelTitle.sd_layout
        .centerXEqualToView(titleView)
        .heightRatioToView(btReturn, 1.0)
        .bottomSpaceToView(titleView, 6.0/frameHeight*viewY);
    [labelTitle setFont:[UIFont fontWithName:@"Arial" size:14.0/frameHeight*viewY]];
    [labelTitle setTextColor:[UIColor whiteColor]];
    [labelTitle setSingleLineAutoResizeWithMaxWidth:200];
    
    //设置按钮
    UIButton *btSetting = [[UIButton alloc]init];
    [self.view addSubview:btSetting];
    btSetting.sd_layout
        .centerXIs(261.0/frameWidth*viewX)
        .centerYIs(44.0/frameHeight*viewY)
        .widthIs(18.0/frameWidth*viewX)
        .autoHeightRatio(1.0);
    [btSetting setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    
    //设置区view1
    UIView *view1 = [UIView new];
    [self.view addSubview:view1];
    [view1 setBackgroundColor:[UIColor colorWithRed:210/255.0 green:235/255.0 blue:250/255.0 alpha:1.0]];
    view1.sd_layout
        .topSpaceToView(titleView, 4.0/frameHeight*viewY)
        .leftSpaceToView(self.view,14.0/frameHeight*viewX)
        .rightSpaceToView(self.view,14.0/frameHeight*viewX)
        .heightRatioToView(self.view,185.0/frameHeight);
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
