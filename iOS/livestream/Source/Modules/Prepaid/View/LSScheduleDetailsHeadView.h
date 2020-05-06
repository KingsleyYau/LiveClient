//
//  LSScheduleDetailsHeadView.h
//  livestream
//
//  Created by Calvin on 2020/4/20.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSScheduleInviteListItemObject.h"
#import "LSScheduleInviteDetailItemObject.h"
#import "LSImageViewLoader.h"

@protocol LSScheduleDetailsHeadViewDelegate <NSObject>

- (void)scheduleDetailsHeadViewDidCancelBtn;
- (void)scheduleDetailsHeadViewDidGfitBtn;
- (void)scheduleDetailsHeadViewDidMailBtn;
- (void)scheduleDetailsHeadViewDidChatBtn;
- (void)scheduleDetailsHeadViewDidDurationBtn;
@end

@interface LSScheduleDetailsHeadView : UIView 
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *sentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelBtnWidth;

@property (weak, nonatomic) IBOutlet UIView *cancelStatuView;
@property (weak, nonatomic) IBOutlet UIView *canceledTipView;
@property (weak, nonatomic) IBOutlet UILabel *canceledTipLabel;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImage;
@property (weak, nonatomic) IBOutlet UIImageView *onlineIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ladyIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *yrsLabel;
@property (weak, nonatomic) IBOutlet UIButton *giftBtn;
@property (weak, nonatomic) IBOutlet UIButton *mailBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;

@property (weak, nonatomic) IBOutlet UIView *informationView;
@property (weak, nonatomic) IBOutlet UILabel *timeZoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *localTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *durationBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationBtnHeight;


@property (weak, nonatomic) IBOutlet UIView *furtherView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *furtherViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *minutesLabel;


@property (nonatomic, strong) LSImageViewLoader * imageViewLoader;
@property (weak, nonatomic) id<LSScheduleDetailsHeadViewDelegate> delegate;

- (void)updateSentTime:(LSScheduleInviteDetailItemObject *)item;
- (void)updateUI:(LSScheduleInviteListItemObject *)item;
@end

 
