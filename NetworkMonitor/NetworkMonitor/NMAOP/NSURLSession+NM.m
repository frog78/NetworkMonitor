//
//  NSURLSession+NM.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/25.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NSURLSession+NM.h"
//#import "NMURLProtocol.h"
#import "NMProxy.h"
#import "NMObjectDelegate.h"
#import <objc/runtime.h>
#import "NMCache.h"
#import "NSURL+NM.h"
#import <UIKit/UIKit.h>
#import "NSHTTPURLResponse+NM.h"
#import "NSURLRequest+NM.h"

typedef void(^CompletionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void(^DownloadCompletionHandler)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void(^UploadCompletionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@implementation NSURLSession (EE)

#pragma mark method-hook
+ (void)hook {
    //初始化方法
    [NMHooker hookClass:@"NSURLSession" sel:@"sessionWithConfiguration:delegate:delegateQueue:" withClass:@"NSURLSession" andSel:@"hook_sessionWithConfiguration:delegate:delegateQueue:"];
    //内部调用便捷式调用sessionWithConfiguration:delegate:delegateQueue:，不需要hook
//    [NMHooker hookClass:@"NSURLSession" sel:@"sessionWithConfiguration:" withClass:@"NSURLSession" andSel:@"hook_sessionWithConfiguration:"];
    
    //网络请求
    //便捷式调用方法
    [NMHooker hookInstance:@"NSURLSession" sel:@"dataTaskWithRequest:completionHandler:" withClass:@"NSURLSession" andSel:@"hook_dataTaskWithRequest:completionHandler:"];
    //内部调用便捷式调用方法，不需要hook
    //iOS 13.0以上不再走便捷式方法，需要hook
    if (@available(iOS 13, *)) {
        [NMHooker hookInstance:@"NSURLSession" sel:@"dataTaskWithRequest:" withClass:@"NSURLSession" andSel:@"hook_dataTaskWithRequest:"];
        [NMHooker hookInstance:@"NSURLSession" sel:@"dataTaskWithURL:" withClass:@"NSURLSession" andSel:@"hook_dataTaskWithURL:"];
        [NMHooker hookInstance:@"NSURLSession" sel:@"dataTaskWithURL:completionHandler:" withClass:@"NSURLSession" andSel:@"hook_dataTaskWithURL:completionHandler:"];
    }
    
    //下载
    [NMHooker hookInstance:@"NSURLSession" sel:@"downloadTaskWithRequest:" withClass:@"NSURLSession" andSel:@"hook_downloadTaskWithRequest:"];
    //    [NMHooker hookInstance:@"NSURLSession" sel:@"downloadTaskWithURL:" withClass:@"NSURLSession" andSel:@"hook_downloadTaskWithURL:"];
    //    断点下载方法，暂不实现
    //    [NMHooker hookInstance:@"NSURLSession" sel:@"downloadTaskWithResumeData:" withClass:@"NSURLSession" andSel:@"hook_downloadTaskWithResumeData:"];
    [NMHooker hookInstance:@"NSURLSession" sel:@"downloadTaskWithRequest:completionHandler:" withClass:@"NSURLSession" andSel:@"hook_downloadTaskWithRequest:completionHandler:"];
    //    [NMHooker hookInstance:@"NSURLSession" sel:@"downloadTaskWithURL:completionHandler:" withClass:@"NSURLSession" andSel:@"hook_downloadTaskWithURL:completionHandler:"];
    //    [NMHooker hookInstance:@"NSURLSession" sel:@"downloadTaskWithResumeData:completionHandler:" withClass:@"NSURLSession" andSel:@"hook_downloadTaskWithResumeData:completionHandler:"];
    
    //上传
    [NMHooker hookInstance:@"NSURLSession" sel:@"uploadTaskWithRequest:fromFile:" withClass:@"NSURLSession" andSel:@"hook_uploadTaskWithRequest:fromFile:"];
    [NMHooker hookInstance:@"NSURLSession" sel:@"uploadTaskWithRequest:fromData:" withClass:@"NSURLSession" andSel:@"hook_uploadTaskWithRequest:fromData:"];
    [NMHooker hookInstance:@"NSURLSession" sel:@"uploadTaskWithStreamedRequest:" withClass:@"NSURLSession" andSel:@"hook_uploadTaskWithStreamedRequest:"];
    [NMHooker hookInstance:@"NSURLSession" sel:@"uploadTaskWithRequest:fromFile:completionHandler:" withClass:@"NSURLSession" andSel:@"hook_uploadTaskWithRequest:fromFile:completionHandler:"];
    [NMHooker hookInstance:@"NSURLSession" sel:@"uploadTaskWithRequest:fromData:completionHandler:" withClass:@"NSURLSession" andSel:@"hook_uploadTaskWithRequest:fromData:completionHandler:"];
}

/*
+ (void)unhook {
    //初始化方法
    [NMHooker hookClass:@"NSURLSession" sel:@"hook_sessionWithConfiguration:delegate:delegateQueue:" withClass:@"NSURLSession" andSel:@"sessionWithConfiguration:delegate:delegateQueue:"];
    //    [NMHooker hookClass:@"NSURLSession" sel:@"sessionWithConfiguration:" withClass:@"NSURLSession" andSel:@"hook_sessionWithConfiguration:"];
    
    //网络请求
    //    [NMHooker hookInstance:@"NSURLSession" sel:@"dataTaskWithRequest:" withClass:@"NSURLSession" andSel:@"hook_dataTaskWithRequest:"];
    //    [NMHooker hookInstance:@"NSURLSession" sel:@"dataTaskWithURL:" withClass:@"NSURLSession" andSel:@"hook_dataTaskWithURL:"];
    [NMHooker hookInstance:@"NSURLSession" sel:@"hook_dataTaskWithRequest:completionHandler:" withClass:@"NSURLSession" andSel:@"dataTaskWithRequest:completionHandler:"];
    //    [NMHooker hookInstance:@"NSURLSession" sel:@"dataTaskWithURL:completionHandler:" withClass:@"NSURLSession" andSel:@"hook_dataTaskWithURL:completionHandler:"];
    
    //下载
    [NMHooker hookInstance:@"NSURLSession" sel:@"hook_downloadTaskWithRequest:" withClass:@"NSURLSession" andSel:@"downloadTaskWithRequest:"];
    //    [NMHooker hookInstance:@"NSURLSession" sel:@"hook_downloadTaskWithURL:" withClass:@"NSURLSession" andSel:@"downloadTaskWithURL:"];
    //    [NMHooker hookInstance:@"NSURLSession" sel:@"hook_downloadTaskWithResumeData:" withClass:@"NSURLSession" andSel:@"downloadTaskWithResumeData:"];
    [NMHooker hookInstance:@"NSURLSession" sel:@"hook_downloadTaskWithRequest:completionHandler:" withClass:@"NSURLSession" andSel:@"downloadTaskWithRequest:completionHandler:"];
    //    [NMHooker hookInstance:@"NSURLSession" sel:@"hook_downloadTaskWithURL:completionHandler:" withClass:@"NSURLSession" andSel:@"downloadTaskWithURL:completionHandler:"];
    //    [NMHooker hookInstance:@"NSURLSession" sel:@"hook_downloadTaskWithResumeData:completionHandler:" withClass:@"NSURLSession" andSel:@"downloadTaskWithResumeData:completionHandler:"];
    
    //上传
    [NMHooker hookInstance:@"NSURLSession" sel:@"hook_uploadTaskWithRequest:fromFile:" withClass:@"NSURLSession" andSel:@"uploadTaskWithRequest:fromFile:"];
    [NMHooker hookInstance:@"NSURLSession" sel:@"hook_uploadTaskWithRequest:fromData:" withClass:@"NSURLSession" andSel:@"uploadTaskWithRequest:fromData:"];
//    [NMHooker hookInstance:@"NSURLSession" sel:@"hook_uploadTaskWithStreamedRequest:" withClass:@"NSURLSession" andSel:@"uploadTaskWithStreamedRequest:"];
    [NMHooker hookInstance:@"NSURLSession" sel:@"hook_uploadTaskWithRequest:fromFile:completionHandler:" withClass:@"NSURLSession" andSel:@"uploadTaskWithRequest:fromFile:completionHandler:"];
    [NMHooker hookInstance:@"NSURLSession" sel:@"hook_uploadTaskWithRequest:fromData:completionHandler:" withClass:@"NSURLSession" andSel:@"uploadTaskWithRequest:fromData:completionHandler:"];
}
*/
#pragma mark hook_method
//初始化
+ (NSURLSession *)hook_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        //注册自定义NSURLProtocol
        //    NSMutableArray *array = [[configuration protocolClasses] mutableCopy];
        //    [array insertObject:[NMURLProtocol class] atIndex:0];
        //    configuration.protocolClasses = array;
        
        NMObjectDelegate *objectDelegate = [NMObjectDelegate new];
        if (delegate) {
            [[self class] registerDelegateMethod:@"URLSession:task:didFinishCollectingMetrics:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@@"];
            [[self class] registerDelegateMethod:@"URLSession:task:didCompleteWithError:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@@"];
            [[self class] registerDelegateMethod:@"URLSession:dataTask:didReceiveData:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@@"];
            
            [[self class] registerDelegateMethod:@"URLSession:downloadTask:didFinishDownloadingToURL:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@@"];
            [[self class] registerDelegateMethod:@"URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@@@@"];
            [[self class] registerDelegateMethod:@"URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@@@@"];
            [[self class] registerDelegateMethod:@"URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@@@@"];
            //        [[self class] registerDelegateMethod:@"URLSession:dataTask:didReceiveResponse:completionHandler:" oriDelegate:delegate assistDelegate:objectDelegate flag:"v@:@@@@"];
            
            delegate = [NMProxy proxyForObject:delegate delegate:objectDelegate];
        } else {
            delegate = objectDelegate;
        }
    }
    EELog(@"-------->over<--------");
    return [self hook_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

//+ (NSURLSession *)hook_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration {
//    return [self hook_sessionWithConfiguration:configuration];
//}

//网络请求，调用dataTaskWithRequest:completionHandler:
- (NSURLSessionDataTask *)hook_dataTaskWithRequest:(NSURLRequest *)request {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        //设置traceId，如果成功生成traceId，说明不在白名单中；
        //如果生成traceId为空，则说明在白名单中
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (!traceId) {
            EELog(@"-------->over<--------");
            return [self hook_dataTaskWithRequest:request];
        }
        //请求相关监控
        NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
        [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
        [[self class] survayRequest:rq traceId:traceId];
        EELog(@"-------->over<--------");
        return [self hook_dataTaskWithRequest:rq];
    }
    EELog(@"-------->over<--------");
    return [self hook_dataTaskWithRequest:request];
}

- (NSURLSessionDataTask *)hook_dataTaskWithURL:(NSURL *)url {
    if (!url) {
        EELog(@"url为空");
        return nil;
    }
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        //设置traceId，如果成功生成traceId，说明不在白名单中；
        //如果生成traceId为空，则说明在白名单中
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (!traceId) {
            EELog(@"-------->over<--------");
            return [self hook_dataTaskWithURL:url];
        }
        //请求相关监控
        NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
        [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
        [[self class] survayRequest:rq traceId:traceId];
        EELog(@"-------->over<--------");
        return [self hook_dataTaskWithRequest:rq];
    }
    EELog(@"-------->over<--------");
    return [self hook_dataTaskWithURL:url];
}

- (NSURLSessionDataTask *)hook_dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    if (!url) {
        EELog(@"url为空");
        return nil;
    }
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        //设置traceId，如果成功生成traceId，说明不在白名单中；
        //如果生成traceId为空，则说明在白名单中
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (!traceId) {
            EELog(@"-------->over<--------");
            return [self hook_dataTaskWithURL:url completionHandler:completionHandler];
        }
        //请求相关监控
        NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
        [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
        [[self class] survayRequest:rq traceId:traceId];
        if (completionHandler) {
            CompletionHandler hook_completionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                //把traceId设置到响应头
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                httpResponse.traceId = traceId;
                EELog(@"-------->over<--------");
                completionHandler(data, httpResponse, error);
                //响应监控
                [[self class] survayResponse:httpResponse traceId:traceId  requestUrl:request.URL.absoluteString data:data loaction:nil error:error];
                if (![NMUtil isInterferenceMode]) {
                    [[NMCache sharedNMCache] persistData:traceId];
                }
            };
            EELog(@"-------->over<--------");
            return [self hook_dataTaskWithRequest:rq completionHandler:hook_completionHandler];
        }
        EELog(@"-------->over<--------");
        return [self hook_dataTaskWithRequest:rq completionHandler:completionHandler];
    }
    EELog(@"-------->over<--------");
    return [self hook_dataTaskWithURL:url completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)hook_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        //设置traceId，如果成功生成traceId，说明不在白名单中；
        //如果生成traceId为空，则说明在白名单中
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (!traceId) {
            EELog(@"-------->over<--------");
            return [self hook_dataTaskWithRequest:request completionHandler:completionHandler];
        }
        //请求相关监控
        NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
        [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
        [[self class] survayRequest:rq traceId:traceId];
        
        if (completionHandler) {
            CompletionHandler hook_completionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                //把traceId设置到响应头
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                httpResponse.traceId = traceId;
                EELog(@"-------->over<--------");
                completionHandler(data, httpResponse, error);
                //响应监控
                [[self class] survayResponse:httpResponse traceId:traceId  requestUrl:request.URL.absoluteString data:data loaction:nil error:error];
                if (![NMUtil isInterferenceMode]) {
                    [[NMCache sharedNMCache] persistData:traceId];
                }
            };
            EELog(@"-------->over<--------");
            return [self hook_dataTaskWithRequest:rq completionHandler:hook_completionHandler];
        }
        EELog(@"-------->over<--------");
        return [self hook_dataTaskWithRequest:rq completionHandler:completionHandler];
    }
    EELog(@"-------->over<--------");
    return [self hook_dataTaskWithRequest:request completionHandler:completionHandler];
}

