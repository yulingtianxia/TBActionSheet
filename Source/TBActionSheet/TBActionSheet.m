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

const CGFloat blurRadius = 0.7;

typedef void (^TBBlurEffectBlock)(void);

@interface TBActionSheet () <UIScrollViewDelegate>

@property (nonatomic, readwrite, getter=isVisible) BOOL visible;
@property (nonatomic, nonnull, strong) TBActionContainer * actionContainer;
@property (nonatomic, nonnull, strong) UIScrollView *scrollView;
@property (nonatomic, nonnull, strong) TBActionBackground * background;
@property (nonatomic, nonnull, strong) NSMutableArray<TBActionButton *> *buttons;
@property (nonatomic, nonnull, strong) NSMutableArray<UIView *> *separators;
@property (nonatomic, strong, nullable, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, nullable, readwrite) UILabel *messageLabel;
@property (nonatomic, readwrite) NSInteger cancelButtonIndex;
@property (nonatomic, readwrite) NSInteger destructiveButtonIndex;
@property (weak, nonatomic, readwrite) UIWindow *previousKeyWindow;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, nullable) UIImage *originalBackgroundImage;
@property (strong, nonatomic) NSMutableArray<TBBlurEffectBlock> *blurBlocks;

@end

@implementation TBActionSheet

@synthesize buttonFont = _buttonFont;

+ (void)initialize
{
    if (self != [TBActionSheet class]) {
        return;
    }
    TBActionSheet *appearance = [self appearance];
    appearance.buttonHeight = 56;
    appearance.bigFragment = 8;
    appearance.smallFragment = 0.5;
    appearance.offsetY = -appearance.bigFragment;
    if (@available(iOS 11.0, *)) {
        CGFloat bottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
        if (bottom > 0) {
            appearance.offsetY = -bottom;
        }
    }
    appearance.tintColor = [UIColor blackColor];
    appearance.destructiveButtonColor = [UIColor redColor];
    appearance.cancelButtonColor = [UIColor blackColor];
    appearance.sheetWidth = MIN(kScreenWidth, kScreenHeight) - 20;
    appearance.backgroundTransparentEnabled = YES;
    appearance.backgroundTouchClosureEnabled = YES;
    appearance.blurEffectEnabled = YES;
    appearance.rectCornerRadius = 10;
    appearance.ambientColor = [UIColor colorWithWhite:1 alpha:0.65];
    appearance.separatorColor = [UIColor clearColor];
    appearance.animationDuration = 0.2;
    appearance.animationDampingRatio = 1;
    appearance.animationVelocity = 1;
    appearance.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    appearance.scrollEnabled = YES;
    appearance.headerVerticalSpacing = 10;
}

