//
//  NMCache.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMModelCommon.h"

extern NSString *NMDATA_KEY_EXTENSION;
extern NSString *NMDATA_KEY_TRACEID;
extern NSString *NMDATA_KEY_ERRORCODE;
//extern NSString *NMDATA_KEY_STATUSCODE;
extern NSString *NMDATA_KEY_STATE;
extern NSString *NMDATA_KEY_REQUESTSIZE;
extern NSString *NMDATA_KEY_REDIRECTIP;
extern NSString *NMDATA_KEY_ORIGINALIP;
extern NSString *NMDATA_KEY_REDIRECTURL;
extern NSString *NMDATA_KEY_ORIGINALURL;
extern NSString *NMDATA_KEY_APN;
extern NSString *NMDATA_KEY_NETSTRENGTH;
extern NSString *NMDATA_KEY_TOTALTIME;
extern NSString *NMDATA_KEY_ENDRESPONSE;
extern NSString *NMDATA_KEY_RECEIVETIME;
extern NSString *NMDATA_KEY_WAITTIME;
extern NSString *NMDATA_KEY_SENDTIME;
extern NSString *NMDATA_KEY_CONNTIME;
extern NSString *NMDATA_KEY_SSLTIME;
extern NSString *NMDATA_KEY_DNSTIME;
extern NSString *NMDATA_KEY_STARTREQUEST;
extern NSString *NMDATA_KEY_CONTENTTYPE;
extern NSString *NMDATA_KEY_RESPONSESIZE;
extern NSString *NMDATA_KEY_ERRORDETAIL;

extern NSString *NMDATA_KEY_REQUESTSIZE_HEAD;
extern NSString *NMDATA_KEY_REQUESTSIZE_BODY;

typedef NS_ENUM(NSInteger, CacheDataType) {
    CacheDataTypeDownload = 0,
    CacheDataTypeUpload,
    CacheDataTypeOther
};

@interface NMCache : NSObject

+ (instancetype)sharedNMCache;

/**
 根据traceId暂时缓存键值对

 @param value 值
 @param key 键
 @param traceId 单次网络请求唯一id
 */
- (void)cacheValue:(NSString *)value key:(const NSString *)key traceId:(NSString *)traceId;

/**
 根据traceId暂时缓存扩展参数

 @param ext 扩展参数字典
 @param traceId 网络请求唯一id
 @return 返回值 1表示同一条traceId数据还没持久化，0表示已经持久化
 */
- (int)cacheExtension:(NSDictionary *)ext traceId:(NSString *)traceId;

/**
 根据traceId持久化网络请求数据

 @param traceId 网络请求唯一id
 */
- (void)persistData:(NSString *)traceId;

/**
 获取全部数据

 @return 返回数据
 */
- (id)getAllData;

/**
 删除全部数据
 */
- (void)removeAllData;

#pragma mark-临时数据缓存
/**
 通过traceId储存数据
 
 @param data 数据片段
 @param traceId 唯一记录Id
 */
- (void)appendData:(NSData *)data byTraceId:(NSString *)traceId;

/**
 通过traceId删除储存数据
 
 @param traceId 唯一记录Id
 */
- (void)removeDataByTraceId:(NSString *)traceId;

/**
 通过traceId获取到
 
 @param traceId 唯一记录Id
 @return 返回数据值
 */
- (NSData *)getDataByTraceId:(NSString *)traceId;

/**
 通过traceId储存已下载数据大小
 
 @param num 要储存的数据
 @param traceId 唯一记录Id
 */
- (void)cacheNum:(NSNumber *)num byTraceId:(NSString *)traceId
            type:(CacheDataType)type;

/**
 通过traceId删除储存数据
 
 @param traceId 唯一记录Id
 */
- (void)removeNumByTraceId:(NSString *)traceId type:(CacheDataType)type;

/**
 通过traceId获取到
 
 @param traceId 唯一记录Id
 @return 返回数据值
 */
- (NSNumber *)getNumByTraceId:(NSString *)traceId type:(CacheDataType)type;


@end
