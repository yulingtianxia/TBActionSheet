//
//  TBActionSheet.m
//
//  Created by 杨萧玉 on 15/11/17.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//

#import "TBActionSheet.h"
#import "UIImage+BoxBlur.h"
#import "TBMacro.h"
#import "TBActionContainer.h"
#import "TBActionBackground.h"
#import "TBActionSheetController.h"
#import "UIWindow+TBAdditions.h"
#import "UIView+TBAdditions.h"

const CGFloat bigFragment = 8;
const CGFloat smallFragment = 0.5;
const CGFloat headerVerticalSpace = 10;
const CGFloat blurRadius = 0.7;

@interface TBActionSheet ()
@property (nonatomic,readwrite,getter=isVisible) BOOL visible;
@property (nonatomic,nonnull,strong) TBActionContainer * actionContainer;
@property (nonatomic,nonnull,strong) TBActionBackground * background;
@property (nonatomic,nonnull,strong) NSMutableArray<TBActionButton *> *buttons;
@property (nonatomic,nonnull,strong) NSMutableArray<UIView *> *separators;
@property (nonatomic,strong,nullable,readwrite) UILabel *titleLabel;
@property (nonatomic,strong,nullable,readwrite) UILabel *messageLabel;
@property (weak, nonatomic, readwrite) UIWindow *previousKeyWindow;
@property (strong, nonatomic) UIWindow *window;
@end

@implementation TBActionSheet

+ (void)initialize
{
    if (self != [TBActionSheet class]) {
        return;
    }
    TBActionSheet *appearance = [self appearance];
    appearance.buttonHeight = 56;
    appearance.offsetY = - bigFragment;
    appearance.tintColor = [UIColor blackColor];
    appearance.destructiveButtonColor = [UIColor redColor];
    appearance.cancelButtonColor = [UIColor blackColor];
    appearance.sheetWidth = MIN(kScreenWidth, kScreenHeight) - 20;
    appearance.backgroundTransparentEnabled = YES;
    appearance.blurEffectEnabled = YES;
    appearance.rectCornerRadius = 10;
    appearance.ambientColor = [UIColor colorWithWhite:1 alpha:0.65];
    appearance.separatorColor = [UIColor clearColor];
    appearance.animationDuration = 0.2;
    appearance.animationDampingRatio = 1;
    appearance.animationVelocity = 1;
}

