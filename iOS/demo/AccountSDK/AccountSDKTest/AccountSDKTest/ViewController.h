//
//  ViewController.h
//  AccountSDKTest
//
//  Created by Max on 2017/12/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak) IBOutlet UILabel *labelType;
@property (weak) IBOutlet UILabel *labelToken;
@property (weak) IBOutlet UIImageView *imageViewHead;
@property (weak) IBOutlet UILabel *labelName;
@property (weak) IBOutlet UILabel *labelTips;
@property (weak, nonatomic) IBOutlet UILabel *generLabel;
@end

