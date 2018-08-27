//
//  NSHTTPURLResponse+NM.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/5/15.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 为响应头添加traceId
 */
@interface NSHTTPURLResponse (EE)

/**
 在响应头中添加traceId
 */
@property (nonatomic, strong)NSString *traceId;

@property (nonatomic, assign, readonly)NSUInteger statusLineSize;

@property (nonatomic, assign, readonly)NSUInteger headerSize;

@end
