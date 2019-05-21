//
//  LSSayHiLeadInfoView.m
//  livestream
//
//  Created by test on 2019/4/24.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiLeadInfoView.h"


@interface LSSayHiLeadInfoView()
@property (weak, nonatomic) IBOutlet UIView *firstIcon;
@property (weak, nonatomic) IBOutlet UIView *secondIcon;
@property (weak, nonatomic) IBOutlet UIView *thirdIcon;
@property (weak, nonatomic) IBOutlet UILabel *firstLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstLineTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstLineThreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLineOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLineTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLineThreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLineTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLineFreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLineOneLabel;

@property (weak, nonatomic) IBOutlet UILabel *thirdLineTwoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDistance;

@end


@implementation LSSayHiLeadInfoView

+ (LSSayHiLeadInfoView *)leadInfoView {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    LSSayHiLeadInfoView* view = [nibs objectAtIndex:0];
    view.contentView.layer.cornerRadius = 4.0f;
    view.contentView.layer.masksToBounds = YES;
    [view setupUI];
    return view;
}


- (void)showSayHiLeadInfoView:(UIView *)view{
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.equalTo(view);
        }];
    }
}


- (IBAction)closeAction:(id)sender {
    if ([self.leadInfoDelegate respondsToSelector:@selector(lsSayHiLeadInfoDidClose:)]) {
        [self.leadInfoDelegate lsSayHiLeadInfoDidClose:self];
    }
}

- (void)setupUI {
    self.firstIcon.layer.cornerRadius = self.firstIcon.frame.size.width * 0.5f;
    self.secondIcon.layer.cornerRadius = self.secondIcon.frame.size.width * 0.5f;
    self.thirdIcon.layer.cornerRadius = self.thirdIcon.frame.size.width * 0.5f;
    self.firstIcon.layer.masksToBounds = YES;
    self.secondIcon.layer.masksToBounds = YES;
    self.thirdIcon.layer.masksToBounds = YES;
    UIFont *smallFont = [UIFont italicSystemFontOfSize:13];
    if (screenSize.width < 375) {
        self.firstLineLabel.font = smallFont;
        self.firstLineTwoLabel.font = smallFont;
        self.firstLineThreeLabel.font = smallFont;
        self.secondLineOneLabel.font = smallFont;
        self.secondLineTwoLabel.font = smallFont;
        self.secondLineThreeLabel.font = smallFont;
        self.thirdLineTopLabel.font = smallFont;
        self.thirdLineFreeLabel.font = smallFont;
        self.thirdLineOneLabel.font = smallFont;
        self.thirdLineTwoLabel.font = smallFont;
    }
}

@end
