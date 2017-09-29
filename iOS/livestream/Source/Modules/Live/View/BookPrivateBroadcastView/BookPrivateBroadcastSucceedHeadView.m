//
//  BookPrivateBroadcastSucceedHeadView.m
//  livestream
//
//  Created by Calvin on 17/9/28.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "BookPrivateBroadcastSucceedHeadView.h"

@interface BookPrivateBroadcastSucceedHeadView ()

@end

@implementation BookPrivateBroadcastSucceedHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[NSBundle mainBundle] loadNibNamed:@"BookPrivateBroadcastSucceedHeadView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

@end