- (instancetype)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _background = [[TBActionBackground alloc] initWithFrame:self.bounds];
        [self addSubview:_background];
        _actionContainer = [[TBActionContainer alloc] initWithSheet:self];
        [self addSubview:_actionContainer];
        _buttons = [NSMutableArray array];
        _separators = [NSMutableArray array];
        //set default values
        _cancelButtonIndex = -1;
        _destructiveButtonIndex = -1;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidChangeOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id<TBActionSheetDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    self = [self init];
    if (self) {
        _title = title;
        _delegate = delegate;
        
        if (destructiveButtonTitle) {
            _destructiveButtonIndex = [self addButtonWithTitle:destructiveButtonTitle style:TBActionButtonStyleDestructive];
        }
        
        NSString* eachArg;
        va_list argList;
        if (otherButtonTitles) { // 第一个参数 otherButtonTitles 是不属于参数列表的,
            [self addButtonWithTitle:otherButtonTitles style:TBActionButtonStyleDefault];
            va_start(argList, otherButtonTitles);          // 从 otherButtonTitles 开始遍历参数，不包括 format 本身.
            while ((eachArg = va_arg(argList, NSString*))) {// 从 args 中遍历出参数，NSString* 指明类型
                [self addButtonWithTitle:eachArg style:TBActionButtonStyleDefault];
            }
            va_end(argList);
        }
        
        if (cancelButtonTitle) {
            _cancelButtonIndex = [self addButtonWithTitle:cancelButtonTitle style:TBActionButtonStyleCancel];
        }
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(nullable NSString *)message delegate:(id<TBActionSheetDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    self = [self init];
    if (self) {
        _title = title;
        _message = message;
        _delegate = delegate;
        
        if (destructiveButtonTitle) {
            _destructiveButtonIndex = [self addButtonWithTitle:destructiveButtonTitle style:TBActionButtonStyleDestructive];
        }
        
        NSString* eachArg;
        va_list argList;
        if (otherButtonTitles) { // 第一个参数 otherButtonTitles 是不属于参数列表的,
            [self addButtonWithTitle:otherButtonTitles style:TBActionButtonStyleDefault];
            va_start(argList, otherButtonTitles);          // 从 otherButtonTitles 开始遍历参数，不包括 format 本身.
            while ((eachArg = va_arg(argList, NSString*))) {// 从 args 中遍历出参数，NSString* 指明类型
                [self addButtonWithTitle:eachArg style:TBActionButtonStyleDefault];
            }
            va_end(argList);
        }
        
        if (cancelButtonTitle) {
            _cancelButtonIndex = [self addButtonWithTitle:cancelButtonTitle style:TBActionButtonStyleCancel];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
    return [self addButtonWithTitle:title style:TBActionButtonStyleDefault];
}

- (NSInteger)addButtonWithTitle:(NSString *)title style:(TBActionButtonStyle)style
{
    return [self addButtonWithTitle:title style:style handler:nil];
}

- (NSInteger)addButtonWithTitle:(nullable NSString *)title style:(TBActionButtonStyle)style handler:(void (^ __nullable)( TBActionButton * _Nonnull button))handler
{
    TBActionButton *button = [TBActionButton buttonWithTitle:title style:style handler:handler];
    [button addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttons addObject:button];
    NSInteger index = self.buttons.count - 1;
    switch (style) {
        case TBActionButtonStyleDefault: {
            ;
            break;
        }
        case TBActionButtonStyleCancel: {
            self.cancelButtonIndex = index;
            break;
        }
        case TBActionButtonStyleDestructive: {
            self.destructiveButtonIndex = index;
            break;
        }
        default: {
            break;
        }
    }
    return index;
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    if ([self isIndexValid:buttonIndex]) {
        return self.buttons[buttonIndex].currentTitle;
    }
    return nil;
}

- (NSInteger)numberOfButtons
{
    return self.buttons.count;
}

#pragma mark getter&setter

- (void)setButtonFont:(UIFont *)buttonFont
{
    if (buttonFont && [self buttonFont] != buttonFont) {
        for (TBActionButton *btn in self.buttons) {
            btn.titleLabel.font = buttonFont;
        }
    }
}

- (UIFont *)buttonFont
{
    return self.buttons.lastObject.titleLabel.font;
}

- (NSInteger)firstOtherButtonIndex
{
    for (int i=0; i<self.buttons.count; i++) {
        if (self.buttons[i].style==TBActionButtonStyleDefault) {
            return i;
        }
    }
    return -1;
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    if (separatorColor && separatorColor != _separatorColor) {
        _separatorColor = separatorColor;
        for (UIView *separator in self.separators) {
            separator.backgroundColor = separatorColor;
        }
    }
}

- (BOOL)isVisible
{
    // action sheet is visible iff it's associated with a window
    return !!self.window;
}

#pragma mark show action
/**
 *  设定新的 UIWindow，并将 TBActionSheet 附加在上面
 */
- (void)setUpNewWindow
{
    if ([self isVisible]) {
        return;
    }
    
    self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    [self.previousKeyWindow interruptGesture];
    TBActionSheetController *actionSheetVC = [[TBActionSheetController alloc] initWithNibName:nil bundle:nil];
    actionSheetVC.actionSheet = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.window.opaque = NO;
    self.window.rootViewController = actionSheetVC;
    [self.window makeKeyAndVisible];
}

/**
 *  设定所有内容的布局
 */
- (void)setUpLayout
{
    //将视图从上到下排列，计算当前排列的纵坐标
    __block CGFloat lastY = 0;
    //inline block, 减少代码冗余
    void(^handleLabelFrameBlock)(UILabel *label, NSString *content) = ^(UILabel *label, NSString *content) {
        //给一个比较大的高度，宽度不变
        CGSize size =CGSizeMake(self.sheetWidth,1000);
        //获取当前文本的属性
        NSDictionary * tdic = @{NSFontAttributeName:label.font};
        //ios7方法，获取文本需要的size，限制宽度
        CGSize actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        label.frame = CGRectMake(0, lastY, self.sheetWidth, actualsize.height);
        lastY = CGRectGetMaxY(label.frame);
    };
    
    //处理标题
    if ([self hasTitle]) {
        lastY += headerVerticalSpace;
        if (!self.titleLabel) {
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, lastY, self.sheetWidth, 0)];
        }
        self.titleLabel.textColor = [UIColor colorWithWhite:0.56 alpha:1];
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.2) {
            self.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
        }
        else {
            self.titleLabel.font = [UIFont systemFontOfSize:13];
        }
        self.titleLabel.text = self.title;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;

        [self.actionContainer.header addSubview:self.titleLabel];
        handleLabelFrameBlock(self.titleLabel, self.title);
    }
    //处理 message
    if ([self hasMessage]) {
        if (![self hasTitle]) {
            lastY += headerVerticalSpace;
        }
        if (!self.messageLabel) {
            self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, lastY, self.sheetWidth, 0)];
        }
        self.messageLabel.textColor = [UIColor colorWithWhite:0.56 alpha:1];
        self.messageLabel.font = [UIFont systemFontOfSize:13];
        self.messageLabel.text = self.message;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;

        [self.actionContainer.header addSubview:self.messageLabel];
        handleLabelFrameBlock(self.messageLabel, self.message);
    }
    //处理title与自定义视图间的分割线
    if ([self hasHeader]) {
        lastY += headerVerticalSpace;
        self.actionContainer.header.frame = CGRectMake(0, 0, self.sheetWidth, lastY);
        if (self.buttons.firstObject.style == TBActionButtonStyleCancel && !self.customView) {
            [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:YES];
            lastY = CGRectGetMaxY(self.actionContainer.header.frame) + bigFragment;
        }
        else {
            [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:NO];
            lastY = CGRectGetMaxY(self.actionContainer.header.frame) + smallFragment;
        }
    }
    //处理自定义视图
    if (self.customView) {
        self.actionContainer.custom.frame = CGRectMake(0, lastY, self.sheetWidth, self.customView.frame.size.height);
        self.customView.center = CGPointMake(self.sheetWidth / 2, self.customView.frame.size.height/2);
        [self.actionContainer.custom addSubview:self.customView];
        if (self.buttons.firstObject.style == TBActionButtonStyleCancel) {
            [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:YES];
            lastY = CGRectGetMaxY(self.actionContainer.custom.frame) + bigFragment;
        }
        else {
            [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:NO];
            lastY = CGRectGetMaxY(self.actionContainer.custom.frame) + smallFragment;
        }
    }
    
    //计算按钮坐标并添加样式
    [self.buttons enumerateObjectsUsingBlock:^(TBActionButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //inline block, 减少代码冗余
        void(^addDefaultSeparatorBlock)(void) = ^() {
            //上一个 button 如果是 cancel
            if (idx>0&&self.buttons[idx-1].style == TBActionButtonStyleCancel) {
                [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:YES];
                lastY += bigFragment;
            }
            else {
                [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:NO];
                lastY += smallFragment;
            }
        };
        
        switch (obj.style) {
            case TBActionButtonStyleDefault: {
                [obj setTitleColor:self.tintColor forState:UIControlStateNormal];
                if (idx != 0) {
                    addDefaultSeparatorBlock();
                }
                break;
            }
            case TBActionButtonStyleCancel: {
                [obj setTitleColor:self.cancelButtonColor forState:UIControlStateNormal];
                if (idx != 0) {
                    [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:YES];
                    lastY += bigFragment;
                }
                break;
            }
            case TBActionButtonStyleDestructive: {
                [obj setTitleColor:self.destructiveButtonColor forState:UIControlStateNormal];
                if (idx != 0) {
                    addDefaultSeparatorBlock();
                }
                break;
            }
            default: {
                break;
            }
        }
        
        obj.frame = CGRectMake(0, lastY, self.sheetWidth, self.buttonHeight);
        lastY = CGRectGetMaxY(obj.frame);
        [self.actionContainer addSubview:obj];
    }];
    
    if (self.offsetY < 0) {
        lastY -= self.offsetY;
    }
    
    self.actionContainer.frame = CGRectMake(kContainerLeft, kScreenHeight, self.sheetWidth, lastY);
}

