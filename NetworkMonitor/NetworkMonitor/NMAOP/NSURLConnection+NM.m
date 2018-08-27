//
//  NSURLConnection+NM.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/28.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NSURLConnection+NM.h"
#import "NMProxy.h"
#import <objc/runtime.h>
#import "NMObjectDelegate.h"
#import "NMCache.h"
#import "NSURL+NM.h"
#import "NSHTTPURLResponse+NM.h"
#import "NSURLRequest+NM.h"

typedef void (^CompletionHandler)(NSURLResponse* _Nullable response, NSData* _Nullable data, NSError* _Nullable connectionError);

@implementation NSURLConnection (NM)

#pragma mark method-hook
+ (void)hook {
    //同步请求
    [NMHooker hookClass:@"NSURLConnection" sel:@"sendSynchronousRequest:returningResponse:error:" withClass:@"NSURLConnection" andSel:@"hook_sendSynchronousRequest:returningResponse:error:"];
    //异步请求
    [NMHooker hookClass:@"NSURLConnection" sel:@"sendAsynchronousRequest:queue:completionHandler:" withClass:@"NSURLConnection" andSel:@"hook_sendAsynchronousRequest:queue:completionHandler:"];
    //初始化方法
    [NMHooker hookInstance:@"NSURLConnection" sel:@"initWithRequest:delegate:startImmediately:" withClass:@"NSURLConnection" andSel:@"hook_initWithRequest:delegate:startImmediately:"];
    [NMHooker hookInstance:@"NSURLConnection" sel:@"initWithRequest:delegate:" withClass:@"NSURLConnection" andSel:@"hook_initWithRequest:delegate:"];
//    [NMHooker hookClass:@"NSURLConnection" sel:@"connectionWithRequest:delegate:" withClass:@"NSURLConnection" andSel:@"hook_connectionWithRequest:delegate:"];
    //代理模式开始与取消
    [NMHooker hookInstance:@"NSURLConnection" sel:@"start" withClass:@"NSURLConnection" andSel:@"hook_start"];
    [NMHooker hookInstance:@"NSURLConnection" sel:@"cancel" withClass:@"NSURLConnection" andSel:@"hook_cancel"];
}

/*
+ (void)unhook {
    [NMHooker hookClass:@"NSURLConnection" sel:@"hook_sendSynchronousRequest:returningResponse:error:" withClass:@"NSURLConnection" andSel:@"sendSynchronousRequest:returningResponse:error:"];
    [NMHooker hookClass:@"NSURLConnection" sel:@"hook_sendAsynchronousRequest:queue:completionHandler:" withClass:@"NSURLConnection" andSel:@"sendAsynchronousRequest:queue:completionHandler:"];
    [NMHooker hookInstance:@"NSURLConnection" sel:@"hook_initWithRequest:delegate:startImmediately:" withClass:@"NSURLConnection" andSel:@"initWithRequest:delegate:startImmediately:"];
    [NMHooker hookInstance:@"NSURLConnection" sel:@"hook_initWithRequest:delegate:" withClass:@"NSURLConnection" andSel:@"initWithRequest:delegate:"];
    //    [NMHooker hookClass:@"NSURLConnection" sel:@"connectionWithRequest:delegate:" withClass:@"NSURLConnection" andSel:@"hook_connectionWithRequest:delegate:"];
    [NMHooker hookInstance:@"NSURLConnection" sel:@"hook_start" withClass:@"NSURLConnection" andSel:@"start"];
    [NMHooker hookInstance:@"NSURLConnection" sel:@"hook_cancel" withClass:@"NSURLConnection" andSel:@"cancel"];
}
*/

