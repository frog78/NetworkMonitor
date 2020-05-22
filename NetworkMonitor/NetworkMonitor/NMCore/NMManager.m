//
//  NMManager.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NMManager.h"
#import "NSURLSession+NM.h"
#import "NSURLConnection+NM.h"
#import "NMCache.h"

@interface NMManager()

@property (nonatomic, strong) NMConfig *NMConfig;

@end

@implementation NMManager

+ (instancetype)sharedNMManager {
    static NMManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NMManager alloc] init];
    });
    return manager;
}


- (void)initConfig:(NMConfig *)config {
    self.NMConfig = config;
}


- (void)start {
    if (self.NMConfig.enableNetworkMonitor && ![NMUtil isNetworkMonitorOn]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSURLSession hook];
            [NSURLConnection hook];
        });
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_NetworkMonitor_ON];
    }
}


- (void)stop {
    if (self.NMConfig.enableNetworkMonitor && [NMUtil isNetworkMonitorOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_NetworkMonitor_ON];
    }
}


- (NMConfig *)getConfig {
    return _NMConfig;
}

- (void)setExtendedParameter:(NSDictionary *)params traceId:(NSString *)traceId {
    if (_NMConfig.enableInterferenceMode) {
        [[NMCache sharedNMCache] cacheExtension:params traceId:traceId];
    }
}

- (void)finishColection:(NSString *)traceId {
    if (_NMConfig.enableInterferenceMode) {
        [[NMCache sharedNMCache] persistData:traceId];
    }
}

- (NSArray *)getAllData {
    return [[NMCache sharedNMCache] getAllData];
}

- (void)removeAllData {
    [[NMCache sharedNMCache] removeAllData];
}


@end
