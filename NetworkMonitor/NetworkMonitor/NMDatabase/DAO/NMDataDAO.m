//
//  NMDATADAO.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NMDataDAO.h"

#define ENTITY_NAME @"NMData"

@implementation NMDataDAO

+ (instancetype)share {
    static NMDataDAO *_dataIPDAO = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _dataIPDAO = [[self alloc] init];
    });
    return _dataIPDAO;
}

- (NSMutableArray *)findAll {
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (listData == nil || listData.count == 0) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for (NMData *nmData in listData) {
        NMDataModel *model = [[NMDataModel alloc] init];
        model.ti = nmData.ti;
        model.apn = nmData.apn;
        model.ns = nmData.ns;
        model.ec = nmData.ec;
        model.etp = nmData.etp;
        model.sc = nmData.sc;
        model.state = nmData.state;
        model.reqs = nmData.reqs;
        model.rip = nmData.rip;
        model.oip = nmData.oip;
        model.rurl = nmData.rurl;
        model.ourl = nmData.ourl;
        model.cmd = nmData.cmd;
        model.rdsize = nmData.rdsize;
        model.dsize = nmData.dsize;
        model.osize = nmData.osize;
        model.dmd5 = nmData.dmd5;
        model.omd5 = nmData.omd5;
        model.ttt = nmData.ttt;
        model.eres = nmData.eres;
        model.rcvt = nmData.rcvt;
        model.wtt = nmData.wtt;
        model.sdt = nmData.sdt;
        model.cnnt = nmData.cnnt;
        model.sslt = nmData.sslt;
        model.dnst = nmData.dnst;
        model.sreq = nmData.sreq;
        model.ddata = nmData.ddata;
        model.cty = nmData.cty;
        model.ress = nmData.ress;
        model.ed = nmData.ed;
        NSDictionary *extension = (NSDictionary *)nmData.extension;
        model.extension = extension;
        [array addObject:[model toDictionary]];
    }
    return array;
}

- (NMDataModel *)findById:(NSString *)traceId {
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ti = %@", traceId];
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (listData == nil || listData.count == 0) {
        return nil;
    }
    NMData *NMDATA = [listData lastObject];
    NMDataModel *model = [[NMDataModel alloc] init];
    model.ti = NMDATA.ti;
    model.apn = NMDATA.apn;
    model.ns = NMDATA.ns;
    model.ec = NMDATA.ec;
    model.etp = NMDATA.etp;
    model.sc = NMDATA.sc;
    model.state = NMDATA.state;
    model.reqs = NMDATA.reqs;
    model.rip = NMDATA.rip;
    model.oip = NMDATA.oip;
    model.rurl = NMDATA.rurl;
    model.ourl = NMDATA.ourl;
    model.cmd = NMDATA.cmd;
    model.rdsize = NMDATA.rdsize;
    model.dsize = NMDATA.dsize;
    model.osize = NMDATA.osize;
    model.dmd5 = NMDATA.dmd5;
    model.omd5 = NMDATA.omd5;
    model.ttt = NMDATA.ttt;
    model.eres = NMDATA.eres;
    model.rcvt = NMDATA.rcvt;
    model.wtt = NMDATA.wtt;
    model.sdt = NMDATA.sdt;
    model.cnnt = NMDATA.cnnt;
    model.sslt = NMDATA.sslt;
    model.dnst = NMDATA.dnst;
    model.sreq = NMDATA.sreq;
    model.ddata = NMDATA.ddata;
    model.cty = NMDATA.cty;
    model.ress = NMDATA.ress;
    model.ed = NMDATA.ed;
    NSDictionary *extension = (NSDictionary *)NMDATA.extension;
    model.extension = extension;
    return model;
}

- (int)removeById:(NSString *)traceId {
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ti = %@", traceId];
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if ([listData count] > 0) {
        NMData *mo = [listData lastObject];
        [self.context deleteObject:mo];
        if ([self.context hasChanges] && ![self.context save:&error]) {
            EELog(@"删除数据失败:%@", [error description]);
            return -1;
        }
    }
    return 0;
}

