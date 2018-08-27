//
//  NSURLConnectionDownloadDelegate.m
//  NetworkMonitorSample
//
//  Created by frog78 on 2018/6/7.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NSURLConnectionDownloadDelegate.h"

@implementation NSURLConnectionDownloadDelegate

#pragma mark-NSURLConnectionDownloadDelegate
- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes {

}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes {

}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL {

}


@end
