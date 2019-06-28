//
//  UIWindow+TBAdditions.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/2/15.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "UIWindow+TBAdditions.h"
#import "TBMacro.h"

@implementation UIWindow (TBAdditions)

#pragma mark - Public

- (UIViewController *)tb_viewControllerForStatusBarStyle
{
    UIViewController *currentViewController = [self currentViewController];
    while ([currentViewController childViewControllerForStatusBarStyle]) {
        currentViewController = [currentViewController childViewControllerForStatusBarStyle];
    }
    return currentViewController;
}

- (UIViewController *)tb_viewControllerForStatusBarHidden
{
    UIViewController *currentViewController = [self currentViewController];
    while ([currentViewController childViewControllerForStatusBarHidden]) {
        currentViewController = [currentViewController childViewControllerForStatusBarHidden];
    }
    return currentViewController;
}

- (UIViewController *)currentViewController
{
    UIViewController *viewController = self.rootViewController;
    while (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
    }
    return viewController;
}
@end
