//
//  LSChatTableView.h
//  livestream
//
//  Created by Calvin on 2018/7/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMessage.h"
#import "LSChatSystemTipsTableViewCell.h"
#import "LSChatAddCreditsTableViewCell.h"
#import "LSChatTimeTableViewCell.h"
#import "LSChatSelfMessageCell.h"
#import "LSChatLadyMessageCell.h"

@protocol LSChatTableViewDelegate <NSObject>
@optional

- (void)chatTextSelfRetryMessage:(LSChatSelfMessageCell *)cell sendErr:(NSInteger)sendErr;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)pushToAddCreditVC;

@end

@interface LSChatTableView : UITableView<UITableViewDataSource, UITableViewDelegate, LSChatSelfMessageCellDelegate, LSChatAddCreditsTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet id <LSChatTableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSArray *msgArray;

@end
