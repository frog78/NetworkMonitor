//
//  NSURL+NM.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/5/14.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NSURL+NM.h"
#import <objc/runtime.h>


static char *NSURLNMKey = "NSURLNMKey";

@implementation NSURL (NM)

- (void)setExtendedParameter:(NSDictionary *)extendedParameter {
    objc_setAssociatedObject(self, NSURLNMKey, extendedParameter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)extendedParameter {
    return objc_getAssociatedObject(self, NSURLNMKey);
}


@end
