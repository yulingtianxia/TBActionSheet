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
    if (kiOS7Later) {
        while ([currentViewController childViewControllerForStatusBarStyle]) {
            currentViewController = [currentViewController childViewControllerForStatusBarStyle];
        }
    }
    return currentViewController;
}

- (UIViewController *)tb_viewControllerForStatusBarHidden
{
    UIViewController *currentViewController = [self currentViewController];
    if (kiOS7Later) {
        while ([currentViewController childViewControllerForStatusBarHidden]) {
            currentViewController = [currentViewController childViewControllerForStatusBarHidden];
        }
    }
    return currentViewController;
}

- (UIImage *)tb_snapshot
{
    // source (under MIT license): https://github.com/shinydevelopment/SDScreenshotCapture/blob/master/SDScreenshotCapture/SDScreenshotCapture.m#L35
    
    // UIWindow doesn't have to be rotated on iOS 8+.
    BOOL ignoreOrientation = kiOS8Later;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGSize imageSize = CGSizeZero;
    if (UIInterfaceOrientationIsPortrait(orientation) || ignoreOrientation) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, self.center.x, self.center.y);
    CGContextConcatCTM(context, self.transform);
    CGContextTranslateCTM(context, -self.bounds.size.width * self.layer.anchorPoint.x, -self.bounds.size.height * self.layer.anchorPoint.y);
    
    // correct for the screen orientation
    if (!ignoreOrientation) {
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, (CGFloat)M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, (CGFloat)-M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, (CGFloat)M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
    }
    
    if([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    } else {/* iOS 6 */
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    CGContextRestoreGState(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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