//下载
- (NSURLSessionDownloadTask *)hook_downloadTaskWithRequest:(NSURLRequest *)request {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (traceId) {
            NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
            [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
            [[self class] survayRequest:rq traceId:traceId];
            EELog(@"-------->over<--------");
            return [self hook_downloadTaskWithRequest:rq];
        }
    }
    EELog(@"-------->over<--------");
    return [self hook_downloadTaskWithRequest:request];
}

- (NSURLSessionDownloadTask *)hook_downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (!traceId) {
            EELog(@"-------->over<--------");
            return [self hook_downloadTaskWithRequest:request completionHandler:completionHandler];
        }
        NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
        [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
        [[self class] survayRequest:rq traceId:traceId];
        if (completionHandler) {
            DownloadCompletionHandler hook_completionHandler = ^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                httpResponse.traceId = traceId;
                EELog(@"-------->over<--------");
                completionHandler(location, httpResponse, error);
                //响应监控
                [[self class] survayResponse:httpResponse traceId:traceId  requestUrl:request.URL.absoluteString data:nil loaction:[location.absoluteString lastPathComponent] error:error];

                if (![NMUtil isInterferenceMode]) {
                    [[NMCache sharedNMCache] persistData:traceId];
                }
            };
            EELog(@"-------->over<--------");
            return [self hook_downloadTaskWithRequest:rq completionHandler:hook_completionHandler];
        }
        EELog(@"-------->over<--------");
        return [self hook_downloadTaskWithRequest:rq completionHandler:completionHandler];
    }
    EELog(@"-------->over<--------");
    return [self hook_downloadTaskWithRequest:request completionHandler:completionHandler];
}

