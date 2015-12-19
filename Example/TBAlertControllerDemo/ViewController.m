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

@interface ViewController () <TBActionSheetDelegate>
@property (nonnull,nonatomic) NSObject *leakTest;
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
    TBActionSheet *actionSheet = [[TBActionSheet alloc] initWithTitle:@"八爪鱼" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"销毁" otherButtonTitles:@"点我", nil];
    actionSheet.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"github"]];
    [actionSheet showInView:self.view];
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


#pragma mark - TBActionSheetDelegate

- (void)actionSheet:(TBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld",(long)buttonIndex);
}

@end
