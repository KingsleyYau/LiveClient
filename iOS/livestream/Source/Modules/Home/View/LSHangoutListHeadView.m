//
//  LSHangoutListHeadView.m
//  livestream
//
//  Created by test on 2019/1/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSHangoutListHeadView.h"

@implementation LSHangoutListHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"LSHangoutListHeadView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

}
- (IBAction)clickAction:(id)sender {
    if ([self.hangoutHeadDelegate respondsToSelector:@selector(LSHangoutListHeadViewDidShowMore:)]) {
        [self.hangoutHeadDelegate LSHangoutListHeadViewDidShowMore:self];
    }
}

- (void)selectedChanged:(id)sender {
    UIButton *emotionBtn = (UIButton *)sender;
    if (emotionBtn.selected == YES) {
        // 弹出底部emotion的键盘
        if ([self.hangoutHeadDelegate respondsToSelector:@selector(LSHangoutListHeadViewDidShowMore:)]) {
            [self.hangoutHeadDelegate LSHangoutListHeadViewDidShowMore:self];
        }
        
    } else {
        if ([self.hangoutHeadDelegate respondsToSelector:@selector(LSHangoutListHeadViewDidShowMore:)]) {
            [self.hangoutHeadDelegate LSHangoutListHeadViewDidShowMore:self];
        }
    }
}
@end
