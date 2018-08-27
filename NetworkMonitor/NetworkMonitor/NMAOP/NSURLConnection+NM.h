//
//  NSURLConnection+NM.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/28.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 NSURLConnection扩展，用于NSURLConnection相关方法的监控
 */
@interface NSURLConnection (NM)

/**
 hook NSURLConnection 相关方法
 */
+ (void)hook;

/**
 取消hook NSURLConnection 相关方法
 */
//+ (void)unhook;


@end
