//
//  LSMailCellHeightItem.h
//  livestream
//
//  Created by Randy_Fan on 2018/12/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSMailAttachmentModel.h"

@interface LSMailCellHeightItem : NSObject

@property (nonatomic, copy) NSString *mailId;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) AttachmentType attachType;

@end
