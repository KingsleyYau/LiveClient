//
//  PushShowViewController.h
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"
@interface PushShowViewController : LSGoogleAnalyticsViewController

@property (weak) IBOutlet UIImageView *ladyImageView;
@property (weak) IBOutlet UILabel *tipsLabel;
@property (strong) NSURL *url;
@property (strong) NSString *tips;
@property (strong) NSString *anchorId;
@end
