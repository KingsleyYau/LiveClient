//
//  LSAccessKeyRequestViewController.h
//  livestream
//
//  Created by Albert on 2020/7/29.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPremiumRequestTableView.h"
#import "LSGoogleAnalyticsPageViewController.h"
#import "LSPremiumInterestView.h"
#import "LSPremiumRequestFooterView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSAccessKeyRequestViewController : LSGoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet LSPremiumRequestTableView *listTableView;
@property (weak, nonatomic) IBOutlet UIView *titleSegment;
@property (weak, nonatomic) IBOutlet UIImageView *nodataImgView;

@property (weak, nonatomic) IBOutlet UIView *topButtonsView;
@property (weak, nonatomic) IBOutlet UIButton *segmentLeftBtn;
@property (weak, nonatomic) IBOutlet UIButton *segmentRightBtn;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *richLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *richLabelH;

@property (weak, nonatomic) IBOutlet UIView *lineView;

@end

NS_ASSUME_NONNULL_END
