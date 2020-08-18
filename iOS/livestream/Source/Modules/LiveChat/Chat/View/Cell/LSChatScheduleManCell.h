//
//  LSChatScheduleManCell.h
//  livestream
//
//  Created by Calvin on 2020/4/10.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPrepaidCardView.h"
#import "QNMessage.h"
@class LSChatScheduleManCell;
@protocol LSChatScheduleManCellDelegate <NSObject>

- (void)chatScheduleManCellHidenDetalis:(NSInteger)row;
- (void)chatScheduleManCellShowDetalis:(NSInteger)row;
- (void)chatScheduleManCellDidOpenScheduleList;
- (void)chatScheduleManCellDidLearnHowWorks;
- (void)chatScheduleManCellDidRetryBtn:(LSChatScheduleManCell*)cell;
@end

@interface LSChatScheduleManCell : UITableViewCell<LSPrepaidCardViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *cardCellView;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
@property (strong, nonatomic) LSPrepaidCardView *cardView;
@property (weak, nonatomic) id<LSChatScheduleManCellDelegate> cellDelegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardViewW;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(BOOL)isMore;
+ (id)getUITableViewCell:(UITableView*)tableView;

- (void)updateCardData:(QNMessage *)item ladyName:(NSString *)name;
@end

 
