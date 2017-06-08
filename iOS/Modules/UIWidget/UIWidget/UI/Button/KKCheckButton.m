//
//  KKCheckButton.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKCheckButton.h"

@implementation KKCheckButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark － 界面（Action）
- (void)buttonAction:(id)sender {
    self.selected = !self.selected;
    [self setSelected:self.selected];
    
    if( self.selectedChangeDelegate && [self.selectedChangeDelegate respondsToSelector:@selector(selectedChanged:)] ) {
        [self.selectedChangeDelegate selectedChanged:self];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
