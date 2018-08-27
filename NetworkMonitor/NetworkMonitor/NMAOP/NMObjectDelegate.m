//
//  NMObjectDelegate.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/26.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NMObjectDelegate.h"
#import "NMCache.h"
#import "NSHTTPURLResponse+NM.h"
#import "NSData+GZIP.h"
#import <UIKit/UIKit.h>


@interface NMObjectDelegate()

@property (nonatomic, strong)NSMutableArray *selList;

@end

@implementation NMObjectDelegate

- (NSMutableArray *)selList {
    if (!_selList) {
        _selList = [NSMutableArray arrayWithCapacity:0];
    }
    return _selList;
}

- (void)invoke:(NSInvocation *)invocation {
    if (![NMUtil isNetworkMonitorOn] || invocation.selector == @selector(respondsToSelector:)) {
        return;
    }
    if ([self.selList containsObject:NSStringFromSelector(invocation.selector)]) {
        if ([self respondsToSelector:invocation.selector]) {
            invocation.target = self;
            [invocation invoke];
        }
    } 
}

- (void)registerSelector:(NSString *)selector {
    if (![self.selList containsObject:selector]) {
        [self.selList addObject:selector];
    }
}

- (void)unregisterSelector:(NSString *)selector {
    if ([self.selList containsObject:selector]) {
        [self.selList removeObject:selector];
    }
}

#pragma mark-NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics {
    EELog(@"-------->start<--------");
    if (![NMUtil isNetworkMonitorOn]) {
        return;
    }
    NSURLSessionTaskTransactionMetrics *metric = [metrics.transactionMetrics lastObject];
    NSString *traceId = metric.request.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    if (!traceId) {
        EELog(@"-------->over<--------");
        return;
    }
