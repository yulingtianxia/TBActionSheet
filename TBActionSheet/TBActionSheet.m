//
//  TBActionSheet.m
//
//  Created by 杨萧玉 on 15/11/17.
//  Copyright © 2015年 yulingtianxia. All rights reserved.
//

#import "TBActionSheet.h"
#import "UIImage+BoxBlur.h"
#import "TBMacro.h"
#import <objc/runtime.h>

const CGFloat bigFragment = 8;
const CGFloat smallFragment = 0.5;
const NSTimeInterval animationDuration = 0.2;
const CGFloat sheetCornerRadius = 10.0f;
const CGFloat headerVerticalSpace = 10;

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

#pragma mark - UIView (TBActionSheet)

@interface UIView (TBActionSheet)
@property (nonatomic,strong,nullable) TBActionSheet *tbActionSheet;
@end

@implementation UIView (TBActionSheet)

@dynamic tbActionSheet;

- (TBActionSheet *)tbActionSheet
{
    return objc_getAssociatedObject(self, @selector(tbActionSheet));
}

- (void)setTbActionSheet:(TBActionSheet *)tbActionSheet
{
    objc_setAssociatedObject(self, @selector(tbActionSheet), tbActionSheet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
@interface TBActionButton()

@property (nonatomic) TBActionButtonCorner corner;
@property (nonatomic,nullable) UIColor *normalColor;
@property (nonatomic,nullable) UIColor *highlightedColor;
@property (nonatomic,nullable,strong,readwrite) void (^handler)(TBActionButton * _Nonnull button);

+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style;
+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style handler:(void (^ __nullable)( TBActionButton * _Nonnull button))handler;

@end

@implementation TBActionButton

+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style
{
    return [TBActionButton buttonWithTitle:title style:style handler:nil];
}

+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style handler:(void (^ __nullable)( TBActionButton * _Nonnull button))handler
{
    TBActionButton *button = [TBActionButton buttonWithType:UIButtonTypeCustom];
    button.style = style;
    button.corner = TBActionButtonCornerNone;
    button.handler = handler;
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button.titleLabel setFont:[UIFont systemFontOfSize:20]];
    return button;
}

- (void)dealloc
{
    
}

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = self.highlightedColor;
    }
    else {
        self.backgroundColor = self.normalColor;
    }
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
    self.backgroundColor = normalColor;
    if (!self.highlightedColor) {
        self.highlightedColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    }
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
@property (nonatomic,readwrite,getter=isVisible) BOOL visible;
@property (nonatomic,nonnull,strong) TBActionBackground * background;
@property (nonatomic,nonnull,strong) TBActionContainer * actionContainer;
@property (nonatomic,nonnull,strong) NSMutableArray<TBActionButton *> *buttons;
@property (nonatomic,nonnull,strong) NSMutableArray<UIView *> *separators;
@property (nonatomic,strong,nullable,readwrite) UILabel *titleLabel;
@property (nonatomic,strong,nullable,readwrite) UILabel *messageLabel;
@property (nonatomic,weak,nullable) UIView *owner;
@end

