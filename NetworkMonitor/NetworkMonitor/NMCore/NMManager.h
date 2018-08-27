//
//  NMManager.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkMonitorDef.h"
#import "NMConfig.h"

@interface NMManager : NSObject<NetworkMonitorProtocol>

/**
 监控数据输出block
 设置了该block，SDK每收集一条完整数据，就会通过该block回调出去
 如果不设置该block，SDK收集的数据将缓存在数据库中
 */
@property (nonatomic, copy)DataOutputBlock outputBlock;

/**
 获取单例
 
 @return 返回实例
 */
+ (instancetype)sharedNMManager;

/**
 初始化配置
 
 @param config NetworkMonitor相关参数配置
 */
- (void)initConfig:(NMConfig *)config;



@end