- (instancetype)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _background = [[TBActionBackground alloc] initWithFrame:self.bounds];
        [self addSubview:_background];
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        _actionContainer = [[TBActionContainer alloc] initWithSheet:self];
        [_scrollView addSubview:_actionContainer];
        _buttons = [NSMutableArray array];
        _separators = [NSMutableArray array];
        _blurBlocks = [NSMutableArray array];
        //set default values
        _cancelButtonIndex = -1;
        _destructiveButtonIndex = -1;
        _windowLevel = UIWindowLevelStatusBar + 100;
        TBWeakSelf(self);
        _closeAnimation = ^(UIImageView * _Nonnull background, UIView * _Nonnull container, void (^ _Nonnull completion)(void)) {
            TBStrongSelf(self);
            void(^animations)(void) = ^() {
                background.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
                container.frame = CGRectMake(kContainerLeft, kScreenHeight, container.frame.size.width, container.frame.size.height);
            };
            [UIView animateWithDuration:self.animationDuration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:animations
                             completion:^(BOOL finished) {
                                 completion();
                             }];
        };
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidChangeOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id<TBActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    va_list argList;
    // 从 otherButtonTitles 开始遍历参数，不包括 otherButtonTitles 本身.
    va_start(argList, otherButtonTitles);
    self = [self initWithTitle:title message:nil delegate:delegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle firstOtherButtonTitle:otherButtonTitles titleList:argList];
    va_end(argList);
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<TBActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    va_list argList;
    // 从 otherButtonTitles 开始遍历参数，不包括 otherButtonTitles 本身.
    va_start(argList, otherButtonTitles);
    self = [self initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle firstOtherButtonTitle:otherButtonTitles titleList:argList];
    va_end(argList);
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<TBActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle firstOtherButtonTitle:(NSString *)firstOtherButtonTitle titleList:(va_list)argList
{
    self = [self init];
    if (self) {
        _title = title;
        _message = message;
        _delegate = delegate;
        
        if (destructiveButtonTitle) {
            _destructiveButtonIndex = [self addButtonWithTitle:destructiveButtonTitle style:TBActionButtonStyleDestructive];
        }
        
        if (firstOtherButtonTitle) {// 第一个参数 firstOtherButtonTitle 是不属于参数列表的,
            [self addButtonWithTitle:firstOtherButtonTitle style:TBActionButtonStyleDefault];
            NSString* eachArg;
            while ((eachArg = va_arg(argList, NSString*))) {// 从 args 中遍历出参数，NSString* 指明类型
                [self addButtonWithTitle:eachArg style:TBActionButtonStyleDefault];
            }
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

- (NSInteger)addButtonWithTitle:(nullable NSString *)title style:(TBActionButtonStyle)style handler:(nullable TBActionButtonHandler)handler
{
    return [self addButtonWithTitle:title style:style handler:handler animation:nil];
}

- (NSInteger)addButtonWithTitle:(nullable NSString *)title style:(TBActionButtonStyle)style handler:(nullable TBActionButtonHandler)handler animation:(TBActionSheetAnimation)animation
{
    TBActionButton *button = [TBActionButton buttonWithTitle:title style:style handler:handler animation:animation];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
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
    return [self buttonAtIndex:buttonIndex].currentTitle;
}

- (TBActionButton *)buttonAtIndex:(NSInteger)buttonIndex
{
    if ([self isIndexValid:buttonIndex]) {
        return self.buttons[buttonIndex];
    }
    return nil;
}

#pragma mark - getter&setter

- (NSInteger)numberOfButtons
{
    return self.buttons.count;
}

- (void)setButtonFont:(UIFont *)buttonFont
{
    if (buttonFont && _buttonFont != buttonFont) {
        _buttonFont = buttonFont;
        for (TBActionButton *btn in self.buttons) {
            btn.titleLabel.font = buttonFont;
        }
    }
}

- (UIFont *)buttonFont
{
    if (!_buttonFont) {
        _buttonFont = self.buttons.lastObject.titleLabel.font;
    }
    return _buttonFont;
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

- (NSInteger)customViewIndex
{
    if (!self.customView) {
        return -1;
    }
    return MIN(MAX(_customViewIndex, 0), self.numberOfButtons);
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

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.2) {
            _titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
        }
        else {
            _titleLabel.font = [UIFont systemFontOfSize:13];
        }
        self.titleLabel.textColor = [UIColor colorWithWhite:0.56 alpha:1];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [UILabel new];
        self.messageLabel.textColor = [UIColor colorWithWhite:0.56 alpha:1];
        self.messageLabel.font = [UIFont systemFontOfSize:13];
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLabel;
}

- (BOOL)isVisible
{
    // action sheet is visible iff it's associated with a window
    return !!self.window && self.window.rootViewController;
}

- (void)setBackgroundTouchClosureEnabled:(BOOL)backgroundTouchClosureEnabled
{
    _backgroundTouchClosureEnabled = backgroundTouchClosureEnabled;
    self.background.userInteractionEnabled = backgroundTouchClosureEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    _scrollEnabled = scrollEnabled;
    self.scrollView.scrollEnabled = scrollEnabled;
}

- (void)setCloseAnimation:(TBActionSheetAnimation)closeAnimation
{
    if (!closeAnimation) {
        return;
    }
    _closeAnimation = closeAnimation;
}

#pragma mark - show action
/**
 *  设定新的 UIWindow，并将 TBActionSheet 附加在上面
 */
- (void)setupNewWindow
{
    if ([self isVisible]) {
        return;
    }
    
    self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    [self.previousKeyWindow interruptGesture];
    TBActionSheetController *actionSheetVC = [[TBActionSheetController alloc] initWithNibName:nil bundle:nil];
    actionSheetVC.actionSheet = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = self.windowLevel;
    self.window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.window.opaque = NO;
    [self.window makeKeyAndVisible];
    self.window.rootViewController = actionSheetVC;
}

/**
 *  设定所有内容的布局
 */
- (void)setupLayout
{
    //将视图从上到下排列，计算当前排列的纵坐标
    __block CGFloat lastY = 0;
    //inline block, 减少代码冗余
    void(^handleLabelFrameBlock)(UILabel *label, NSString *content) = ^(UILabel *label, NSString *content) {
        //给一个比较大的高度，宽度不变
        CGSize size =CGSizeMake(self.sheetWidth, 1000);
        //获取当前文本的属性
        NSDictionary * tdic = @{NSFontAttributeName:label.font};
        CGSize actualsize;
        //iOS7方法，获取文本需要的size，限制宽度
        actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        label.frame = CGRectMake(0, lastY, self.sheetWidth, actualsize.height);
        lastY = CGRectGetMaxY(label.frame);
    };
    
    // 设定是否触碰背景关闭 ActionSheet
    self.background.userInteractionEnabled = self.isBackgroundTouchClosureEnabled;
    
    //移除所有 Separator
    for (UIView *separator in self.separators) {
        [separator removeFromSuperview];
    }
    [self.separators removeAllObjects];
    
    //处理标题
    if ([self hasTitle]) {
        lastY += self.headerVerticalSpacing;
        self.titleLabel.frame = CGRectMake(0, lastY, self.sheetWidth, 0);
        [self.actionContainer.header addSubview:self.titleLabel];
        self.titleLabel.text = self.title;
        handleLabelFrameBlock(self.titleLabel, self.title);
    }
    //处理 message
    if ([self hasMessage]) {
        if (![self hasTitle]) {
            lastY += self.headerVerticalSpacing;
        }
        else {
            lastY += self.headerLineSpacing;
        }
        self.messageLabel.frame = CGRectMake(0, lastY, self.sheetWidth, 0);
        [self.actionContainer.header addSubview:self.messageLabel];
        self.messageLabel.text = self.message;
        handleLabelFrameBlock(self.messageLabel, self.message);
    }
    
    //处理title
    if ([self hasHeader]) {
        lastY += self.headerVerticalSpacing;
        self.actionContainer.header.frame = CGRectMake(0, 0, self.sheetWidth, lastY);
    }
    
    //插入自定义视图
    void(^insertCustomViewAtIndex)(NSUInteger) = ^(NSUInteger idx) {
        if (self.customViewIndex == idx) {
            if (idx > 0 && idx <= self.numberOfButtons && self.buttons[idx - 1].style == TBActionButtonStyleCancel) {
                [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:YES];
                lastY += self.bigFragment;
            }
            else if (!(idx == 0 && ![self hasHeader])) {
                [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:NO];
                lastY += self.smallFragment;
            }
            self.actionContainer.custom.frame = CGRectMake(0, lastY, self.sheetWidth, self.customView.frame.size.height);
            self.customView.center = CGPointMake(self.sheetWidth / 2, self.customView.frame.size.height / 2);
            [self.actionContainer.custom addSubview:self.customView];
            lastY = CGRectGetMaxY(self.actionContainer.custom.frame);
        }
    };
    
    //计算按钮坐标并添加样式
    [self.buttons enumerateObjectsUsingBlock:^(TBActionButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        insertCustomViewAtIndex(idx);
        
        switch (obj.style) {
            case TBActionButtonStyleDefault: {
                [obj setTitleColor:self.tintColor forState:UIControlStateNormal];
                break;
            }
            case TBActionButtonStyleCancel: {
                [obj setTitleColor:self.cancelButtonColor forState:UIControlStateNormal];
                break;
            }
            case TBActionButtonStyleDestructive: {
                [obj setTitleColor:self.destructiveButtonColor forState:UIControlStateNormal];
                break;
            }
        }
        
        
        if (idx == 0 && ![self hasHeader] && self.customViewIndex != idx) {
            // 没有 Header 的时候，首个 button 上方也没有 customView 时，不需要间隙
        }
        else if (obj.style == TBActionButtonStyleCancel
                 || (idx > 0 && self.buttons[idx - 1].style == TBActionButtonStyleCancel && self.customViewIndex != idx)) {
            //当前 button 如果是 cancel，或者上一个 button 是 cancel 且当前 button 没有插入 customView，就采用大间隙。
            [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:YES];
            lastY += self.bigFragment;
        }
        else {
            [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:NO];
            lastY += self.smallFragment;
        }
        
        obj.frame = CGRectMake(0, lastY, self.sheetWidth, obj.height ?: self.buttonHeight);
        lastY = CGRectGetMaxY(obj.frame);
        [self.actionContainer addSubview:obj];
    }];
    
    insertCustomViewAtIndex(self.numberOfButtons);
    
    if (self.offsetY < 0) {
        lastY -= self.offsetY;
    }
    
    self.actionContainer.frame = CGRectMake(0, 0, self.sheetWidth, lastY);
    self.scrollView.frame = CGRectMake(kContainerLeft, kScreenHeight, self.sheetWidth, MIN(self.actionContainer.frame.size.height, kScreenHeight));
    self.scrollView.contentSize = CGSizeMake(self.sheetWidth, lastY);
}

/**
 *  设置毛玻璃效果、圆角、背景颜色等
 */
- (void)setupStyle
{
    // 清理容器内用于毛玻璃效果的视图
    [self.actionContainer cleanTempViews];
    [self.blurBlocks removeAllObjects];
    
    CGFloat containerHeight = self.actionContainer.bounds.size.height;
    
    self.originalBackgroundImage = [self screenShotRect:CGRectMake(kContainerLeft, kScreenHeight - containerHeight, self.sheetWidth, containerHeight)];
    
    __block BOOL useBoxBlurEffect = NO;
    
    if (!self.isBackgroundTransparentEnabled) {
        if (self.isBlurEffectEnabled) {
            if (![self.actionContainer useSystemBlurEffect]) {
                TBWeakSelf(self);
                TBBlurEffectBlock blurBlock = ^void() {
                    TBStrongSelf(self);
                    UIImage *backgroundImage = [self.originalBackgroundImage drn_boxblurImageWithBlur:blurRadius withTintColor:[self.ambientColor colorWithAlphaComponent:0.5]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.actionContainer.image = backgroundImage;
                    });
                };
                [self.blurBlocks addObject:blurBlock];
                useBoxBlurEffect = YES;
                blurBlock();
            }
            else {
                self.actionContainer.image = nil;
            }
        }
        else {
            self.actionContainer.image = nil;
            self.actionContainer.backgroundColor = [self.ambientColor colorWithAlphaComponent:0.5];
        }
    }
    else {
        self.actionContainer.image = nil;
        self.actionContainer.backgroundColor = nil;
    }
    
    // 初始化容器内的圆角
    self.actionContainer.header.tbRectCorner = TBRectCornerTop;
    self.actionContainer.custom.tbRectCorner = TBRectCornerNone;
    // 所有 Cancel 按钮圆角
    for (TBActionButton *button in self.buttons) {
        button.tbRectCorner = button.style == TBActionButtonStyleCancel ? TBRectCornerAll : TBRectCornerNone;
    }
    // 最顶部圆角
    if (![self hasHeader]) {
        if (self.customViewIndex == 0) {
            self.actionContainer.custom.tbRectCorner |= TBRectCornerTop;
        }
        else {
            self.buttons.firstObject.tbRectCorner |= TBRectCornerTop;
        }
    }
    // 最底部圆角
    if (self.customViewIndex == self.numberOfButtons) {
        self.actionContainer.custom.tbRectCorner |= TBRectCornerBottom;
    }
    else {
        self.buttons.lastObject.tbRectCorner |= TBRectCornerBottom;
    }
    
    // 遍历设置圆角
    [self.buttons enumerateObjectsUsingBlock:^(TBActionButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if (obj.style == TBActionButtonStyleCancel) {
            // 处理上面
            if (self.customViewIndex == idx) {
                self.actionContainer.custom.tbRectCorner |= TBRectCornerBottom;
            }
            else if (idx > 0) {
                self.buttons[idx - 1].tbRectCorner |= TBRectCornerBottom;
            }
            else if ([self hasHeader]) {
                self.actionContainer.header.tbRectCorner |= TBRectCornerBottom;
            }
            // 处理下面
            if (self.customViewIndex == idx + 1) {
                self.actionContainer.custom.tbRectCorner |= TBRectCornerTop;
            }
            else if (idx + 1 < self.buttons.count) {
                self.buttons[idx + 1].tbRectCorner |= TBRectCornerTop;
            }
        }
    }];
    
    for (TBActionButton *btn in self.buttons) {
        [btn setCornerRadius:self.rectCornerRadius];
        btn.titleLabel.font = self.buttonFont;
    }
    
    [self.actionContainer.header setCornerRadius:self.rectCornerRadius];
    [self.actionContainer.custom setCornerRadius:self.rectCornerRadius];
    
    TBWeakSelf(self);
    UIImage *(^cutOriginalBackgroundImageInRect)(CGRect frame) = ^UIImage *(CGRect sourceFrame) {
        TBStrongSelf(self);
        CGRect targetFrame;
        targetFrame = CGRectMake(sourceFrame.origin.x, sourceFrame.origin.y - MAX(0, self.scrollView.contentOffset.y), sourceFrame.size.width, sourceFrame.size.height);
        UIImage *cuttedImage = [self cutFromImage:self.originalBackgroundImage inRect:targetFrame];
        return cuttedImage;
    };
    
    //设置背景风格
    if ([self hasHeader]) {
        if (self.isBlurEffectEnabled && self.isBackgroundTransparentEnabled) {
            self.actionContainer.header.backgroundColor = nil;
            if (![self.actionContainer useSystemBlurEffectUnderView:self.actionContainer.header]) {
                TBWeakSelf(self);
                TBBlurEffectBlock blurBlock = ^void() {
                    TBStrongSelf(self);
                    UIImage *backgroundImage = [cutOriginalBackgroundImageInRect(self.actionContainer.header.frame) drn_boxblurImageWithBlur:blurRadius withTintColor:self.ambientColor];
                    if (backgroundImage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.actionContainer.header.image = backgroundImage;
                        });
                    }
                };
                [self.blurBlocks addObject:blurBlock];
                useBoxBlurEffect = YES;
                blurBlock();
            }
            else {
                self.actionContainer.header.image = nil;
            }
        }
        else {
            self.actionContainer.header.image = nil;
            self.actionContainer.header.backgroundColor = self.ambientColor;
        }
    }
    
    if (self.customView) {
        if (self.isBlurEffectEnabled && self.isBackgroundTransparentEnabled) {
            self.actionContainer.custom.backgroundColor = nil;
            if (![self.actionContainer useSystemBlurEffectUnderView:self.actionContainer.custom]) {
                TBWeakSelf(self);
                TBBlurEffectBlock blurBlock = ^void() {
                    TBStrongSelf(self);
                    UIImage *backgroundImage = [cutOriginalBackgroundImageInRect(self.actionContainer.custom.frame) drn_boxblurImageWithBlur:blurRadius withTintColor:self.ambientColor];
                    if (backgroundImage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.actionContainer.custom.image = backgroundImage;
                        });
                    }
                };
                [self.blurBlocks addObject:blurBlock];
                useBoxBlurEffect = YES;
                blurBlock();
            }
            else {
                self.actionContainer.custom.image = nil;
            }
        }
        else {
            self.actionContainer.custom.image = nil;
            self.actionContainer.custom.backgroundColor = self.ambientColor;
        }
    }
    
    [self.buttons enumerateObjectsUsingBlock:^(TBActionButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.isBlurEffectEnabled && self.isBackgroundTransparentEnabled) {
            if (![self.actionContainer useSystemBlurEffectUnderView:obj withColor:obj.normalColor]) {
                TBWeakSelf(self);
                TBBlurEffectBlock blurBlock = ^void() {
                    TBStrongSelf(self);
                    UIImage *cuttedImage = cutOriginalBackgroundImageInRect(obj.frame);
                    if (cuttedImage) {
                        UIImage *backgroundImageNormal = [cuttedImage drn_boxblurImageWithBlur:blurRadius withTintColor: (obj.normalColor ? obj.normalColor : self.ambientColor)];
                        UIImage *backgroundImageHighlighted = [cuttedImage drn_boxblurImageWithBlur:blurRadius withTintColor:(obj.highlightedColor ? obj.highlightedColor : [UIColor colorWithWhite:0.5 alpha:0.5])];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [obj setBackgroundImage:backgroundImageNormal forState:UIControlStateNormal];
                            [obj setBackgroundImage:backgroundImageHighlighted forState:UIControlStateHighlighted];
                            obj.backgroundColor = [UIColor clearColor];
                        });
                    }
                };
                [self.blurBlocks addObject:blurBlock];
                useBoxBlurEffect = YES;
                blurBlock();
            }
            else {
                [obj setBackgroundImage:nil forState:UIControlStateNormal];
                [obj setBackgroundImage:nil forState:UIControlStateHighlighted];
            }
            obj.backgroundColor = [UIColor clearColor];
        }
        else {
            [obj setBackgroundImage:nil forState:UIControlStateNormal];
            [obj setBackgroundImage:nil forState:UIControlStateHighlighted];
            obj.backgroundColor = obj.normalColor ?: self.ambientColor;
            if (!obj.highlightedColor) {
                obj.highlightedColor = [UIColor colorWithWhite:0.5 alpha:0.5];
            }
        }
    }];
}

