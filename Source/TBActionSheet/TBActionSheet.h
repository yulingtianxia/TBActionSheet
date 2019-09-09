//
//  TBActionSheet.h
//
//  Created by 杨萧玉 on 15/11/17.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBActionButton.h"

NS_ASSUME_NONNULL_BEGIN

@class TBActionContainer;
@protocol TBActionSheetDelegate;

@interface TBActionSheet : UIView

@property (nullable, nonatomic, weak) id<TBActionSheetDelegate> delegate;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;
/**
 *   标记藏于 ActionSheet 下面的 UIWindow
 */
@property (weak, nonatomic, readonly) UIWindow *previousKeyWindow;

- (instancetype)initWithTitle:(nullable NSString *)title delegate:(nullable id <TBActionSheetDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id <TBActionSheetDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

// adds a button with the title. returns the index (0 based) of where it was added. buttons are displayed in the order added except for the
// destructive and cancel button which will be positioned based on HI requirements. buttons cannot be customized.
- (NSInteger)addButtonWithTitle:(nullable NSString *)title;
- (NSInteger)addButtonWithTitle:(nullable NSString *)title style:(TBActionButtonStyle)style;    // returns index of button. 0 based.
- (NSInteger)addButtonWithTitle:(nullable NSString *)title style:(TBActionButtonStyle)style handler:(nullable void (^)(TBActionButton * button))handler;
- (NSInteger)addButtonWithTitle:(nullable NSString *)title style:(TBActionButtonStyle)style handler:(nullable TBActionButtonHandler)handler animation:(nullable TBActionSheetAnimation)animation;
- (nullable NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
- (nullable TBActionButton *)buttonAtIndex:(NSInteger)buttonIndex;
@property (nonatomic, readonly) NSInteger numberOfButtons;
@property (nonatomic, readonly) NSInteger cancelButtonIndex;      // if the delegate does not implement -actionSheetCancel:, we pretend this button was clicked on. default is -1
@property (nonatomic, readonly) NSInteger destructiveButtonIndex; // sets destructive (red) button. -1 means none set. default is -1. ignored if only one button

@property (nonatomic, readonly) NSInteger firstOtherButtonIndex;	// -1 if no otherButtonTitles or initWithTitle:... not used

/**
 自定义视图在按钮中插入的 Index，值在 [0...numberOfButtons] 之间。如果 customView 为 nil，则 customViewIndex 值为 -1
 */
@property (nonatomic) NSInteger customViewIndex;
/**
 *  是否可见
 */
@property (nonatomic, readonly, getter=isVisible) BOOL visible;

/**
 *  显示 ActionSheet
 */
- (void)show;
/**
 使用自定义动画显示 ActionSheet

 @param animation 自定义动画，传 nil 则等价于 show 方法，使用默认动画。
 */
- (void)showWithAnimation:(nullable TBActionSheetAnimation)animation;
/**
 *  显示 ActionSheet，已废弃
 *
 *  @param view 此参数直接传 nil
 */
- (void)showInView:(nullable UIView *)view __deprecated;

/**
 关闭动画，不设置则为默认动画。
 NOTE: 设置 nil 是无效的。
 */
@property (nonatomic, strong) TBActionSheetAnimation closeAnimation;
/**
 *  关闭 ActionSheet 的方法
 */
- (void)close;
/**
 使用自定义动画关闭 ActionSheet
 
 @param animation 自定义动画，传 nil 则等价于 close 方法，使用 closeAnimation。
 */
- (void)closeWithAnimation:(nullable TBActionSheetAnimation)animation;

//custom UI
/**
 *  按钮高度
 */
@property (nonatomic) CGFloat buttonHeight UI_APPEARANCE_SELECTOR;
/**
 *  actionsheet下方的 y 轴位移，向下为正，非负值无效，默认值为 -8
 */
@property (nonatomic) CGFloat offsetY UI_APPEARANCE_SELECTOR;
/**
 *  标题 UILabel
 */
@property (nonatomic, strong, nullable, readonly) UILabel *titleLabel;
/**
 *  Message UILabel
 */
@property (nonatomic, strong, nullable, readonly) UILabel *messageLabel;
/**
 *  文字颜色
 */
@property (nonatomic, strong) UIColor *tintColor UI_APPEARANCE_SELECTOR;
/**
 *  Destructive 按钮文字颜色
 */
@property (nonatomic, strong) UIColor *destructiveButtonColor UI_APPEARANCE_SELECTOR;
/**
 *  Cancel 按钮文字颜色
 */
@property (nonatomic, strong) UIColor *cancelButtonColor UI_APPEARANCE_SELECTOR;
/**
 *  分割线颜色
 */
@property (nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR;
/**
 *  按钮字体
 */
@property (nonatomic, strong) UIFont *buttonFont UI_APPEARANCE_SELECTOR;
/**
 *  sheet 的宽度，也就是按钮宽度
 */
@property (nonatomic) CGFloat sheetWidth UI_APPEARANCE_SELECTOR;
/**
 *  是否让 ActionSheet 背景透明
 */
@property (nonatomic, getter=isBackgroundTransparentEnabled) BOOL backgroundTransparentEnabled UI_APPEARANCE_SELECTOR;
/**
 *  是否点击背景后关闭 ActionSheet
 */
@property (nonatomic, getter=isBackgroundTouchClosureEnabled) BOOL backgroundTouchClosureEnabled UI_APPEARANCE_SELECTOR;
/**
 *  是否启用毛玻璃效果
 */
@property (nonatomic, getter=isBlurEffectEnabled) BOOL blurEffectEnabled UI_APPEARANCE_SELECTOR;
/**
 *  矩形圆角半径
 */
@property (nonatomic, assign) CGFloat rectCornerRadius UI_APPEARANCE_SELECTOR;
/**
 *  ActionSheet 的环境色
 */
@property (nonatomic, strong) UIColor *ambientColor UI_APPEARANCE_SELECTOR;
/**
 *  自定义视图
 */
@property (nonatomic, strong, nullable) UIView *customView;
/**
 *  默认动画的持续时长
 */
@property (nonatomic, assign) NSTimeInterval animationDuration UI_APPEARANCE_SELECTOR;
/**
 *  默认动画的动画弹簧效果衰弱比例，值为 1 时无摆动，值越接近 0 摆动越大
 */
@property (nonatomic, assign) CGFloat animationDampingRatio UI_APPEARANCE_SELECTOR;
/**
 *  默认动画的动画弹簧效果初速度。如果动画总距离为 200 点，想让初速度为每秒 100 点，那么将值设为 0.5
 */
@property (nonatomic, assign) CGFloat animationVelocity UI_APPEARANCE_SELECTOR;
/**
 *  支持的朝向
 */
@property (nonatomic, assign) UIInterfaceOrientationMask supportedInterfaceOrientations UI_APPEARANCE_SELECTOR;
/**
 default = UIWindowLevelStatusBar + 100
 */
@property (nonatomic) UIWindowLevel windowLevel;
/**
 按钮之间的大间隙，default = 8。
 */
@property (nonatomic) CGFloat bigFragment UI_APPEARANCE_SELECTOR;
/**
 按钮之间的小间隙，default = 0.5
 */
@property (nonatomic) CGFloat smallFragment UI_APPEARANCE_SELECTOR;

/**
 --------------------------
 headerVerticalSpacing
 --------------------------
 title
 --------------------------
 headerLineSpacing
 --------------------------
 message
 --------------------------
 headerVerticalSpacing
 --------------------------
 */

/**
 header 文字的纵向留白
 */
@property (nonatomic) CGFloat headerVerticalSpacing UI_APPEARANCE_SELECTOR;
/**
 title 与 message 文字的行距
 */
@property (nonatomic) CGFloat headerLineSpacing UI_APPEARANCE_SELECTOR;
/**
 ActionSheet 内容超出屏幕后是否开启滚动，默认为 YES
 */
@property (nonatomic, assign, getter=isScrollEnabled) BOOL scrollEnabled UI_APPEARANCE_SELECTOR;
/**
 *  设置布局
 */
- (void)setupLayout;
/**
 *  设置毛玻璃效果、圆角、背景颜色等风格
 */
- (void)setupStyle;
/**
 *  更新容器展示在屏幕上的 frame
 */
- (void)updateContainerFrame;
@end

@protocol TBActionSheetDelegate <NSObject>
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(TBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(TBActionSheet *)actionSheet;

- (void)willPresentActionSheet:(TBActionSheet *)actionSheet;  // before animation and showing view
- (void)didPresentActionSheet:(TBActionSheet *)actionSheet;  // after animation

- (void)actionSheet:(TBActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)actionSheet:(TBActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

@end

NS_ASSUME_NONNULL_END
