//
//  ViewController.m
//  TBAlertControllerDemo
//
//  Created by 杨萧玉 on 15/12/15.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//

#import "ViewController.h"
#import "TBActionSheet.h"
#import "TBAlertController.h"
#import "ConditionerView.h"

@interface ViewController () <TBActionSheetDelegate>
@property (nonnull,nonatomic) NSObject *leakTest;
@property (nonnull,nonatomic) ConditionerView *conditioner;
@property (nonatomic) TBActionSheet *actionSheet;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _leakTest = [NSObject new];
//    [self runSpinAnimationOnView:self.imageView duration:1 rotations:1 repeat:HUGE_VALF];
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickActionSheet:(UIButton *)sender {
    self.actionSheet = [[TBActionSheet alloc] initWithTitle:@"MagicalActionSheet" message:@"巴拉巴拉小魔仙，变！" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"销毁" otherButtonTitles:nil];
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"ConditionerView" owner:nil options:nil];
    self.conditioner = views[0];
    self.conditioner.frame = CGRectMake(0, 0, [TBActionSheet appearance].sheetWidth, 400);
    self.conditioner.actionSheet = self.actionSheet;
    
//    UI Conditioner Demo
    self.actionSheet.customView = self.conditioner;

//    Github Logo Demo
//    self.actionSheet.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"github"]];
    
//    //    Add Buttons Dynamically Demo
//    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [addBtn setTitle:@"Add Button" forState:UIControlStateNormal];
//    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//    addBtn.frame = (CGRect){0,0,200,50};
//    [addBtn addTarget:self action:@selector(addButton:) forControlEvents:UIControlEventTouchUpInside];
//    self.actionSheet.customView = addBtn;
    
    __weak __typeof(ViewController *) weakSelf = self;
    [self.actionSheet addButtonWithTitle:@"支持 block" style:TBActionButtonStyleDefault handler:^(TBActionButton * _Nonnull button) {
        NSLog(@"%@ %@",button.currentTitle,weakSelf.leakTest);
    }];
    
    [self.actionSheet show];
    [self.conditioner setUpUI];
}

- (void)addButton:(UIButton *)sender{
    static int hint = 1;
    [self.actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%d",hint]];
    [self.actionSheet setupLayout];
    [self.actionSheet setupContainerFrame];
    [self.actionSheet setupStyle];
    hint++;
}

- (IBAction)clickControllerWithAlert:(UIButton *)sender {
    TBAlertController *controller = [TBAlertController alertControllerWithTitle:@"TBAlertController" message:@"AlertStyle" preferredStyle:TBAlertControllerStyleAlert];
    TBAlertAction *clickme = [TBAlertAction actionWithTitle:@"点我" style: TBAlertActionStyleDefault handler:^(TBAlertAction * _Nonnull action) {
        NSLog(@"%@ %@",action.title,self.leakTest);
    }];
    TBAlertAction *cancel = [TBAlertAction actionWithTitle:@"取消" style: TBAlertActionStyleCancel handler:^(TBAlertAction * _Nonnull action) {
        NSLog(@"%@ %@",action.title,self.leakTest);
    }];
    [controller addAction:clickme];
    [controller addAction:cancel];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)clickControllerWithActionSheet:(UIButton *)sender {
    TBAlertController *controller = [TBAlertController alertControllerWithTitle:@"TBAlertController" message:@"AlertStyle" preferredStyle:TBAlertControllerStyleActionSheet];
    TBAlertAction *clickme = [TBAlertAction actionWithTitle:@"点我" style: TBAlertActionStyleDefault handler:^(TBAlertAction * _Nonnull action) {
        NSLog(@"%@ %@",action.title,self.leakTest);
    }];
    TBAlertAction *cancel = [TBAlertAction actionWithTitle:@"取消" style: TBAlertActionStyleCancel handler:^(TBAlertAction * _Nonnull action) {
        NSLog(@"%@ %@",action.title,self.leakTest);
    }];
    [controller addAction:clickme];
    [controller addAction:cancel];
    [self presentViewController:controller animated:YES completion:nil];
}


#pragma mark - TBActionSheetDelegate

- (void)actionSheet:(TBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"click button:%ld",(long)buttonIndex);
}

- (void)actionSheet:(TBActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"willDismiss");
}

- (void)actionSheet:(TBActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"didDismiss");
}

@end
