//
//  TBActionSheet+Orientation.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/1/31.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "TBActionSheet+Orientation.h"
#import "TBMacro.h"
#import "TBActionContainer.h"

@implementation TBActionSheet (Orientation)
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
@end
