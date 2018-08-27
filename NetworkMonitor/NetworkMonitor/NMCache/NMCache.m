//
//  NMCache.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NMCache.h"
#import "NMDataModel.h"
#import "NMDataDAO.h"

//对外暴露字段名
const NSString *NMDATA_KEY_CMD =              @"cmd";
const NSString *NMDATA_KEY_ERRORTYPE =        @"etp";
const NSString *NMDATA_KEY_RESPONSEDATA =     @"ddata";
const NSString *NMDATA_KEY_ORIGINALMD5 =      @"omd5";
const NSString *NMDATA_KEY_DOWNLOADMD5 =      @"dmd5";
const NSString *NMDATA_KEY_ORIGINALSIZE =     @"osize";
const NSString *NMDATA_KEY_DOWNLOADSIZE =     @"dsize";
const NSString *NMDATA_KEY_REALDOWNLOADSIZE = @"rdsize";

//非对外暴露字段名
const NSString *NMDATA_KEY_EXTENSION =        @"extension";
const NSString *NMDATA_KEY_TRACEID =          @"ti";
const NSString *NMDATA_KEY_ERRORCODE =        @"ec";
//const NSString *NMDATA_KEY_STATUSCODE =       @"sc";
const NSString *NMDATA_KEY_STATE =            @"state";
const NSString *NMDATA_KEY_REQUESTSIZE =      @"reqs";
const NSString *NMDATA_KEY_REDIRECTIP =       @"rip";
const NSString *NMDATA_KEY_ORIGINALIP =       @"oip";
const NSString *NMDATA_KEY_REDIRECTURL =      @"rurl";
const NSString *NMDATA_KEY_ORIGINALURL =      @"ourl";
const NSString *NMDATA_KEY_APN =              @"apn";
const NSString *NMDATA_KEY_NETSTRENGTH =      @"ns";
const NSString *NMDATA_KEY_TOTALTIME =        @"ttt";
const NSString *NMDATA_KEY_ENDRESPONSE =      @"eres";
const NSString *NMDATA_KEY_RECEIVETIME =      @"rcvt";
const NSString *NMDATA_KEY_WAITTIME =         @"wtt";
const NSString *NMDATA_KEY_SENDTIME =         @"sdt";
const NSString *NMDATA_KEY_CONNTIME =         @"cnnt";
const NSString *NMDATA_KEY_SSLTIME =          @"sslt";
const NSString *NMDATA_KEY_DNSTIME =          @"dnst";
const NSString *NMDATA_KEY_STARTREQUEST =     @"sreq";
const NSString *NMDATA_KEY_CONTENTTYPE =      @"cty";
const NSString *NMDATA_KEY_RESPONSESIZE =     @"ress";
const NSString *NMDATA_KEY_ERRORDETAIL =      @"ed";

const NSString *NMDATA_KEY_REQUESTSIZE_HEAD = @"reqs_head";
const NSString *NMDATA_KEY_REQUESTSIZE_BODY = @"reqs_body";

@interface NMCache()

@property (nonatomic, strong)NSMutableDictionary *cache;
@property (nonatomic, strong)NSMutableDictionary *dataCache;
@property (nonatomic, strong)NSMutableDictionary *downloadCache;
@property (nonatomic, strong)NSMutableDictionary *uploadCache;
@property (nonatomic, strong)NMDataDAO *dao;

@end

@implementation NMCache


+ (instancetype)sharedNMCache {
    static NMCache *nmCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!nmCache) {
            nmCache = [[NMCache alloc] init];
        }
    });
    return nmCache;
}

- (void)cacheValue:(NSString *)value key:(NSString *)key traceId:(NSString *)traceId {
    if (!value || !key || !traceId) {
        return;
    }
    @synchronized (self) {
        NMDataModel *model = self.cache[traceId];
        if (!model) {
            model = [[NMDataModel alloc] init];
            model.ti = traceId;
            model.ns = [NMUtil getNetWorkInfo];
            model.apn = [NMUtil getDetailApCode];
            [self.cache setObject:model forKey:traceId];
        }
        if ([key isEqualToString:(NSString *)NMDATA_KEY_REQUESTSIZE_HEAD]) {
            [model setRequestHeaderSize:value];
        } else if ([key isEqualToString:(NSString *)NMDATA_KEY_REQUESTSIZE_BODY]) {
            [model setRequestBodySize:value];
        } else {
            [model setValue:value forKey:key];
        }
    }
}

