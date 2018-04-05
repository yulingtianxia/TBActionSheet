//
//  TBActionSheetController.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/2/15.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "TBActionSheetController.h"
#import "TBActionSheet.h"
#import "UIWindow+TBAdditions.h"
#import "TBMacro.h"

@implementation TBActionSheetController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.actionSheet];
    self.actionSheet.frame = self.view.bounds;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.actionSheet.frame = self.view.bounds;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.actionSheet.supportedInterfaceOrientations;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIWindow *window = self.actionSheet.previousKeyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows firstObject];
    }
    return [[window tb_viewControllerForStatusBarStyle] preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    UIWindow *window = self.actionSheet.previousKeyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows firstObject];
    }
    return [[window tb_viewControllerForStatusBarHidden] prefersStatusBarHidden];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (self.actionSheet.blurEffectEnabled && !kiOS8Later) {
        [self.actionSheet setupStyle];
    }
}
#pragma clang diagnostic pop

@end
