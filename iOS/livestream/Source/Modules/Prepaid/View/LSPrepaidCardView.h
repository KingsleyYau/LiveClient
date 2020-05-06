//
//  LSPrepaidCardView.h
//  livestream
//
//  Created by Calvin on 2020/3/31.
//  Copyright © 2020 net.qdating. All rights reserved.
// 该控件固定高度， 266和460

#import <UIKit/UIKit.h>
#import "QNMessage.h"
#import "LSPrePaidManager.h"
#import "MsgItem.h"
@protocol LSPrepaidCardViewDelegate <NSObject>

- (void)prepaidCardViewHidenDetalis;
- (void)prepaidCardViewShowDetalis;
- (void)prepaidCardViewDidOpenScheduleList;
- (void)prepaidCardViewDidLearnHowWorks;

@end

@interface LSPrepaidCardView : UIView
@property (weak, nonatomic) IBOutlet UIView *wartingView;
@property (weak, nonatomic) IBOutlet UIView *wartingInfoView;
@property (weak, nonatomic) IBOutlet UIView *declineView;
@property (weak, nonatomic) IBOutlet UIView *declineInfoView;
@property (weak, nonatomic) IBOutlet UIView *acceptView;
@property (weak, nonatomic) IBOutlet UIView *acceptInfoView;
@property (weak, nonatomic) IBOutlet UILabel *acceptLabel;
@property (weak, nonatomic) IBOutlet UILabel *declineLabel;
@property (weak, nonatomic) IBOutlet UILabel *wartingLabel;
@property (weak, nonatomic) IBOutlet UILabel *declineInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *acceptInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateTimeLabel;


@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UILabel *scheduleIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSentLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *comfirmLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *localTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *localTimeView;

@property (weak, nonatomic) IBOutlet UILabel *startTimeViewLabel;
@property (weak, nonatomic) IBOutlet UILabel *localTimeViewLabel;
@property (weak, nonatomic) IBOutlet UIView *localView;

@property (weak, nonatomic) id<LSPrepaidCardViewDelegate> delegate;

// LiveChat用
- (void)updateUI:(QNMessage *)item ladyName:(NSString *)name;
// 直播间用
- (void)updataInfo:(MsgItem *)item ladyName:(NSString *)name;

@end