//    for (NSURLSessionTaskTransactionMetrics *mrc in metrics.transactionMetrics) {
//        NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
//        NSLog(@"fetchStartDate:%@", [NSString stringWithFormat:@"%2f", [mrc.fetchStartDate timeIntervalSince1970] * 1000]);
//        NSLog(@"domainLookupStartDate:%@", [NSString stringWithFormat:@"%2f", [mrc.domainLookupStartDate timeIntervalSince1970] * 1000]);
//        NSLog(@"domainLookupEndDate:%@", [NSString stringWithFormat:@"%2f", [mrc.domainLookupEndDate timeIntervalSince1970] * 1000]);
//        NSLog(@"connectStartDate:%@", [NSString stringWithFormat:@"%2f", [mrc.connectStartDate timeIntervalSince1970] * 1000]);
//        NSLog(@"secureConnectionStartDate:%@", [NSString stringWithFormat:@"%2f", [mrc.secureConnectionStartDate timeIntervalSince1970] * 1000]);
//        NSLog(@"secureConnectionEndDate:%@", [NSString stringWithFormat:@"%2f", [mrc.secureConnectionEndDate timeIntervalSince1970] * 1000]);
//        NSLog(@"connectEndDate:%@", [NSString stringWithFormat:@"%2f", [mrc.connectEndDate timeIntervalSince1970] * 1000]);
//        NSLog(@"requestStartDate:%@", [NSString stringWithFormat:@"%2f", [mrc.requestStartDate timeIntervalSince1970] * 1000]);
//        NSLog(@"requestEndDate:%@", [NSString stringWithFormat:@"%2f", [mrc.requestEndDate timeIntervalSince1970] * 1000]);
//        NSLog(@"responseStartDate:%@", [NSString stringWithFormat:@"%2f", [mrc.responseStartDate timeIntervalSince1970] * 1000]);
//        NSLog(@"responseEndDate:%@", [NSString stringWithFormat:@"%2f", [mrc.responseEndDate timeIntervalSince1970] * 1000]);
//        NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
//    }
    if (metric) {
        //请求开始时间
        NSString *sreq = [NSString stringWithFormat:@"%.f", [metric.fetchStartDate timeIntervalSince1970] * 1000];
        [[NMCache sharedNMCache] cacheValue:sreq key:NMDATA_KEY_STARTREQUEST traceId:traceId];
        //域名解析时间
        NSString *dnst = [NSString stringWithFormat:@"%.f", [metric.domainLookupEndDate timeIntervalSinceDate:metric.domainLookupStartDate] * 1000];
        [[NMCache sharedNMCache] cacheValue:dnst key:NMDATA_KEY_DNSTIME traceId:traceId];
        //连接建立时间
        NSString *cnnt = [NSString stringWithFormat:@"%.f", [metric.connectEndDate timeIntervalSinceDate:metric.connectStartDate] * 1000];
        [[NMCache sharedNMCache] cacheValue:cnnt key:NMDATA_KEY_CONNTIME traceId:traceId];
        //https ssl验证时间
        NSString *sslt = [NSString stringWithFormat:@"%.f", [metric.secureConnectionEndDate timeIntervalSinceDate:metric.secureConnectionStartDate] * 1000];
        [[NMCache sharedNMCache] cacheValue:sslt key:NMDATA_KEY_SSLTIME traceId:traceId];
        //从客户端发送HTTP请求到服务器所耗费的时间
        NSString *sdt = [NSString stringWithFormat:@"%.f", [metric.requestEndDate timeIntervalSinceDate:metric.requestStartDate] * 1000];
        [[NMCache sharedNMCache] cacheValue:sdt key:NMDATA_KEY_SENDTIME traceId:traceId];
        //响应报文首字节到达时间
        NSString *wtt = [NSString stringWithFormat:@"%.f", [metric.responseStartDate timeIntervalSinceDate:metric.requestEndDate] * 1000];
        [[NMCache sharedNMCache] cacheValue:wtt key:NMDATA_KEY_WAITTIME traceId:traceId];
        //客户端从开始接收数据到接收完所有数据的时间
        NSString *rcvt = [NSString stringWithFormat:@"%.f", [metric.responseEndDate timeIntervalSinceDate:metric.responseStartDate] * 1000];
        [[NMCache sharedNMCache] cacheValue:rcvt key:NMDATA_KEY_RECEIVETIME traceId:traceId];
        //请求结束时间
        NSString *eres = [NSString stringWithFormat:@"%.f", [metric.responseEndDate timeIntervalSince1970] * 1000];
        [[NMCache sharedNMCache] cacheValue:eres key:NMDATA_KEY_ENDRESPONSE traceId:traceId];
        //网络请求总时间
        NSString *ttt = [NSString stringWithFormat:@"%.f", [metrics.taskInterval duration] * 1000];
        [[NMCache sharedNMCache] cacheValue:ttt key:NMDATA_KEY_TOTALTIME traceId:traceId];
    }
    EELog(@"-------->over<--------");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    EELog(@"-------->start<--------");
    if (![NMUtil isNetworkMonitorOn]) {
        EELog(@"-------->over<--------");
        return;
    }
    NSString *traceId = task.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    if (!traceId) {
        EELog(@"-------->over<--------");
        return;
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
//iOS 10.0以下系统版本处理
    if (![NMUtil isAbove_iOS_10_0]) {
        [[NMCache sharedNMCache] cacheValue:[NMUtil getCurrentTime] key:NMDATA_KEY_ENDRESPONSE traceId:traceId];
    }
    NSString *ress;
    NSUInteger statusLineSize = httpResponse.statusLineSize;
    NSUInteger headerSize = httpResponse.headerSize;
    NSData *data = [[NMCache sharedNMCache] getDataByTraceId:traceId];
    if ([[httpResponse.allHeaderFields objectForKey:@"Content-Encoding"] isEqualToString:@"gzip"]) {
        // 模拟压缩
        data = [data gzippedData];
    }
    
    NSUInteger bodySize = data.length;
    NSInteger statusCode = httpResponse.statusCode;
    if (error) {
        [[NMCache sharedNMCache] cacheValue:@"1" key:NMDATA_KEY_ERRORTYPE traceId:traceId];
        [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%d", (int)error.code] key:NMDATA_KEY_ERRORCODE traceId:traceId];
        [[NMCache sharedNMCache] cacheValue:error.description key:NMDATA_KEY_ERRORDETAIL traceId:traceId];
        if ([error.description containsString:@"cancelled"]) {
            [[NMCache sharedNMCache] cacheValue:@"cancel" key:NMDATA_KEY_STATE traceId:traceId];
        } else {
            [[NMCache sharedNMCache] cacheValue:@"failure" key:NMDATA_KEY_STATE traceId:traceId];
        }
//        ress = [NSString stringWithFormat:@"%lu", (unsigned long)error.description.length + [[NMCache sharedNMCache] getDataByTraceId:traceId].length + [[[NMCache sharedNMCache] getNumByTraceId:traceId type:CacheDataTypeDownload] unsignedLongValue]];
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
//        ress = [NSString stringWithFormat:@"%lu", (unsigned long)httpResponse.description.length +  [[NMCache sharedNMCache] getDataByTraceId:traceId].length + [[[NMCache sharedNMCache] getNumByTraceId:traceId type:CacheDataTypeDownload] unsignedLongValue]];
    }
    [NMObjectDelegate survayUpload:traceId];
    ress = [NSString stringWithFormat:@"%lu", (unsigned long)statusLineSize +  bodySize + headerSize + [[[NMCache sharedNMCache] getNumByTraceId:traceId type:CacheDataTypeDownload] unsignedLongValue]];
    [[NMCache sharedNMCache] cacheValue:ress key:NMDATA_KEY_RESPONSESIZE traceId:traceId];
    [[NMCache sharedNMCache] removeDataByTraceId:traceId];
    [[NMCache sharedNMCache] removeNumByTraceId:traceId type:CacheDataTypeDownload];
//    [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (long)statusCode] key:NMDATA_KEY_STATUSCODE traceId:traceId];
    if (httpResponse.MIMEType) {
        [[NMCache sharedNMCache] cacheValue:httpResponse.MIMEType key:NMDATA_KEY_CONTENTTYPE traceId:traceId];
    } else {
        NSString *type = task.originalRequest.URL.lastPathComponent.pathExtension;
        [[NMCache sharedNMCache] cacheValue:[NMUtil mimeType:type] key:NMDATA_KEY_CONTENTTYPE traceId:traceId];
    }
    
    if (![NMUtil isInterferenceMode]) {
        [[NMCache sharedNMCache] persistData:traceId];
    }
    EELog(@"-------->over<--------");
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    if (![NMUtil isNetworkMonitorOn]) {
        EELog(@"-------->over<--------");
        return;
    }
    NSString *traceId = dataTask.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    if (traceId) {
        [[NMCache sharedNMCache] appendData:data byTraceId:traceId];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    EELog(@"-------->start<--------");
    if (![NMUtil isNetworkMonitorOn]) {
        EELog(@"-------->over<--------");
        return;
    }
    NSString *traceId = downloadTask.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    if (traceId) {
        [NMObjectDelegate survayDownload:traceId];
    }
    EELog(@"-------->over<--------");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (![NMUtil isNetworkMonitorOn]) {
        EELog(@"-------->over<--------");
        return;
    }
    NSString *traceId = downloadTask.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    if (traceId) {
        [[NMCache sharedNMCache] cacheNum:@(totalBytesWritten) byTraceId:traceId type:CacheDataTypeDownload];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    EELog(@"-------->start<--------");
    if (completionHandler && ![self isKindOfClass:[NMObjectDelegate class]]) {
        completionHandler(request);
    }
    if (![NMUtil isNetworkMonitorOn]) {
        EELog(@"-------->over<--------");
        return;
    }
    if (response) {
        NSString *traceId = task.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
        if (traceId) {
            NSString *host = request.URL.host;
            [[NMCache sharedNMCache] cacheValue:request.URL.absoluteString key:NMDATA_KEY_REDIRECTURL traceId:traceId];
            if ([NMUtil isDomain:host]) {
                [[NMCache sharedNMCache] cacheValue:[NMUtil getIPByDomain:host] key:NMDATA_KEY_REDIRECTIP traceId:traceId];
            } else {
                [[NMCache sharedNMCache] cacheValue:host key:NMDATA_KEY_REDIRECTIP traceId:traceId];
            }
        }
    }
    EELog(@"-------->over<--------");
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if (![NMUtil isNetworkMonitorOn]) {
        EELog(@"-------->over<--------");
        return;
    }
    NSString *traceId = task.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    if (traceId) {
        [[NMCache sharedNMCache] cacheNum:@(totalBytesSent) byTraceId:traceId type:CacheDataTypeUpload];
    }
}

#pragma mark-NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    EELog(@"-------->start<--------");
    if (![NMUtil isNetworkMonitorOn]) {
        EELog(@"-------->over<--------");
        return;
    }
    NSString *traceId = connection.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    [[NMCache sharedNMCache] cacheValue:[NMUtil getCurrentTime] key:NMDATA_KEY_ENDRESPONSE traceId:traceId];
    if (error) {
        [[NMCache sharedNMCache] cacheValue:@"failure" key:NMDATA_KEY_STATE traceId:traceId];
        [[NMCache sharedNMCache] cacheValue:@"1" key:NMDATA_KEY_ERRORTYPE traceId:traceId];
        [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%d", (int)error.code] key:NMDATA_KEY_ERRORCODE traceId:traceId];
        [[NMCache sharedNMCache] cacheValue:error.description key:NMDATA_KEY_ERRORDETAIL traceId:traceId];
        [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (unsigned long)error.description.length] key:NMDATA_KEY_RESPONSESIZE traceId:traceId];
        [NMObjectDelegate survayUpload:traceId];
    }
    [NMObjectDelegate survayDownload:traceId];
    
    if (![NMUtil isInterferenceMode]) {
        [[NMCache sharedNMCache] persistData:traceId];
    }
    EELog(@"-------->over<--------");
}

- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response {
    EELog(@"-------->start<--------");
    if (![NMUtil isNetworkMonitorOn]) {
        EELog(@"-------->over<--------");
        return nil;
    }
    if (response) {
        NSString *traceId = connection.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
        [[NMCache sharedNMCache] cacheValue:request.URL.absoluteString key:NMDATA_KEY_REDIRECTURL traceId:traceId];
        if ([NMUtil isDomain:request.URL.host]) {
            [[NMCache sharedNMCache] cacheValue:[NMUtil getIPByDomain:request.URL.host] key:NMDATA_KEY_REDIRECTIP traceId:traceId];
        } else {
            [[NMCache sharedNMCache] cacheValue:request.URL.host key:NMDATA_KEY_REDIRECTIP traceId:traceId];
        }
    }
    EELog(@"-------->over<--------");
    return request;
}

#pragma mark-NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    EELog(@"-------->start<--------");
    if (![NMUtil isNetworkMonitorOn]) {
        EELog(@"-------->over<--------");
        return;
    }
    NSString *traceId = connection.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    [[NMCache sharedNMCache] cacheValue:@"success" key:NMDATA_KEY_STATE traceId:traceId];
    if (httpResponse.MIMEType) {
        [[NMCache sharedNMCache] cacheValue:httpResponse.MIMEType key:NMDATA_KEY_CONTENTTYPE traceId:traceId];
    } else {
        NSString *type = connection.originalRequest.URL.lastPathComponent.pathExtension;
        [[NMCache sharedNMCache] cacheValue:[NMUtil mimeType:type] key:NMDATA_KEY_CONTENTTYPE traceId:traceId];
    }
    NSUInteger statusLineSize = httpResponse.statusLineSize;
    NSUInteger headerSize = httpResponse.headerSize;
    NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)statusLineSize + headerSize];
