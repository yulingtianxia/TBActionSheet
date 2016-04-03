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

- (IBAction)touchUp:(id)sender {
    [self refreshActionSheet];
}

- (void)setUpUI
{
    self.buttonHeightSlider.value = self.actionSheet.buttonHeight;
    self.buttonWidthSlider.value = self.actionSheet.sheetWidth / [UIScreen mainScreen].bounds.size.width;
    self.offsetYSlider.value = self.actionSheet.offsetY;
    self.enableBackgroundTransparentSwitch.on = self.actionSheet.isBackgroundTransparentEnabled;
    self.enableBlurEffectSwitch.on = self.actionSheet.isBlurEffectEnabled;
    self.rectCornerRadiusSlider.value = self.actionSheet.rectCornerRadius;
    self.animationDurationSlider.value = self.actionSheet.animationDuration;
}

- (void)refreshActionSheet
{
    self.bounds = CGRectMake(0, 0, self.actionSheet.sheetWidth, self.bounds.size.height);
    [[self.actionSheet valueForKeyPath:@"actionContainer"] removeFromSuperview];
    TBActionContainer *container = [[TBActionContainer alloc] initWithSheet:self.actionSheet];
    [self.actionSheet setValue:container forKeyPath:@"actionContainer"];
    [self.actionSheet addSubview:container];
    [self.actionSheet setUpLayout];
    [self.actionSheet setUpContainerFrame];
    [self.actionSheet setUpStyle];
}
@end
