//
//  LSSayHiReadReplyCell.h
//  livestream
//
//  Created by Calvin on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSayHiDetailResponseListItemObject.h"
#import "LSImageViewLoader.h"
@protocol LSSayHiReadReplyCellDelegate <NSObject>

- (void)sayHiReadReplyCellReplyBtnDid;
- (void)sayHiReadReplyCellContentImageTap;
@end

@interface LSSayHiReadReplyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeIcon;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
@property (weak, nonatomic) IBOutlet UIButton *replyMiniBtn;
@property (nonatomic, strong) LSImageViewLoader * imageLoader;
@property (weak, nonatomic) id<LSSayHiReadReplyCellDelegate> cellDelegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyBtnH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freeW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyBtnY;
@property (weak, nonatomic) IBOutlet UIImageView *lineView;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight:(LSSayHiDetailResponseListItemObject *)obj;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end