/**
 *  设置毛玻璃效果、圆角、背景颜色等
 */
- (void)setUpStyle
{
    CGFloat containerHeight = self.actionContainer.bounds.size.height;
    UIImage *originalBackgroundImage = [self screenShotRect:CGRectMake(kContainerLeft, kScreenHeight-containerHeight, self.sheetWidth, containerHeight)];
    CGFloat heightLargerThanImage = containerHeight - originalBackgroundImage.size.height;// 计算 container 的高度超出截图的数值
    
    if (!self.isBackgroundTransparentEnabled) {
        if (self.isBlurEffectEnabled) {
            if (![self.actionContainer useSystemBlurEffect]) {
                UIImage *backgroundImage = [originalBackgroundImage drn_boxblurImageWithBlur:blurRadius withTintColor:[self.ambientColor colorWithAlphaComponent:0.5]];
                self.actionContainer.image = backgroundImage;
            }
        }
        else {
            self.actionContainer.backgroundColor = [self.ambientColor colorWithAlphaComponent:0.5];
        }
    }
    
    TBWeakSelf(self);
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TBStrongSelf(self);
        //设置圆角
        [self.buttons enumerateObjectsUsingBlock:^(TBActionButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.buttons.count == 1) {
                obj.tbRectCorner |= TBRectCornerTop|TBRectCornerBottom;
                if ([self hasHeader]) {
                    self.actionContainer.header.tbRectCorner |= self.customView ? TBRectCornerTop : TBRectCornerAll;
                }
                if (self.customView) {
                    self.actionContainer.custom.tbRectCorner |= [self hasHeader] ? TBRectCornerBottom : TBRectCornerAll;
                }
            }
            else if (obj.style == TBActionButtonStyleCancel) {
                obj.tbRectCorner = TBRectCornerTop|TBRectCornerBottom;
                if (idx >= 1) {
                    self.buttons[idx - 1].tbRectCorner |= TBRectCornerBottom;
                }
                else {
                    if (self.customView) {
                        self.actionContainer.custom.tbRectCorner |= TBRectCornerBottom;
                    }
                    else if ([self hasHeader]) {
                        self.actionContainer.header.tbRectCorner |= TBRectCornerBottom;
                    }
                }
                if (idx + 1 <= self.buttons.count - 1) {
                    self.buttons[idx + 1].tbRectCorner |= TBRectCornerTop;
                }
            }
            else if (idx == 0) {
                if (![self hasHeader] && !self.customView) {
                    obj.tbRectCorner |= TBRectCornerTop;
                }
            }
            else if (idx == self.buttons.count - 1) {
                obj.tbRectCorner |= TBRectCornerBottom;
            }
        }];
        
        
        for (TBActionButton *btn in self.buttons) {
            [btn setCornerRadius:self.rectCornerRadius];
        }
        
        UIImage *(^cutOriginalBackgroundImageInRect)(CGRect frame) = ^UIImage *(CGRect sourceFrame) {
            CGRect targetFrame;
            if (heightLargerThanImage > 0) {
                targetFrame = CGRectMake(sourceFrame.origin.x, sourceFrame.origin.y - heightLargerThanImage, sourceFrame.size.width, sourceFrame.size.height);
            }
            else {
                targetFrame = sourceFrame;
            }
            UIImage *cuttedImage = [self cutFromImage:originalBackgroundImage inRect:targetFrame];
            return cuttedImage;
        };
        
        //设置背景风格
        if ([self hasHeader]) {
            self.actionContainer.header.tbRectCorner |= TBRectCornerTop;
            if (self.isBlurEffectEnabled && self.isBackgroundTransparentEnabled) {
                if (![self.actionContainer useSystemBlurEffectUnderView:self.actionContainer.header]) {
                    
                    UIImage *backgroundImage = [cutOriginalBackgroundImageInRect(self.actionContainer.header.frame) drn_boxblurImageWithBlur:blurRadius withTintColor:self.ambientColor];
                    self.actionContainer.header.image = backgroundImage;
                }
            }
            else {
                self.actionContainer.header.backgroundColor = self.ambientColor;
            }
        }
        
        if (self.customView) {
            if (![self hasHeader]) {
                self.actionContainer.custom.tbRectCorner |= TBRectCornerTop;
            }
            if (self.isBlurEffectEnabled && self.isBackgroundTransparentEnabled) {
                if (![self.actionContainer useSystemBlurEffectUnderView:self.actionContainer.custom]) {
                    UIImage *backgroundImage = [cutOriginalBackgroundImageInRect(self.actionContainer.custom.frame) drn_boxblurImageWithBlur:blurRadius withTintColor:self.ambientColor];
                    self.actionContainer.custom.image = backgroundImage;
                }
            }
            else {
                self.actionContainer.custom.backgroundColor = self.ambientColor;
            }
        }
        
        [self.actionContainer.header setCornerRadius:self.rectCornerRadius];
        [self.actionContainer.custom setCornerRadius:self.rectCornerRadius];
        
        [self.buttons enumerateObjectsUsingBlock:^(TBActionButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.isBlurEffectEnabled && self.isBackgroundTransparentEnabled) {
                if (![self.actionContainer useSystemBlurEffectUnderView:obj]) {
                    UIImage *cuttedImage = cutOriginalBackgroundImageInRect(obj.frame);
                    UIImage *backgroundImageNormal = [cuttedImage drn_boxblurImageWithBlur:blurRadius withTintColor:self.ambientColor];
                    UIImage *backgroundImageHighlighted = [cuttedImage drn_boxblurImageWithBlur:blurRadius withTintColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
                    [obj setBackgroundImage:backgroundImageNormal forState:UIControlStateNormal];
                    [obj setBackgroundImage:backgroundImageHighlighted forState:UIControlStateHighlighted];
                    obj.backgroundColor = [UIColor clearColor];
                }
            }
            else {
                obj.normalColor = self.ambientColor;
                obj.highlightedColor = [UIColor colorWithWhite:0.5 alpha:0.5];
            }
        }];
    });
}

