//
//  NMDATAModel.m
//  NetworkMonitor
//
//  Created by frog78 on 2018/4/24.
//  Copyright © 2018年 frog78. All rights reserved.
//

#import "NMDataModel.h"

@interface NMDataModel() {
    NSString * _headerSize;
    NSString * _bodySize;
}

@end

@implementation NMDataModel

- (void)setCnnt:(NSString *)cnnt {
    if (!_cnnt) {
        _cnnt = cnnt;
    }
}

- (void)setSreq:(NSString *)sreq {
    if (!_sreq) {
        _sreq = sreq;
    }
}

- (void)setDnst:(NSString *)dnst {
    if (!_dnst) {
        _dnst = dnst;
    }
}

- (void)setSslt:(NSString *)sslt {
    if (!_sslt) {
        _sslt = sslt;
    }
}

- (void)setSdt:(NSString *)sdt {
    if (!_sdt) {
        _sdt = sdt;
    }
}

- (void)setWtt:(NSString *)wtt {
    if (!_wtt) {
        _wtt = wtt;
    }
}

- (void)setRcvt:(NSString *)rcvt {
    if (!_rcvt) {
        _rcvt = rcvt;
    }
}

- (void)setEres:(NSString *)eres {
    if (!_eres) {
        _eres = eres;
    }
}

- (void)setTtt:(NSString *)ttt {
    if (!_ttt) {
        _ttt = ttt;
    }
}

- (void)setOurl:(NSString *)ourl {
    if (!_ourl) {
        _ourl = ourl;
    }
}

- (void)setOip:(NSString *)oip {
    if (!_oip) {
        _oip = oip;
    }
}

- (NSString *)reqs {
    return [NSString stringWithFormat:@"%lld", [_bodySize longLongValue] + [_headerSize longLongValue]];
}
//- (void)setReqs:(NSString *)reqs {
//    if (!_reqs) {
//        _reqs = reqs;
//    } else {
//        _reqs = [NSString stringWithFormat:@"%lld", [reqs longLongValue] + [_reqs longLongValue]];
//    }
//}

- (void)setState:(NSString *)state {
    if (!_state) {
        _state = state;
    }
}

- (void)setSc:(NSString *)sc {
    if (!_sc) {
        _sc = sc;
    }
}

- (void)setEtp:(NSString *)etp {
    if (!_etp) {
        _etp = etp;
    }
}

- (void)setEc:(NSString *)ec {
    if (!_ec) {
        _ec = ec;
    }
}

- (void)setEd:(NSString *)ed {
    if (!_ed) {
        _ed = ed;
    }
}

- (void)setCty:(NSString *)cty {
    if (!_cty) {
        _cty = cty;
    }
}

- (void)setDdata:(NSString *)ddata {
    if (!_ddata) {
        _ddata = ddata;
    }
}

- (void)setRess:(NSString *)ress {
    if (!_ress) {
        _ress = ress;
    } else {
        _ress = [NSString stringWithFormat:@"%lld", [ress longLongValue] + [_ress longLongValue]];
    }
}

- (void)setRequestHeaderSize:(NSString *)size {
    _headerSize = size;
}

- (void)setRequestBodySize:(NSString *)size {
    _bodySize = size;
}



@end
