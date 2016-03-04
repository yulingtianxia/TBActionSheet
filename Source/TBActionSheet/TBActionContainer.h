//
//  TBActionContainer.h
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/1/31.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  容器类，用于包含所有按钮，可定制 header，custom 和 footer 三个 view
 */
@interface TBActionContainer : UIImageView
@property (nonnull,nonatomic,strong) UIImageView *header;
@property (nonnull,nonatomic,strong) UIImageView *custom;
@property (nonnull,nonatomic,strong) UIImageView *footer;

- (nonnull instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end