#pragma mark hooked method
//异步请求方法
+ (void)hook_sendAsynchronousRequest:(NSURLRequest*)request queue:(NSOperationQueue*)queue completionHandler:(void (^)(NSURLResponse* _Nullable response, NSData* _Nullable data, NSError* _Nullable connectionError)) handler {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        //设置traceId，如果成功生成traceId，说明不在白名单中；
        //如果生成traceId为空，则说明在白名单中
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (!traceId) {
            EELog(@"-------->over<--------");
            [[self class] hook_sendAsynchronousRequest:request queue:queue completionHandler:handler];
            return;
        }
        NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
        [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
        //请求相关监控
        [[self class] survayRequest:rq traceId:traceId];
        CompletionHandler hook_handler = ^(NSURLResponse* _Nullable response, NSData* _Nullable data, NSError* _Nullable connectionError) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            //响应相关监控
            [[self class] survayResponse:httpResponse traceId:traceId requestUrl:request.URL.absoluteString data:data error:connectionError];
            httpResponse.traceId = traceId;
            if (handler) {
                EELog(@"-------->over<--------");
                handler(httpResponse, data, connectionError);
            }
            //如果是上传，需要统计已上传数据
            if (connectionError) {
                [[self class] survayUpload:traceId];
            }
            if (![NMUtil isInterferenceMode]) {
                [[NMCache sharedNMCache] persistData:traceId];
            }
        };
        EELog(@"-------->over<--------");
        [[self class] hook_sendAsynchronousRequest:rq queue:queue completionHandler:hook_handler];
        return;
    }
    EELog(@"-------->over<--------");
    [[self class] hook_sendAsynchronousRequest:request queue:queue completionHandler:handler];
}

//同步请求方法
+ (nullable NSData *)hook_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse * _Nullable * _Nullable)response error:(NSError **)error {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        //设置traceId，如果成功生成traceId，说明不在白名单中；
        //如果生成traceId为空，则说明在白名单中
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (!traceId) {
            EELog(@"-------->over<--------");
            return [[self class] hook_sendSynchronousRequest:request returningResponse:response error:error];
        }
        NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
        [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
        //请求相关监控
        [[self class] survayRequest:rq traceId:traceId];
        //发起请求
        NSData *data = [[self class] hook_sendSynchronousRequest:rq returningResponse:response error:error];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)(*response);
        //响应相关监控
        [[self class] survayResponse:httpResponse traceId:traceId requestUrl:request.URL.absoluteString data:data error:*error];
        httpResponse.traceId = traceId;
        *response = httpResponse;
        
        //如果是上传，需要统计已上传数据
        if (error) {
            [[self class] survayUpload:traceId];
        }
        if (![NMUtil isInterferenceMode]) {
            [[NMCache sharedNMCache] persistData:traceId];
        }
        EELog(@"-------->over<--------");
        return data;
    }
    EELog(@"-------->over<--------");
    return [[self class] hook_sendSynchronousRequest:request returningResponse:response error:error];
}

//初始化方法一
- (nullable instancetype)hook_initWithRequest:(NSURLRequest *)request delegate:(nullable id)delegate startImmediately:(BOOL)startImmediately {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        //设置traceId，如果成功生成traceId，说明不在白名单中；
        //如果生成traceId为空，则说明在白名单中
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (traceId) {
            NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
            [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
            EELog(@"-------->over<--------");
            return [self hook_initWithRequest:rq delegate:[self processDelegate:delegate] startImmediately:startImmediately];
        }
    }
    EELog(@"-------->over<--------");
    return [self hook_initWithRequest:request delegate:delegate startImmediately:startImmediately];
}

//初始化方法二
- (nullable instancetype)hook_initWithRequest:(NSURLRequest *)request delegate:(nullable id)delegate {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        //设置traceId，如果成功生成traceId，说明不在白名单中；
        //如果生成traceId为空，则说明在白名单中
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (traceId) {
            NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
            [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
            EELog(@"-------->over<--------");
            return [self hook_initWithRequest:rq delegate:[self processDelegate:delegate]];
        }
    }
    EELog(@"-------->over<--------");
    return [self hook_initWithRequest:request delegate:delegate];
}

