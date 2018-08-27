//
//  NMModelCommon.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NMModelCommon : NSObject

/**
 把模型转为字典方法

 @return 返回模型转字典结果
 */
- (NSDictionary *)toDictionary;

/**
 获取所有的属性key

 @return 返回所有的属性key数组
 */
//- (NSArray *)getAllKeys;

/**
 字典转化为模型

 @param dic 字典
 @return 返回模型
 */
+ (NMModelCommon *)toModel:(NSDictionary *)dic;


@end
