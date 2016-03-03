//
//  UIView+TBAdditions.h
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/2/16.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TBActionSheet;

@interface UIView (TBAdditions)

@end

@interface UIView (TBActionSheet)
@property (nonatomic,strong,nullable) TBActionSheet *tbActionSheet;
- (void)interruptGesture;
@end

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