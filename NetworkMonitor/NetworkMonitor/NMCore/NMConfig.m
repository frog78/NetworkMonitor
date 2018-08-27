//
//  NMConfig.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NMConfig.h"


@implementation NMConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.enableLog = YES;
        self.enableNetworkMonitor = NO;
        self.enableInterferenceMode = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_NetworkMonitor_ON];
    }
    return self;
}

- (void)setUrlWhiteList:(NSArray *)urlWhiteList {
    if (!urlWhiteList) {
        return;
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for (NSString *urlStr in urlWhiteList) {
        if ([NSURL URLWithString:urlStr].host) {
            [array addObject:urlStr];
        }
    }
    _urlWhiteList = array;
}


@end
