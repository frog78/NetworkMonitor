//
//  NMDATADAO.h
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "BaseDAO.h"
#import "NMDataModel.h"
#import "NMData+CoreDataProperties.h"

@interface NMDataDAO : BaseDAO

/**
 获取单例

 @return 返回单例方法
 */
+ (instancetype)share;

/**
 查询所有数据

 @return 返回所有查询结果
 */
- (NSMutableArray *)findAll;

/**
 根据traceId查询单条记录

 @param traceId 单条记录唯一id
 @return 返回单条的数据记录
 */
- (NMDataModel *)findById:(NSString *)traceId;

/**
 根据traceId删除单条记录

 @param traceId 单条记录唯一id
 @return 返回0删除成功，1删除失败
 */
- (int)removeById:(NSString *)traceId;

/**
 插入一条数据记录

 @param model 数据记录模型
 @return 返回0插入成功，1插入失败
 */
- (int)insert:(NMDataModel *)model;

/**
 修改一条数据记录

 @abstract 如果数据库里已经存在该条记录，则修改；否则插入
 @param model 数据记录模型
 @return 返回0修改成功，1修改失败
 */
- (int)modify:(NMDataModel *)model;

/**
 插入或者修改一条数据记录

 @param model 数据记录模型
 @return 返回0成功，1失败
 */
- (int)insertOrModify:(NMDataModel *)model;

/**
 删除全部缓存数据

 @return 返回0删除成功，1删除失败
 */
- (int)removeAll;

@end
