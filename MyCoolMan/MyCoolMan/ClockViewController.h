//
//  ClockViewController.h
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/4/25.
//

#import <UIKit/UIKit.h>
#import "DataRead.h"
#import "BabyBluetooth.h"

NS_ASSUME_NONNULL_BEGIN

@interface ClockViewController : UIViewController
@property (nonatomic,retain) DataRead *dataRead;

@property (nonatomic, strong) NSData *data;
@property (nonatomic,strong) CBCharacteristic *characteristic;
@property (nonatomic,strong) CBPeripheral *currPeripheral;
@end

NS_ASSUME_NONNULL_END
