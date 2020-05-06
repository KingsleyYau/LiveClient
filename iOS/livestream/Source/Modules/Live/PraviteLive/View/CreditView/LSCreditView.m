//
//  LSCreditViewView.m
//  livestream
//
//  Created by Calvin on 2019/9/6.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSCreditView.h"
#import "LSShadowView.h"
#import "LiveGobalManager.h"
@interface LSCreditView ()

@end

@implementation LSCreditView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"LSCreditView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}


+ (instancetype)initLSCreditView {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSCreditView" owner:nil options:nil];
    LSCreditView *view = [nibs objectAtIndex:0];

    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.layer.cornerRadius = 4;
    self.contentView.layer.masksToBounds = YES;
    
    self.addBtn.layer.cornerRadius = 6;
    self.addBtn.layer.masksToBounds = YES;
    
    LSShadowView * view = [[LSShadowView alloc]init];
    [view showShadowAddView:self.addBtn];
}

- (IBAction)tapBG:(UITapGestureRecognizer *)sender {
//    self.hidden = YES;
    [self removeShowCreditView];
}

- (IBAction)addBtnDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(creditViewDidAddCredit)]) {
        [self.delegate creditViewDidAddCredit];
    }
//    self.hidden = YES;
    [self removeShowCreditView];
}

- (IBAction)closeBtnDid:(UIButton *)sender {
//    self.hidden = YES;
    [self removeShowCreditView];
}


- (void)showLSCreditViewInView:(UIView *)view {
    [[LiveGobalManager manager] showPopupView:self withVc:nil];
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.leading.trailing.equalTo(view);
        }];

    }

}

- (void)removeShowCreditView {
    [self removeFromSuperview];
    [[LiveGobalManager manager] removeLiveRoomPopup];
}
@end
