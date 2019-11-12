//
//  LSGiftInfoView.m
//  livestream
//
//  Created by Calvin on 2019/9/9.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSGiftInfoView.h"

@interface LSGiftInfoView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewH;
@end

@implementation LSGiftInfoView

- (instancetype)init {
    self = [super init];
    if (self) {
        LSGiftInfoView *contenView = (LSGiftInfoView *)[[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        contenView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [contenView layoutIfNeeded];
        self = contenView;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
 
    self.contentView.layer.cornerRadius = 4;
    self.contentView.layer.masksToBounds = YES;
    
    if (SCREEN_WIDTH == 320) {
        self.contentViewH.constant = 200;
    }else {
        self.contentViewH.constant = 187;
    }
}
 
- (IBAction)closeBtnDid:(id)sender {
    self.hidden = YES;
}

- (IBAction)bgTap:(id)sender {
    self.hidden = YES;
}

@end
