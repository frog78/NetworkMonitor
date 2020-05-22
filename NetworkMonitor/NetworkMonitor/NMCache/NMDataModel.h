//
//  NMDATAModel.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMModelCommon.h"

/**
 端到端监控缓存数据模型
 */
@interface NMDataModel : NMModelCommon


/**
 单次请求的唯一id.(=ti)
 */
@property (strong, nonatomic) NSString *ti;

/**
 当前接入点名称（wifi、cmwap、ctwap、uniwap、cmnet、uninet、ctnet、g3net、g3wap、unknown）.(=apn)
 */
@property (strong, nonatomic) NSString *apn;

/**
 网络类型(=networktype)
 */
@property (strong, nonatomic) NSString *ns;

// 接口描述.(=cmd)
@property (strong, nonatomic) NSString *cmd;

/**
 原始url.(=originalUrl)
 */
@property (strong, nonatomic) NSString *ourl;

/**
 重定向url.(=redirectUrl)
 */
@property (strong, nonatomic) NSString *rurl;

/**
 原始ip.(=originalIp)
 */
@property (strong, nonatomic) NSString *oip;

/**
 重定向ip.(=redirectIp)
 */
@property (strong, nonatomic) NSString *rip;

/**
 请求包大小.(=requestSize)
 */
@property (strong, nonatomic) NSString *reqs;

/**
 接口请求结果：success、failure、cancel.(=state)
 */
@property (strong, nonatomic) NSString *state;

/**
 状态码(=statusCode)
 */
@property (strong, nonatomic) NSString *sc;

/**
 错误类型：1网络错误 2http错误 3业务错误.(=errorType)
 */
@property (strong, nonatomic) NSString *etp;

/**
 错误码.(=errorCode)
 */
@property (strong, nonatomic) NSString *ec;

/**
 错误描述.(=errorDetail)
 */
@property (strong, nonatomic) NSString *ed;

/**
 返回包大小.(=responseSize)
 */
@property (strong, nonatomic) NSString *ress;

/**
 mimeType.(=contentType)
 */
@property (strong, nonatomic) NSString *cty;

/**
 返回包（状态为失败时记录）.(=responseData)
 */
@property (strong, nonatomic) NSString *ddata;

/**
 请求开始时间.(=startRequest)
 */
@property (strong, nonatomic) NSString *sreq;

/**
 域名解析的时间.(=dnsTime)
 */
@property (strong, nonatomic) NSString *dnst;

/**
 SSL的时间，仅针对https，当http时此项为空.(=sslTime)
 */
@property (strong, nonatomic) NSString *sslt;

/**
 与服务器建立tcp链接需要的时间.(=connTime)
 */
@property (strong, nonatomic) NSString *cnnt;

/**
 从客户端发送HTTP请求到服务器所耗费的时间.(=sendTime)
 */
@property (strong, nonatomic) NSString *sdt;

/**
 响应报文首字节到达时间.(=waitTime)
 */
@property (strong, nonatomic) NSString *wtt;

/**
 客户端从开始接收数据到接收完所有数据的时间.(=receiveTime)
 */
@property (strong, nonatomic) NSString *rcvt;

/**
 响应结束时间.(=endResponse)
 */
@property (strong, nonatomic) NSString *eres;

/**
 请求总耗时.(=totalTime)
 */
@property (strong, nonatomic) NSString *ttt;

/**
 原始md5信息.(=originalMd5)
 */
@property (strong, nonatomic) NSString *omd5;

/**
 下载成功文件的md5信息.(=downloadMd5)
 */
@property (strong, nonatomic) NSString *dmd5;

/**
 原始文件大小，单位：字节.(=originalSize)
 */
@property (strong, nonatomic) NSString *osize;

/**
 下载成功文件的文件大小，单位：字节.(=downloadSize)
 */
@property (strong, nonatomic) NSString *dsize;

/**
 实际下载大小（md5不一致时记录），单位：字节.(=realDownloadSize)
 */
@property (strong, nonatomic) NSString *rdsize;

/**
 扩展数据
 */
@property (strong, nonatomic) NSDictionary *extension;

- (void)setRequestHeaderSize:(NSString *)size;

- (void)setRequestBodySize:(NSString *)size;


@end
