//
//  ChatAccessoryListViewController.h
//  dating
//
//  Created by Calvin on 2019/3/21.
//  Copyright © 2019 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"

@interface LSChatAccessoryListViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet LSPZPagingScrollView *scrollView;
@property (nonatomic, strong) NSArray * items;
@property (nonatomic, assign) NSInteger row;
@end


