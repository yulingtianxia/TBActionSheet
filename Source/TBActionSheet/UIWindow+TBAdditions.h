//
//  UIWindow+TBAdditions.h
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/2/15.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (TBAdditions)

- (UIViewController *)tb_viewControllerForStatusBarStyle;
- (UIViewController *)tb_viewControllerForStatusBarHidden;
- (UIViewController *)currentViewController;
@end
