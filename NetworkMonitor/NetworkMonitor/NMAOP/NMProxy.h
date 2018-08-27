//
//  NMProxy.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NMObjectDelegate;

/**
 代理方法监控类，注册对象的代理后，代理方法的调用会
 流经该类的几个特定方法。
 */
@interface NMProxy : NSProxy

/**
 注册对象代理

 @param obj 需要注册的代理
 @param delegate 代理方法
 @return 返回包裹了代理监控的代理对象
 */
+ (id)proxyForObject:(id)obj delegate:(NMObjectDelegate *)delegate;


@end
