//
//  LSSayHiUnreadReplyCell.h
//  livestream
//
//  Created by Calvin on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LSSayHiUnreadReplyCellDelegate <NSObject>

- (void)sayHiUnreadReplyCellReadNowBtnDid;

@end

@interface LSSayHiUnreadReplyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoIcon;
@property (weak, nonatomic) IBOutlet UIButton *readBtn;
@property (weak, nonatomic) id<LSSayHiUnreadReplyCellDelegate> cellDelegate;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