- (void)setUpContainerFrame
{
    self.actionContainer.frame = CGRectMake(kContainerLeft, kScreenHeight - self.actionContainer.frame.size.height - (!kiOS7Later? 20: 0), self.actionContainer.frame.size.width, self.actionContainer.frame.size.height);
}
/**
 *  显示 ActionSheet
 */
- (void)show
{
    [self showInView:nil];
}

/**
 *  从一个 UIView 显示 ActionSheet
 *
 *  @param view ActionSheet 的父 View
 */
- (void)showInView:(UIView *)view
{
    if ([self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [self.delegate willPresentActionSheet:self];
    }
    
    [self setUpNewWindow];
    
    [self setUpLayout];
    
    [self setUpStyle];
    
    //弹出 ActionSheet 动画
    void(^animations)(void) = ^() {
        self.background.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self setUpContainerFrame];
    };
    void(^completion)(BOOL finished) = ^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
            [self.delegate didPresentActionSheet:self];
        }
        self.visible = YES;
    };
    if (kiOS7Later) {
        [UIView animateWithDuration:self.animationDuration delay:0 usingSpringWithDamping:self.animationDampingRatio initialSpringVelocity:self.animationVelocity options:UIViewAnimationOptionCurveEaseInOut animations:animations completion:completion];
    }
    else {
        [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:animations completion:completion];
    }
}

