//
//  CountryTableViewCell.h
//  UIWidget
//
//  Created by test on 2017/5/24.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *countryName;
@property (weak, nonatomic) IBOutlet UILabel *countryZipCode;


+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;
@end
