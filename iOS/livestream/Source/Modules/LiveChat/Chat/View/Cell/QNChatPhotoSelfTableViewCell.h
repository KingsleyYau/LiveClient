//
//  QNChatPhotoSelfTableViewCell.h
//  dating
//
//  Created by test on 16/7/8.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QNChatPhotoSelfTableViewCell;
@protocol ChatPhotoSelfTableViewCellDelegate <NSObject>

@optional
/**  点击查看大图   */
- (void)ChatPhotoSelfTableViewCellDidLookPhoto:(QNChatPhotoSelfTableViewCell *)cell;
- (void)ChatPhotoSelfTableViewCellDidClickRetryBtn:(QNChatPhotoSelfTableViewCell *)cell;

@end

@interface QNChatPhotoSelfTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *secretPhoto;
/** 代理 */
@property (nonatomic,weak) id<ChatPhotoSelfTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageW;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (IBAction)retryBtnAction:(id)sender;
@end
