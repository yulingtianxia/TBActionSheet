//
//  TBActionSheet.m
//
//  Created by 杨萧玉 on 15/11/17.
//  Copyright © 2015年 Tencent. All rights reserved.
//

#import "TBActionSheet.h"
#import "UIImage+BoxBlur.h"

/* 宏字符串操作，避免在宏里面嵌套使用宏带来的问题 */
#define TB_stringify(STR) # STR
#define TB_string_concat(A, B) A ## B

/*
 * 用于防止在 Blocks 里面循环引用变量，并且无需改变变量名的写法。`TB_weakify` 和 `TB_strongify` 要搭配使用，`TB_weakify`
 * 用于将变量弱化，`TB_strongify` 用于在 Blocks 开始执行后将变量进行强引用，防止执行过程中变量被释放（多线程的情况下）。
 */
#define TBWeakSelf(VAR) \
__weak __typeof__(VAR) TB_string_concat(VAR, _weak_) = (VAR)

#define TBStrongSelf(VAR) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong __typeof__(VAR) VAR = TB_string_concat(VAR, _weak_) \
_Pragma("clang diagnostic pop")

#pragma mark - const values

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define containerLeft (SCREEN_WIDTH-self.sheetWidth)/2

const CGFloat bigFragment = 8;
const CGFloat smallFragment = 0.5;
const NSTimeInterval animationDuration = 0.2;
const CGFloat sheetCornerRadius = 10.0f;

#pragma mark - UIView (RectCorner)

/**
 *  加圆角
 */
@interface UIView (RectCorner)
- (void)setCornerOnTop;
- (void)setCornerOnBottom;
- (void)setAllCorner;
- (void)setNoneCorner;
@end

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

#pragma mark - TBActionButton

typedef NS_OPTIONS(NSUInteger, TBActionButtonCorner) {
    TBActionButtonCornerTop = 1 << 0,
    TBActionButtonCornerBottom = 1 << 1,
    TBActionButtonCornerNone = 0,
    TBActionButtonCornerAll = TBActionButtonCornerTop|TBActionButtonCornerBottom,
};

/**
 *  可定制风格和圆角的按钮
 */
@interface TBActionButton : UIButton

@property (nonatomic) TBActionButtonStyle style;
@property (nonatomic) TBActionButtonCorner corner;

+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style;

@end

@implementation TBActionButton

+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style
{
    TBActionButton *button = [TBActionButton buttonWithType:UIButtonTypeCustom];
    button.style = style;
    button.corner = TBActionButtonCornerNone;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button.titleLabel setFont:[UIFont systemFontOfSize:20]];
    return button;
}

@end

#pragma mark - TBActionContainer
/**
 *  容器类，用于包含所有按钮，可定制 header，custom 和 footer 三个 view
 */
@interface TBActionContainer : UIImageView
@property (nonnull,nonatomic,strong) UIImageView *header;
@property (nonnull,nonatomic,strong) UIImageView *custom;
@property (nonnull,nonatomic,strong) UIImageView *footer;

- (nonnull instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end

@implementation TBActionContainer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _header = [[UIImageView alloc] init];
        _custom = [[UIImageView alloc] init];
        _footer = [[UIImageView alloc] init];
        _header.clipsToBounds = YES;
        _custom.clipsToBounds = YES;
        _footer.clipsToBounds = YES;
        [self addSubview:_header];
        [self addSubview:_custom];
        [self addSubview:_footer];
    }
    return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

}

@end

#pragma mark - TBActionBackground

@interface TBActionBackground : UIImageView

@end

@implementation TBActionBackground

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.superview respondsToSelector:@selector(close)]) {
        [self.superview performSelector:@selector(close)];
    }
}

@end

#pragma mark - TBActionSheet

@interface TBActionSheet ()
@property(nonatomic,readwrite,getter=isVisible) BOOL visible;
@property (nonatomic,nonnull,strong) TBActionBackground * background;
@property (nonatomic,nonnull,strong) TBActionContainer * actionContainer;
@property (nonatomic,nonnull,strong) NSMutableArray<TBActionButton *> *buttons;
@property(nonatomic,strong,nullable,readwrite) UILabel *titleLabel;
@end

@implementation TBActionSheet

