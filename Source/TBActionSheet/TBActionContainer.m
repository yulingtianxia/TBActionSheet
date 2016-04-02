//
//  TBActionContainer.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/1/31.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "TBActionContainer.h"
#import "TBMacro.h"

@interface TBActionContainer ()

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

- (BOOL)useSystemBlurEffect
{
    if (kiOS8Later) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        self.layer.masksToBounds = YES;
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        blurEffectView.frame = self.bounds;
        blurEffectView.layer.masksToBounds = YES;
        [self insertSubview:blurEffectView atIndex:0];
        return YES;
    }
    return NO;
}

- (BOOL)useSystemBlurEffectUnderView:(UIView *)view
{
    if (!view) {
        return NO;
    }
    if (kiOS8Later) {
        UIView *whiteView = [[UIView alloc] initWithFrame:view.frame];
        whiteView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        whiteView.layer.masksToBounds = YES;
        
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        blurEffectView.frame = view.frame;
        blurEffectView.layer.masksToBounds = YES;
        
        [self insertSubview:blurEffectView atIndex:0];
        
        if ([view.layer.mask isKindOfClass:[CAShapeLayer class]]) {
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = view.bounds;
            maskLayer.path = ((CAShapeLayer *)view.layer.mask).path;
            blurEffectView.layer.mask = maskLayer;
        }
        
        [self insertSubview:whiteView atIndex:0];
        whiteView.layer.mask = view.layer.mask;
        return YES;
    }
    return NO;
}

@end
