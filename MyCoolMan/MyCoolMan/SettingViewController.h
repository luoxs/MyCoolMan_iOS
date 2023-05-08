//
//  SettingViewController.h
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/1/16.
//

#import <UIKit/UIKit.h>
#import "BabyBluetooth.h"
#import "DataRead.h"

NS_ASSUME_NONNULL_BEGIN

@interface SettingViewController : UIViewController{
@public BabyBluetooth *baby;
}
@property (nonatomic,retain) NSData *data;
@property (nonatomic,retain) CBCharacteristic *characteristic;
@property (nonatomic,retain) CBPeripheral *currPeripheral;
@property (nonatomic,retain) DataRead *dataRead;
@end

NS_ASSUME_NONNULL_END
