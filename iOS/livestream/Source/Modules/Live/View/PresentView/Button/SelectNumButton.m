//
//  SelectNumButton.m
//  livestream
//
//  Created by randy on 2017/7/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SelectNumButton.h"

@implementation SelectNumButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if( self.containView == nil ) {
        self.containView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.containView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.containView];
    }
    
    self.containView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.containView.layer.cornerRadius = 3;
    self.containView.layer.masksToBounds = YES;
    
    CGFloat curIndex = self.blanking;
    if( !self.isVertical ) {
        // 水平排版
        CGFloat itemWidth = (self.containView.frame.size.width - self.blanking * (self.items.count + 1)) / self.items.count;
        
        for(UIView *view in self.items) {
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [view removeFromSuperview];
            [self.containView addSubview:view];
            view.frame = CGRectMake(curIndex, self.blanking, itemWidth, self.containView.frame.size.height - 2 * self.blanking);
            curIndex += itemWidth;
            curIndex += self.blanking;
        }
    }
    else {
        // 垂直排版
        CGFloat itemHeight = (self.containView.frame.size.height - self.blanking * (self.items.count + 1)) / self.items.count;
        
        for(UIView *view in self.items) {
            [view removeFromSuperview];
            [self.containView addSubview:view];
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.width.equalTo(self.containView);
                make.top.equalTo(@(curIndex));
                make.height.equalTo(@(itemHeight));
            }];
            curIndex += itemHeight;
        }
    }
    
    if([self.delegate respondsToSelector:@selector(itemsDidLayout:)]) {
        [self.delegate itemsDidLayout:self];
    }
}

- (void)sendDelegate {
    
}

@end
