//
//  LSButtonBar.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSButtonBar.h"
#import "CustomUIView.h"

@implementation LSButtonBar
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        // Initialization code
        self.blanking = 0;
        self.isVertical = NO;
    }
    return self;
}

- (void)reloadData:(BOOL)animated {
//    CGFloat curIndex = self.blanking;
//    if( !self.isVertical ) {
//        // 水平排版
//        CGFloat itemWidth = (self.containView.frame.size.width - self.blanking * (self.items.count + 1)) / self.items.count;
//        
//        for(UIView *view in self.items) {
//            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//            [view removeFromSuperview];
//            [self.containView addSubview:view];
//            view.frame = CGRectMake(curIndex, 0, itemWidth, self.containView.frame.size.height);
//            curIndex += itemWidth;
//            curIndex += self.blanking;
//        }
//    }
//    else {
//        // 垂直排版
//        CGFloat itemHeight = (self.containView.frame.size.height - self.blanking * (self.items.count + 1)) / self.items.count;
//        
//        for(UIView *view in self.items) {
//            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//            [view removeFromSuperview];
//            [self.containView addSubview:view];
//            view.frame = CGRectMake(0, curIndex, self.containView.frame.size.width, itemHeight);
//            curIndex += itemHeight;
//            curIndex += self.blanking;
//        }
//    }
//    
//    if([self.delegate respondsToSelector:@selector(itemsDidLayout:)]) {
//        [self.delegate itemsDidLayout:self];
//    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if( self.containView == nil ) {
        self.containView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.containView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.containView];
    }
    
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
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [view removeFromSuperview];
            [self.containView addSubview:view];
            view.frame = CGRectMake(self.blanking, curIndex, self.containView.frame.size.width - 2 * self.blanking, itemHeight);
            curIndex += itemHeight;
            curIndex += self.blanking;
        }
    }
    
    [self sendDelegate];
}

- (void)sendDelegate {
    if([self.delegate respondsToSelector:@selector(itemsDidLayout:)]) {
        [self.delegate itemsDidLayout:self];
    }
}

- (void)removeAllButton {
    [self.containView removeAllSubviews];
}

@end
