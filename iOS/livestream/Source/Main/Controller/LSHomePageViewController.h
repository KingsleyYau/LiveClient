//
//  LSHomePageViewController.h
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

@interface LSHomePageViewController : LSGoogleAnalyticsViewController <LSPZPagingScrollViewDelegate>
@property (weak) IBOutlet LSPZPagingScrollView *pagingScrollView;

@end
