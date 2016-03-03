//
//  TBActionSheet.h
//
//  Created by 杨萧玉 on 15/11/17.
//  Copyright © 2015年 yulingtianxia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBActionButton.h"

@class TBActionContainer;
@protocol TBActionSheetDelegate;

@interface TBActionSheet : UIView
@property(nullable,nonatomic,weak) id<TBActionSheetDelegate> delegate;
@property(nonatomic,copy)  NSString * _Nullable  title;
@property(nonatomic,copy)  NSString * _Nullable  message;
/**
 *   标记藏于 ActionSheet 下面的 UIWindow
 */
@property (weak, nonatomic, readonly) UIWindow *previousKeyWindow;

- (nonnull instancetype)initWithTitle:(nullable NSString *)title delegate:(nullable id <TBActionSheetDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (nonnull instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id <TBActionSheetDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (nonnull instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

// adds a button with the title. returns the index (0 based) of where it was added. buttons are displayed in the order added except for the
// destructive and cancel button which will be positioned based on HI requirements. buttons cannot be customized.
- (NSInteger)addButtonWithTitle:(nullable NSString *)title;
- (NSInteger)addButtonWithTitle:(nullable NSString *)title style:(TBActionButtonStyle)style;    // returns index of button. 0 based.
- (NSInteger)addButtonWithTitle:(nullable NSString *)title style:(TBActionButtonStyle)style handler:(void (^ __nullable)( TBActionButton * _Nonnull button))handler;
- (nullable NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
@property(nonatomic,readonly) NSInteger numberOfButtons;
@property(nonatomic) NSInteger cancelButtonIndex;      // if the delegate does not implement -actionSheetCancel:, we pretend this button was clicked on. default is -1
@property(nonatomic) NSInteger destructiveButtonIndex; // sets destructive (red) button. -1 means none set. default is -1. ignored if only one button

@property(nonatomic,readonly) NSInteger firstOtherButtonIndex;	// -1 if no otherButtonTitles or initWithTitle:... not used
@property(nonatomic,readonly,getter=isVisible) BOOL visible;

- (void)showInView:(nonnull UIView *)view;

//custom UI
/**
 *  按钮高度
 */
@property(nonatomic) CGFloat buttonHeight UI_APPEARANCE_SELECTOR;
/**
 *  actionsheet下方的 y 轴位移，向下为正，默认值为 -8
 */
@property(nonatomic) CGFloat bottomOffset UI_APPEARANCE_SELECTOR;
/**
 *  标题 UILabel
 */
@property(nonatomic,strong,nullable,readonly) UILabel *titleLabel;
/**
 *  Message UILabel
 */
@property (nonatomic,strong,nullable,readonly) UILabel *messageLabel;
/**
 *  文字颜色
 */
@property(nonatomic,strong,nonnull) UIColor *tintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic,strong,nonnull) UIColor *destructiveButtonColor UI_APPEARANCE_SELECTOR;
@property(nonatomic,strong,nonnull) UIColor *cancelButtonColor UI_APPEARANCE_SELECTOR;
/**
 *  分割线颜色
 */
@property(nonatomic,strong,nonnull) UIColor *separatorColor UI_APPEARANCE_SELECTOR;
/**
 *  按钮字体
 */
@property(nonatomic,strong,nonnull) UIFont *buttonFont UI_APPEARANCE_SELECTOR;
/**
 *  sheet 的宽度，也就是按钮宽度
 */
@property(nonatomic) CGFloat sheetWidth UI_APPEARANCE_SELECTOR;
/**
 *  是否让背景透明
 */
@property(nonatomic, getter=isBackgroundTransparentEnabled) BOOL backgroundTransparentEnabled UI_APPEARANCE_SELECTOR;
/**
 *  是否启用毛玻璃效果
 */
@property(nonatomic, getter=isBlurEffectEnabled) BOOL blurEffectEnabled UI_APPEARANCE_SELECTOR;
/**
 *  是否使用圆角矩形
 */
@property(nonatomic, getter=isRectCornerEnabled) BOOL rectCornerEnabled UI_APPEARANCE_SELECTOR;
/**
 *  ActionSheet 的环境色，如果 useBlurEffect 为 YES，会与其效果混合。
 */
@property(nonatomic,strong,nonnull) UIColor *ambientColor UI_APPEARANCE_SELECTOR;
/**
 *  自定义视图
 */
@property(nonatomic,strong,nullable) UIView *customView;
/**
 *  动画持续时长
 */
@property(nonatomic,assign) NSTimeInterval animationDuration UI_APPEARANCE_SELECTOR;
/**
 *  重置毛玻璃效果、圆角、背景颜色等
 */
- (void)setUpStyle;

@end

@protocol TBActionSheetDelegate <NSObject>
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(nonnull TBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(nonnull TBActionSheet *)actionSheet;

- (void)willPresentActionSheet:(nonnull TBActionSheet *)actionSheet;  // before animation and showing view
- (void)didPresentActionSheet:(nonnull TBActionSheet *)actionSheet;  // after animation

- (void)actionSheet:(nonnull TBActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)actionSheet:(nonnull TBActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

@end