#pragma mark handle button press
/**
 *  按钮点击事件，不要直接调用
 *
 *  @param sender 点击的按钮对象
 */
- (void)checkButtonTapped:(TBActionButton *)sender
{
    if (![self isVisible]) {
        return;
    }
    
    NSUInteger index = [self.buttons indexOfObject:sender];
    
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.background.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.actionContainer.frame = CGRectMake(kContainerLeft, kScreenHeight, self.actionContainer.frame.size.width, self.actionContainer.frame.size.height);
    } completion:^(BOOL finished) {
        //这里之所以把各种 delegate 调用都放在动画完成后是有原因的：为了支持在回调方法中 show 另一个 actionsheet，系统的 UIActionSheet 的调用时机也是如此。
        
        if ([self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
            [self.delegate actionSheet:self willDismissWithButtonIndex:index];
        }
        
        self.window.rootViewController = nil;
        [self.previousKeyWindow makeKeyAndVisible];
        
        if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
            [self.delegate actionSheet:self clickedButtonAtIndex:index];
        }
        if (sender.handler) {
            __weak __typeof(TBActionButton *)weakSender = sender;
            sender.handler(weakSender);
        }
        
        if (self.userClickIndex) {
            self.userClickIndex(index);
        }
        
        if ([self.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
            [self.delegate actionSheet:self didDismissWithButtonIndex:index];
        }
        self.visible = NO;
    }];
    
}

