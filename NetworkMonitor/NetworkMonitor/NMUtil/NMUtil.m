//
//  NMUtil.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NMUtil.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#include <CommonCrypto/CommonDigest.h>
#import <CoreTelephony/CTCarrier.h>
#import <UIKit/UIKit.h>
#import <sys/socket.h>
#import "arpa/inet.h"
#import "netdb.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define HEAD_KEYS @"head_keys_"

typedef enum _CARRIER_AP_TYPE
{
    CARRIER_AP_TYPE_CMNET,		// cmnet
    CARRIER_AP_TYPE_UNINET,		// uninet
    CARRIER_AP_TYPE_CTNET,		// ctnet
    CARRIER_AP_TYPE_MAX
} CARRIER_AP_TYPE;

const NSString *const reCrasher_CarrierApTypeStr[] =
{
    @"cmnet",
    @"uninet",
    @"ctnet",
    @"wifi"
};


@implementation NMUtil

+ (NSString *)getTraceId {
    
    NSString *traceId;
    
    CFUUIDRef ptraceId = CFUUIDCreate( nil );
    
    CFStringRef traceIdString = CFUUIDCreateString( nil, ptraceId );
    
    traceId = [NSString stringWithFormat:@"%@", traceIdString];
    
    CFRelease(ptraceId);
    
    CFRelease(traceIdString);
    
    return traceId;
}

+ (BOOL)isNetworkMonitorOn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:IS_NetworkMonitor_ON];
}

+ (BOOL)isInterferenceMode {
    return [[NMManager sharedNMManager] getConfig].enableInterferenceMode;
}

+ (NSString *)getNetWorkInfo {
    NSString *strNetworkInfo = @"none";
    struct sockaddr_storage zeroAddress;
    bzero(&zeroAddress,sizeof(zeroAddress));
    zeroAddress.ss_len = sizeof(zeroAddress);
    zeroAddress.ss_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL,(struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability,&flags);
    CFRelease(defaultRouteReachability);
    //如果不能获取连接标志，则不能连接网络，直接返回
    if(!didRetrieveFlags){
        return strNetworkInfo;
    }
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable)!=0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired)!=0);
    if(!isReachable || needsConnection) {
        return strNetworkInfo;
    }// 网络类型判断
    if((flags & kSCNetworkReachabilityFlagsConnectionRequired)== 0) {
        strNetworkInfo = @"wifi";
    }
    if(((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0) {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            strNetworkInfo = @"wifi";
        }
    }
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) ==kSCNetworkReachabilityFlagsIsWWAN) {
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
            CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
            if (currentRadioAccessTechnology) {
                if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                    strNetworkInfo = @"4G";
                } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                    strNetworkInfo = @"2G";
                } else {
                    strNetworkInfo = @"3G";
                }
            }
        } else {
            if((flags & kSCNetworkReachabilityFlagsReachable) == kSCNetworkReachabilityFlagsReachable) {
                if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection) {
                    if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired) {
                        strNetworkInfo = @"2G";
                    } else {
                        strNetworkInfo = @"3G";
                    }
                }
            }
        }
    }
    return strNetworkInfo;
}

+ (NSString *)getSignalStrength {
    UIApplication *app = [UIApplication sharedApplication];
    if ([[app valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        return @"unknow";
    }
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    UIView *dataNetworkItemView = nil;
    
    for (UIView * subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    int signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
    return [NSString stringWithFormat:@"signal %d", signalStrength];
}

+ (NSString *)getIPByDomain:(const NSString *)domain {
    Boolean result = NO;
    CFHostRef hostRef;
    CFArrayRef addresses = NULL;
    NSString *_ip = @"";
    const char *str =[domain UTF8String];
    CFStringRef hostNameRef = CFStringCreateWithCString(kCFAllocatorDefault, str, kCFStringEncodingASCII);
    hostRef = CFHostCreateWithName(kCFAllocatorDefault, hostNameRef);
    if (hostRef) {
        result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
        if (result) {
            addresses = CFHostGetAddressing(hostRef, &result);
        }
    }
    if(result) {
        struct sockaddr_in* remoteAddr;
        for(int i = 0; i < CFArrayGetCount(addresses); i++) {
            CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex(addresses, i);
            remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);
            if(remoteAddr != NULL) {
                char ip[16];
                strcpy(ip, inet_ntoa(remoteAddr->sin_addr));
                _ip = [NSString stringWithUTF8String:ip];
            }
        }
    } else {
        EELog(@"本地获取域名IP失败");
    }
    if (hostNameRef) {
        CFRelease(hostNameRef);
    }
    if (hostRef) {
        CFRelease(hostRef);
    }
    return _ip;
}

+ (BOOL)isDomain:(NSString *)domain {
    NSString *regex = @"^(?=^.{3,255}$)[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:domain];
}

+ (NSDictionary *)extractParamsFromHeader:(NSDictionary *)headerField {
    NSMutableDictionary *header = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSString *field in headerField.allKeys) {
        if ([field containsString:HEAD_KEYS]) {
            [header setObject:headerField[field] forKey:[field stringByReplacingOccurrencesOfString:HEAD_KEYS withString:@""]];
        }
    }
    return header;
}

+ (NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSDictionary *attri = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:error];
    return (NSNumber *)attri[NSFileSize];
}