//初始化方法三
//+ (nullable NSURLConnection*)hook_connectionWithRequest:(NSURLRequest *)request delegate:(nullable id)delegate {
//    NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
//    [rq setValue:[NMUtil getTraceId] forHTTPHeaderField:HEAD_KEY_EETRACEID];
//    return [[self class] hook_connectionWithRequest:rq delegate:delegate];
//}

//请求开始
- (void)hook_start {
    [self hook_start];
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        NSString *traceId = self.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
        if (traceId) {
            [[self class] survayRequest:self.originalRequest traceId:traceId];
        }
    }
    EELog(@"-------->over<--------");
}

//请求取消
- (void)hook_cancel {
    [self hook_cancel];
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        NSString *traceId = self.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
        if (traceId) {
            //结束时间
            [[NMCache sharedNMCache] cacheValue:[NMUtil getCurrentTime] key:NMDATA_KEY_ENDRESPONSE traceId:traceId];
            [[NMCache sharedNMCache] cacheValue:@"cancel" key:NMDATA_KEY_STATE traceId:traceId];
            [[self class] survayDownload:traceId];
            [[self class] survayUpload:traceId];
            if (![NMUtil isInterferenceMode]) {
                [[NMCache sharedNMCache] persistData:traceId];
            }
        }
    }
    EELog(@"-------->over<--------");
}

#pragma mark util
//请求相关监控
+ (void)survayResponse:(NSHTTPURLResponse *)httpResponse traceId:(NSString *)traceId requestUrl:(NSString *)requestUrl data:(NSData *)data error:(NSError *)error {
    EELog(@"-------->start<--------");
    //结束时间
    [[NMCache sharedNMCache] cacheValue:[NMUtil getCurrentTime] key:NMDATA_KEY_ENDRESPONSE traceId:traceId];
    NSUInteger statusLineSize = httpResponse.statusLineSize;
    NSUInteger headerSize = httpResponse.headerSize;
    if ([[httpResponse.allHeaderFields objectForKey:@"Content-Encoding"] isEqualToString:@"gzip"]) {
        // 模拟压缩
        data = [data gzippedData];
    }
    
    NSUInteger bodySize = data.length;
    //响应相关监控
    NSInteger statusCode = httpResponse.statusCode;
    if (error) {
        [[NMCache sharedNMCache] cacheValue:@"failure" key:NMDATA_KEY_STATE traceId:traceId];
        [[NMCache sharedNMCache] cacheValue:@"1" key:NMDATA_KEY_ERRORTYPE traceId:traceId];
        [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%d", (int)error.code] key:NMDATA_KEY_ERRORCODE traceId:traceId];
        [[NMCache sharedNMCache] cacheValue:error.description key:NMDATA_KEY_ERRORDETAIL traceId:traceId];
//        [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (unsigned long)error.description.length + data.length] key:NMDATA_KEY_RESPONSESIZE traceId:traceId];
    } else {
        switch (statusCode) {
            case 200:
            case 304:
                [[NMCache sharedNMCache] cacheValue:@"success" key:NMDATA_KEY_STATE traceId:traceId];
                break;
            default:
                [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%d", (int)statusCode] key:NMDATA_KEY_ERRORCODE traceId:traceId];
                [[NMCache sharedNMCache] cacheValue:@"2" key:NMDATA_KEY_ERRORTYPE traceId:traceId];
                [[NMCache sharedNMCache] cacheValue:@"failure" key:NMDATA_KEY_STATE traceId:traceId];
                break;
        }
//        [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (unsigned long)httpResponse.description.length + data.length] key:NMDATA_KEY_RESPONSESIZE traceId:traceId];
    }
    [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (unsigned long)statusLineSize + headerSize +bodySize] key:NMDATA_KEY_RESPONSESIZE traceId:traceId];
//    [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (long)statusCode] key:NMDATA_KEY_STATUSCODE traceId:traceId];
    if (httpResponse.MIMEType) {
        [[NMCache sharedNMCache] cacheValue:httpResponse.MIMEType key:NMDATA_KEY_CONTENTTYPE traceId:traceId];
    } else {
        NSString *type = requestUrl.lastPathComponent.pathExtension;
        [[NMCache sharedNMCache] cacheValue:[NMUtil mimeType:type] key:NMDATA_KEY_CONTENTTYPE traceId:traceId];
    }
    //重定向url
    if (![httpResponse.URL.absoluteString isEqualToString:requestUrl]) {
        [[NMCache sharedNMCache] cacheValue:httpResponse.URL.absoluteString key:NMDATA_KEY_REDIRECTURL traceId:traceId];
        if ([NMUtil isDomain:httpResponse.URL.host]) {
            [[NMCache sharedNMCache] cacheValue:[NMUtil getIPByDomain:httpResponse.URL.host] key:NMDATA_KEY_REDIRECTIP traceId:traceId];
        } else {
            [[NMCache sharedNMCache] cacheValue:httpResponse.URL.host key:NMDATA_KEY_REDIRECTIP traceId:traceId];
        }
    }
    EELog(@"-------->over<--------");
}

+ (void)survayRequest:(NSURLRequest *)req traceId:(NSString *)trId {
    EELog(@"-------->start<--------");
    //开始时间
    [[NMCache sharedNMCache] cacheValue:[NMUtil getCurrentTime] key:NMDATA_KEY_STARTREQUEST traceId:trId];
    NSString *host = req.URL.host;
    [[NMCache sharedNMCache] cacheValue:req.URL.absoluteString key:NMDATA_KEY_ORIGINALURL traceId:trId];
    if ([NMUtil isDomain:host]) {
        [[NMCache sharedNMCache] cacheValue:[NMUtil getIPByDomain:host] key:NMDATA_KEY_ORIGINALIP traceId:trId];
    } else {
        [[NMCache sharedNMCache] cacheValue:host key:NMDATA_KEY_ORIGINALIP traceId:trId];
    }
//    NSUInteger lenght = req.HTTPBody.length + req.URL.absoluteString.length + req.allHTTPHeaderFields.description.length;
    
    NSUInteger statusLineSize = req.statusLineSize;
    NSUInteger headerSize = req.headerSize;
    NSUInteger bodySize = req.bodySize;
    NSUInteger length = statusLineSize + headerSize;
    [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (unsigned long)length] key:NMDATA_KEY_REQUESTSIZE_HEAD traceId:trId];
    [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (unsigned long)bodySize] key:NMDATA_KEY_REQUESTSIZE_BODY traceId:trId];
    EELog(@"-------->over<--------");
}

