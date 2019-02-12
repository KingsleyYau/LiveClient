//
//  LSMailAttachmentViewController.h
//  dating
//
//  Created by test on 2017/6/26.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSMailAttachmentModel.h"
#import "LSHttpLetterListItemObject.h"

@class LSMailAttachmentViewController;
@protocol LSMailAttachmentViewControllerDelegate <NSObject>
@optional
- (void)emfAttachmentViewControllerDidBuyAttachments:(LSMailAttachmentViewController *)attachmentVC;
@end

@interface LSMailAttachmentViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet LSPZPagingScrollView *pageScrollView;

@property (nonatomic, strong) LSHttpLetterListItemObject *letterItem;

/** 附件列表 */
@property (nonatomic, copy) NSArray<LSMailAttachmentModel *> *attachmentsArray;
/**
 *  附件当前下标
 */
@property (nonatomic, assign) NSInteger photoIndex;
/** 代理 */
@property (nonatomic, weak) id<LSMailAttachmentViewControllerDelegate> attachmentDelegate;
@end
