//
//  NSURLSession+NM.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/25.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 NSURLSession扩展，用于NSURLSession相关方法的监控
 */
@interface NSURLSession (EE)

/**
 hook NSURLSession 相关方法
 */
+ (void)hook;

/**
 取消hook NSURLSession 相关方法
 */
//+ (void)unhook;


@end
