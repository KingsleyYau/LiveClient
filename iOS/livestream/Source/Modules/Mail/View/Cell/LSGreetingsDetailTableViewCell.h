//
//  LSGreetingsDetailTableViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/12/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMailAttachmentModel.h"

@class LSGreetingsDetailTableViewCell;
@protocol LSGreetingsDetailTableViewCellDelegate <NSObject>
@optional

- (void)greetingsDetailCellLoadImageSuccess:(CGFloat)height model:(LSMailAttachmentModel *)model;

@end

@interface LSGreetingsDetailTableViewCell : UITableViewCell

@property (nonatomic, weak) id<LSGreetingsDetailTableViewCellDelegate> delegate;

+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)setupGreetingContent:(LSMailAttachmentModel *)obj tableView:(UITableView *)tableView;

+ (NSString *)cellIdentifier;

@end
