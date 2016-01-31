//
//  TBActionButton.h
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/1/31.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TBActionButtonStyle) {
    TBActionButtonStyleDefault = 0,
    TBActionButtonStyleCancel,
    TBActionButtonStyleDestructive
};

typedef NS_OPTIONS(NSUInteger, TBActionButtonCorner) {
    TBActionButtonCornerTop = 1 << 0,
    TBActionButtonCornerBottom = 1 << 1,
    TBActionButtonCornerNone = 0,
    TBActionButtonCornerAll = TBActionButtonCornerTop|TBActionButtonCornerBottom,
};

@interface TBActionButton : UIButton
@property (nonatomic) TBActionButtonCorner corner;
@property (nonatomic,nullable) UIColor *normalColor;
@property (nonatomic,nullable) UIColor *highlightedColor;
@property (nonatomic) TBActionButtonStyle style;
@property (nonatomic,nullable,strong,readonly) void (^handler)(TBActionButton * _Nonnull button);

+ (nonnull instancetype)buttonWithTitle:(nonnull NSString *)title style:(TBActionButtonStyle)style;
+ (nonnull instancetype)buttonWithTitle:(nonnull NSString *)title style:(TBActionButtonStyle)style handler:(void (^ __nullable)( TBActionButton * _Nonnull button))handler;
@end
