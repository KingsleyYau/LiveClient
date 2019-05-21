//
//  LSSayHiResponseNumCell.h
//  livestream
//
//  Created by Calvin on 2019/5/5.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSayHiDetailItemObject.h"

@interface LSSayHiResponseNumCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
- (void)setContentText:(LSSayHiDetailItemObject *)detail;
@end

