//
//  NSURLRequest+NM.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/6/6.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+GZIP.h"

@interface NSURLRequest (EE)

@property (nonatomic, assign, readonly)NSUInteger statusLineSize;

@property (nonatomic, assign, readonly)NSUInteger headerSize;

@property (nonatomic, assign, readonly)NSUInteger bodySize;

@end
