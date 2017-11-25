//
//  UIView+TBAdditions.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/2/16.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "UIView+TBAdditions.h"
#import <objc/runtime.h>
#import "TBMacro.h"

@implementation TBMaskView

+ (Class)layerClass
{
    return CAShapeLayer.class;
}

- (void)setMaskPath:(UIBezierPath *)maskPath
{
    _maskPath = maskPath;
    ((CAShapeLayer *)self.layer).path = maskPath.CGPath;
}

@end

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

- (void)applyMaskPath:(UIBezierPath *)maskPath
{
    TBMaskView *maskView = nil;
    if (maskPath) {
        maskView = [[TBMaskView alloc] initWithFrame:self.bounds];
        maskView.maskPath = maskPath;
    }
    // iOS 10 圆角毛玻璃有 bug
    if ([self isKindOfClass:UIVisualEffectView.class] && kiOS10Later && !kiOS11Later && self.tbRectCorner > 0) {
        self.maskView = maskView;
    }
    else {
        self.layer.mask = maskView.layer;
    }
}

- (void)setTopCornerRadius:(CGFloat) radius
{
    if (radius < 0) {
        return;
    }
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(radius, radius)];
    [self applyMaskPath:maskPath];
}

- (void)setBottomCornerRadius:(CGFloat) radius
{
    if (radius < 0) {
        return;
    }
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                           cornerRadii:CGSizeMake(radius, radius)];
    [self applyMaskPath:maskPath];
}

- (void)setAllCornerRadius:(CGFloat) radius
{
    if (radius < 0) {
        return;
    }
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    [self applyMaskPath:maskPath];
}

- (void)setNoneCorner
{
    [self applyMaskPath:nil];
}

- (void)setCornerRadius:(CGFloat) radius
{
    if (radius == 0) {
        [self setNoneCorner];
        return;
    }
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
