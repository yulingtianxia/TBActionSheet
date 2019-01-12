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
    self.conditioner.frame = CGRectMake(0, 0, [TBActionSheet appearance].sheetWidth, 425);
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
    
    // Custom Animation Demo
    TBActionButton *destructiveBtn = [self.actionSheet buttonAtIndex:self.actionSheet.destructiveButtonIndex];
    destructiveBtn.animation = ^(UIImageView * _Nonnull background, UIView * _Nonnull container, void (^ _Nonnull completion)(void)) {
        [UIView animateWithDuration:0.5 animations:^{
            background.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            container.frame = CGRectMake(CGRectGetMidX(container.frame), CGRectGetMidY(container.frame), 0, 0);
        } completion:^(BOOL finished) {
            completion();
        }];
    };
    
    // Support Block and Attributed Title
    __weak __typeof(ViewController *) weakSelf = self;
    [self.actionSheet addButtonWithTitle:@"支持 block" style:TBActionButtonStyleCancel handler:^(TBActionButton * _Nonnull button) {
        NSLog(@"%@ %@",button.currentTitle,weakSelf.leakTest);
    }];
    TBActionButton *blockBtn = [self.actionSheet buttonAtIndex:self.actionSheet.numberOfButtons - 1];
    blockBtn.normalColor = [UIColor yellowColor];
    blockBtn.highlightedColor = [UIColor greenColor];
    
    //创建NSMutableAttributedString
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"支持 block\n限时推广"];
    
    //设置字体和设置字体的范围
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0f] range:NSMakeRange(9, 4)];
    //添加文字颜色
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 9)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(9, 4)];

    [blockBtn setAttributedTitle:attrStr forState:UIControlStateNormal];
    blockBtn.height = 70;
    [self.actionSheet show];
    [self.conditioner setUpUI];
}

- (void)addButton:(UIButton *)sender{
    static int hint = 1;
    [self.actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%d",hint]];
    [self.actionSheet setupLayout];
    [self.actionSheet updateContainerFrame];
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
