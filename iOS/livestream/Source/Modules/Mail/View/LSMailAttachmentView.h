//
//  LSMailAttachmentView.h
//  livestream
//
//  Created by Albert on 2020/8/10.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSMailAttachmentViewDelegate <NSObject>

- (void)mailVideoKeyViewUpdateHeight:(UIImageView *)imageV;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LSMailAttachmentView : UIView

@property (nonatomic, weak) id<LSMailAttachmentViewDelegate> delegate;

/** 图片数组 */
@property (nonatomic, strong) NSMutableArray* imageArray;

- (void)reloadAttactments:(NSArray*)array;

@end

NS_ASSUME_NONNULL_END
