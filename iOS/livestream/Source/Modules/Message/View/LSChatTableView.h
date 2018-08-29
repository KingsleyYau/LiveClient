//
//  LSChatTableView.h
//  livestream
//
//  Created by Calvin on 2018/7/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMessage.h"
#import "LSChatTextSelfTableViewCell.h"
#import "LSChatTextLadyTableViewCell.h"
#import "LSChatSystemTipsTableViewCell.h"
#import "LSChatAddCreditsTableViewCell.h"

@protocol LSChatTableViewDelegate <NSObject>
@optional


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;

@end

@interface LSChatTableView : UITableView<UITableViewDataSource, UITableViewDelegate,LSChatTextSelfDelegate>

@property (nonatomic, weak) IBOutlet id <LSChatTableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSArray *msgArray;

@end
