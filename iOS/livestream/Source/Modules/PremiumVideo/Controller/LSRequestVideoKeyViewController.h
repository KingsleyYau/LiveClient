//
//  LSRequestVideoKeyViewController.h
//  livestream
//
//  Created by Albert on 2020/7/29.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsPageViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSRequestVideoKeyViewController : LSGoogleAnalyticsPageViewController

@property (nonatomic, weak) IBOutlet LSPZPagingScrollView *pagingScrollView;

@property (weak, nonatomic) IBOutlet UIView *titleSegment;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@end

NS_ASSUME_NONNULL_END
