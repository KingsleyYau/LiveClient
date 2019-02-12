//
//  LSSelectBoxView.m
//  livestream
//
//  Created by Randy_Fan on 2018/11/22.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSSelectBoxView.h"

@interface LSSelectBoxView ()

@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (weak, nonatomic) IBOutlet UIImageView *inboxIcon;
@property (weak, nonatomic) IBOutlet UIImageView *outboxIcon;

@end

@implementation LSSelectBoxView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.inboxIcon.hidden = NO;
    self.outboxIcon.hidden = YES;
    
    self.shadowView.layer.cornerRadius = 6;
    self.shadowView.layer.masksToBounds = YES;
    
    self.layer.shadowColor = Color(0, 0, 0, 0.25).CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 4.0;
    self.layer.masksToBounds = NO;
}

- (IBAction)inboxAction:(id)sender {
    self.inboxIcon.hidden = NO;
    self.outboxIcon.hidden = YES;
    
    if ([self.delegate respondsToSelector:@selector(didClickInbox)]) {
        [self.delegate didClickInbox];
    }
}

- (IBAction)outboxAction:(id)sender {
    self.inboxIcon.hidden = YES;
    self.outboxIcon.hidden = NO;
    
    if ([self.delegate respondsToSelector:@selector(didClickOutbox)]) {
        [self.delegate didClickOutbox];
    }
}


@end
