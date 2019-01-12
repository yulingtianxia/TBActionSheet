//
//  TBMacro.h
//  TBAlertControllerDemo
//
//  Created by skyline on 15/12/19.
//  Copyright © 2015年 杨萧玉. All rights reserved.
//


/* 宏字符串操作，避免在宏里面嵌套使用宏带来的问题 */
#define TB_stringify(STR) # STR
#define TB_string_concat(A, B) A ## B

/*
 * 用于防止在 Blocks 里面循环引用变量，并且无需改变变量名的写法。`TB_weakify` 和 `TB_strongify` 要搭配使用，`TB_weakify`
 * 用于将变量弱化，`TB_strongify` 用于在 Blocks 开始执行后将变量进行强引用，防止执行过程中变量被释放（多线程的情况下）。
 */
#define TBWeakSelf(VAR) \
__weak __typeof__(VAR) TB_string_concat(VAR, _weak_) = (VAR)

#define TBStrongSelf(VAR) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong __typeof__(VAR) VAR = TB_string_concat(VAR, _weak_) \
_Pragma("clang diagnostic pop")

#pragma mark - const values

#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kContainerLeft ((kScreenWidth - self.sheetWidth)/2)

#define kiOS8Later SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")
#define kiOS9Later SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")
#define kiOS10Later SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")
#define kiOS11Later SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
