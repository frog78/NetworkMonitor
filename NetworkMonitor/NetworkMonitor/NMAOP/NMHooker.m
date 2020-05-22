//
//  NMHooker.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NMHooker.h"
#import <objc/runtime.h>

@implementation NMHooker

+ (void)hookInstance:(NSString *)oriClass sel:(NSString *)oriSel withClass:(NSString *)newClass andSel:(NSString *)newSel {
    Class hookedClass = objc_getClass([oriClass UTF8String]);
    Class swizzledClass = objc_getClass([newClass UTF8String]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL oriSelector = NSSelectorFromString(oriSel);
    SEL swizzledSelector = NSSelectorFromString(newSel);
#pragma clang diagnostic pop
    Method originalMethod = class_getInstanceMethod(hookedClass, oriSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}


+ (void)hookClass:(NSString *)oriClass sel:(NSString *)oriSel withClass:(NSString *)newClass andSel:(NSString *)newSel {
    Class hookedClass = objc_getClass([oriClass UTF8String]);
    Class swizzledClass = objc_getClass([newClass UTF8String]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL oriSelector = NSSelectorFromString(oriSel);
    SEL swizzledSelector = NSSelectorFromString(newSel);
#pragma clang diagnostic pop
    Method originalMethod = class_getClassMethod(hookedClass, oriSelector);
    Method swizzledMethod = class_getClassMethod(swizzledClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}


@end
