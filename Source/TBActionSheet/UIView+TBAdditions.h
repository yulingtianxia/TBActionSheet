//
//  UIView+TBAdditions.h
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/2/16.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBMaskView: UIView

@property (nonatomic) UIBezierPath *maskPath;

@end

@interface UIView (TBActionSheet)
- (void)interruptGesture;
@end

#pragma mark - UIView (RectCorner)

/**
 *  加圆角
 */

typedef NS_OPTIONS(NSUInteger, TBRectCorner) {
    TBRectCornerTop = 1 << 0,
    TBRectCornerBottom = 1 << 1,
    TBRectCornerNone = 0,
    TBRectCornerAll = TBRectCornerTop|TBRectCornerBottom,
};

@interface UIView (TBRectCorner)
@property (nonatomic,assign) TBRectCorner tbRectCorner;
- (void)setCornerRadius:(CGFloat) radius;
@end
