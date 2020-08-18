//
//  LSPremiumUnlockViewController.h
//  livestream
//
//  Created by Albert on 2020/7/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsPageViewController.h"
#import "LSPremiumRequestTableView.h"
#import "LSRichLabel.h"
#import "LSPremiumInterestView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSPremiumUnlockViewController : LSGoogleAnalyticsPageViewController

@property (weak, nonatomic) IBOutlet LSPremiumRequestTableView *listTableView;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet LSRichLabel *richLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nodataImgView;

@property (strong, nonatomic) LSPremiumInterestView *interestView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *richLabelH;

@property (weak, nonatomic) IBOutlet UIView *lineView;

@end

NS_ASSUME_NONNULL_END
