//
//  LSHomeSettingHaedView.h
//  livestream
//
//  Created by Calvin on 2018/6/13.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSHomeSettingHaedView;
@protocol LSHomeSettingHaedViewDelegate <NSObject>
@optional;
- (void)didChangeSiteClick;
- (void)didOpenPersonalCenter;
- (void)pushToCreditsVC;
- (void)pushSettingInfoVC;
@end

@interface LSHomeSettingHaedView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *headView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeSiteBtn;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingBtnY;
@property (weak, nonatomic) id<LSHomeSettingHaedViewDelegate> delegate;

- (void)updateUserInfo;
@end
