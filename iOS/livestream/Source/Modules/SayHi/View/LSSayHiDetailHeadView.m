//
//  LSSayHiDetailHeadView.m
//  livestream
//
//  Created by Calvin on 2019/4/18.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiDetailHeadView.h"

@interface LSSayHiDetailHeadView ()

@end

@implementation LSSayHiDetailHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiDetailHeadView" owner:self options:0].firstObject;
        
        self.frame = frame;
    }
    return self;
}

- (IBAction)sortBtnDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(sayHiDetailHeadViewDidSortBtn)]) {
        [self.delegate sayHiDetailHeadViewDidSortBtn];
    }
}

- (IBAction)noteBtnDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(sayHiDetailHeadViewDidNoteBtn)]) {
        [self.delegate sayHiDetailHeadViewDidNoteBtn];
    }
}

@end
