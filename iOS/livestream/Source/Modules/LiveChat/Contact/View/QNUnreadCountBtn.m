//
//  UnreadCountBtn.m
//
//
//  Created by test on 2018/11/22.
//

#import "QNUnreadCountBtn.h"



@implementation QNUnreadCountBtn

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"QNUnreadCountBtn" owner:self options:nil].firstObject;
        self.frame = frame;
        self.unreadCountTips.layer.cornerRadius = self.unreadCountTips.frame.size.height/2.0;
        self.unreadCountTips.layer.masksToBounds = YES;
        self.userInteractionEnabled = YES;
        self.noNumUnreadTips.layer.cornerRadius = self.noNumUnreadTips.frame.size.height/2.0;
        self.noNumUnreadTips.layer.masksToBounds = YES;
        self.unreadCountTips.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUnreadCount)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}


- (void)tapUnreadCount {
    if ([self.delegate respondsToSelector:@selector(unreadCountBtnDidTap:)]) {
        [self.delegate unreadCountBtnDidTap:self];
    }
}


- (void)updateUnreadCount:(NSString *)count
{
    if ([count intValue] == 0) {
        _unreadCountTips.hidden = YES;
        _noNumUnreadTips.hidden = YES;
    }else if ([count intValue] < 0){
        _unreadCountTips.hidden = YES;
        _noNumUnreadTips.hidden = NO;
    }
    else
    {
        _unreadCountTips.hidden = NO;
        if ([count intValue] >= 10) {
            _unreadLabelWidth.constant = 20;
        }else {
            _unreadLabelWidth.constant = 13;
        }
        if ([count intValue] > 99) {
            _unreadCountTips.text = @"99+";
            _unreadLabelWidth.constant = 28;
        }
        else
        {
            _unreadCountTips.text = count;
        }
    }
}
@end

