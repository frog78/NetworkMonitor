//
//  NMHooker.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 通过Runtime交换类、实例方法
 */
@interface NMHooker : NSObject

/**
 hook实例方法

 @param oriClass 原实例类名
 @param oriSel 原实例方法名
 @param newClass 新的实例类名
 @param newSel 新的实例方法名
 */
+ (void)hookInstance:(NSString *)oriClass sel:(NSString *)oriSel withClass:(NSString *)newClass andSel:(NSString *)newSel;

/**
 hook类方法
 
 @param oriClass 原类名
 @param oriSel 原类方法名
 @param newClass 新的类名
 @param newSel 新的类方法名
 */
+ (void)hookClass:(NSString *)oriClass sel:(NSString *)oriSel withClass:(NSString *)newClass andSel:(NSString *)newSel;


@end
