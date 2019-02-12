//
//  LSHotViewController.h
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

//#import "LSGoogleAnalyticsViewController.h"
#import "LSViewController.h"
#import "HotTableView.h"

@interface LSHotViewController : LSListViewController

@property (weak) IBOutlet HotTableView* tableView;

- (void)reloadHotHeadView;

- (void)setCanDidpush:(BOOL)canClick;

@end
