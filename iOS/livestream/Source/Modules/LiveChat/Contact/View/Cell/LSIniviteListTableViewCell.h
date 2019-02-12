//
//  LSIniviteListTableViewCell.h
//  livestream
//
//  Created by test on 2018/11/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSLCLadyRecentContactObject.h"

@interface LSIniviteListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *onlineImage;
@property (weak, nonatomic) IBOutlet UIImageView *ladyImage;
@property (weak, nonatomic) IBOutlet UILabel *ladyName;
@property (weak, nonatomic) IBOutlet UILabel *ladyLastContact;
@property (nonatomic, strong) LSImageViewLoader* imageViewLoader;


+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;


- (void)updateUI:(LSLCLadyRecentContactObject *)item;
@end