- (void)refreshBlurEffect
{
    CGFloat containerHeight = self.actionContainer.bounds.size.height;
    
    self.originalBackgroundImage = [self screenShotRect:CGRectMake(kContainerLeft, kScreenHeight-containerHeight, self.sheetWidth, containerHeight)];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (void (^blurBlock)(void) in self.blurBlocks) {
            blurBlock();
        }
    });
}

- (void)updateContainerFrame
{
    CGFloat y = kScreenHeight - self.actionContainer.frame.size.height;
    self.scrollView.frame = CGRectMake(kContainerLeft, MAX(0, y), self.scrollView.frame.size.width, MIN(self.actionContainer.frame.size.height, kScreenHeight));
    self.scrollView.contentOffset = CGPointMake(0, MAX(0, -y));
}
/**
 *  显示 ActionSheet
 */
- (void)show
{
    //弹出 ActionSheet 动画
    [self showWithAnimation:nil];
}

- (void)showWithAnimation:(TBActionSheetAnimation)animation
{
    if ([self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [self.delegate willPresentActionSheet:self];
    }
    
    [self setupNewWindow];
    
    [self setupLayout];
    
    [self setupStyle];
    
    void(^completion)(void) = ^() {
        if ([self.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
            [self.delegate didPresentActionSheet:self];
        }
        self.visible = YES;
    };
    // 使用内置动画
    if (!animation) {
        animation = ^(UIImageView * _Nonnull background, UIView * _Nonnull container, void (^ _Nonnull completion)(void)) {
            void(^animations)(void) = ^() {
                background.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
                [self updateContainerFrame];
            };
            [UIView animateWithDuration:self.animationDuration
                                  delay:0
                 usingSpringWithDamping:self.animationDampingRatio
                  initialSpringVelocity:self.animationVelocity
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:animations
                             completion:^(BOOL finished) {
                                 completion();
                             }];
        };
    }
    animation(self.background, self.scrollView, completion);
}

/**
 *  显示 ActionSheet
 *
 *  @param view 没有用到
 */
- (void)showInView:(UIView *)view
{
    [self show];
}

#pragma mark - handle button press
/**
 *  按钮点击事件，不要直接调用
 *
 *  @param sender 点击的按钮对象
 */
- (void)buttonTapped:(TBActionButton *)sender
{
    if (![self isVisible]) {
        return;
    }
    
    NSUInteger index = [self.buttons indexOfObject:sender];
    
    void(^completion)(void) = ^() {
        //这里之所以把各种 delegate 调用都放在动画完成后是有原因的：为了支持在回调方法中 show 另一个 actionsheet，系统的 UIActionSheet 的调用时机也是如此。
        
        if ([self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
            [self.delegate actionSheet:self willDismissWithButtonIndex:index];
        }
        
        [self cleanWindow];
        
        if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
            [self.delegate actionSheet:self clickedButtonAtIndex:index];
        }
        if (sender.handler) {
            __weak __typeof(TBActionButton *)weakSender = sender;
            sender.handler(weakSender);
        }
        
        if ([self.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
            [self.delegate actionSheet:self didDismissWithButtonIndex:index];
        }
        self.visible = NO;
    };
    // 优先使用按钮动画，其次是关闭动画
    TBActionSheetAnimation animation = sender.animation ?: self.closeAnimation;
    
    animation(self.background, self.scrollView, completion);
}

#pragma mark - handle close
/**
 *  取消 ActionSheet 的方法
 */
- (void)close
{
    [self closeWithAnimation:nil];
}

- (void)closeWithAnimation:(TBActionSheetAnimation)animation
{
    if (![self isVisible]) {
        return;
    }
    
    void(^completion)(void) = ^() {
        [self cleanWindow];
        
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
    };
    
    // 关闭动画
    animation = animation ?: self.closeAnimation;
    
    animation(self.background, self.scrollView, completion);
}

- (void)cleanWindow
{
    self.window.rootViewController = nil;
    self.window = nil;
    [self.previousKeyWindow makeKeyAndVisible];
}

#pragma mark - handle Notification

- (void)statusBarDidChangeOrientation:(NSNotification *)notification {
    self.bounds = [UIScreen mainScreen].bounds;
    self.background.frame = self.bounds;
    [self updateContainerFrame];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (void (^blurBlock)(void) in self.blurBlocks) {
        blurBlock();
    }
}

#pragma mark - help methods

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
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, self.sheetWidth, isBigFragment ? self.bigFragment : self.smallFragment)];
    separatorLine.backgroundColor = self.separatorColor;
    [self.actionContainer addSubview:separatorLine];
    [self.separators addObject:separatorLine];
}

/**
 *  从区域截屏
 *
 *  @param aRect 区域
 *
 *  @return 截取的图片
 */
- (UIImage *)screenShotRect:(CGRect)aRect
{
    // 获取最上层的 UIViewController
    UIViewController *topController = [self.previousKeyWindow currentViewController];
    UIView *view = topController.view;
    
    UIGraphicsBeginImageContext(view.bounds.size);
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        const CGFloat crashMagicNumber = 0.3;// size 小于0.3 在 iOS7 上会导致 crash
        if (view.frame.size.width >= crashMagicNumber &&
            view.frame.size.height >= crashMagicNumber ) { // resolve iOS7 size crash
            [view drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
        }
    }
    else {/* iOS 6 */
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *screenshotimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [self cutFromImage:screenshotimage inRect:aRect];
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
}

- (BOOL)isIndexValid:(NSInteger) index
{
    if (index >=0 && index < self.buttons.count) {
        return YES;
    }
    return NO;
}

@end
