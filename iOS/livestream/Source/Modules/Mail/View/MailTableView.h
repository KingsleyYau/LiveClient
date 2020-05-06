//
//  MailTableView.h
//  livestream
//
//  Created by Randy_Fan on 2018/11/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailTableViewCell.h"
#import "LSGetEmfboxListRequest.h"

@class MailTableView;
@protocol MailTableViewDelegate <NSObject>
@optional
- (void)tableView:(MailTableView *)tableView cellDidSelectRowAtIndexPath:(LSHttpLetterListItemObject *)model index:(NSInteger)index;
- (void)tableViewWillBeginDragging;
@end

@interface MailTableView : LSTableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *items;

@property (nonatomic, weak) id<MailTableViewDelegate> mailDelegate;


@property (nonatomic, assign) LSEMFType mailType;

@end
