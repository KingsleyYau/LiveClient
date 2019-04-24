//
//  QNChatPhotoLadyTableViewCell.h
//  dating
//
//  Created by test on 16/7/8.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "UIImageViewFitCell.h"

@class QNChatPhotoLadyTableViewCell;
@protocol ChatPhotoLadyTableViewCellDelegate <NSObject>
@optional
/**  点击查看大图   */
- (void)ChatPhotoLadyTableViewCellDidLookPhoto:(QNChatPhotoLadyTableViewCell *)cell;

@end


@interface QNChatPhotoLadyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *secretPhoto;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageW;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingPhoto;
/** 代理 */
@property (nonatomic,weak) id<ChatPhotoLadyTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *privateLock;
@property (weak, nonatomic) IBOutlet UIImageView *privateUnlock;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIImageView *loadPhotoFailIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageH;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(BOOL)isCross;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end
