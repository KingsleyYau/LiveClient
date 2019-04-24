//
//  LSSayHiAllTableView.h
//  livestream
//
//  Created by test on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSayHiAllListItemObject.h"

NS_ASSUME_NONNULL_BEGIN
@class LSSayHiAllTableView;
@protocol LSSayHiAllTableViewDelegate <NSObject>
@optional
//cell点击回调
- (void)tableView:(LSSayHiAllTableView *)tableView didSelectSayHiDetail:(LSSayHiAllListItemObject *)item;

@end
@interface LSSayHiAllTableView : UITableView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, copy) NSArray *items;
/** 代理 */
@property (nonatomic, weak) id<LSSayHiAllTableViewDelegate> tableViewDelegate;

@end

NS_ASSUME_NONNULL_END
