//
//  NSURLConnectionVC.m
//  NetworkMonitorSample
//
//  Created by frog78 on 2018/4/28.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NSURLConnectionVC.h"
#import "NSURLConnectionDownloadDelegate.h"
#import <NetworkMonitor/NetworkMonitor.h>

extern NSString *rtpKey;
extern NSString *rspKey;
extern NSString *urlKey;

//#define TEST_URL @"http://wthrcdn.etouch.cn/weather_mini?citykey=101010100"
#define TEST_URL @"https://ossptest.voicecloud.cn/oppsclient/do?c=100810&v=3.2&t=20180630093408"
//#define TEST_URL @"https://www.google.com/"
//#define TEST_URL @"https://wj.ahga.gov.cn/business-services/h5/remove-car-record"
//#define TEST_URL @"https://m.taobao.com"

#define DOWNLOAD_URL @"http://10.5.131.240/test.pdf"

#define UPLOAD_URL @"http://test.cystorage.cycore.cn"

@interface NSURLConnectionVC ()<NSURLConnectionDataDelegate> {
    NSURLConnection *conn;
    NSDictionary *rtp;
    NSDictionary *rsp;
    NSString *urlString;
}

@end

@implementation NSURLConnectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NSURLConnection";
    rtp = [[NSUserDefaults standardUserDefaults] objectForKey:rtpKey];
    rsp = [[NSUserDefaults standardUserDefaults] objectForKey:rspKey];
    urlString = [[NSUserDefaults standardUserDefaults] objectForKey:urlKey];
}

//同步请求
- (IBAction)synchronousRequest:(id)sender {
    
    NSURL *url;
    if (urlString && ![urlString isEqualToString:@""]) {
        url = [NSURL URLWithString:urlString];
    } else {
        url = [NSURL URLWithString:TEST_URL];
    }
    url.extendedParameter = rtp;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *traceId = response.allHeaderFields[HEAD_KEY_EETRACEID];
    [[NMManager sharedNMManager] setExtendedParameter:rsp traceId:traceId];
    if ([[NMManager sharedNMManager] getConfig].enableInterferenceMode) {
        [[NMManager sharedNMManager] finishColection:traceId];
    }
}

//异步请求
- (IBAction)asynchronousRequest:(id)sender {
    NSURL *url;
    if (urlString && ![urlString isEqualToString:@""]) {
        url = [NSURL URLWithString:urlString];
    } else {
        url = [NSURL URLWithString:TEST_URL];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    url.extendedParameter = rtp;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *traceId = httpResponse.allHeaderFields[HEAD_KEY_EETRACEID];
        [[NMManager sharedNMManager] setExtendedParameter:rsp traceId:traceId];
        if ([[NMManager sharedNMManager] getConfig].enableInterferenceMode) {
            [[NMManager sharedNMManager] finishColection:traceId];
        }
    }];
}

//代理方式请求
- (IBAction)connectionStart:(id)sender {
    NSURL *url;
    if (urlString && ![urlString isEqualToString:@""]) {
        url = [NSURL URLWithString:urlString];
    } else {
        url = [NSURL URLWithString:TEST_URL];
    }
    url.extendedParameter = rtp;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"get";
    // 第一种代理方式
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    // 第二种代理方式
//    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    //在startImmediately为NO时，调用该方法控制网络请求的发送
    [conn start];
    
    // 第三种代理方式
    //设置代理的第三种方式：使用类方法设置代理，会自动发送网络请求
//    conn = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (IBAction)downloadStart:(id)sender {
    NSURL *url;
    if (urlString && ![urlString isEqualToString:@""]) {
        url = [NSURL URLWithString:urlString];
    } else {
        url = [NSURL URLWithString:DOWNLOAD_URL];
    }
    url.extendedParameter = rtp;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 第一种代理方式
    //    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    // 第二种代理方式
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:[NSURLConnectionDownloadDelegate new] startImmediately:YES];
}
- (IBAction)downloadCancel:(id)sender {
    [conn cancel];
}

- (IBAction)uploadStart:(id)sender {
    // 请求的Url
    NSURL *url = [NSURL URLWithString:UPLOAD_URL];
    url.extendedParameter = rtp;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"28" forHTTPHeaderField:@"Content-Length"];
    [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [request setHTTPMethod:@"POST"];
    // 设置ContentType
    NSString *contentType = @"multipart/form-data";
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
    NSData *httpBody = [self createBodyWithBoundary:@"" parameters:@{} paths:@[filePath] fieldName:@"file"];
    [request setHTTPBody:httpBody];
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (IBAction)uploadCancel:(id)sender {
    [conn cancel];
}

#pragma mark-NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSMutableURLRequest *mrq = (NSMutableURLRequest *)connection.originalRequest;
    NSString *traceId = mrq.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    if ([[NMManager sharedNMManager] getConfig].enableInterferenceMode) {
        [[NMManager sharedNMManager] finishColection:traceId];
    }
}

#pragma mark-NSURLConnectionDataDelegate
//- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response {
//    return request;
//}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSMutableURLRequest *mrq = (NSMutableURLRequest *)connection.originalRequest;
    NSString *traceId = mrq.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    [[NMManager sharedNMManager] setExtendedParameter:rsp traceId:traceId];
    if ([[NMManager sharedNMManager] getConfig].enableInterferenceMode) {
        [[NMManager sharedNMManager] finishColection:traceId];
    }
}

//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    NSLog(@"EE---->%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//}
//
//- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
// totalBytesWritten:(NSInteger)totalBytesWritten
//totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
//    
//}


//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    
//}

- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName {
    NSMutableData *httpBody = [NSMutableData data];
    
    // 文本参数
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // 本地文件的NSData
    for (NSString *path in paths) {
        NSString *filename = [path lastPathComponent];
        NSData   *data     = [NSData dataWithContentsOfFile:path];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return httpBody;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
