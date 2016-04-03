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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _leakTest = [NSObject new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickActionSheet:(UIButton *)sender {
    TBActionSheet *actionSheet = [[TBActionSheet alloc] initWithTitle:@"百变ActionSheet" message:@"巴拉巴拉小魔仙，变！" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"销毁" otherButtonTitles:nil];
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"ConditionerView" owner:nil options:nil];
    self.conditioner = views[0];
    self.conditioner.frame = CGRectMake(0, 0, [TBActionSheet appearance].sheetWidth, 280);
    self.conditioner.actionSheet = actionSheet;
    actionSheet.customView = self.conditioner;
    
    [actionSheet addButtonWithTitle:@"支持 block" style:TBActionButtonStyleDefault handler:^(TBActionButton * _Nonnull button) {
        NSLog(@"%@ %@",button.currentTitle,self.leakTest);
    }];
    [actionSheet showInView:self.view];
    [self.conditioner setUpUI];
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
