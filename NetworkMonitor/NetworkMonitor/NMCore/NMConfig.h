//
//  NMConfig.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class NMConfig
 @abstract NetworkMonitor配置项
 */
@interface NMConfig : NSObject

/**
 是否开启监控，默认为NO;
 */
@property (nonatomic, assign)BOOL enableNetworkMonitor;

/**
 是否开启log，默认为YES;
 */
@property (nonatomic, assign)BOOL enableLog;

/**
 是否开启干扰模式，默认为NO;
 非干扰模式下，记录结束时间由SDK决定;
 干扰模式下，记录结束由开发者手动触发
 */
@property (nonatomic, assign)BOOL enableInterferenceMode;

/**
 排除在监控之外的url列表
 */
@property (nonatomic, strong)NSArray *urlWhiteList;

/**
 排除在监控之外的cmd列表
 */
@property (nonatomic, strong)NSArray *cmdWhiteList;


@end
