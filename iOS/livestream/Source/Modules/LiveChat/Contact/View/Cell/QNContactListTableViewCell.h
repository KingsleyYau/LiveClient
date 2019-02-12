//
//  ChatContactListTableViewCell.h
//  dating
//
//  Created by test on 2017/2/24.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSLadyRecentContactObject.h"

@class QNContactListTableViewCell;

@protocol LSContactListTableViewCellCellDelegate <NSObject>
@optional

@end
@interface QNContactListTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIView *onlineImage;
@property (weak, nonatomic) IBOutlet UIImageView *ladyImage;
@property (weak, nonatomic) IBOutlet UILabel *ladyName;
@property (weak, nonatomic) IBOutlet UILabel *ladyLastContact;
@property (nonatomic, strong) LSImageViewLoader* imageViewLoader;
@property (weak, nonatomic) IBOutlet UIImageView *inchatIcon;
@property (weak, nonatomic) IBOutlet UILabel *unreadCountIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unreadCountIconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ladyNameCenter;

/** 代理 */
@property (nonatomic,weak) id<LSContactListTableViewCellCellDelegate> chatContactDelegate;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;


- (void)updateUI:(LSLadyRecentContactObject *)item;
@end
