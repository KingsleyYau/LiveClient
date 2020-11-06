//
//  StreamViewController.h
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StreamBaseViewController.h"
#import "GPUImage.h"

@interface StreamViewController : StreamBaseViewController

@property (strong) IBOutlet NSLayoutConstraint *previewTop;
@property (strong) IBOutlet NSLayoutConstraint* previewViewRadio;
@property (strong) IBOutlet NSLayoutConstraint* previewViewBottom;

@property (weak) IBOutlet UIActivityIndicatorView* loadingView;
@property (weak) IBOutlet UILabel* labelVideoSize;
@property (weak) IBOutlet UILabel* labelFps;
@property (weak) IBOutlet GPUImageView* previewView;

@property (weak) IBOutlet GPUImageView* previewPublishView;
@property (weak) IBOutlet UIView* controlView;
@property (weak) IBOutlet UITextField* textFieldAddress;
@property (weak) IBOutlet UITextField* textFieldPublishAddress;

@property (weak) IBOutlet UILabel* labelCacheMS;
@property (weak) IBOutlet UISlider* sliderCacheMS;
@property (weak) IBOutlet NSLayoutConstraint* controlBottom;
@property (weak) IBOutlet NSLayoutConstraint* controlTop;

@property (weak) IBOutlet UIButton* button0_5x;
@property (weak) IBOutlet UIButton* button1x;
@property (weak) IBOutlet UIButton* button2x;
@property (weak) IBOutlet UIButton* buttonRecord;

- (IBAction)scale:(id)sender;
- (IBAction)mutePlay:(id)sender;
- (IBAction)filterPlay:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)stopPlay:(id)sender;
- (IBAction)publish:(id)sender;
- (IBAction)stopPush:(id)sender;
- (IBAction)beauty:(id)sender;
- (IBAction)mute:(id)sender;
- (IBAction)roate:(id)sender;
- (IBAction)startCam:(id)sender;
- (IBAction)stopCam:(id)sender;
@end

