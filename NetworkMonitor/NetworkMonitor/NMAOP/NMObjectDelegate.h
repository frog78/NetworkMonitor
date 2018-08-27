//
//  NMObjectDelegate.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/26.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class NMObjectDelegate
 @abstract 当应用层没有设置实现NSURLSessionDelegate或者NSURLConnectionDelegate的代理时，NetworkMonitor会将本类的一个实例设置为代理，代理方法将被转发到本类的实现。
 */
@interface NMObjectDelegate : NSObject<NSURLSessionDelegate, NSURLConnectionDelegate>

/**
 代理方法调用传递

 @param invocation 方法调用对象
 */
- (void)invoke:(NSInvocation *)invocation;

/**
 注册需要调用传递的方法

 @param selector 方法名
 */
- (void)registerSelector:(NSString *)selector;

/**
 注销需要调用传递的方法

 @param selector 方法名
 */
- (void)unregisterSelector:(NSString *)selector;



@end