#pragma mark handle close
/**
 *  取消 ActionSheet 的方法
 */
- (void)close
{
    if (![self isVisible]) {
        return;
    }
    
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.background.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.actionContainer.frame = CGRectMake(kContainerLeft, kScreenHeight, self.actionContainer.frame.size.width, self.actionContainer.frame.size.height);
    } completion:^(BOOL finished) {
        self.window.rootViewController = nil;
        [self.previousKeyWindow makeKeyAndVisible];
        
        if ([self.delegate respondsToSelector:@selector(actionSheetCancel:)]) {
            [self.delegate actionSheetCancel:self];
        }
        else if ([self isIndexValid:self.cancelButtonIndex]) {
            if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
                [self.delegate actionSheet:self clickedButtonAtIndex:self.cancelButtonIndex];
            }
            
            TBActionButton *button = self.buttons[self.cancelButtonIndex];
            if (button.handler) {
                __weak __typeof(TBActionButton *)weakButton = button;
                button.handler(weakButton);
            }
            
            if ([self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
                [self.delegate actionSheet:self willDismissWithButtonIndex:self.cancelButtonIndex];
            }
            
            if ([self.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
                [self.delegate actionSheet:self didDismissWithButtonIndex:self.cancelButtonIndex];
            }
        }

        self.visible = NO;
    }];
}

- (void)statusBarDidChangeOrientation:(NSNotification *)notification {
    self.bounds = [UIScreen mainScreen].bounds;
    self.background.frame = self.bounds;
    [self setUpContainerFrame];
}

#pragma mark help methods

- (BOOL)hasTitle
{
    return self.title && self.title.length > 0;
}

- (BOOL)hasMessage
{
    return self.message && self.message.length > 0;
}

- (BOOL)hasHeader
{
    return [self hasTitle] || [self hasMessage];
}

- (void)addSeparatorLineAt:(CGPoint) point isBigFragment:(BOOL) isBigFragment
{
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, self.sheetWidth, isBigFragment?bigFragment:smallFragment)];
    separatorLine.backgroundColor = self.separatorColor;
    [self.actionContainer addSubview:separatorLine];
    [self.separators addObject:separatorLine];
}

/**
 *  从UIView 的一定区域截屏
 *
 *  @param aRect 区域
 *  @param view  截取的 view
 *
 *  @return  截取的图片
 */
- (UIImage *)screenShotRect:(CGRect)aRect
{
    // 获取最上层的 UIViewController
    UIViewController *topController = self.previousKeyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    UIView *view = topController.view;
    
    UIGraphicsBeginImageContext(view.bounds.size);
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        const CGFloat crashMagicNumber = 0.3;// size 小于0.3 在 iOS7 上会导致 crash
        if (view.frame.size.width >= crashMagicNumber && view.frame.size.height >= crashMagicNumber ) { // resolve iOS7 size crash
            [view drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
        }
    }
    else {/* iOS 6 */
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *screenshotimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [self cutFromImage:screenshotimage inRect:aRect];
//    return [self cutFromImage:[self.previousKeyWindow tb_snapshot] inRect:aRect];
}
/**
 *  从图片中切图
 *
 *  @param image 要被切的图片
 *  @param rect  这里可以设置想要截图的区域
 *
 *  @return 截图
 */
- (UIImage *)cutFromImage:(UIImage *)image inRect:(CGRect) rect
{
    CGImageRef imageRef = image.CGImage;
    CGRect transRect = CGRectMake(rect.origin.x*image.scale, rect.origin.y*image.scale, rect.size.width*image.scale, rect.size.height*image.scale);
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, transRect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect scale:image.scale orientation:UIImageOrientationUp];
    NSData *imageViewData = UIImagePNGRepresentation(sendImage);
    CGImageRelease(imageRefRect);
    return [UIImage imageWithData:imageViewData];
//    return sendImage;
}

- (BOOL)isIndexValid:(NSInteger) index
{
    if (index >=0 && index < self.buttons.count) {
        return YES;
    }
    return NO;
}

@end
