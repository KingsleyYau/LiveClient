//
//  LSMailDetailFreePhotoCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/12/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMailAttachmentModel.h"

@class LSMailDetailFreePhotoCell;
@protocol LSMailDetailFreePhotoCellDelegate <NSObject>
@optional
- (void)freePhotoDidClick:(LSMailAttachmentModel *)model;
@end

@interface LSMailDetailFreePhotoCell : UITableViewCell



@property (nonatomic, weak) id<LSMailDetailFreePhotoCellDelegate> delegate;

+ (id)getUITableViewCell:(UITableView *)tableView;

- (void)setupImageDetail:(LSMailAttachmentModel *)item;

+ (NSString *)cellIdentifier;

@end
