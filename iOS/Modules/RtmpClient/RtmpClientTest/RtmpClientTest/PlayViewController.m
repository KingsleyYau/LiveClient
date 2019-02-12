//
//  PlayViewController.m
//  RtmpClientTest
//
//  Created by Max on 2018/11/26.
//  Copyright © 2018 net.qdating. All rights reserved.
//

#import "PlayViewController.h"

#import "LiveStreamSession.h"
#import "LiveStreamPlayer.h"
#import "LiveStreamPublisher.h"

@interface PlayViewController ()
@property (strong) LiveStreamPlayer *player;
@property (nonatomic, weak) IBOutlet GPUImageView *playerPreview;
@end

@implementation PlayViewController

- (void)dealloc {
    NSLog(@"PlayViewController::dealloc()");
    [self.player stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"PlayViewController::viewDidLoad()");
    
    self.player = [LiveStreamPlayer instance];
    self.player.playView = self.playerPreview;
    self.player.playView.fillMode = kGPUImageFillModePreserveAspectRatio;
    
    NSString *playUrl = @"rtmp://192.168.88.17:19351/live/max0";
    [self.player playUrl:playUrl recordFilePath:@"" recordH264FilePath:@"" recordAACFilePath:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
