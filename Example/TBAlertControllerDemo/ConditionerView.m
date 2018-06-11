//
//  ConditionerView.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 16/4/3.
//  Copyright © 2016年 杨萧玉. All rights reserved.
//

#import "ConditionerView.h"
#import "TBActionSheet.h"
#import "TBActionContainer.h"

@interface ConditionerView ()
@property (weak, nonatomic) IBOutlet UISlider *buttonHeightSlider;
@property (weak, nonatomic) IBOutlet UISlider *buttonWidthSlider;
@property (weak, nonatomic) IBOutlet UISlider *offsetYSlider;
@property (weak, nonatomic) IBOutlet UISwitch *enableBackgroundTransparentSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableBlurEffectSwitch;
@property (weak, nonatomic) IBOutlet UISlider *rectCornerRadiusSlider;
@property (weak, nonatomic) IBOutlet UISlider *animationDurationSlider;
@property (weak, nonatomic) IBOutlet UISlider *animationDumpingRatioSlider;
@property (weak, nonatomic) IBOutlet UISlider *animationVelocitySlider;
@property (weak, nonatomic) IBOutlet UISlider *ambientColorSlider;
@property (weak, nonatomic) IBOutlet UISlider *customViewIndexSlider;
@property (weak, nonatomic) IBOutlet UILabel *customViewIndexLabel;

@end

@implementation ConditionerView

- (IBAction)buttonHeight:(UISlider *)sender {
    self.actionSheet.buttonHeight = sender.value;
    [TBActionSheet appearance].buttonHeight = sender.value;
}

- (IBAction)buttonWidth:(UISlider *)sender {
    self.actionSheet.sheetWidth = sender.value * [UIScreen mainScreen].bounds.size.width;
    [TBActionSheet appearance].sheetWidth = sender.value * [UIScreen mainScreen].bounds.size.width;
}


- (IBAction)offsetY:(UISlider *)sender {
    self.actionSheet.offsetY = -sender.value;
    [TBActionSheet appearance].offsetY = -sender.value;
}


- (IBAction)backgroundTransparentEnabled:(UISwitch *)sender {
    self.actionSheet.backgroundTransparentEnabled = sender.isOn;
    [TBActionSheet appearance].backgroundTransparentEnabled = sender.isOn;
    [self refreshActionSheet];
}


- (IBAction)blurEffectEnabled:(UISwitch *)sender {
    self.actionSheet.blurEffectEnabled = sender.isOn;
    [TBActionSheet appearance].blurEffectEnabled = sender.isOn;
    [self refreshActionSheet];
}


- (IBAction)cornerRadius:(UISlider *)sender {
    self.actionSheet.rectCornerRadius = sender.value;
    [TBActionSheet appearance].rectCornerRadius = sender.value;
}


- (IBAction)animationDuration:(UISlider *)sender {
    self.actionSheet.animationDuration = sender.value;
    [TBActionSheet appearance].animationDuration = sender.value;
}

- (IBAction)animationDampingRatio:(UISlider *)sender {
    self.actionSheet.animationDampingRatio = sender.value;
    [TBActionSheet appearance].animationDampingRatio = sender.value;
}

- (IBAction)animationVelocity:(UISlider *)sender {
    self.actionSheet.animationVelocity = sender.value;
    [TBActionSheet appearance].animationVelocity = sender.value;
}

- (IBAction)ambientColor:(UISlider *)sender {
    self.actionSheet.ambientColor = [UIColor colorWithHue:sender.value saturation:sender.value brightness:1 alpha:0.5];
    [TBActionSheet appearance].ambientColor = self.actionSheet.ambientColor;
}

- (IBAction)customViewIndex:(UISlider *)sender {
    self.actionSheet.customViewIndex = roundf(sender.value);
    self.customViewIndexLabel.text = [NSString stringWithFormat:@"%ld", (long)self.actionSheet.customViewIndex];
}

- (IBAction)touchUp:(id)sender {
    [self refreshActionSheet];
}

- (void)setUpUI
{
    self.buttonHeightSlider.value = self.actionSheet.buttonHeight;
    self.buttonWidthSlider.value = self.actionSheet.sheetWidth / [UIScreen mainScreen].bounds.size.width;
    self.offsetYSlider.value = -self.actionSheet.offsetY;
    self.enableBackgroundTransparentSwitch.on = self.actionSheet.isBackgroundTransparentEnabled;
    self.enableBlurEffectSwitch.on = self.actionSheet.isBlurEffectEnabled;
    self.rectCornerRadiusSlider.value = self.actionSheet.rectCornerRadius;
    self.animationDurationSlider.value = self.actionSheet.animationDuration;
    self.animationDumpingRatioSlider.value = self.actionSheet.animationDampingRatio;
    self.animationVelocitySlider.value = self.actionSheet.animationVelocity;
    CGFloat hue;
    [self.actionSheet.ambientColor getHue:&hue saturation:nil brightness:nil alpha:nil];
    self.ambientColorSlider.value = hue;
}

- (void)refreshActionSheet
{
    [self.actionSheet setupLayout];
    [self.actionSheet setupStyle];
    [self.actionSheet setupContainerFrame];
    self.frame = CGRectMake(0, 0, self.actionSheet.sheetWidth, self.bounds.size.height);
}
@end
