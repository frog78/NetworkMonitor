//
//  NetworkMonitorDef.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#ifndef NetworkMonitorDef_h
#define NetworkMonitorDef_h

#define HEAD_KEY_EETRACEID @"head_key_traceid"
#define HEAD_KEY_MAKE(key) [NSString stringWithFormat:@"head_keys_%@", key]

extern NSString *NMDATA_KEY_CMD; //接口描述
extern NSString *NMDATA_KEY_ERRORTYPE; //错误类型
extern NSString *NMDATA_KEY_RESPONSEDATA; //返回包（状态为失败时记录）
extern NSString *NMDATA_KEY_ORIGINALMD5; //原始md5信息
extern NSString *NMDATA_KEY_DOWNLOADMD5; //下载成功文件的md5信息
extern NSString *NMDATA_KEY_ORIGINALSIZE; //原始文件大小
extern NSString *NMDATA_KEY_DOWNLOADSIZE; //下载成功文件的文件大小
extern NSString *NMDATA_KEY_REALDOWNLOADSIZE; //实际下载大小（md5不一致时记录）

//监控数据输出block定义
typedef void(^DataOutputBlock)(NSString * traceId, NSDictionary *data);

@class NMConfig;

/**
 NetworkMonitor对外接口
 */
@protocol NetworkMonitorProtocol <NSObject>

/**
 开始监控
 */
- (void)start;

/**
 停止监控
 */
- (void)stop;

/**
 获取到当前配置
 
 @return 返回当前配置实例
 */
- (NMConfig *)getConfig;

#pragma mark-以下接口在干预模式下有效
/**
 根据traceId添加扩展参数

 @abstract 服务端返回的一些业务参数可以通过该方法设置到
           监控记录中。
 @param params 业务扩展参数
 @param traceId 单次请求唯一id
 */
- (void)setExtendedParameter:(NSDictionary *)params
                     traceId:(NSString *)traceId;

/**
 结束本次网络请求数据收集

 @param traceId 单次请求唯一id
 */
- (void)finishColection:(NSString *)traceId;

#pragma mark-以下接口在不设置outputBlock时有效
/**
 获取所有缓存数据

 @return 返回缓存数据数组
 */
- (NSArray *)getAllData;

/**
 删除所有缓存数据
 */
- (void)removeAllData;


@end

#endif /* NetworkMonitorDef_h */
