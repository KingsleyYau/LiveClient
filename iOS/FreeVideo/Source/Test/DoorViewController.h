//
//  DoorViewController.h
//  livestream
//
//  Created by Max on 2019/6/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

@interface DoorViewController : LSViewController

@property (weak) IBOutlet UITextField *usernameTextField;
@property (weak) IBOutlet UITextField *passwordTextField;
@property (weak) IBOutlet UITextField *checkcodeTextField;
@property (weak) IBOutlet UIImageView *checkcodeImageView;
@property (weak) IBOutlet UIActivityIndicatorView *activityView;

@end
