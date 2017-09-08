//
//  PrePublishViewController.h
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"

@interface PrePublishViewController : KKViewController

@property (nonatomic, weak) IBOutlet UIButton* btnSelectCover;

@property (nonatomic, weak) IBOutlet UITextField *textFieldTitle;

@property (nonatomic, weak) IBOutlet UIButton* btnGoLive;

@property (weak, nonatomic) IBOutlet UIImageView *liverCoverImageView;

@property (weak, nonatomic) IBOutlet UIButton *faceBookBtn;

@property (weak, nonatomic) IBOutlet UIButton *twitterBtn;

@property (weak, nonatomic) IBOutlet UIButton *instrgramBtn;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

- (IBAction)cancelAction:(id)sender;

- (IBAction)goLiveAction:(id)sender;

- (IBAction)chooseCoverAction:(id)sender;



@end
