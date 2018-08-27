//
//  NSURLSessionVC.m
//  NetworkMonitorSample
//
//  Created by frog78 on 2018/4/28.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NSURLSessionVC.h"
#import <NetworkMonitor/NetworkMonitor.h>

extern NSString *rtpKey;
extern NSString *rspKey;
extern NSString *urlKey;

//#define TEST_URL @"http://wthrcdn.etouch.cn/weather_mini?citykey=101010100"
#define TEST_URL @"https://www.xunfei.cn/gettuid?bizid=100ime&uid=180606190946715065"
//#define TEST_URL @"http://download.voicecloud.cn/ygxt/20180605/85ee0f89-a95f-4424-8abc-4f6243ef79b2.zip"
//#define TEST_URL @"https://wj.ahga.gov.cn/business-services/h5/remove-car-record"
//#define TEST_URL @"https://h5.m.taobao.com"

#define DOWNLOAD_URL @"http://10.5.131.240/test.pdf"

#define UPLOAD_URL @"http://test.cystorage.cycore.cn"

@interface NSURLSessionVC ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate> {
    NSURLSessionTask *task1;
    NSDictionary *rtp;
    NSDictionary *rsp;
    NSString *urlString;
}

@end

@implementation NSURLSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NSURLSession";
    rtp = [[NSUserDefaults standardUserDefaults] objectForKey:rtpKey];
    rsp = [[NSUserDefaults standardUserDefaults] objectForKey:rspKey];
    urlString = [[NSUserDefaults standardUserDefaults] objectForKey:urlKey];
}

- (IBAction)get:(id)sender {
    
    NSURL *url;
    if (urlString && ![urlString isEqualToString:@""]) {
        url = [NSURL URLWithString:urlString];
    } else {
        url = [NSURL URLWithString:TEST_URL];
    }
    url.extendedParameter = rtp;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session  = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    //    NSURLSession *session  = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *traceId = httpResponse.allHeaderFields[HEAD_KEY_EETRACEID];
        [[NMManager sharedNMManager] setExtendedParameter:rsp traceId:traceId];
        if ([[NMManager sharedNMManager] getConfig].enableInterferenceMode) {
            [[NMManager sharedNMManager] finishColection:traceId];
        }
        [session invalidateAndCancel];
    }];
    [task resume];
}

- (IBAction)post:(id)sender {
    NSURL *url;
    if (urlString && ![urlString isEqualToString:@""]) {
        url = [NSURL URLWithString:urlString];
    } else {
        url = [NSURL URLWithString:TEST_URL];
    }
    url.extendedParameter = rtp;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session  = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
//    NSURLSession *session  = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    NSMutableURLRequest *mrq = (NSMutableURLRequest *)task.originalRequest;
    NSString *traceId = mrq.allHTTPHeaderFields[HEAD_KEY_EETRACEID];
    [[NMManager sharedNMManager] setExtendedParameter:rsp traceId:traceId];
    if ([[NMManager sharedNMManager] getConfig].enableInterferenceMode) {
        [[NMManager sharedNMManager] finishColection:traceId];
    }
    [session invalidateAndCancel];
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
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session  = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
//方式一：代理
    task1 = [session downloadTaskWithRequest:request];
    [task1 resume];
//方式二：block
//    task1 = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//    }];
}


- (IBAction)downloadCancel:(id)sender {
    [task1 cancel];
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
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    // 设置ContentType
    NSString *contentType = @"multipart/form-data";
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
    NSData *httpBody = [self createBodyWithBoundary:@"" parameters:@{} paths:@[filePath] fieldName:@"file"];
    task1 = [session uploadTaskWithRequest:request fromData:httpBody];
//    task1 = [session uploadTaskWithRequest:request fromData:httpBody completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (error) {
//            NSLog(@"error = %@", error);
//        }
//    }];
//    task1 = [session uploadTaskWithRequest:request fromFile:[NSURL URLWithString:filePath] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//    }];
    [task1 resume];
}

- (IBAction)uploadCancel:(id)sender {
    [task1 cancel];
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
