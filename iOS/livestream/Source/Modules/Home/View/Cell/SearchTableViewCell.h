//
//  SearchTableViewCell.h
//  livestream
//
//  Created by randy on 17/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewLoader.h"
#import "SearchListObject.h"

@interface SearchTableViewCell : UITableViewCell

/**
 * 用户头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImage;

/**
 * 用户名称
 */
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

/**
 * 用户ID
 */
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

/**
 * 用户性别
 */
@property (weak, nonatomic) IBOutlet UIImageView *sexImage;

/**
 * 用户等级
 */
@property (weak, nonatomic) IBOutlet UIImageView *lvImage;

/**
 * 关注按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *followBtn;

@property (nonatomic, strong) ImageViewLoader* imageViewLoader;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)setTheUserMessage:(SearchListObject *)lists;

@end
