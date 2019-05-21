//
//  LSSayHiChooseView.m
//  livestream
//
//  Created by Calvin on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiChooseView.h"
#import "LSShadowView.h"
@interface LSSayHiChooseView ()

@end

@implementation LSSayHiChooseView

- (instancetype)init {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiChooseView" owner:self options:0].firstObject;
    }
    return self;
}

- (void)setIsSelectedUnread:(BOOL)isSelectedUnread {
    if (isSelectedUnread) {
        self.unreadBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0xECEEF1);
        self.lastBtn.backgroundColor = [UIColor whiteColor];
    } else {
        self.unreadBtn.backgroundColor = [UIColor whiteColor];
        self.lastBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0xECEEF1);
    }
    _isSelectedUnread = isSelectedUnread;
}

- (IBAction)unreadBtnDid:(UIButton *)sender {
    self.isSelectedUnread = YES;
    if ([self.delegate respondsToSelector:@selector(sayHiChooseViewSelected:)]) {
        [self.delegate sayHiChooseViewSelected:self.isSelectedUnread];
    }
}

- (IBAction)lastBtnDid:(UIButton *)sender {
    self.isSelectedUnread = NO;
    if ([self.delegate respondsToSelector:@selector(sayHiChooseViewSelected:)]) {
        [self.delegate sayHiChooseViewSelected:self.isSelectedUnread];
    }
}

@end
