//
//  TestViewController.h
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GPUImage.h"

@interface TestViewController : KKViewController
@property (nonatomic, weak) IBOutlet GPUImageView* publishView;

- (IBAction)publish:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)beauty:(id)sender;
@end