@implementation TBActionSheet

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, [self screenWidth], [self screenHeight])];
    if (self) {
        [super setBackgroundColor:[UIColor clearColor]];
        self.windowLevel = UIWindowLevelAlert;
        _background = [[TBActionBackground alloc] initWithFrame:self.frame];
        _background.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        _background.userInteractionEnabled = YES;
        [self addSubview:_background];
        _actionContainer = [[TBActionContainer alloc] init];
        _actionContainer.userInteractionEnabled = YES;
        [self addSubview:_actionContainer];
        _buttons = [NSMutableArray array];
        _separators = [NSMutableArray array];
        //set default values
        _cancelButtonIndex = -1;
        _destructiveButtonIndex = -1;
        _buttonHeight = 56;
        _bottomOffset = - bigFragment;
        _tintColor = [UIColor blackColor];
        _destructiveButtonColor = [UIColor redColor];
        _cancelButtonColor = [UIColor blackColor];
        _sheetWidth = MIN(kScreenWidth, kScreenHeight) - 20;
        _backgroundTransparentEnabled = YES;
        _blurEffectEnabled = YES;
        _rectCornerEnabled = YES;
        _backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        _separatorColor = [UIColor clearColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarWillChangeOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id<TBActionSheetDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    self = [self initWithTitle:title message:nil delegate:delegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, nil];
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
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    //将视图从上到下排列，计算当前排列的纵坐标
    __block CGFloat lastY = 0;
    //处理标题
    if ([self hasTitle]) {
        lastY += headerVerticalSpace;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, lastY, self.sheetWidth, 0)];
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
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self.actionContainer.header addSubview:self.titleLabel];
        //给一个比较大的高度，宽度不变
        CGSize size =CGSizeMake(self.sheetWidth,1000);
        //获取当前文本的属性
        NSDictionary * tdic = @{NSFontAttributeName:self.titleLabel.font};
        //ios7方法，获取文本需要的size，限制宽度
        CGSize actualsize =[self.title boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        self.titleLabel.frame = CGRectMake(0, lastY, self.sheetWidth, actualsize.height);
        lastY = CGRectGetMaxY(self.titleLabel.frame);
    }
    //处理 message
    if ([self hasMessage]) {
        if (![self hasTitle]) {
            lastY += headerVerticalSpace;
        }
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, lastY, self.sheetWidth, 0)];
        self.messageLabel.textColor = [UIColor colorWithWhite:0.56 alpha:1];
        self.messageLabel.font = [UIFont systemFontOfSize:13];
        self.messageLabel.text = self.message;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.backgroundColor = [UIColor clearColor];
        [self.actionContainer.header addSubview:self.messageLabel];
        //给一个比较大的高度，宽度不变
        CGSize size =CGSizeMake(self.sheetWidth,1000);
        //获取当前文本的属性
        NSDictionary * tdic = @{NSFontAttributeName:self.messageLabel.font};
        //ios7方法，获取文本需要的size，限制宽度
        CGSize actualsize =[self.message boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        self.messageLabel.frame = CGRectMake(0, lastY, self.sheetWidth, actualsize.height);
        lastY = CGRectGetMaxY(self.messageLabel.frame);
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
        switch (obj.style) {
            case TBActionButtonStyleDefault: {
                [obj setTitleColor:self.tintColor forState:UIControlStateNormal];
                if (idx != 0) {
                    [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:NO];
                    lastY += smallFragment;
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
                    [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:NO];
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
            lastY -= smallFragment;
            [self addSeparatorLineAt:CGPointMake(0, lastY) isBigFragment:YES];
            lastY += bigFragment;
        }
        obj.frame = CGRectMake(0, lastY, self.sheetWidth, self.buttonHeight);
        lastY = CGRectGetMaxY(obj.frame);
        [self.actionContainer addSubview:obj];
    }];
    
    //圆角处理和毛玻璃效果、背景颜色

    self.actionContainer.frame = CGRectMake(kContainerLeft, [self screenHeight], self.sheetWidth, lastY);
    [self prepareActionContainerForOrientation:orientation];
    UIImage *originalBackgroundImage = [self screenShotRect:CGRectMake(kContainerLeft, kScreenHeight-lastY, self.sheetWidth, lastY)];
    
    if (!self.isBackgroundTransparentEnabled) {
        if (self.isBlurEffectEnabled) {
            UIImage *backgroundImage = [originalBackgroundImage drn_boxblurImageWithBlur:0.5 withTintColor:[self.backgroundColor colorWithAlphaComponent:0.5]];
            self.actionContainer.image = backgroundImage;
        }
        else {
            self.actionContainer.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0.5];
        }
    }
    
    if ([self hasHeader]) {
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
                obj.normalColor = self.backgroundColor;
                obj.highlightedColor = [UIColor colorWithWhite:0.5 alpha:0.5];
            }
            //设置圆角，已知 bug：cancel 按钮不在末尾会导致圆角不正常，懒得改，因为 cancel 不放在末尾本身就不正常
            if (self.isRectCornerEnabled) {
                if (self.buttons.count == 1) {
                    obj.corner = TBActionButtonCornerTop|TBActionButtonCornerBottom;
                    if ([self hasHeader]) {
                        if (self.customView) {
                            [self.actionContainer.header setCornerOnTop];
                        }
                        else {
                            [self.actionContainer.header setAllCorner];
                        }
                    }
                    if (self.customView) {
                        if ([self hasHeader]) {
                            [self.actionContainer.custom setCornerOnBottom];
                        }
                        else {
                            [self.actionContainer.custom setAllCorner];
                        }
                    }
                }
                else if (obj.style == TBActionButtonStyleCancel) {
                    obj.corner = TBActionButtonCornerTop|TBActionButtonCornerBottom;
                    if (idx >= 1) {
                        self.buttons[idx - 1].corner |= TBActionButtonCornerBottom;
                    }
                    else {
                        if ([self hasHeader]) {
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
                    if ([self hasHeader]) {
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
    view.tbActionSheet = self;
    self.owner = view;
    
    [self makeKeyAndVisible];
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.background.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
//        self.actionContainer.frame = CGRectMake(kContainerLeft, kScreenHeight - lastY + self.bottomOffset - (!kiOS7Later? 20: 0), self.actionContainer.frame.size.width, self.actionContainer.frame.size.height);
        [self appearActionContainerForOrientation:orientation];
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
            [self.delegate didPresentActionSheet:self];
        }
        self.visible = YES;
    }];
}

#pragma mark handle orientation
#define DegreesToRadians(degrees) (degrees * M_PI / 180)

- (void)prepareActionContainerForOrientation:(UIInterfaceOrientation) orientation
{
    CGAffineTransform trans;
    CGFloat height = fabs(self.actionContainer.transform.b) == 1 ? self.actionContainer.frame.size.width : self.actionContainer.frame.size.height;
    CGPoint point = CGPointMake(0, -height/2 - [self screenHeight] / 2);
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft: {
            trans = CGAffineTransformMakeRotateAroundPoint(point, -DegreesToRadians(90));
            trans = CGAffineTransformTranslate(trans, 0, -([self screenHeight]-[self screenWidth])/2);
            break;
        }
        case UIInterfaceOrientationLandscapeRight: {
            trans = CGAffineTransformMakeRotateAroundPoint(point, DegreesToRadians(90));
            trans = CGAffineTransformTranslate(trans, 0, -([self screenHeight]-[self screenWidth])/2);
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            trans = CGAffineTransformMakeRotation(DegreesToRadians(180));
            break;
        }
        case UIInterfaceOrientationPortrait:
        default:
            trans = CGAffineTransformMakeRotation(DegreesToRadians(0));
            break;
    }
    self.actionContainer.transform = trans;
}

