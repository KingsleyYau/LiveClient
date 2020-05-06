//
//  LSCheckOutViewController.h
//  livestream
//
//  Created by test on 2019/10/10.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSGiftProductTableViewCell.h"
#import "LSChatTextView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSCheckOutViewController : LSGoogleAnalyticsViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,LSGiftProductTableViewCellDelegate>

/** 主播id **/
@property (nonatomic, copy) NSString *anchorId;
@property (nonatomic, copy) NSString *anchorName;
@property (nonatomic, copy) NSString *anchorImageUrl;
@property (weak, nonatomic) IBOutlet UILabel *greetingMsgCount;
@property (weak, nonatomic) IBOutlet LSChatTextView *greetingMsgTextView;
@property (weak, nonatomic) IBOutlet UILabel *specialDeliveryMsgCount;
@property (weak, nonatomic) IBOutlet LSChatTextView *specialDeliveryMsg;
@property (weak, nonatomic) IBOutlet UIView *totalPriceView;
@property (weak, nonatomic) IBOutlet UILabel *deliveryFeesPrice;
@property (weak, nonatomic) IBOutlet UILabel *discountPrice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet LSTableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *freeGreetingCard;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freeGreetingCardHeight;

@end

NS_ASSUME_NONNULL_END
