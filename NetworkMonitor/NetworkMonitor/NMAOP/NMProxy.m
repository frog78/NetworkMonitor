//
//  NMProxy.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NMProxy.h"
#import "NMObjectDelegate.h"

@interface NMProxy() {
    id _object; //代理对象
    NMObjectDelegate *_objectDelegate; //代理方法调用传递对象
}

@end

@implementation NMProxy

+ (id)proxyForObject:(id)obj delegate:(NMObjectDelegate *)delegate {
    NMProxy *instance = [NMProxy alloc];
    instance->_object = obj;
    instance->_objectDelegate = delegate;
    
    return instance;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [_object methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([_object respondsToSelector:invocation.selector]) {
        //代理方法执行
        [invocation invokeWithTarget:_object];
        //代理方法执行传递
        [_objectDelegate invoke:invocation];
    }
}


@end
