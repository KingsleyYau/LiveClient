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

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiChooseView" owner:self options:0].firstObject;
        
        self.chooseBGView.layer.cornerRadius = 5;
        self.chooseBGView.layer.masksToBounds = YES;
        
        LSShadowView * shadowView = [[LSShadowView alloc]init];
        [shadowView showShadowAddView:self.chooseBGView];
        
        self.frame = frame;
    }
    return self;
}

- (instancetype)initArrowDirectionIsUp:(BOOL)isUp {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiChooseView" owner:self options:0].firstObject;
        
        self.chooseBGView.layer.cornerRadius = 5;
        self.chooseBGView.layer.masksToBounds = YES;
        
        LSShadowView * shadowView = [[LSShadowView alloc]init];
        [shadowView showShadowAddView:self.chooseBGView];
        
        CGRect rect = self.chooseBGView.frame;
        rect.origin.y = isUp?13:0;
        self.chooseBGView.frame = rect;
    }
    return self;
}

- (void)setIsSelectedUnread:(BOOL)isSelectedUnread {
    if (isSelectedUnread) {
        self.unreadBtn.backgroundColor = [UIColor lightGrayColor];
        self.lastBtn.backgroundColor = [UIColor whiteColor];
        self.selectedUnread.hidden = NO;
        self.selectedLast.hidden = YES;
    }else {
        self.unreadBtn.backgroundColor = [UIColor whiteColor];
        self.lastBtn.backgroundColor = [UIColor lightGrayColor];
        self.selectedUnread.hidden = YES;
        self.selectedLast.hidden = NO;
    }
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
