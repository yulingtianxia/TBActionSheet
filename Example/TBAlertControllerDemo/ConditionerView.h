//
//  ConditionerView.h
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/4/3.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TBActionSheet;
@interface ConditionerView : UIView
@property (weak,nonatomic) TBActionSheet *actionSheet;
- (void)setUpUI;
@end
