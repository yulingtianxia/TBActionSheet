//
//  TBAlertController.h
//
//  Created by 杨萧玉 on 15/10/29.
//  Copyright © 2015年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TBAlertActionStyle) {
    TBAlertActionStyleDefault = 0,
    TBAlertActionStyleCancel,
    TBAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, TBAlertControllerStyle) {
    TBAlertControllerStyleActionSheet = 0,
    TBAlertControllerStyleAlert
};

@interface TBAlertAction : NSObject

@property (nullable, nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) TBAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nullable,nonatomic,strong,readonly) void (^handler)(TBAlertAction * _Nonnull);

+ (id)actionWithTitle:(nullable NSString *)title style:(TBAlertActionStyle)style handler:(void (^ __nullable)( TBAlertAction *action))handler;

@end

@interface TBAlertController : UIViewController


@property (nonatomic,nullable,copy,readonly) void (^userClickIndex)(NSInteger indexTag);


@property (nonatomic,strong,readonly) id adaptiveAlert;
@property (nullable,nonatomic,weak) UIViewController *ownerController;
@property (nullable,nonatomic,strong) UIColor *tintColor;
@property(nonatomic,assign) UIAlertViewStyle alertViewStyle;

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(TBAlertControllerStyle)preferredStyle;
- (void)addAction:(TBAlertAction *)action;

@property (nonatomic, readonly) NSArray<TBAlertAction *> *actions;
@property (nullable, nonatomic, copy, readonly) NSArray< void (^)(UITextField *_Nonnull textField)> *textFieldHandlers;

@property (nonatomic, strong, nullable) TBAlertAction *preferredAction NS_AVAILABLE_IOS(9_0);

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField * _Nonnull textField))configurationHandler;

@property (nullable, nonatomic, readonly) NSArray<UITextField *> *textFields;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;

@property (nonatomic, readonly) TBAlertControllerStyle preferredStyle;

@end

NS_ASSUME_NONNULL_END
