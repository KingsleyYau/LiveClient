//
//  LoadingView.m
//  Cartoon
//
//  Created by Max on 2021/5/7.
//

#import "LoadingView.h"

@implementation LoadingView

+ (instancetype)view {
    LoadingView *view = [[LoadingView alloc] init];
    view = [[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:nil options:nil].firstObject;
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
