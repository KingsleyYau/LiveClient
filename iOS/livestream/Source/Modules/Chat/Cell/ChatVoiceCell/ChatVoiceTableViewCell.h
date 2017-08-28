//
//  ChatVoiceTableViewCell.h
//  dating
//
//  Created by Calvin on 17/4/25.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatVoiceTableViewCellDelegate <NSObject>
@optional
- (void)palyVoice:(NSInteger)row;
- (void)stopVoice:(NSInteger)row;
@end

@interface ChatVoiceTableViewCell : UITableViewCell

@property (nonatomic,weak) id<ChatVoiceTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *palyButton;
@property (weak, nonatomic) IBOutlet UIView *redView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (nonatomic,copy) NSString * voicePath;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)setPalyButtonImage:(BOOL)isPaly;
- (void)setPalyButtonTime:(int)time;
@end
