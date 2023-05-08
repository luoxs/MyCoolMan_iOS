//
//  MainViewController.h
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/1/13.
//

#import <UIKit/UIKit.h>
#import "BabyBluetooth.h"
#import "DataRead.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : UIViewController{
@public BabyBluetooth *baby;
}
@property (nonatomic, strong) NSData *data;
@property (nonatomic,strong) CBCharacteristic *characteristic;
@property (nonatomic,strong) CBPeripheral *currPeripheral;

@property (nonatomic,retain) DataRead *dataRead;

@end

NS_ASSUME_NONNULL_END
