//
//  LSProfilePhotoTableViewCell.h
//  livestream
//
//  Created by test on 2017/12/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSProfilePhotoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet LSUIImageViewFill *profilePhoto;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)updateAvatarStatus;

@end
