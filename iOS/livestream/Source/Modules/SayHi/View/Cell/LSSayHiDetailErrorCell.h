//
//  LSSayHiDetailErrorCell.h
//  livestream
//
//  Created by Calvin on 2019/5/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

 

@interface LSSayHiDetailErrorCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end

 
