//
//  LSMailDetailPrivatePhotoCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/12/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMailAttachmentModel.h"

@class LSMailDetailPrivatePhotoCell;
@protocol LSMailDetailPrivatePhotoCellDelegate <NSObject>
@optional

- (void)didCollectionViewItem:(NSInteger)row model:(LSMailAttachmentModel *)model;

@end

@interface LSMailDetailPrivatePhotoCell : UITableViewCell

@property (nonatomic, weak) id<LSMailDetailPrivatePhotoCellDelegate> delegate;

+ (id)getUITableViewCell:(UITableView *)tableView;

- (void)setupCollection:(NSMutableArray *)imageItems;

+ (NSString *)cellIdentifier;

@end
