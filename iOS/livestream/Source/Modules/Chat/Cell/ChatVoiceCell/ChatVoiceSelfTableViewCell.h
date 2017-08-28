//
//  ChatVoiceSelfTableViewCell.h
//  dating
//
//  Created by Calvin on 17/4/25.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatVoiceSelfTableViewCell;
@protocol ChatVoiceSelfTableViewCellDelegate <NSObject>
@optional
- (void)palyVoice:(NSInteger)row;
- (void)stopVoice:(NSInteger)row;
- (void)ChatVoiceSelfTableViewCellDidClickRetryBtn:(ChatVoiceSelfTableViewCell *)cell;

@end

@interface ChatVoiceSelfTableViewCell : UITableViewCell

@property (nonatomic,weak) id<ChatVoiceSelfTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *palyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;

@property (nonatomic,copy) NSString * voicePath;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)setPalyButtonImage:(BOOL)isPaly;
- (void)setPalyButtonTime:(int)time;
@end
