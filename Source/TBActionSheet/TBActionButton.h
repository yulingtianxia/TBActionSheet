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


/**
 自定义动画 Block

 @param background 全屏背景视图，可用做阴影渐变等动画
 @param container ActionSheet 容器视图，可设置 frame 等做动画。做 show 动画时，建议调用 updateContainerFrame 方法来设定动画的结束 frame（而不是手动随便设个 frame）。
 @param ^completion 动画结束的回调 block，一定要调用。
 */
typedef void(^TBActionSheetAnimation)(UIImageView *background, UIView *container, void(^completion)(void));
@class TBActionButton;
typedef void(^TBActionButtonHandler)(TBActionButton * button);

@interface TBActionButton : UIButton

@property (nonatomic, nullable) UIColor *normalColor;
@property (nonatomic, nullable) UIColor *highlightedColor;
@property (nonatomic) TBActionButtonStyle style;
/**
 点击按钮后的响应回调
 */
@property (nonatomic, nullable, strong, readonly) TBActionButtonHandler handler;
/**
 点击按钮后 TBActionSheet 的自定义关闭动画
 */
@property (nonatomic, nullable, strong) TBActionSheetAnimation animation;
/**
 *  位于按钮后面的调节颜色的图层，在没有 `normalColor` 或 `highlightedColor` 时使用 ambientColor 替代
 */
@property (weak,nonatomic) UIView *behindColorView;
@property (nonatomic) CGFloat height;

+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style;
+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style handler:(nullable TBActionButtonHandler)handler;
+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style handler:(nullable TBActionButtonHandler)handler animation:(nullable TBActionSheetAnimation)animation;

@end

NS_ASSUME_NONNULL_END

