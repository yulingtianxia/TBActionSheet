//
//  TBActionContainer.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/1/31.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "TBActionContainer.h"
#import "TBMacro.h"
#import "TBActionSheet.h"
#import "TBActionButton.h"
#import "UIView+TBAdditions.h"

@interface TBActionContainer ()

@property (weak,nonatomic) TBActionSheet *actionSheet;
@property (nonatomic) NSMutableArray<UIView *> *tempViews;

@end

@implementation TBActionContainer

- (instancetype)initWithSheet:(TBActionSheet *)actionSheet
{
    self = [super init];
    if (self) {
        _header = [[UIImageView alloc] init];
        _custom = [[UIImageView alloc] init];
        _footer = [[UIImageView alloc] init];
        _header.clipsToBounds = YES;
        _custom.clipsToBounds = YES;
        _footer.clipsToBounds = YES;
        _header.userInteractionEnabled = YES;
        _custom.userInteractionEnabled = YES;
        _footer.userInteractionEnabled = YES;
        _actionSheet = actionSheet;
        self.userInteractionEnabled = YES;
        [self addSubview:_header];
        [self addSubview:_custom];
        [self addSubview:_footer];
        _tempViews = [NSMutableArray array];
    }
    return self;
}

- (BOOL)isSupportSystemBlurEffect
{
    // iOS 8 之后才支持
    if (!kiOS8Later) {
        return NO;
    }
    return YES;
}

- (BOOL)useSystemBlurEffect
{
    if ([self isSupportSystemBlurEffect]) {
        self.backgroundColor = self.actionSheet.ambientColor;
        self.layer.masksToBounds = YES;
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        blurEffectView.frame = self.bounds;
        blurEffectView.layer.masksToBounds = YES;
        [self insertSubview:blurEffectView atIndex:0];
        [self.tempViews addObject:blurEffectView];
        return YES;
    }
    return NO;
}

- (BOOL)useSystemBlurEffectUnderView:(UIView *)view
{
    return [self useSystemBlurEffectUnderView:view withColor:nil];
}

- (BOOL)useSystemBlurEffectUnderView:(UIView *)view withColor:(UIColor *)color
{
    if (!view) {
        return NO;
    }
    if ([self isSupportSystemBlurEffect]) {
        UIView *colorView = [[UIView alloc] initWithFrame:view.frame];
        colorView.backgroundColor = color ? color : self.actionSheet.ambientColor;
        colorView.layer.masksToBounds = YES;
        colorView.tbRectCorner = view.tbRectCorner;
        
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        blurEffectView.frame = view.frame;
        blurEffectView.layer.masksToBounds = YES;
        blurEffectView.tbRectCorner = view.tbRectCorner;
        
        [self insertSubview:blurEffectView atIndex:0];
        [self.tempViews addObject:blurEffectView];
        
        [blurEffectView setCornerRadius:self.actionSheet.rectCornerRadius];
        [colorView setCornerRadius:self.actionSheet.rectCornerRadius];
        
        [self insertSubview:colorView atIndex:0];
        [self.tempViews addObject:colorView];
        
        if ([view isKindOfClass:[TBActionButton class]]) {
            TBActionButton *btn = (TBActionButton *)view;
            btn.behindColorView = colorView;
        }
        return YES;
    }
    return NO;
}

- (void)cleanTempViews
{
    for (UIView *view in self.tempViews) {
        [view removeFromSuperview];
    }
    [self.tempViews removeAllObjects];
}

@end
