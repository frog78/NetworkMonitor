//
//  NMUtil.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NMUtil : NSObject

/**
 获取唯一traceId

 @return 返回traceId
 */
+ (NSString *)getTraceId;

/**
 是否开始监控

 @return 返回结果
 */
+ (BOOL)isNetworkMonitorOn;

/**
 是否为干预模式

 @return 返回结果
 */
+ (BOOL)isInterferenceMode;

/**
 获取当前网络类型

 @return 返回网络类型
 */
+ (NSString *)getNetWorkInfo;

/**
 获取当前网络强度

 @return 返回网络强度
 */
+ (NSString *)getSignalStrength;

/**
 检测是否为域名

 @param domain 域名
 @return 返回检测结果
 */
+ (BOOL)isDomain:(NSString *)domain;

/**
 通过域名获取ip

 @param domain 域名
 @return 返回本地域名解析结果
 */
+ (NSString *)getIPByDomain:(const NSString *)domain;

/**
 从请求头中提取参数

 @param headerField 请求头中headerField
 @return 返回提取到的特定参数
 */
+ (NSDictionary *)extractParamsFromHeader:(NSDictionary *)headerField;

/**
 获取文件大小

 @param path 文件路径
 @param error 错误
 @return 返回文件大小结果
 */
+ (NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error;

/**
 获取当前时间戳

 @return 返回当前时间戳
 */
+ (NSString *)getCurrentTime;

/**
 请求转为可变请求

 @abstract 如果原来就是可变请求则强转，如果不是则用mutablecopy
 @param request 原请求
 @return 可变请求
 */
+ (NSMutableURLRequest *)mutableRequest:(NSURLRequest *)request;

/**
 *  获取运营商网络的详细接入点信息，其无法根据当前网络状态进行区分，外部使用时需要注意
 *
 *  @return 详细接入点信息
 */
+ (NSString *)getDetailApCode;

/**
 系统版本是否大于等于10.0

 @return 返回判断值
 */
+ (BOOL)isAbove_iOS_10_0;

/**
 根据文件后缀获取mimetype

 @param type 文件后缀
 @return 返回mimetype值
 */
+ (NSString *)mimeType:(NSString *)type;


@end
