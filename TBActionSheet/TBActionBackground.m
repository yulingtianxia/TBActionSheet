//
//  TBActionBackground.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/1/31.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "TBActionBackground.h"

@implementation TBActionBackground

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.superview respondsToSelector:@selector(close)]) {
        [self.superview performSelector:@selector(close)];
    }
}

@end
