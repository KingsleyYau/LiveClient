//
//  ChatTitleView.h
//  dating
//
//  Created by test on 16/5/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QNChatTitleView : UIView


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loadingWidth;

@property (weak, nonatomic) IBOutlet UILabel *personName;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *personIcon;
@end