+ (NSString *)isInWhiteLists:(NSURLRequest *)request {
    EELog(@"-------->start<--------");
    for (NSString *urlStr in [NMManager sharedNMManager].getConfig.urlWhiteList) {
        if ([request.URL.absoluteString containsString:urlStr]) {
            EELog(@"-------->over<--------");
            return nil;
        }
    }
    NSDictionary *extension = request.URL.extendedParameter;
    if ([[NMManager sharedNMManager].getConfig.cmdWhiteList containsObject:extension[NMDATA_KEY_CMD]]) {
        EELog(@"-------->over<--------");
        return nil;
    }
    NSDictionary *extensionInHeader = [NMUtil extractParamsFromHeader:request.allHTTPHeaderFields];
    if ([[NMManager sharedNMManager].getConfig.cmdWhiteList containsObject:extensionInHeader[NMDATA_KEY_CMD]]) {
        EELog(@"-------->over<--------");
        return nil;
    }
    NSString *trId = [NMUtil getTraceId];
    if (extension) {
        [[NMCache sharedNMCache] cacheExtension:extension traceId:trId];
    }
    
    if (extensionInHeader && extensionInHeader.count > 0) {
        [[NMCache sharedNMCache] cacheExtension:extensionInHeader traceId:trId];
    }
    EELog(@"-------->over<--------");
    return trId;
}

