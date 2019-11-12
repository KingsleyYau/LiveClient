//
//  LSMycontactTableView.h
//  livestream
//
//  Created by Calvin on 2019/6/20.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSRecommendAnchorItemObject.h"
@protocol LSMycontactTableViewDelegate <NSObject>

- (void)mycontactTableViewDidSelectItem:
(LSRecommendAnchorItemObject *)item;    
- (void)mycontactTableViewDidClickWatchNowBtn:
(LSRecommendAnchorItemObject *)item;
- (void)mycontactTableViewDidClickInviteBtn:
(LSRecommendAnchorItemObject *)item;
- (void)mycontactTableViewDidClickChatBtn:
(LSRecommendAnchorItemObject *)item;
- (void)mycontactTableViewDidClickMailBtn:
(LSRecommendAnchorItemObject *)item;
- (void)mycontactTableViewDidClickBookBtn:
(LSRecommendAnchorItemObject *)item;
@end

@interface LSMycontactTableView : UITableView<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, weak) id <LSMycontactTableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSArray *items;
@end

