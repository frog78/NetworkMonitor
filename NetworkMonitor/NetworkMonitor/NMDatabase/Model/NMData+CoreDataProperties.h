//
//  NMDATA+CoreDataProperties.h
//  
//
//  Created by frog78 on 2018/5/10.
//
//

#import "NMData+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface NMData (CoreDataProperties)

+ (NSFetchRequest<NMData *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSObject *extension;
@property (nullable, nonatomic, copy) NSString *ti;
@property (nullable, nonatomic, copy) NSString *ec;
@property (nullable, nonatomic, copy) NSString *etp;
@property (nullable, nonatomic, copy) NSString *sc;
@property (nullable, nonatomic, copy) NSString *state;
@property (nullable, nonatomic, copy) NSString *reqs;
@property (nullable, nonatomic, copy) NSString *rip;
@property (nullable, nonatomic, copy) NSString *oip;
@property (nullable, nonatomic, copy) NSString *rurl;
@property (nullable, nonatomic, copy) NSString *ourl;
@property (nullable, nonatomic, copy) NSString *cmd;
@property (nullable, nonatomic, copy) NSString *apn;
@property (nullable, nonatomic, copy) NSString *ns;
@property (nullable, nonatomic, copy) NSString *rdsize;
@property (nullable, nonatomic, copy) NSString *dsize;
@property (nullable, nonatomic, copy) NSString *osize;
@property (nullable, nonatomic, copy) NSString *dmd5;
@property (nullable, nonatomic, copy) NSString *omd5;
@property (nullable, nonatomic, copy) NSString *ttt;
@property (nullable, nonatomic, copy) NSString *eres;
@property (nullable, nonatomic, copy) NSString *rcvt;
@property (nullable, nonatomic, copy) NSString *wtt;
@property (nullable, nonatomic, copy) NSString *sdt;
@property (nullable, nonatomic, copy) NSString *cnnt;
@property (nullable, nonatomic, copy) NSString *sslt;
@property (nullable, nonatomic, copy) NSString *dnst;
@property (nullable, nonatomic, copy) NSString *sreq;
@property (nullable, nonatomic, copy) NSString *ddata;
@property (nullable, nonatomic, copy) NSString *cty;
@property (nullable, nonatomic, copy) NSString *ress;
@property (nullable, nonatomic, copy) NSString *ed;

@end

NS_ASSUME_NONNULL_END