+ (void)survayUpload:(NSString *)trId {
    EELog(@"-------->start<--------");
    if (!trId) {
        EELog(@"-------->over<--------");
        return;
    }
    NSNumber *uploadSize = [[NMCache sharedNMCache] getNumByTraceId:trId type:CacheDataTypeUpload];
    if (uploadSize != nil) {
        [[NMCache sharedNMCache] cacheValue:[uploadSize stringValue] key:NMDATA_KEY_REQUESTSIZE_BODY traceId:trId];
        [[NMCache sharedNMCache] removeNumByTraceId:trId type:CacheDataTypeUpload];
    }
    EELog(@"-------->over<--------");
}

+ (void)survayDownload:(NSString *)trId {
    EELog(@"-------->start<--------");
    if (!trId) {
        EELog(@"-------->over<--------");
        return;
    }
    NSNumber *downloadSize = [[NMCache sharedNMCache] getNumByTraceId:trId type:CacheDataTypeDownload];
    if (downloadSize != nil) {
        [[NMCache sharedNMCache] cacheValue:[downloadSize stringValue] key:NMDATA_KEY_RESPONSESIZE traceId:trId];
        [[NMCache sharedNMCache] removeNumByTraceId:trId type:CacheDataTypeDownload];
    }
    EELog(@"-------->over<--------");
}

- (id)processDelegate:(id)delegate {
    NMObjectDelegate *objectDelegate = [NMObjectDelegate new];
    if (delegate) {
        //以下为请求代理方法
        [self registerDelegateMethod:@"connection:didFailWithError:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@"];
        [self registerDelegateMethod:@"connection:didReceiveResponse:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@"];
        [self registerDelegateMethod:@"connection:didReceiveData:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@"];
        [self registerDelegateMethod:@"connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@@@"];
        [self registerDelegateMethod:@"connectionDidFinishLoading:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@"];
        [self registerDelegateMethod:@"connection:willSendRequest:redirectResponse:" oriDelegate:delegate assistDelegate:objectDelegate flag:"@@:@@"];
        
        //以下为下载代理方法
        [self registerDownloadDelegateMethod:@"connection:didWriteData:totalBytesWritten:expectedTotalBytes:" oriDelegate:delegate assistDelegate:objectDelegate ];
        [self registerDownloadDelegateMethod:@"connectionDidResumeDownloading:totalBytesWritten:expectedTotalBytes:" oriDelegate:delegate assistDelegate:objectDelegate];
        [self registerDownloadDelegateMethod:@"connectionDidFinishDownloading:destinationURL:" oriDelegate:delegate assistDelegate:objectDelegate];
        
        delegate = [NMProxy proxyForObject:delegate delegate:objectDelegate];
    } else {
        delegate = objectDelegate;
    }
    return delegate;
}


//对代理方法分类处理
- (void)registerDelegateMethod:(NSString *)method oriDelegate:(id)oriDel assistDelegate:(NMObjectDelegate *)assiDel flag:(const char *)flag {
    if ([oriDel respondsToSelector:NSSelectorFromString(method)]) {
        IMP imp1 = class_getMethodImplementation([NMObjectDelegate class], NSSelectorFromString(method));
        IMP imp2 = class_getMethodImplementation([oriDel class], NSSelectorFromString(method));
        if (imp1 != imp2) {
            [assiDel registerSelector:method];
        }
    } else {
        class_addMethod([oriDel class], NSSelectorFromString(method), class_getMethodImplementation([NMObjectDelegate class], NSSelectorFromString(method)), flag);
    }
}

//对下载代理方法处理
//下载代理方法比较特殊，如果应用不实现下载代理方法，
//则不走下载代理方法，而会走普通请求代理方法
- (void)registerDownloadDelegateMethod:(NSString *)method oriDelegate:(id)oriDel assistDelegate:(NMObjectDelegate *)assiDel {
    if ([oriDel respondsToSelector:NSSelectorFromString(method)]) {
        [assiDel registerSelector:method];
    }
}



@end