//- (NSURLSessionDownloadTask *)hook_downloadTaskWithURL:(NSURL *)url {
//    return [self hook_downloadTaskWithURL:url];
//}

//- (NSURLSessionDownloadTask *)hook_downloadTaskWithResumeData:(NSData *)resumeData {
//    return [self hook_downloadTaskWithResumeData:resumeData];
//}

//- (NSURLSessionDownloadTask *)hook_downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
//    return [self hook_downloadTaskWithURL:url completionHandler:completionHandler];
//}

//- (NSURLSessionDownloadTask *)hook_downloadTaskWithResumeData:(NSData *)resumeData completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
//    return [self hook_downloadTaskWithResumeData:resumeData completionHandler:completionHandler];
//}

//上传
- (NSURLSessionUploadTask *)hook_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (traceId) {
            NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
            [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
            [[self class] survayRequest:rq traceId:traceId];
            EELog(@"-------->over<--------");
            return [self hook_uploadTaskWithRequest:rq fromFile:fileURL];
        }
    }
    EELog(@"-------->over<--------");
    return [self hook_uploadTaskWithRequest:request fromFile:fileURL];
}

- (NSURLSessionUploadTask *)hook_uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (traceId) {
            NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
            [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
            [[self class] survayRequest:rq traceId:traceId];
            EELog(@"-------->over<--------");
            return [self hook_uploadTaskWithRequest:rq fromData:bodyData];
        }
    }
    EELog(@"-------->over<--------");
    return [self hook_uploadTaskWithRequest:request fromData:bodyData];
}