+ (NSString *)getCurrentTime {
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970;
    return [NSString stringWithFormat:@"%.f", time * 1000];
}

+ (NSMutableURLRequest *)mutableRequest:(NSURLRequest *)request {
    if ([request isKindOfClass:[NSMutableURLRequest class]]) {
        return (NSMutableURLRequest *)request;
    } else {
        return [request mutableCopy];
    }
}

+ (NSString *)getDetailApCode {
    if ([[[self class] getNetWorkInfo] isEqualToString:@"wifi"]) {
        return @"wifi";
    }
    static NSString *apCode;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *carrierName = [[self class] getCarrierName];
        apCode = [[self class] getApTypeStrByCarrierName:carrierName];
    });
    return apCode;
}

+ (NSString *)getCarrierName {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    return carrier.carrierName;
}

+ (CARRIER_AP_TYPE)getApTypeByCarrierName:(NSString *)carrierName {
    if (!carrierName) {
        return CARRIER_AP_TYPE_MAX;
    }
    
    if ([carrierName isEqualToString:@"中国移动"]) {
        return CARRIER_AP_TYPE_CMNET;
    }
    else if([carrierName isEqualToString:@"中国联通"]) {
        return CARRIER_AP_TYPE_UNINET;
    }
    else if([carrierName isEqualToString:@"中国电信"]) {
        return CARRIER_AP_TYPE_CTNET;
    }
    else {
        return CARRIER_AP_TYPE_MAX;
    }
}

+ (NSString *)getApTypeStrByType:(CARRIER_AP_TYPE)type {
    return (NSString *)reCrasher_CarrierApTypeStr[(int)type];
}

+ (NSString *)getApTypeStrByCarrierName:(NSString *)carrierName {
    return [self getApTypeStrByType:[self getApTypeByCarrierName:carrierName]];
}

+ (BOOL)isAbove_iOS_10_0 {
    static BOOL isAboveiOS_10_0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isAboveiOS_10_0 = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0");
    });
    return isAboveiOS_10_0;
}

+ (NSString *)mimeType:(NSString *)type {
    static NSDictionary *MIME_MapDic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MIME_MapDic = @{
                        //{后缀名，MIME类型}
                        @"3gp":@"video/3gpp",
                        @"apk":@"application/vnd.android.package-archive",
                        @"asf":@"video/x-ms-asf",
                        @"avi":@"video/x-msvideo",
                        @"bin":@"application/octet-stream",
                        @"bmp":@"image/bmp",
                        @"c":@"text/plain",
                        @"class":@"application/octet-stream",
                        @"conf":@"text/plain",
                        @"cpp":@"text/plain",
                        @"doc":@"application/msword",
                        @"docx":@"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                        @"xls":@"application/vnd.ms-excel",
                        @"xlsx":@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                        @"exe":@"application/octet-stream",
                        @"gif":@"image/gif",
                        @"gtar":@"application/x-gtar",
                        @"gz":@"application/x-gzip",
                        @"h":@"text/plain",
                        @"htm":@"text/html",
                        @"html":@"text/html",
                        @"jar":@"application/java-archive",
                        @"java":@"text/plain",
                        @"jpeg":@"image/jpeg",
                        @"jpg":@"image/jpeg",
                        @"js":@"application/x-javascript",
                        @"log":@"text/plain",
                        @"m3u":@"audio/x-mpegurl",
                        @"m4a":@"audio/mp4a-latm",
                        @"m4b":@"audio/mp4a-latm",
                        @"m4p":@"audio/mp4a-latm",
                        @"m4u":@"video/vnd.mpegurl",
                        @"m4v":@"video/x-m4v",
                        @"mov":@"video/quicktime",
                        @"mp2":@"audio/x-mpeg",
                        @"mp3":@"audio/x-mpeg",
                        @"mp4":@"video/mp4",
                        @"mpc":@"application/vnd.mpohun.certificate",
                        @"mpe":@"video/mpeg",
                        @"mpeg":@"video/mpeg",
                        @"mpg":@"video/mpeg",
                        @"mpg4":@"video/mp4",
                        @"mpga":@"audio/mpeg",
                        @"msg":@"application/vnd.ms-outlook",
                        @"ogg":@"audio/ogg",
                        @"pdf":@"application/pdf",
                        @"png":@"image/png",
                        @"pps":@"application/vnd.ms-powerpoint",
                        @"ppt":@"application/vnd.ms-powerpoint",
                        @"pptx":@"application/vnd.openxmlformats-officedocument.presentationml.presentation",
                        @"prop":@"text/plain",
                        @"rc":@"text/plain",
                        @"rmvb":@"audio/x-pn-realaudio",
                        @"rtf":@"application/rtf",
                        @"sh":@"text/plain",
                        @"tar":@"application/x-tar",
                        @"tgz":@"application/x-compressed",
                        @"txt":@"text/plain",
                        @"wav":@"audio/x-wav",
                        @"wma":@"audio/x-ms-wma",
                        @"wmv":@"audio/x-ms-wmv",
                        @"wps":@"application/vnd.ms-works",
                        @"xml":@"text/plain",
                        @"z":@"application/x-compress",
                        @"zip":@"application/zip",
                        @"":@"*/*"
                        };
    });
    return MIME_MapDic[type];
}

@end
