//
//  TBActionSheet+Orientation.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/1/31.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "TBActionSheet+Orientation.h"
#import "TBMacro.h"
#import "TBActionContainer.h"

@implementation TBActionSheet (Orientation)
#pragma mark handle orientation


- (CGFloat)screenHeight
{
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationLandscapeLeft || currentOrientation == UIInterfaceOrientationLandscapeRight) {
        return kScreenWidth;
    }
    else {
        return kScreenHeight;
    }
}

- (CGFloat)screenWidth
{
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationLandscapeLeft || currentOrientation == UIInterfaceOrientationLandscapeRight) {
        return kScreenHeight;
    }
    else {
        return kScreenWidth;
    }
}
@end
