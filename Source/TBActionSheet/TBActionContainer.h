//
//  TBActionContainer.h
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/1/31.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TBActionSheet;
NS_ASSUME_NONNULL_BEGIN
/**
 *  容器类，用于包含所有按钮，可定制 header，custom 和 footer 三个 view
 */
@interface TBActionContainer : UIImageView

@property (nonatomic,strong) UIImageView *header;
@property (nonatomic,strong) UIImageView *custom;
@property (nonatomic,strong) UIImageView *footer;

- (instancetype)initWithSheet:(TBActionSheet *)actionSheet;
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("initWithFrame: not available, please use initWithSheet:")));
- (instancetype)init __attribute__((unavailable("init not available, please use initWithSheet:")));

- (BOOL)useSystemBlurEffect;
- (BOOL)useSystemBlurEffectUnderView:(UIView *)view;
- (BOOL)useSystemBlurEffectUnderView:(UIView *)view withColor:(nullable UIColor *)color;

- (void)cleanTempViews;

@end

NS_ASSUME_NONNULL_END
