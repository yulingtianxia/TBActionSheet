//
//  UIView+TBAdditions.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/2/16.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "UIView+TBAdditions.h"
#import <objc/runtime.h>

#pragma mark - UIView (TBActionSheet)



@implementation UIView (TBActionSheet)

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


@implementation UIView (TBRectCorner)

@dynamic tbRectCorner;

- (TBRectCorner)tbRectCorner
{
    NSNumber *corner = objc_getAssociatedObject(self, @selector(tbRectCorner));
    return corner.integerValue;
}

- (void)setTbRectCorner:(TBRectCorner)tbRectCorner
{
    objc_setAssociatedObject(self, @selector(tbRectCorner), @(tbRectCorner), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTopCornerRadius:(CGFloat) radius
{
    if (radius < 0) {
        return;
    }
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setBottomCornerRadius:(CGFloat) radius
{
    if (radius < 0) {
        return;
    }
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                           cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setAllCornerRadius:(CGFloat) radius
{
    if (radius < 0) {
        return;
    }
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setNoneCorner
{
    self.layer.mask = nil;
}

- (void)setCornerRadius:(CGFloat) radius
{
    switch (self.tbRectCorner) {
        case TBRectCornerTop: {
            [self setTopCornerRadius:radius];
            break;
        }
        case TBRectCornerBottom: {
            [self setBottomCornerRadius:radius];
            break;
        }
        case TBRectCornerNone: {
            [self setNoneCorner];
            break;
        }
        case TBRectCornerAll: {
            [self setAllCornerRadius:radius];
            break;
        }
        default: {
            break;
        }
    }
}

@end