- (void)appearActionContainerForOrientation:(UIInterfaceOrientation) orientation
{
    CGFloat height = fabs(self.actionContainer.transform.b) == 1 ? self.actionContainer.frame.size.width : self.actionContainer.frame.size.height;
    self.actionContainer.transform = CGAffineTransformTranslate(self.actionContainer.transform, 0, -height+self.bottomOffset);
}

- (void)disappearActionContainerForOrientation:(UIInterfaceOrientation) orientation
{
    CGAffineTransform trans;
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation) orientation
{
    CGFloat halfWidth = self.frame.size.width / 2;
    CGFloat halfHeight = self.frame.size.height / 2;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft: {
            CGPoint point = CGPointMake(0, halfWidth-halfHeight);
            return CGAffineTransformMakeRotateAroundPoint(point, -DegreesToRadians(90));
        }
        case UIInterfaceOrientationLandscapeRight: {
            CGPoint point = CGPointMake(halfHeight-halfWidth, 0);
            return CGAffineTransformMakeRotateAroundPoint(point, DegreesToRadians(90));
        }
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(DegreesToRadians(180));
            
        case UIInterfaceOrientationPortrait:
        default:
            return CGAffineTransformMakeRotation(DegreesToRadians(0));
    }
}

CGAffineTransform CGAffineTransformMakeRotateAroundPoint(CGPoint point, CGFloat angle)
{
    CGFloat x = point.x;
    CGFloat y = point.y;
    CGAffineTransform  trans = CGAffineTransformMakeTranslation(x, y);
    trans = CGAffineTransformRotate(trans,angle);
    trans = CGAffineTransformTranslate(trans,-x, -y);
    return trans;
}

- (void)statusBarWillChangeOrientation:(NSNotification *)notification {
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIInterfaceOrientation futureOrientation = ((NSNumber *)notification.userInfo[UIApplicationStatusBarOrientationUserInfoKey]).integerValue;
    [self rotateFromOrientation:currentOrientation toOrientation:futureOrientation];
}

- (CGFloat)screenHeight
{
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationLandscapeLeft || currentOrientation == UIInterfaceOrientationLandscapeRight) {
        return kScreenWidth;
    }
    else {
        return kScreenHeight;
    }
}

- (CGFloat)screenWidth
{
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationLandscapeLeft || currentOrientation == UIInterfaceOrientationLandscapeRight) {
        return kScreenHeight;
    }
    else {
        return kScreenWidth;
    }
}