//    [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (unsigned long)httpResponse.statusCode] key:NMDATA_KEY_STATUSCODE traceId:traceId];
    [[NMCache sharedNMCache] cacheValue:length key:NMDATA_KEY_RESPONSESIZE traceId:traceId];
    EELog(@"-------->over<--------");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (![NMUtil isNetworkMonitorOn]) {
        return;
    }
    //记录接收到数据
    NSString *traceId = connection.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    [[NMCache sharedNMCache] appendData:data byTraceId:traceId];
}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (![NMUtil isNetworkMonitorOn]) {
        return;
    }
    //缓存当前已上传数据大小
    NSString *traceId = connection.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    [[NMCache sharedNMCache] cacheNum:@(totalBytesWritten) byTraceId:traceId type:CacheDataTypeUpload];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    EELog(@"-------->start<--------");
    if (![NMUtil isNetworkMonitorOn]) {
        EELog(@"-------->over<--------");
        return;
    }
    NSString *traceId = connection.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    //停止时间
    [[NMCache sharedNMCache] cacheValue:[NMUtil getCurrentTime] key:NMDATA_KEY_ENDRESPONSE traceId:traceId];
    //响应监控
    NSUInteger length = [[[NMCache sharedNMCache] getDataByTraceId:traceId] gzippedData].length;
    [[NMCache sharedNMCache] cacheValue:[NSString stringWithFormat:@"%lu", (unsigned long)length] key:NMDATA_KEY_RESPONSESIZE traceId:traceId];
    [[NMCache sharedNMCache] removeDataByTraceId:traceId];
    if (![NMUtil isInterferenceMode]) {
        [[NMCache sharedNMCache] persistData:traceId];
    }
    EELog(@"-------->over<--------");
}

