//
//  NMDATA+CoreDataProperties.m
//  
//
//  Created by frog78 on 2018/5/10.
//
//

#import "NMData+CoreDataProperties.h"

@implementation NMData (CoreDataProperties)

+ (NSFetchRequest<NMData *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"NMData"];
}

@dynamic extension;
@dynamic ti;
@dynamic ec;
@dynamic etp;
@dynamic sc;
@dynamic state;
@dynamic reqs;
@dynamic rip;
@dynamic oip;
@dynamic rurl;
@dynamic ourl;
@dynamic cmd;
@dynamic apn;
@dynamic ns;
@dynamic rdsize;
@dynamic dsize;
@dynamic osize;
@dynamic dmd5;
@dynamic omd5;
@dynamic ttt;
@dynamic eres;
@dynamic rcvt;
@dynamic wtt;
@dynamic sdt;
@dynamic cnnt;
@dynamic sslt;
@dynamic dnst;
@dynamic sreq;
@dynamic ddata;
@dynamic cty;
@dynamic ress;
@dynamic ed;

@end
