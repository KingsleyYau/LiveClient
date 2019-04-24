//
//  LSSayHiReadReplyCell.h
//  livestream
//
//  Created by Calvin on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSSayHiReadReplyCellDelegate <NSObject>

- (void)sayHiReadReplyCellArrowBtnDid;

@end

@interface LSSayHiReadReplyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeIcon;
@property (weak, nonatomic) IBOutlet UIImageView *photoIcon;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
@property (weak, nonatomic) IBOutlet UIButton *arrowBtn;
@property (weak, nonatomic) id<LSSayHiReadReplyCellDelegate> cellDelegate;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(NSString *)str isUnfold:(BOOL)unfold;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end


