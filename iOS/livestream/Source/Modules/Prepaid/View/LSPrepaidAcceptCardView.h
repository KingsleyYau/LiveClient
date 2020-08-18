//
//  LSPrepaidAcceptCardView.h
//  livestream
//
//  Created by Calvin on 2020/4/1.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QNMessage.h"
#import "MsgItem.h"
 
@protocol LSPrepaidAcceptCardViewDelegate <NSObject>

- (void)prepaidAcceptCardViewDidAcceptBtn;
- (void)prepaidAcceptCardViewHidenDetalis;
- (void)prepaidAcceptCardViewShowDetalis;
- (void)prepaidAcceptCardViewDidDuration;
- (void)prepaidAcceptCardViewDidOpenScheduleList;
- (void)prepaidAcceptCardViewDidLearnHowWorks;

@end
@interface LSPrepaidAcceptCardView : UIView
@property (weak, nonatomic) IBOutlet UILabel *bigTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UIView *detailsTimeView;
@property (weak, nonatomic) IBOutlet UILabel *scheduleIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSentLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *localTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *durationBtn;
@property (weak, nonatomic) IBOutlet UIButton *arrowBtn;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;
@property (weak, nonatomic) IBOutlet UILabel *onconfirmLabel;

@property (weak, nonatomic) IBOutlet UIView *defaultView;
@property (weak, nonatomic) IBOutlet UIView *defaultTimeView;
@property (weak, nonatomic) IBOutlet UILabel *defaultStartTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *defaultLocalTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *defaultDurationBtn;
@property (weak, nonatomic) IBOutlet UIButton *defaultAcceptBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingIcon;
@property (weak, nonatomic) id<LSPrepaidAcceptCardViewDelegate> delegate;

// LiveChat用
- (void)updateUI:(QNMessage *)item;
// 直播间用
- (void)updateInfo:(MsgItem *)item;
@end
 
