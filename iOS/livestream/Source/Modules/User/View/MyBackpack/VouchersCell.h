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
@property (weak, nonatomic) IBOutlet UIImageView *vouchersBGView;
@property (weak, nonatomic) IBOutlet UILabel *liveTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ladyTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlyLadyLabel;
@property (weak, nonatomic) IBOutlet UILabel *ladyLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+ (NSString *)cellIdentifier;

+ (NSInteger)cellHeight;

+ (id)getUITableViewCell:(UITableView *)tableView;

- (NSString *)getTime:(NSInteger)time;
@end
