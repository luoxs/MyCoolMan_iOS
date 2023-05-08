//
//  fanscaleViewController.h
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/2/14.
//

#import <UIKit/UIKit.h>
#import "DataRead.h"
#import "BabyBluetooth.h"

NS_ASSUME_NONNULL_BEGIN

@interface fanscaleViewController : UIViewController{
//@public BabyBluetooth *baby;
}
@property (nonatomic,retain) DataRead *dataRead;

@property (nonatomic, strong) NSData *data;
@property (nonatomic,strong) CBCharacteristic *characteristic;
@property (nonatomic,strong) CBPeripheral *currPeripheral;

@end

NS_ASSUME_NONNULL_END
