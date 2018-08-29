//
//  EMFBoxTableViewCell.h
//  dating
//
//  Created by alex shum on 17/6/14.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
@interface LSEMFBoxTableViewCell : UITableViewCell
@property (nonatomic, assign) CGRect nameFrame;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *attachImg;
@property (weak, nonatomic) IBOutlet UIImageView *secondAttachImg;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UIImageView *stateImg;
@property (nonatomic, strong) LSImageViewLoader* imageViewLoader;
@property (weak, nonatomic) IBOutlet UIImageView *replyImg;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
+ (UIEdgeInsets)defaultInsets;
- (void)updateNameFrame:(NSString *)name;

@end
