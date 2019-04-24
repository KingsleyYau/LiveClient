//
//  LSChatVideoLadyTableViewCell.h
//  livestream
//
//  Created by Calvin on 2019/3/20.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSChatVideoLadyTableViewCell;
@protocol ChatVideoLadyTableViewCellDelegate <NSObject>
@optional
/**  点击查看视频   */
- (void)ChatVideoLadyTableViewCellDid:(LSChatVideoLadyTableViewCell *)cell;

@end

@interface LSChatVideoLadyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *imageBGView;

@property (weak, nonatomic) IBOutlet UIImageView *secretPhoto;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageH;
@property (weak, nonatomic) IBOutlet UIImageView *playIcon;
@property (weak, nonatomic) IBOutlet UIView *lockPhoto;

@property (weak, nonatomic) IBOutlet UIImageView *lockIcon;
@property (weak, nonatomic) IBOutlet UIImageView *loadFailIcon;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingPhoto;
@property (weak, nonatomic) IBOutlet UIView *alphaView;
/** 代理 */
@property (nonatomic,weak) id<ChatVideoLadyTableViewCellDelegate> delegate;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(BOOL)isCross;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end
