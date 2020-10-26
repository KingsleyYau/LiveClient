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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewTop;

@property (nonatomic, weak) IBOutlet UILabel* labelVideoSize;
@property (nonatomic, weak) IBOutlet UILabel* labelFps;
@property (nonatomic, weak) IBOutlet GPUImageView* previewView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* previewViewRadio;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* previewViewBottom;

@property (nonatomic, weak) IBOutlet GPUImageView* previewPublishView;
@property (nonatomic, weak) IBOutlet UIView* controlView;
@property (nonatomic, weak) IBOutlet UITextField* textFieldAddress;
@property (nonatomic, weak) IBOutlet UITextField* textFieldPublishAddress;

@property (nonatomic, weak) IBOutlet UILabel* labelCacheMS;
@property (nonatomic, weak) IBOutlet UISlider* sliderCacheMS;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* controlBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* controlTop;

@property (nonatomic, weak) IBOutlet UIButton* button0_5x;
@property (nonatomic, weak) IBOutlet UIButton* button1x;
@property (nonatomic, weak) IBOutlet UIButton* button2x;

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

