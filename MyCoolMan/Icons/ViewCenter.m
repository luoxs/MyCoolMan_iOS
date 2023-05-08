//
//  viewCenter.m
//  MyCoolMan
//
//  Created by 罗路雅 on 2023/2/4.
//

#import "ViewCenter.h"

@implementation ViewCenter

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
   
    CGContextSetRGBStrokeColor(context, 0.5, 0, 0, 1);//线条颜色
    CGContextSetRGBFillColor(context, self.redValue, self.greenValue, self.blueValue, 1.0);  //填充颜色
    CGContextFillEllipseInRect(context, CGRectMake(rect.size.width/4, rect.size.height/4, rect.size.width/2, rect.size.height/2));
    CGContextStrokePath(context);
}

@end
