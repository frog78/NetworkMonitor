//
//  NMModelCommon.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NMModelCommon.h"
#import <objc/runtime.h>

@implementation NMModelCommon

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    // 获取当前类的所有属性
    unsigned int count;// 记录属性个数
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        // objc_property_t 属性类型
        objc_property_t property = properties[i];
        // 获取属性的名称 C语言字符串
        const char *cName = property_getName(property);
        // 转换为Objective C 字符串
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:name];
        
        if (value) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                [dic addEntriesFromDictionary:value];
            } else {
                [dic setValue:value forKey:name];
            }
        }
    }
    free(properties);
    return dic;
}

+ (NMModelCommon *)toModel:(NSDictionary *)dic {
    
    NMModelCommon *model = [[[self class] alloc] init];
    // 获取当前类的所有属性
    unsigned int count;// 记录属性个数
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        // objc_property_t 属性类型
        objc_property_t property = properties[i];
        // 获取属性的名称 C语言字符串
        const char *cName = property_getName(property);
        // 转换为Objective C 字符串
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        
        id value = dic[name];
        
        if (value) {
            [model setValue:value forKey:name];
        }
    }
    free(properties);
    return model;
}

@end
