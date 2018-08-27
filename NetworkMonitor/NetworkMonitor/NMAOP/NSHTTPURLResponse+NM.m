//
//  NSHTTPURLResponse+NM.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/5/15.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NSHTTPURLResponse+NM.h"
#import "NMHooker.h"
#import <objc/runtime.h>
#import <dlfcn.h>

typedef CFHTTPMessageRef (*NMResponseGetHTTPResponse)(CFURLRef response);

static char *NSHTTPURLResponseEEKey = "NSHTTPURLResponseEEKey";

@implementation NSHTTPURLResponse (EE)

+ (void)load {
    [NMHooker hookInstance:@"NSHTTPURLResponse" sel:@"allHeaderFields" withClass:@"NSHTTPURLResponse" andSel:@"hook_allHeaderFields"];
}

- (NSDictionary *)hook_allHeaderFields {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self hook_allHeaderFields]];
    if (self.traceId) {
        [dic setObject:self.traceId forKey:HEAD_KEY_EETRACEID];
    }
    return dic;
}

- (void)setTraceId:(NSString *)traceId {
    objc_setAssociatedObject(self, NSHTTPURLResponseEEKey, traceId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)traceId {
    return objc_getAssociatedObject(self, NSHTTPURLResponseEEKey);
}

- (NSUInteger)statusLineSize {
    NSURLResponse *response = self;
    NSString *statusLine = @"";
    // 获取CFURLResponseGetHTTPResponse的函数实现
    NSString *funName = @"CFURLResponseGetHTTPResponse";
    NMResponseGetHTTPResponse originURLResponseGetHTTPResponse =
    dlsym(RTLD_DEFAULT, [funName UTF8String]);
    SEL theSelector = NSSelectorFromString(@"_CFURLResponse");
    if ([response respondsToSelector:theSelector] &&
        NULL != originURLResponseGetHTTPResponse) {
        // 获取NSURLResponse的_CFURLResponse
        CFTypeRef cfResponse = CFBridgingRetain([response performSelector:theSelector]);
        if (NULL != cfResponse) {
            // 将CFURLResponseRef转化为CFHTTPMessageRef
            CFHTTPMessageRef messageRef = originURLResponseGetHTTPResponse(cfResponse);
            statusLine = (__bridge_transfer NSString *)CFHTTPMessageCopyResponseStatusLine(messageRef);
            CFRelease(cfResponse);
        }
    }
    NSData *lineData = [statusLine dataUsingEncoding:NSUTF8StringEncoding];
    return lineData.length;
}

- (NSUInteger)headerSize {
    NSUInteger headersLength = 0;
    if ([self isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)self;
        NSDictionary<NSString *, NSString *> *headerFields = httpResponse.allHeaderFields;
        NSString *headerStr = @"";
        for (NSString *key in headerFields.allKeys) {
            headerStr = [headerStr stringByAppendingString:key];
            headerStr = [headerStr stringByAppendingString:@": "];
            if ([headerFields objectForKey:key]) {
                headerStr = [headerStr stringByAppendingString:headerFields[key]];
            }
            headerStr = [headerStr stringByAppendingString:@"\n"];
        }
        NSData *headerData = [headerStr dataUsingEncoding:NSUTF8StringEncoding];
        headersLength = headerData.length;
    }
    return headersLength;
}


@end
