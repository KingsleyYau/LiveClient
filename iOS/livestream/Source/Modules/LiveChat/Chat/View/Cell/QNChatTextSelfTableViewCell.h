//
//  QNChatTextSelfTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QNChatTextSelfTableViewCell;
@protocol ChatTextSelfDelegate <NSObject>

@optional
- (void)chatTextSelfRetryButtonClick:(QNChatTextSelfTableViewCell *)cell;

@end

@interface QNChatTextSelfTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, weak) IBOutlet UIButton* retryButton;
@property (nonatomic, weak) IBOutlet UIImageView* backgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;

/** 代理 */
@property (nonatomic,weak) id<ChatTextSelfDelegate> delegate;

- (IBAction)retryBtnClick:(id)sender;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
