//
//  ChatPhotoPreviewViewController.h
//  dating
//
//  Created by Calvin on 2018/12/21.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"

@interface LSChatPhotoPreviewViewController : LSGoogleAnalyticsViewController

/** 图片位置 */
@property (nonatomic,assign) NSInteger photoIndex;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (nonatomic,assign) BOOL isFormChatVC;
@end

 
