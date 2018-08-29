//
//  StreamTestViewController.h
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSGoogleAnalyticsViewController.h"
#import "GPUImage.h"

@interface StreamTestViewController : LSGoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewTop;

@property (nonatomic, weak) IBOutlet GPUImageView *previewViewBig;
@property (nonatomic, weak) IBOutlet GPUImageView* previewView0;
@property (nonatomic, weak) IBOutlet GPUImageView* previewView1;
@property (nonatomic, weak) IBOutlet GPUImageView* previewView2;
@property (nonatomic, weak) IBOutlet GPUImageView* previewPublishView;
@property (nonatomic, weak) IBOutlet UITextField* textFieldAddress;
@property (nonatomic, weak) IBOutlet UITextField* textFieldPublishAddress;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* playBottom;

- (IBAction)mute0:(id)sender;
- (IBAction)mute1:(id)sender;
- (IBAction)mute2:(id)sender;

- (IBAction)play:(id)sender;
- (IBAction)publish:(id)sender;
- (IBAction)stopPlay:(id)sender;
- (IBAction)stopPush:(id)sender;
- (IBAction)beauty:(id)sender;
- (IBAction)mute:(id)sender;
- (IBAction)roate:(id)sender;
- (IBAction)startCam:(id)sender;
- (IBAction)stopCam:(id)sender;
@end

