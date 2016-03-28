//
//  UIView+TBAdditions.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/2/16.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "UIView+TBAdditions.h"
#import <objc/runtime.h>

@implementation UIView (TBAdditions)

@end

#pragma mark - UIView (TBActionSheet)



@implementation UIView (TBActionSheet)

@dynamic tbActionSheet;

- (TBActionSheet *)tbActionSheet
{
    return objc_getAssociatedObject(self, @selector(tbActionSheet));
}

- (void)setTbActionSheet:(TBActionSheet *)tbActionSheet
{
    objc_setAssociatedObject(self, @selector(tbActionSheet), tbActionSheet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)interruptGesture
{
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if (([gesture isKindOfClass:[UITapGestureRecognizer class]] || [gesture isKindOfClass:[UIPanGestureRecognizer class]]) && gesture.enabled == YES) {
            gesture.enabled = NO;
            gesture.enabled = YES;
        }
    }
    for (UIView *subview in self.subviews) {
        [subview interruptGesture];
    }
}

@end

const CGFloat sheetCornerRadius = 10.0f;

@implementation UIView (RectCorner)
- (void)setCornerOnTop
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(sheetCornerRadius, sheetCornerRadius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setCornerOnBottom
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                           cornerRadii:CGSizeMake(sheetCornerRadius, sheetCornerRadius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setAllCorner
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:sheetCornerRadius];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setNoneCorner
{
    self.layer.mask = nil;
}

@end