- (NSURLSessionUploadTask *)hook_uploadTaskWithStreamedRequest:(NSURLRequest *)request {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (traceId) {
            NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
            [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
            [[self class] survayRequest:rq traceId:traceId];
            EELog(@"-------->over<--------");
            return [self hook_uploadTaskWithStreamedRequest:rq];
        }
    }
    EELog(@"-------->over<--------");
    return [self hook_uploadTaskWithStreamedRequest:request];
}

- (NSURLSessionUploadTask *)hook_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (!traceId) {
            EELog(@"-------->over<--------");
            return [self hook_uploadTaskWithRequest:request fromFile:fileURL completionHandler:completionHandler];
        }
        NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
        [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
        [[self class] survayRequest:rq traceId:traceId];
        
        if (completionHandler) {
            UploadCompletionHandler hook_completionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                //把traceId设置到响应头
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                httpResponse.traceId = traceId;
                EELog(@"-------->over<--------");
                completionHandler(data, httpResponse, error);
                //响应监控
                [[self class] survayResponse:httpResponse traceId:traceId requestUrl:request.URL.absoluteString data:data loaction:nil error:error];
                [[self class] survayUpload:traceId];
                if (![NMUtil isInterferenceMode]) {
                    [[NMCache sharedNMCache] persistData:traceId];
                }
            };
            EELog(@"-------->over<--------");
            return [self hook_uploadTaskWithRequest:rq fromFile:fileURL completionHandler:hook_completionHandler];
        }
        EELog(@"-------->over<--------");
        return [self hook_uploadTaskWithRequest:rq fromFile:fileURL completionHandler:completionHandler];
    }
    EELog(@"-------->over<--------");
    return [self hook_uploadTaskWithRequest:request fromFile:fileURL completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)hook_uploadTaskWithRequest:(NSURLRequest *)request fromData:(nullable NSData *)bodyData completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    EELog(@"-------->start<--------");
    if ([NMUtil isNetworkMonitorOn]) {
        NSString *traceId = [[self class] isInWhiteLists:request];
        if (!traceId) {
            EELog(@"-------->over<--------");
            return [self hook_uploadTaskWithRequest:request fromData:bodyData completionHandler:completionHandler];
        }
        NSMutableURLRequest *rq = [NMUtil mutableRequest:request];
        [rq setValue:traceId forHTTPHeaderField:HEAD_KEY_EETRACEID];
        [[self class] survayRequest:rq traceId:traceId];
        
        if (completionHandler) {
            UploadCompletionHandler hook_completionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                //把traceId设置到响应头
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                httpResponse.traceId = traceId;
                EELog(@"-------->over<--------");
                completionHandler(data, httpResponse, error);
                //响应监控
                [[self class] survayResponse:httpResponse traceId:traceId requestUrl:request.URL.absoluteString data:data loaction:nil error:error];
                [[self class] survayUpload:traceId];
                if (![NMUtil isInterferenceMode]) {
                    [[NMCache sharedNMCache] persistData:traceId];
                }
            };
            EELog(@"-------->over<--------");
            return [self hook_uploadTaskWithRequest:rq fromData:bodyData completionHandler:hook_completionHandler];
        }
        EELog(@"-------->over<--------");
        return [self hook_uploadTaskWithRequest:rq fromData:bodyData completionHandler:completionHandler];
    }
    EELog(@"-------->over<--------");
    return [self hook_uploadTaskWithRequest:request fromData:bodyData completionHandler:completionHandler];
}

