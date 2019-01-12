//
//  TBActionButton.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/1/31.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "TBActionButton.h"
#import "TBMacro.h"

/**
 *  可定制风格和圆角的按钮
 */
@interface TBActionButton()

@property (nonatomic, nullable, strong, readwrite) void (^handler)(TBActionButton * _Nonnull button);

@end

@implementation TBActionButton

+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style
{
    return [self buttonWithTitle:title style:style handler:nil];
}

+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style handler:(nullable TBActionButtonHandler)handler
{
    return [self buttonWithTitle:title style:style handler:handler animation:nil];
}

+ (instancetype)buttonWithTitle:(NSString *)title style:(TBActionButtonStyle)style handler:(nullable TBActionButtonHandler)handler animation:(nullable TBActionSheetAnimation)animation
{
    TBActionButton *button = [TBActionButton buttonWithType:UIButtonTypeCustom];
    button.style = style;
    button.handler = handler;
    button.animation = animation;
    button.clipsToBounds = YES;
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button.titleLabel setFont:[UIFont systemFontOfSize:20]];
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    return button;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        if (self.highlightedColor && !self.currentBackgroundImage) {
            self.backgroundColor = self.highlightedColor;
        }
        else {
            self.behindColorView.alpha = 0.5;
        }
    }
    else {
        if (self.normalColor) {
            self.backgroundColor = self.normalColor;
        }
        else {
            self.behindColorView.alpha = 1;
        }
    }
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (CGFloat)height
{
    return self.frame.size.height;
}

@end
