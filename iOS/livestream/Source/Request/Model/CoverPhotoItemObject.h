//
//  CoverPhotoItemObject.h
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface CoverPhotoItemObject : NSObject
@property (nonatomic, strong) NSString* photoId;
@property (nonatomic, strong) NSString* photoUrl;
@property (nonatomic, assign) ExamineStatus status;
@property (nonatomic, assign) BOOL in_use;
@end
