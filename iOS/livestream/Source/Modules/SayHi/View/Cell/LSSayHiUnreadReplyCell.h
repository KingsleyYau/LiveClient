//
//  LSSayHiUnreadReplyCell.h
//  livestream
//
//  Created by Calvin on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSSayHiDetailResponseListItemObject.h"

@interface LSSayHiUnreadReplyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ladyHead;
@property (weak, nonatomic) IBOutlet UILabel *unreadIcon;
@property (weak, nonatomic) IBOutlet UILabel *freeIcon;
@property (nonatomic, strong) LSImageViewLoader * imageLoader;
@property (weak, nonatomic) IBOutlet UIImageView *selectedIcon;
@property (nonatomic, copy) NSString * url;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)loadUI:(LSSayHiDetailResponseListItemObject *)obj;
@end
