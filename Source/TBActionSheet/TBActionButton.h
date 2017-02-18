//
//  TBActionButton.h
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/1/31.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TBActionButtonStyle) {
    TBActionButtonStyleDefault = 0,
    TBActionButtonStyleCancel,
    TBActionButtonStyleDestructive,
};

@interface TBActionButton : UIButton
@property (nonatomic,nullable) UIColor *normalColor;
@property (nonatomic,nullable) UIColor *highlightedColor;
@property (nonatomic) TBActionButtonStyle style;
@property (nonatomic,nullable,strong,readonly) void (^handler)(TBActionButton * button);
/**
 *  位于按钮后面的调节颜色的图层，在没有 `normalColor` 或 `highlightedColor` 时使用 ambientColor 替代
 */
@property (weak,nonatomic) UIView *behindColorView;

+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style;
+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style handler:(nullable void (^)(TBActionButton * button))handler;
@end

NS_ASSUME_NONNULL_END

