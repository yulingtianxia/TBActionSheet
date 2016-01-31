//
//  TBActionSheet+Orientation.h
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/1/31.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "TBActionSheet.h"

@interface TBActionSheet (Orientation)
- (void)prepareActionContainerForOrientation:(UIInterfaceOrientation) orientation;
- (void)appearActionContainerForOrientation:(UIInterfaceOrientation) orientation;
- (void)disappearActionContainerForOrientation:(UIInterfaceOrientation) orientation;
- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation) orientation;

CGAffineTransform CGAffineTransformMakeRotateAroundPoint(CGPoint point, CGFloat angle);


- (void)statusBarWillChangeOrientation:(NSNotification *)notification;
- (CGFloat)screenHeight;
- (CGFloat)screenWidth;
- (void)rotateFromOrientation:(UIInterfaceOrientation) source toOrientation:(UIInterfaceOrientation) target;
@end
