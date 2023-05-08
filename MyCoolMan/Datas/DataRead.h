//
//  DataRead.h
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataRead : NSObject
@property Byte  start; //通讯开始
@property Byte  power; //0x01开机，0x00关机
@property Byte  tempSetting;  //设定温度
@property Byte  tempReal;  //实时温度
@property Byte  mode;  //工作模式
@property Byte  wind;  //风速档位 0-自动 1-4 是手动风速
@property Byte  turbo;  //强冷模式开关
@property Byte  sleep;  //睡眠模式开关
@property Byte  unit;   //温度单位 0-摄氏度 1-华氏度
@property Byte  countdown;  //倒计时关机时间
@property Byte  logo;  //LOGO 灯开关
@property Byte  atmosphere;  //氛围灯模式或氛围灯变化时间
@property Byte  red;   //R(红色数据值)
@property Byte  green;  //G(绿色数值)
@property Byte  blue;   //B(蓝色数值)
@property Byte  brightness;  //氛围灯亮度
@property Byte  errcode;  //故障代码
@property Byte  version;  //空调版本 0-国内版 1-国外版
@property Byte  reserve1;  //备用
@property Byte  reserve2;  //备用
@property Byte  crcH;  //CRC 校验高八位
@property Byte  crcL;  //CRC 校验高八位
@property Byte  end;  //通讯结束
@end

NS_ASSUME_NONNULL_END