- (void)rotateFromOrientation:(UIInterfaceOrientation) source toOrientation:(UIInterfaceOrientation) target
{
    typedef NS_ENUM(NSUInteger, RotationPoint) {
        LeftPoint,
        RightPoint,
        CenterPoint,
    };
    
    RotationPoint point;
    CGFloat angle = DegreesToRadians(0);
    
    switch (source) {
        case UIInterfaceOrientationPortrait: {
            switch (target) {
                case UIInterfaceOrientationPortraitUpsideDown: {
                    point = CenterPoint;
                    angle = DegreesToRadians(180);
                    break;
                }
                case UIInterfaceOrientationLandscapeLeft: {
                    point = LeftPoint;
                    angle = -DegreesToRadians(90);
                    break;
                }
                case UIInterfaceOrientationLandscapeRight: {
                    point = RightPoint;
                    angle = DegreesToRadians(90);
                    break;
                }
                case UIInterfaceOrientationPortrait:
                case UIInterfaceOrientationUnknown:
                default: {
                    break;
                }
            }
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            switch (target) {
                case UIInterfaceOrientationPortrait: {
                    point = CenterPoint;
                    angle = DegreesToRadians(180);
                    break;
                }
                case UIInterfaceOrientationLandscapeLeft: {
                    point = RightPoint;
                    angle = DegreesToRadians(90);
                    break;
                }
                case UIInterfaceOrientationLandscapeRight: {
                    point = LeftPoint;
                    angle = -DegreesToRadians(90);
                    break;
                }
                case UIInterfaceOrientationUnknown:
                case UIInterfaceOrientationPortraitUpsideDown:
                default: {
                    break;
                }
            }
            break;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            switch (target) {
                case UIInterfaceOrientationPortrait: {
                    point = LeftPoint;
                    angle = DegreesToRadians(90);
                    break;
                }
                case UIInterfaceOrientationPortraitUpsideDown: {
                    point = RightPoint;
                    angle = -DegreesToRadians(90);
                    break;
                }
                case UIInterfaceOrientationLandscapeRight: {
                    point = CenterPoint;
                    angle = DegreesToRadians(180);
                    break;
                }
                case UIInterfaceOrientationLandscapeLeft:
                case UIInterfaceOrientationUnknown:
                default: {
                    break;
                }
            }
            break;
        }
        case UIInterfaceOrientationLandscapeRight: {
            switch (target) {
                case UIInterfaceOrientationPortrait: {
                    point = RightPoint;
                    angle = -DegreesToRadians(90);
                    break;
                }
                case UIInterfaceOrientationPortraitUpsideDown: {
                    point = LeftPoint;
                    angle = DegreesToRadians(90);
                    break;
                }
                case UIInterfaceOrientationLandscapeLeft: {
                    point = CenterPoint;
                    angle = DegreesToRadians(180);
                    break;
                }
                case UIInterfaceOrientationLandscapeRight:
                case UIInterfaceOrientationUnknown:
                default: {
                    break;
                }
            }
            break;
        }
        case UIInterfaceOrientationUnknown:
        default: {
            break;
        }
    }
    
    CGPoint rotationPoint;
    CGFloat width = fabs(self.actionContainer.transform.b) == 1 ? self.actionContainer.frame.size.height : self.actionContainer.frame.size.width;
    CGFloat height = fabs(self.actionContainer.transform.b) == 1 ? self.actionContainer.frame.size.width : self.actionContainer.frame.size.height;
    
    CGFloat screenWidth = [self screenWidth];
    CGFloat screenHeight = [self screenHeight];
    
    
    switch (point) {
        case LeftPoint: {
            CGFloat x = width / 2 - (screenHeight - screenWidth) / 4;
            CGFloat y = -self.bottomOffset + height - (screenWidth + screenHeight) / 4;
            rotationPoint = CGPointMake(x, y);
            break;
        }
        case RightPoint: {
            CGFloat x = width / 2 + (screenHeight - screenWidth) / 4;
            CGFloat y = -self.bottomOffset + height - (screenWidth + screenHeight) / 4;
            rotationPoint = CGPointMake(x, y);
            break;
        }
        case CenterPoint: {
            CGFloat x = width / 2;
            CGFloat y = height - self.bottomOffset - kScreenHeight / 2;
            rotationPoint = CGPointMake(x, y);
            break;
        }
        default:
            break;
    }
    
    CGFloat x = rotationPoint.x - width / 2;
    CGFloat y = rotationPoint.y - height / 2;
    CGPoint offset = CGPointMake(x, y);
    
    CGAffineTransform trans = CGAffineTransformMakeRotateAroundPoint(offset, angle);
    self.actionContainer.transform = CGAffineTransformConcat(trans, self.actionContainer.transform);
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
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.background.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
//        self.actionContainer.frame = CGRectMake(kContainerLeft, kScreenHeight, self.actionContainer.frame.size.width, self.actionContainer.frame.size.height);
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        [self disappearActionContainerForOrientation:orientation];
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.owner.tbActionSheet = nil;
        
        if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
            [self.delegate actionSheet:self clickedButtonAtIndex:index];
        }
        if (sender.handler) {
            __weak __typeof(TBActionButton *)weakSender = sender;
            sender.handler(weakSender);
        }
        
        if ([self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
            [self.delegate actionSheet:self willDismissWithButtonIndex:index];
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
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.background.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
//        self.actionContainer.frame = CGRectMake(kContainerLeft, kScreenHeight, self.actionContainer.frame.size.width, self.actionContainer.frame.size.height);
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        [self disappearActionContainerForOrientation:orientation];
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.owner.tbActionSheet = nil;
        
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
    UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    UIGraphicsBeginImageContext(view.bounds.size);
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        [view drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    else /* iOS 6 */
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];

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
