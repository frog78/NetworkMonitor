//
//  NSURLRequest+NM.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/6/6.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NSURLRequest+NM.h"

@implementation NSURLRequest (EE)

- (NSUInteger)statusLineSize {
    NSString *lineStr = [NSString stringWithFormat:@"%@ %@ %@\n", self.HTTPMethod, self.URL.path, @"HTTP/1.1"];
    NSData *lineData = [lineStr dataUsingEncoding:NSUTF8StringEncoding];
    return lineData.length;
}

- (NSUInteger)headerSize {
    NSUInteger headersLength = 0;
    
    NSDictionary<NSString *, NSString *> *headerFields = self.allHTTPHeaderFields;
    NSDictionary<NSString *, NSString *> *cookiesHeader = [self dgm_getCookies];
    
    // 添加 cookie 信息
    if (cookiesHeader.count) {
        NSMutableDictionary *headerFieldsWithCookies = [NSMutableDictionary dictionaryWithDictionary:headerFields];
        [headerFieldsWithCookies addEntriesFromDictionary:cookiesHeader];
        headerFields = [headerFieldsWithCookies copy];
    }
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
    //一般header中字段会比统计到的多，+180作为数据补充
    return headersLength + 180;
}

- (NSDictionary<NSString *, NSString *> *)dgm_getCookies {
    NSDictionary<NSString *, NSString *> *cookiesHeader;
    if (!self.URL) {
        return nil;
    }
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookiesForURL:self.URL];
    if (cookies.count) {
        cookiesHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    }
    return cookiesHeader;
}

- (NSUInteger)bodySize {
    NSDictionary<NSString *, NSString *> *headerFields = self.allHTTPHeaderFields;
    NSUInteger bodyLength = [self.HTTPBody length];
    
    if ([headerFields objectForKey:@"Content-Encoding"]) {
        NSData *bodyData;
        if (self.HTTPBody == nil) {
            uint8_t d[1024] = {0};
            NSInputStream *stream = self.HTTPBodyStream;
            NSMutableData *data = [[NSMutableData alloc] init];
            [stream open];
            while ([stream hasBytesAvailable]) {
                NSInteger len = [stream read:d maxLength:1024];
                if (len > 0 && stream.streamError == nil) {
                    [data appendBytes:(void *)d length:len];
                }
            }
            bodyData = [data copy];
            [stream close];
        } else {
            bodyData = self.HTTPBody;
        }
        bodyLength = [[bodyData gzippedData] length];
    }
    return bodyLength;
}


@end
