//
//  VouchersCell.h
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSFileCacheManager.h"
@interface VouchersCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *minImage;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *oneLadyView;
@property (weak, nonatomic) IBOutlet UIView *allLadyView;
@property (weak, nonatomic) IBOutlet UIImageView *ladyHeadView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (weak, nonatomic) IBOutlet UIView *unreadView;

+ (NSString *)cellIdentifier;

+ (NSInteger)cellHeight;

+ (id)getUITableViewCell:(UITableView *)tableView;

- (NSString *)getTime:(NSInteger)time;
@end
