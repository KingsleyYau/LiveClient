//
//  ACCountSDKShareItem.h
//  AccountSDK
//
//  Created by Max on 2017/12/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ACCountSDKShareItemType {
    ACCountSDKShareItemType_Link,
    ACCountSDKShareItemType_Photo,
} ACCountSDKShareItemType;

@interface ACCountSDKShareItem : NSObject
@property (assign) ACCountSDKShareItemType type;
@property (strong) NSString *text;

#pragma mark - ACCountSDKShareItemType_Link
@property (strong) NSString *url;

#pragma mark - ACCountSDKShareItemType_Photo
@property (strong) NSArray<UIImage *> *imageArray;

@end
