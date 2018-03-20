//
//  DeletTipView.h
//  TZImagePickerController
//
//  Created by randy on 17/6/19.
//  Copyright © 2017年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeleteTipView;
@protocol DeleteTipViewDelegate <NSObject>
@optional

- (void)deleteImageFromeController;

@end

@interface DeleteTipView : UIView

@property (nonatomic, weak) id<DeleteTipViewDelegate>deleteDelegate;

@property (nonatomic, assign) NSInteger tagNum;

// 移除视图
- (void)cancelPrompt;

// 显示视图
- (void)deleteTipViewShowWithTap:(NSInteger)tag;

// 确认删除
- (void)deleteImage;

@end
