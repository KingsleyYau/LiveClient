//
//  UploadLiveRoomImgRequest.h
//  dating
//  5.2.上传图片
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface UploadLiveRoomImgRequest : SessionRequest
@property (nonatomic, assign) ImageType type;
@property (nonatomic, strong) NSString* imageFileName;
@property (nonatomic, strong) UploadLiveRoomImgFinishHandler _Nullable finishHandler;
@end
