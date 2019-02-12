//
//  LSMailPrivateVideoCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/12/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMailAttachmentModel.h"

@class LSMailPrivateVideoCell;
@protocol LSMailPrivateVideoCellDelegate <NSObject>
@optional
- (void)privateVideoDidClick:(LSMailAttachmentModel *)model;
@end

@interface LSMailPrivateVideoCell : UITableViewCell

@property (nonatomic, weak) id<LSMailPrivateVideoCellDelegate> delegate;

+ (id)getUITableViewCell:(UITableView *)tableView;

- (void)setupVideoDetail:(LSMailAttachmentModel *)model;

+ (NSString *)cellIdentifier;

+ (CGFloat)cellHeight;

@end
