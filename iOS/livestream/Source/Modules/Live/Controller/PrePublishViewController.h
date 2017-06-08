//
//  PrePublishViewController.h
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"

@interface PrePublishViewController : KKViewController

@property (nonatomic, weak) IBOutlet UIImageViewTopFit* imageViewHeader;

@property (nonatomic, weak) IBOutlet BLTextField *textFieldTitle;

@property (nonatomic, weak) IBOutlet UIButton* btnGoLive;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

- (IBAction)cancelAction:(id)sender;

- (IBAction)goLiveAction:(id)sender;

@end
