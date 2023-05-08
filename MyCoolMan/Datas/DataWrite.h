//
//  DataWrite.h
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataWrite : NSObject
@property Byte start;    //通讯开始
@property Byte command;  //指令
@property Byte value;    //数值
@property Byte crch;     //crc校验高八位
@property Byte crcL;     //crc校验低八位
@property Byte end;      //通讯结束
@end

NS_ASSUME_NONNULL_END