#pragma mark util
//响应相关监控
+ (void)survayResponse:(NSHTTPURLResponse *)httpResponse traceId:(NSString *)traceId requestUrl:(NSString *)requestUrl data:(NSData *)data loaction:(NSString *)location error:(NSError *)error {
    EELog(@"-------->start<--------");
    //低于10.0版本适配
    if (![NMUtil isAbove_iOS_10_0]) {
        [[NMCache sharedNMCache] cacheValue:[NMUtil getCurrentTime] key:NMDATA_KEY_ENDRESPONSE traceId:traceId];
    }
    //响应相关监控
    NSInteger statusCode = httpResponse.statusCode;
    NSUInteger statusLineSize = httpResponse.statusLineSize;
    NSUInteger headerSize = httpResponse.headerSize;
    if ([[httpResponse.allHeaderFields objectForKey:@"Content-Encoding"] isEqualToString:@"gzip"]) {
        // 模拟压缩
        data = [data gzippedData];
    }
    NSUInteger bodySize = data.length;
    NSString *ress;
    if (error) {
        [[NMCache sharedNMCache] cacheValue:@"1" key:NMDATA_KEY_ERRORTYPE traceId:traceId];
        [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%d", (int)error.code] key:NMDATA_KEY_ERRORCODE traceId:traceId];
        [[NMCache sharedNMCache] cacheValue:error.description key:NMDATA_KEY_ERRORDETAIL traceId:traceId];
        if ([error.description containsString:@"cancelled"]) {
            [[NMCache sharedNMCache] cacheValue:@"cancel" key:NMDATA_KEY_STATE traceId:traceId];
        } else {
            [[NMCache sharedNMCache] cacheValue:@"failure" key:NMDATA_KEY_STATE traceId:traceId];
        }
//        ress = [NSString stringWithFormat:@"%lu", (unsigned long)error.description.length + data.length];
        ress = [NSString stringWithFormat:@"%lu", (unsigned long)statusLineSize + headerSize + bodySize];
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
        if (location) {
            NSNumber *fileSize = [NMUtil sizeOfItemAtPath:[NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(), location] error:nil];
//            ress = [NSString stringWithFormat:@"%lu", (unsigned long)httpResponse.description.length + fileSize.unsignedLongValue];
            ress = [NSString stringWithFormat:@"%lu", (unsigned long)statusLineSize + headerSize + bodySize + [fileSize unsignedLongValue]];
        } else {
//            ress = [NSString stringWithFormat:@"%lu", (unsigned long)httpResponse.description.length + data.length];
            ress = [NSString stringWithFormat:@"%lu", (unsigned long)statusLineSize + headerSize + bodySize];
        }
    }
    [[NMCache sharedNMCache] cacheValue:ress key:NMDATA_KEY_RESPONSESIZE traceId:traceId];
//    [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (long)statusCode] key:NMDATA_KEY_STATUSCODE traceId:traceId];
    if (httpResponse.MIMEType) {
        [[NMCache sharedNMCache] cacheValue:httpResponse.MIMEType key:NMDATA_KEY_CONTENTTYPE traceId:traceId];
    } else {
        NSString *type = requestUrl.lastPathComponent.pathExtension;
        [[NMCache sharedNMCache] cacheValue:[NMUtil mimeType:type] key:NMDATA_KEY_CONTENTTYPE traceId:traceId];
    }
    EELog(@"-------->over<--------");
}

//请求相关监控
+ (void)survayRequest:(NSMutableURLRequest *)rq traceId:(NSString *)traceId {
    EELog(@"-------->start<--------");
    if (![NMUtil isAbove_iOS_10_0]) {
        [[NMCache sharedNMCache] cacheValue:[NMUtil getCurrentTime] key:NMDATA_KEY_STARTREQUEST traceId:traceId];
    }
    NSString *host = rq.URL.host;
    [[NMCache sharedNMCache] cacheValue:rq.URL.absoluteString key:NMDATA_KEY_ORIGINALURL traceId:traceId];
    if ([NMUtil isDomain:host]) {
        [[NMCache sharedNMCache] cacheValue:[NMUtil getIPByDomain:host] key:NMDATA_KEY_ORIGINALIP traceId:traceId];
    } else {
        [[NMCache sharedNMCache] cacheValue:host key:NMDATA_KEY_ORIGINALIP traceId:traceId];
    }
    NSUInteger statusLineSize = rq.statusLineSize;
    NSUInteger headerSize = rq.headerSize;
    NSUInteger bodySize = rq.bodySize;
    NSUInteger length = statusLineSize + headerSize;
    [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (unsigned long)length] key:NMDATA_KEY_REQUESTSIZE_HEAD traceId:traceId];
    [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (unsigned long)bodySize] key:NMDATA_KEY_REQUESTSIZE_BODY traceId:traceId];
    EELog(@"-------->over<--------");
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

+ (NSString *)isInWhiteLists:(NSURLRequest *)request {
    EELog(@"-------->start<--------");
    for (NSString *url in [NMManager sharedNMManager].getConfig.urlWhiteList) {
        if ([request.URL.absoluteString containsString:url]) {
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


//代理方法分类处理
+ (void)registerDelegateMethod:(NSString *)method oriDelegate:(id<NSURLSessionDelegate>)oriDel assistDelegate:(NMObjectDelegate *)assiDel flag:(const char *)flag {
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


@end
