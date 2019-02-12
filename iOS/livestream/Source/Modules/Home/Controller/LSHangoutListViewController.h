//
//  LSHangoutListViewController.h
//  livestream
//
//  Created by Calvin on 2019/1/16.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSHangoutTableView.h"
NS_ASSUME_NONNULL_BEGIN

@interface LSHangoutListViewController : LSListViewController
@property (weak, nonatomic) IBOutlet LSHangoutTableView *tableView;
@end

NS_ASSUME_NONNULL_END