#pragma mark-NSURLConnectionDownloadDelegate
- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes {
    if (![NMUtil isNetworkMonitorOn]) {
        return;
    }
    //缓存当前已下载数据大小
    NSString *traceId = connection.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    [[NMCache sharedNMCache] cacheNum:@(totalBytesWritten) byTraceId:traceId type:CacheDataTypeDownload];
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes {
    if (![NMUtil isNetworkMonitorOn]) {
        return;
    }
    //缓存当前已下载数据大小
    NSString *traceId = connection.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    [[NMCache sharedNMCache] cacheNum:@(totalBytesWritten) byTraceId:traceId type:CacheDataTypeDownload];
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL {
    EELog(@"-------->start<--------");
    if (![NMUtil isNetworkMonitorOn]) {
        EELog(@"-------->over<--------");
        return;
    }
    NSString *traceId = connection.originalRequest.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    //停止时间
    [[NMCache sharedNMCache] cacheValue:[NMUtil getCurrentTime] key:NMDATA_KEY_ENDRESPONSE traceId:traceId];
    //下载数据统计
    [NMObjectDelegate survayDownload:traceId];
    if (![NMUtil isInterferenceMode]) {
        [[NMCache sharedNMCache] persistData:traceId];
    }
    EELog(@"-------->over<--------");
}

#pragma mark - util
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

@end
