//
//  HotTableViewCell.h
//  livestream
//
//  Created by Max on 13-9-5.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageViewLoader.h"

@interface HotTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageViewTopFit *imageViewHeader;
@property (nonatomic, strong) ImageViewLoader* imageViewLoader;

@property (nonatomic, weak) IBOutlet UILabel *labelViewers;
@property (nonatomic, weak) IBOutlet UILabel *labelCountry;
@property (weak, nonatomic) IBOutlet UILabel *labelRoomTitle;


+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
