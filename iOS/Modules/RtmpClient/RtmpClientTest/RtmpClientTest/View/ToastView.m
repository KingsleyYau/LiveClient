//
//  ToastView.m
//  Cartoon
//
//  Created by Max on 2021/5/7.
//

#import "ToastView.h"

@implementation ToastView

+ (instancetype)view {
    ToastView *view = [[ToastView alloc] init];
    view = [[NSBundle mainBundle] loadNibNamed:@"ToastView" owner:nil options:nil].firstObject;
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.layer.cornerRadius = 15;
    self.layer.masksToBounds = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