- (int)insert:(NMDataModel *)model {
    NMData *NMDATA = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[self managedObjectContext]];

    [NMDATA setValue:model.rurl forKey:@"rurl"];
    [NMDATA setValue:model.oip forKey:@"oip"];
    [NMDATA setValue:model.rip forKey:@"rip"];
    [NMDATA setValue:model.reqs forKey:@"reqs"];
    [NMDATA setValue:model.state forKey:@"state"];
    [NMDATA setValue:model.sc forKey:@"sc"];
    [NMDATA setValue:model.etp forKey:@"etp"];
    [NMDATA setValue:model.ec forKey:@"ec"];
    [NMDATA setValue:model.sdt forKey:@"sdt"];
    [NMDATA setValue:model.wtt forKey:@"wtt"];
    [NMDATA setValue:model.rcvt forKey:@"rcvt"];
    [NMDATA setValue:model.eres forKey:@"eres"];
    [NMDATA setValue:model.ttt forKey:@"ttt"];
    [NMDATA setValue:model.omd5 forKey:@"omd5"];
    [NMDATA setValue:model.dmd5 forKey:@"dmd5"];
    [NMDATA setValue:model.osize forKey:@"osize"];
    [NMDATA setValue:model.dsize forKey:@"dsize"];
    [NMDATA setValue:model.rdsize forKey:@"rdsize"];
    [NMDATA setValue:model.cmd forKey:@"cmd"];
    [NMDATA setValue:model.ourl forKey:@"ourl"];
    [NMDATA setValue:model.ddata forKey:@"ddata"];
    [NMDATA setValue:model.sreq forKey:@"sreq"];
    [NMDATA setValue:model.dnst forKey:@"dnst"];
    [NMDATA setValue:model.sslt forKey:@"sslt"];
    [NMDATA setValue:model.cnnt forKey:@"cnnt"];
    [NMDATA setValue:model.sdt forKey:@"sdt"];
    [NMDATA setValue:model.apn forKey:@"apn"];
    [NMDATA setValue:model.ti forKey:@"ti"];
    [NMDATA setValue:model.ns forKey:@"ns"];
    [NMDATA setValue:model.cty forKey:@"cty"];
    [NMDATA setValue:model.ress forKey:@"ress"];
    [NMDATA setValue:model.ed forKey:@"ed"];
    [NMDATA setValue:model.extension forKey:@"extension"];
    
    NSError *error = nil;
    if ([self.context hasChanges] && ![[self managedObjectContext] save:&error]) {
        EELog(@"插入数据失败:%@", [error description]);
        return -1;
    }
    return 0;
}

- (int)modify:(NMDataModel *)model {
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ti = %@", model.ti];
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if ([listData count] > 0) {
        NMData *NMDATA = [listData lastObject];
        if (model.apn) {
            NMDATA.apn = model.apn;
        }
        if (model.ns) {
            NMDATA.ns = model.ns;
        }
        if (model.rurl) {
            NMDATA.rurl = model.rurl;
        }
        if (model.oip) {
            NMDATA.oip = model.oip;
        }
        if (model.rip) {
            NMDATA.rip = model.rip;
        }
        if (model.reqs) {
            NMDATA.reqs = model.reqs;
        }
        if (model.state) {
            NMDATA.state = model.state;
        }
        if (model.sc) {
            NMDATA.sc = model.sc;
        }
        if (model.etp) {
            NMDATA.etp = model.etp;
        }
        if (model.ec) {
            NMDATA.ec = model.ec;
        }
        if (model.sdt) {
            NMDATA.sdt = model.sdt;
        }
        if (model.wtt) {
            NMDATA.wtt = model.wtt;
        }
        if (model.rcvt) {
            NMDATA.rcvt = model.rcvt;
        }
        if (model.eres) {
            NMDATA.eres = model.eres;
        }
        if (model.ttt) {
            NMDATA.ttt = model.ttt;
        }
        if (model.omd5) {
            NMDATA.omd5 = model.omd5;
        }
        if (model.dmd5) {
            NMDATA.dmd5 = model.dmd5;
        }
        if (model.osize) {
            NMDATA.osize = model.osize;
        }
        if (model.dsize) {
            NMDATA.dsize = model.dsize;
        }
        if (model.rdsize) {
            NMDATA.rdsize = model.rdsize;
        }
        if (model.cmd) {
            NMDATA.cmd = model.cmd;
        }
        if (model.ourl) {
            NMDATA.ourl = model.ourl;
        }
        if (model.ddata) {
            NMDATA.ddata = model.ddata;
        }
        if (model.sreq) {
            NMDATA.sreq = model.sreq;
        }
        if (model.dnst) {
            NMDATA.dnst = model.dnst;
        }
        if (model.sslt) {
            NMDATA.dnst = model.sslt;
        }
        if (model.cnnt) {
            NMDATA.cnnt = model.cnnt;
        }
        if (model.sdt) {
            NMDATA.sdt = model.sdt;
        }
        if (model.cty) {
            NMDATA.cty = model.cty;
        }
        if (model.ress) {
            NMDATA.ress = model.ress;
        }
        if (model.ed) {
            NMDATA.ed = model.ed;
        }
        if (model.extension) {
            NMDATA.extension = model.extension;
        }
        if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
            EELog(@"修改数据失败:%@", [error description]);
            return -1;
        }
    }
    return 0;
}

- (int)insertOrModify:(NMDataModel *)model {
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ti = %@", model.ti];
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (listData.count > 0) {
        return [self modify:model];
    } else {
        return [self insert:model];
    }
}

- (int)removeAll {
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if ([listData count] > 0) {
        for (NMData *NMDATA in listData) {
            [self.context deleteObject:NMDATA];
        }
        if ([self.context hasChanges] && ![self.context save:&error]) {
            EELog(@"删除数据失败:%@", [error description]);
            return -1;
        }
    }
    return 0;
}


@end
