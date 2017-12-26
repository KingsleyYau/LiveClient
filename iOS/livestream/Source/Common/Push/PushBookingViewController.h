//
//  PushBookingViewController.h
//  livestream
//
//  Created by Max on 2017/10/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

@interface PushBookingViewController : LSGoogleAnalyticsViewController
@property (weak) IBOutlet UIImageView *ladyImageView;
@property (weak) IBOutlet UILabel *tipsLabel;

@property (strong) NSURL *url;
@property (strong) NSString *tips;
@property (strong) NSString *userId;
@end
