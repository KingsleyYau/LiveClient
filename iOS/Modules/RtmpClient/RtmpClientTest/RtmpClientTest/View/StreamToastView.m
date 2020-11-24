//
//  StreamToastView.m
//  RtmpClientTest
//
//  Created by Max on 2020/11/17.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "StreamToastView.h"

@implementation StreamToastView

+ (instancetype)view {
    StreamToastView *view = [[StreamToastView alloc] init];
    view = [[NSBundle mainBundle] loadNibNamed:@"StreamToastView" owner:nil options:nil].firstObject;
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 10;
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
