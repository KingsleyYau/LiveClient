//
//  LSPremiumRequestTableView.h
//  livestream
//
//  Created by Albert on 2020/7/29.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSTableView.h"
#import "LSPremiumVideoinfoItemObject.h"
#import "LSPremiumRequestFooterView.h"
#import "LSRequestVideoKeyTableViewCell.h"
#import "LSGetPremiumVideoListRequest.h"
#import "LSPremiumVideoAccessKeyItemObject.h"

NS_ASSUME_NONNULL_BEGIN

@class LSPremiumRequestTableView;
@protocol LSPremiumRequestTableViewDelegate <NSObject>
@optional
//cell点击回调
- (void)tableView:(LSPremiumRequestTableView *)tableView didSelectPremiumRequestDetail:(nullable LSPremiumVideoinfoItemObject *)item;
- (void)tableView:(LSPremiumRequestTableView *)tableView didCollectPremiumRequestDetail:(NSInteger)index;
- (void)tableView:(LSPremiumRequestTableView *)tableView didViewAllPremiumRequestDetail:(NSInteger)index;
- (void)tableView:(LSPremiumRequestTableView *)tableView didUserHeadPremiumRequestDetail:(NSInteger)index;
- (void)didTapTipLabel;
@end

@interface LSPremiumRequestTableView : LSTableView<UITableViewDataSource,UITableViewDelegate, LSRequestVideoKeyTableViewCellDelegate>
{
    LSPremiumRequestFooterView *footView;
    LSAccessKeyType type;
}

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, assign) LSAccessKeyType type;
/** 代理 */
@property (nonatomic, weak) id<LSPremiumRequestTableViewDelegate> tableViewDelegate;

@end

NS_ASSUME_NONNULL_END
