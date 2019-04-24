//
//  LSSayHiResponseListTableView.h
//  livestream
//
//  Created by test on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSayHiResponseListItemObject.h"

NS_ASSUME_NONNULL_BEGIN
@class LSSayHiResponseListTableView;
@protocol LSSayHiResponseListTableViewDelegate <NSObject>
@optional
//cell点击回调
- (void)tableView:(LSSayHiResponseListTableView *)tableView didSelectSayHiDetail:(LSSayHiResponseListItemObject *)item;
@end

@interface LSSayHiResponseListTableView : UITableView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, copy) NSArray *items;
/** 代理 */
@property (nonatomic, weak) id<LSSayHiResponseListTableViewDelegate> tableViewDelegate;
@end

NS_ASSUME_NONNULL_END
