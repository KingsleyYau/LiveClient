//
//  FinishView.m
//  dating
//
//  Created by test on 2017/6/5.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "DialogIconTips.h"
#import <Masonry.h>

@interface DialogIconTips()
@property (nonatomic, assign) BOOL isShow;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end



@implementation DialogIconTips

+ (instancetype)dialogIconTips {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"DialogIconTips" owner:nil options:nil];
    DialogIconTips* view = [nibs objectAtIndex:0];
    view.layer.cornerRadius = 5.0f;
    view.layer.masksToBounds = YES;
    view.isShow = NO;
    return view;
}

- (void)showDialogIconTips:(UIView *)view tipText:(NSString *)tip tipIcon:(NSString *)tipIconName{
    if (self.isShow) {
        [self removeShow];
    }
    
    if (tipIconName.length > 0) {
        self.iconImageView.image = [UIImage imageNamed:tipIconName];
    }

    self.tipLabel.text = tip;
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.width.equalTo(@(80));
            make.centerY.equalTo(view.mas_centerY);
            make.centerX.equalTo(view.mas_centerX);
        }];
        
        self.isShow = YES;
        
        [self sizeToFit];
        [self performSelector:@selector(removeShow) withObject:nil afterDelay:2];
    }
}

- (void)removeShow {
    self.isShow = NO;
    [self removeFromSuperview];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


@end
