//
//  GiftManager.h
//  livestream
//
//  Created by randy on 17/6/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiftModel.h"
#import "GiftDownloaderManager.h"

@interface GiftManager : NSObject

@property (nonatomic, assign) BOOL isDownload;

@property (nonatomic,  strong) NSMutableArray *giftUrlArray;

@property (nonatomic, strong) NSMutableArray *giftArray;

@property (nonatomic, strong) NSMutableDictionary *giftDic;

- (void)downloadGiftImage:(BOOL)isfirstLogin withImageUrl:(NSString *)url;

- (UIImage *)imageGiftWithGiftId:(int)giftId andType:(GiftType)type;

- (void)removeAllField;

@end
