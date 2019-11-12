//
//  LSMyContactsViewController.h
//  livestream
//
//  Created by Calvin on 2019/6/19.
//  Copyright © 2019 net.qdating. All rights reserved.
//  直播联系人列表

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"

@interface LSMyContactsViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet UIView *noMyContactsDataView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noDataViewTop;

@end


