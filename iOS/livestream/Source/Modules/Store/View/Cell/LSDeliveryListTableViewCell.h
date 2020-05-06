//
//  LSDeliveryListTableViewCell.h
//  livestream
//
//  Created by test on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSFlowerGiftBaseInfoItemObject.h"

NS_ASSUME_NONNULL_BEGIN
@class LSDeliveryListTableViewCell;
@protocol LSDeliveryListTableViewCellDelegate <NSObject>
@optional
- (void)lsDeliveryListTableViewCellDidClickStatusAction:(LSDeliveryListTableViewCell *)cell;
- (void)lsDeliveryListTableViewCell:(LSDeliveryListTableViewCell *)cell didClickGiftInfo:(LSFlowerGiftBaseInfoItemObject *)item;
- (void)lsDeliveryListTableViewCellDidAnchorIcon:(LSDeliveryListTableViewCell *)cell;
@end

@interface LSDeliveryListTableViewCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, weak) id<LSDeliveryListTableViewCellDelegate> deliveryDelegate;
@property (weak, nonatomic) IBOutlet UILabel *anchorName;
@property (weak, nonatomic) IBOutlet UILabel *dateTime;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *anchorIcon;
@property (weak, nonatomic) IBOutlet UILabel *giftNote;
@property (weak, nonatomic) IBOutlet UIButton *statusNote;
@property (weak, nonatomic) IBOutlet LSCollectionView *giftListCollectionView;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (nonatomic, copy) NSArray *giftArray;

+ (NSString *)cellIdentifier;

+ (NSInteger)cellHeight;

+ (id)getUITableViewCell:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
