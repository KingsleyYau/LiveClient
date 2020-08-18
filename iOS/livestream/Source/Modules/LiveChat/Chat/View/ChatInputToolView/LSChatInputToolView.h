//
//  LSChatInputToolView.h
//  livestream
//
//  Created by Calvin on 2020/3/26.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSChatInputToolView;
@protocol LSChatInputToolViewDelegate <NSObject>
@optional
- (void)chatInputToolViewBtnDid:(UIButton*)btton;
- (void)voiceButtonTouchDown;
- (void)voiceButtonTouchUpOutside;
- (void)voiceButtonDragOutside;
- (void)voiceButtonDragInside;

@end
@interface LSChatInputToolView : UIView 
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) id<LSChatInputToolViewDelegate> delegate;

- (void)updateUncount:(NSInteger)count;
@end

 
