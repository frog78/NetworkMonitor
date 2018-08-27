//
//  NSURL+NM.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/5/14.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 此NSURL分类用于添加业务扩展参数
 有些业务参数不方便在拦截网络请求时获取(例如：接口描述cmd)，需要业务
 手动添加。通过setExtendedParameter:方法添加在NSURL中的扩展参数，
 将被记录在该次请求的监控数据中。
 */
@interface NSURL (NM)

//在NSURL中添加扩展参数
@property (nonatomic, strong)NSDictionary *extendedParameter;


@end