- (int)cacheExtension:(NSDictionary *)ext traceId:(NSString *)traceId {
    if (!ext || !traceId) {
        return 1;
    }
    @synchronized (self) {
        NMDataModel *model = self.cache[traceId];
        int tag = 1;
        if (!model) {
            tag = 0;
            model = [[NMDataModel alloc] init];
            model.ti = traceId;
            model.ns = [NMUtil getNetWorkInfo];
            model.apn = [NMUtil getDetailApCode];
            [self.cache setObject:model forKey:traceId];
        }
        if (model.extension) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:model.extension];
            [dic addEntriesFromDictionary:ext];
            model.extension = dic;
        } else {
            model.extension = ext;
        }
        return tag;
    }
}

- (void)persistData:(NSString *)traceId {
    if (!traceId) {
        return;
    }
    NMDataModel *model = self.cache[traceId];
    if (!model.ttt && model.sreq && model.eres) {
        model.ttt = [NSString stringWithFormat:@"%lld", [model.eres longLongValue] - [model.sreq longLongValue]];
    }
    //判断是否为NSURLConnection delegate记录的时间点
//    if ([model.wtt longLongValue] > 10000) {
//        model.rcvt = [NSString stringWithFormat:@"%lld", [model.eres longLongValue] - [model.wtt longLongValue]];
//        model.wtt = [NSString stringWithFormat:@"%lld", [model.wtt longLongValue] - [model.sreq longLongValue]];
//    }
    //如果设置了block，则直接通过block回调
    if ([NMManager sharedNMManager].outputBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NMManager sharedNMManager].outputBlock(traceId, [model toDictionary]);
            EELog(@"%@", [model toDictionary]);
            [self.cache removeObjectForKey:traceId];
        });
        return;
    }
    
    @synchronized (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.dao insertOrModify:model] == 0) {
                [self.cache removeObjectForKey:traceId];
                EELog(@"%@", [model toDictionary]);
            }
        });
    }
}

- (id)getAllData {
    return [self.dao findAll];
}

- (void)removeAllData {
    [self.dao removeAll];
}

- (NSMutableDictionary *)cache {
    if (!_cache) {
        _cache = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _cache;
}

- (NMDataDAO *)dao {
    if (!_dao) {
        _dao = [NMDataDAO share];
    }
    return _dao;
}

- (void)appendData:(NSData *)data byTraceId:(NSString *)traceId {
    if (!traceId) {
        return;
    }
    NSMutableData *oriData = self.dataCache[traceId];
    if (oriData) {
        [oriData appendData:data];
    } else {
        [self.dataCache setValue:[NSMutableData dataWithData:data] forKey:traceId];
    }
}

- (void)removeDataByTraceId:(NSString *)traceId {
    if (traceId) {
        [self.dataCache removeObjectForKey:traceId];
    }
}

- (NSData *)getDataByTraceId:(NSString *)traceId {
    return self.dataCache[traceId];
}

- (NSMutableDictionary *)dataCache {
    if (!_dataCache) {
        _dataCache = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _dataCache;
}

- (void)cacheNum:(NSNumber *)num byTraceId:(NSString *)traceId  type:(CacheDataType)type {
    if (!traceId) {
        return;
    }
    if (type == CacheDataTypeUpload) {
        [self.uploadCache setValue:num forKey:traceId];
    } else if (type == CacheDataTypeDownload) {
        [self.downloadCache setValue:num forKey:traceId];
    } else {
    }
}

- (void)removeNumByTraceId:(NSString *)traceId type:(CacheDataType)type {
    if (!traceId) {
        return;
    }
    if (type == CacheDataTypeUpload) {
        [self.uploadCache removeObjectForKey:traceId];
    } else if (type == CacheDataTypeDownload) {
        [self.downloadCache removeObjectForKey:traceId];
    } else {
    }
}

- (NSNumber *)getNumByTraceId:(NSString *)traceId type:(CacheDataType)type {
    if (type == CacheDataTypeUpload) {
        return self.uploadCache[traceId];
    } else if (type == CacheDataTypeDownload) {
        return self.downloadCache[traceId];
    } else {
        return nil;
    }
}

- (NSMutableDictionary *)downloadCache {
    if (!_downloadCache) {
        _downloadCache = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _downloadCache;
}

- (NSMutableDictionary *)uploadCache {
    if (!_uploadCache) {
        _uploadCache = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _uploadCache;
}

@end
