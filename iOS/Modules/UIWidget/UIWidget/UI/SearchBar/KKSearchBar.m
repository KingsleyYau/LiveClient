//
//  KKSearchBar.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KKSearchBar.h"
@interface KKSearchBar() {
    
}
@end
@implementation KKSearchBar
@synthesize kkbackgroundImageView = _kkbackgroundImageView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)initialize {
    if(!_kkbackgroundImageView) {
        _kkbackgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
        _kkbackgroundImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_kkbackgroundImageView];
        [self sendSubviewToBack:_kkbackgroundImageView];
        
        _kkCancelButtonBackgroundView = nil;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    [_kkbackgroundImageView setImage:backgroundImage];
    UIView *kkView = [self valueForKey:@"_background"];
    if(kkView) {
        [kkView removeFromSuperview];
    }
}

- (void)setCancelBackgroundImage:(UIImage *)cancelButtonBackgroundImage {
    if(!_kkCancelButtonBackgroundView) {
        _kkCancelButtonBackgroundView = [[UIImageView alloc] initWithImage:cancelButtonBackgroundImage];
    }
    else {
        _kkCancelButtonBackgroundView.image = cancelButtonBackgroundImage;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIButton *cancelButton = (UIButton *)[self valueForKey:@"_cancelButton"];
    
    if(_kkCancelButtonBackgroundView) {

        UIImageView *kkView = [cancelButton valueForKey:@"_backgroundView"];
        CGRect cancelFrame = CGRectMake(0, 0, cancelButton.frame.size.width, cancelButton.frame.size.height);
        [kkView removeFromSuperview];
        
        [_kkCancelButtonBackgroundView removeFromSuperview];
        _kkCancelButtonBackgroundView.frame = cancelFrame;
        [cancelButton addSubview:_kkCancelButtonBackgroundView];
        [cancelButton sendSubviewToBack:_kkCancelButtonBackgroundView];
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
