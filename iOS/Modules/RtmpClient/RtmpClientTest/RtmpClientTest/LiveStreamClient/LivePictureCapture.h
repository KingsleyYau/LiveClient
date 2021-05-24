//
//  LivePictureCapture.h
//  RtmpClientTest
//
//  Created by Max on 2021/1/12.
//  Copyright © 2021 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUImage.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CaptureFinish)(NSString *filePath);

@interface LivePictureCapture : NSObject
- (void)rotateCamera;
- (void)capture:(UIInterfaceOrientation)orientation captureFinish:(CaptureFinish)captureFinish;
@end

NS_ASSUME_NONNULL_END
