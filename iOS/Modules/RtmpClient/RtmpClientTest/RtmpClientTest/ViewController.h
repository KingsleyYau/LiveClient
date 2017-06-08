//
//  ViewController.h
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GPUImage.h"

@interface ViewController : UIViewController
@property (nonatomic, weak) IBOutlet GPUImageView* gpuImageView;
@property (nonatomic, weak) IBOutlet UIView* publishView;

- (IBAction)publish:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;

@end

