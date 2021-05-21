//
//  StreamTitleView.m
//  RtmpClientTest
//
//  Created by Max on 2020/11/17.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "StreamTitleView.h"

@implementation StreamTitleView

+ (instancetype)view {
    StreamTitleView *view = [[StreamTitleView alloc] init];
    view = [[NSBundle mainBundle] loadNibNamed:@"StreamTitleView" owner:nil options:nil].firstObject;
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
