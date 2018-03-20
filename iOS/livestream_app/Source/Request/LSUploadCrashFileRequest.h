//
// LSUploadCrashFileRequest.h
//  dating
//  6.16.提交crash dump文件（仅独立）接口
//  Created by Max on 18/01/11.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSUploadCrashFileRequest : LSSessionRequest
//deviceId       设备唯一标识
@property (nonatomic, copy) NSString*  _Nullable deviceId;
//file          crash dump文件二进制流
@property (nonatomic, copy) NSString*  _Nullable file;
//tmpDirectory          crash dump文件zip
@property (nonatomic, copy) NSString*  _Nullable tmpDirectory;
@property (nonatomic, strong) UploadCrashFileFinishHandler _Nullable finishHandler;
@end