- (instancetype)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _background = [[TBActionBackground alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _background.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        _background.userInteractionEnabled = YES;
        [self addSubview:_background];
        _actionContainer = [[TBActionContainer alloc] init];
        _actionContainer.userInteractionEnabled = YES;
        [self addSubview:_actionContainer];
        _buttons = [NSMutableArray array];
        //set default values
        _cancelButtonIndex = -1;
        _destructiveButtonIndex = -1;
        _buttonHeight = 56;
        _titleHeight = 45;
        _bottomOffset = - bigFragment;
        _tintColor = [UIColor blackColor];
        _destructiveButtonColor = [UIColor redColor];
        _cancelButtonColor = [UIColor blackColor];
        _sheetWidth = SCREEN_WIDTH-20;
        _backgroundTransparentEnabled = YES;
        _blurEffectEnabled = YES;
        _rectCornerEnabled = YES;
        _backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
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

- (void)dealloc
{
    
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
    TBActionButton *button = [TBActionButton buttonWithTitle:title style:TBActionButtonStyleDefault];
    [button addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttons addObject:button];
    return self.buttons.count - 1;
}

- (NSInteger)addButtonWithTitle:(NSString *)title style:(TBActionButtonStyle)style
{
    TBActionButton *button = [TBActionButton buttonWithTitle:title style:style];
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
    for (TBActionButton *btn in self.buttons) {
        btn.titleLabel.font = buttonFont;
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

#pragma mark show
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
    //将视图从上到下排列，计算当前排列的纵坐标
    __block CGFloat lastY = 0;
    //处理标题
    if (self.title) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.sheetWidth, self.titleHeight)];
        self.titleLabel.textColor = [UIColor grayColor];
        self.titleLabel.text = self.title;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.actionContainer.header.frame = CGRectMake(0, lastY, self.sheetWidth, self.titleHeight);
        [self.actionContainer.header addSubview:self.titleLabel];
        lastY = CGRectGetMaxY(self.actionContainer.header.frame) + smallFragment;
    }
    //处理自定义视图
    if (self.customView) {
        self.actionContainer.custom.frame = CGRectMake(0, lastY, self.sheetWidth, self.customView.frame.size.height);
        self.customView.center = CGPointMake(self.sheetWidth / 2, self.customView.frame.size.height/2);
        [self.actionContainer.custom addSubview:self.customView];
        lastY = CGRectGetMaxY(self.actionContainer.custom.frame) + smallFragment;
    }
    //计算按钮坐标并添加样式
    [self.buttons enumerateObjectsUsingBlock:^(TBActionButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (obj.style) {
            case TBActionButtonStyleDefault: {
                [obj setTitleColor:self.tintColor forState:UIControlStateNormal];
                if (idx != 0) {
                    lastY += smallFragment;
                }
                break;
            }
            case TBActionButtonStyleCancel: {
                [obj setTitleColor:self.cancelButtonColor forState:UIControlStateNormal];
                if (idx != 0) {
                    lastY += bigFragment;
                }
                break;
            }
            case TBActionButtonStyleDestructive: {
                [obj setTitleColor:self.destructiveButtonColor forState:UIControlStateNormal];
                if (idx != 0) {
                    lastY += smallFragment;
                }
                break;
            }
            default: {
                break;
            }
        }
        //上一个 button 如果是 cancel
        if (idx>0&&self.buttons[idx-1].style == TBActionButtonStyleCancel) {
            lastY += bigFragment - smallFragment;
        }
        obj.frame = CGRectMake(0, lastY, self.sheetWidth, self.buttonHeight);
        lastY = CGRectGetMaxY(obj.frame);
        [self.actionContainer addSubview:obj];
    }];
    
    //圆角处理和毛玻璃效果、背景颜色
    
    self.actionContainer.frame = CGRectMake(containerLeft, SCREEN_HEIGHT, self.sheetWidth, lastY);
    UIImage *originalBackgroundImage = [self screenShotRect:CGRectMake(containerLeft, SCREEN_HEIGHT-lastY, self.sheetWidth, lastY)];
    
    if (!self.isBackgroundTransparentEnabled) {
        if (self.isBlurEffectEnabled) {
            UIImage *backgroundImage = [originalBackgroundImage drn_boxblurImageWithBlur:0.5 withTintColor:[self.backgroundColor colorWithAlphaComponent:0.5]];
            self.actionContainer.image = backgroundImage;
        }
        else {
            self.actionContainer.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0.5];
        }
    }
    
    if (self.title) {
        if (self.isBlurEffectEnabled && self.isBackgroundTransparentEnabled) {
            UIImage *cuttedImage = [self cutFromImage:originalBackgroundImage inRect:self.actionContainer.header.frame];
            UIImage *backgroundImage = [cuttedImage drn_boxblurImageWithBlur:0.5 withTintColor:self.backgroundColor];
            self.actionContainer.header.image = backgroundImage;
        }
        else {
            self.actionContainer.header.backgroundColor = self.backgroundColor;
        }
    }
    if (self.customView) {
        if (self.isBlurEffectEnabled && self.isBackgroundTransparentEnabled) {
            UIImage *cuttedImage = [self cutFromImage:originalBackgroundImage inRect:self.actionContainer.custom.frame];
            UIImage *backgroundImage = [cuttedImage drn_boxblurImageWithBlur:0.5 withTintColor:self.backgroundColor];
            self.actionContainer.custom.image = backgroundImage;
        }
        else {
            self.actionContainer.custom.backgroundColor = self.backgroundColor;
        }
    }
    
    TBWeakSelf(self);
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TBStrongSelf(self);
        [self.buttons enumerateObjectsUsingBlock:^(TBActionButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.isBlurEffectEnabled && self.isBackgroundTransparentEnabled) {
                UIImage *cuttedImage = [self cutFromImage:originalBackgroundImage inRect:obj.frame];
                UIImage *backgroundImageNormal = [cuttedImage drn_boxblurImageWithBlur:0.5 withTintColor:self.backgroundColor];
                UIImage *backgroundImageHighlighted = [cuttedImage drn_boxblurImageWithBlur:0.5 withTintColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
                [obj setBackgroundImage:backgroundImageNormal forState:UIControlStateNormal];
                [obj setBackgroundImage:backgroundImageHighlighted forState:UIControlStateHighlighted];
            }
            else {
                obj.backgroundColor = self.backgroundColor;
            }
            //设置圆角，已知 bug：cancel 按钮不在末尾会导致圆角不正常，懒得改，因为 cancel 不放在末尾本身就不正常
            if (self.isRectCornerEnabled) {
                if (self.buttons.count == 1) {
                    obj.corner = TBActionButtonCornerTop|TBActionButtonCornerBottom;
                }
                else if (obj.style == TBActionButtonStyleCancel) {
                    obj.corner = TBActionButtonCornerTop|TBActionButtonCornerBottom;
                    if (idx >= 1) {
                        self.buttons[idx - 1].corner |= TBActionButtonCornerBottom;
                    }
                    else {
                        if (self.title) {
                            [self.actionContainer.header setCornerOnBottom];
                        }
                        else if (self.customView) {
                            [self.actionContainer.custom setCornerOnBottom];
                        }
                    }
                    if (idx + 1 <= self.buttons.count - 1) {
                        self.buttons[idx + 1].corner |= TBActionButtonCornerTop;
                    }
                }
                else if (idx == 0) {
                    if (self.title) {
                        [self.actionContainer.header setCornerOnTop];
                    }
                    else if (self.customView) {
                        [self.actionContainer.custom setCornerOnTop];
                    }
                    else {
                        obj.corner |= TBActionButtonCornerTop;
                    }
                }
                else if (idx == self.buttons.count - 1) {
                    obj.corner |= TBActionButtonCornerBottom;
                }
            }
        }];
        if (self.isRectCornerEnabled) {
            for (TBActionButton *btn in self.buttons) {
                switch (btn.corner) {
                    case TBActionButtonCornerTop: {
                        [btn setCornerOnTop];
                        break;
                    }
                    case TBActionButtonCornerBottom: {
                        [btn setCornerOnBottom];
                        break;
                    }
                    case TBActionButtonCornerNone: {
                        [btn setNoneCorner];
                        break;
                    }
                    case TBActionButtonCornerAll: {
                        [btn setAllCorner];
                        break;
                    }
                    default: {
                        break;
                    }
                }
            }
        }
    });
    
    
    //弹出 ActionSheet 动画
    [view addSubview:self];
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.background.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.actionContainer.frame = CGRectMake(containerLeft, SCREEN_HEIGHT - lastY + self.bottomOffset, self.actionContainer.frame.size.width, self.actionContainer.frame.size.height);
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
            [self.delegate didPresentActionSheet:self];
        }
        self.visible = YES;
    }];
}

#pragma mark handle button press
/**
 *  按钮点击事件，不要直接调用
 *
 *  @param sender 点击的按钮对象
 */
- (void)checkButtonTapped:(TBActionButton *)sender
{
    NSUInteger index = [self.buttons indexOfObject:sender];
    if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self clickedButtonAtIndex:index];
    }
    if ([self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
        [self.delegate actionSheet:self willDismissWithButtonIndex:index];
    }
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.background.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.actionContainer.frame = CGRectMake(containerLeft, SCREEN_HEIGHT, self.actionContainer.frame.size.width, self.actionContainer.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
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
    if ([self.delegate respondsToSelector:@selector(actionSheetCancel:)]) {
        [self.delegate actionSheetCancel:self];
    }
    else if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        if ([self isIndexValid:self.cancelButtonIndex]) {
            [self.delegate actionSheet:self clickedButtonAtIndex:self.cancelButtonIndex];
        }
    }
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.background.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.actionContainer.frame = CGRectMake(containerLeft, SCREEN_HEIGHT, self.actionContainer.frame.size.width, self.actionContainer.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.visible = NO;
    }];
}

#pragma mark help methods

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
    UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
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
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];
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
