//
//  LSChatEmotionViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/10/22.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSChatEmotionViewController.h"
#import "LSChatEmotionKeyboardView.h"
#import "LSLiveStandardEmotionView.h"
#import "LSChatSmallEmotionView.h"
#import "LSChatEmotionManager.h"

@interface LSChatEmotionViewController ()<LSChatEmotionKeyboardViewDelegate,LSLiveStandardEmotionViewDelegate,LSChatSmallEmotionViewDelegate>
/** 表情选择器键盘 **/
@property (nonatomic, strong) LSChatEmotionKeyboardView *chatEmotionKeyboardView;
/** 普通表情 */
@property (nonatomic, strong) LSLiveStandardEmotionView *chatNomalEmotionView;
/** 高级表情 */
@property (nonatomic, strong) LSChatSmallEmotionView *smallEmotionView;
// 表情管理类
@property (nonatomic, strong) LSChatEmotionManager *emotionManager;

@end

@implementation LSChatEmotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emotionManager = [LSChatEmotionManager emotionManager];
    
    [self setupEmotionView];
}

- (void)setupEmotionView {
    
    self.chatNomalEmotionView = [LSLiveStandardEmotionView emotionChooseView:self];
    self.chatNomalEmotionView.delegate = self;
    self.chatNomalEmotionView.stanListItem = self.emotionManager.stanListItem;
    self.chatNomalEmotionView.tipView.hidden = NO;
    self.chatNomalEmotionView.tipLabel.text = self.emotionManager.stanListItem.errMsg;
    [self.chatNomalEmotionView reloadData];
    self.chatNomalEmotionView.tipView.hidden = YES;
    self.chatNomalEmotionView.emotionCollectionView.backgroundColor = [UIColor whiteColor];
    self.chatNomalEmotionView.pageView.pageIndicatorTintColor = COLOR_WITH_16BAND_RGB(0xAAAAAA);
    self.chatNomalEmotionView.pageView.currentPageIndicatorTintColor = COLOR_WITH_16BAND_RGB(0x555555);
    
//    self.smallEmotionView = [LSChatSmallEmotionView chatSmallEmotionView:self];
//    self.smallEmotionView.delegate = self;
////    self.smallEmotionView.smallEmotions = ;
//    self.smallEmotionView.emotionCollectionView.backgroundColor = [UIColor whiteColor];
//    self.smallEmotionView.pageView.pageIndicatorTintColor = COLOR_WITH_16BAND_RGB(0xAAAAAA);
//    self.smallEmotionView.pageView.currentPageIndicatorTintColor = COLOR_WITH_16BAND_RGB(0x555555);
    
    self.chatEmotionKeyboardView = [LSChatEmotionKeyboardView chatEmotionKeyboardView:self];
    self.chatEmotionKeyboardView.delegate = self;
    self.chatEmotionKeyboardView.buttonsView.backgroundColor = COLOR_WITH_16BAND_RGB(0xE7E8EE);
    [self.view addSubview:self.chatEmotionKeyboardView];
    [self.chatEmotionKeyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
    
}

- (void)keyboardViewReload {
    [self.chatEmotionKeyboardView reloadData];
}

#pragma mark - 表情、礼物键盘选择回调 (LSPageChooseKeyboardViewDelegate)
- (NSUInteger)pagingViewCount:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView {
    return 1;
}

- (Class)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView classForIndex:(NSUInteger)index{
    Class cls = nil;
    
    if (index == 0) {
        // 普通表情
        cls = [LSLiveStandardEmotionView class];
    } else if (index == 1) {
        cls = [UIView class];
    }
    return cls;
}

- (UIView *)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView pageViewForIndex:(NSUInteger)index {
    UIView *view = nil;
    
    if (index == 0) {
        view = self.chatNomalEmotionView;
    } else if (index == 1) {
    }
    view.frame = CGRectMake(0, 0, ViewBoundsSize.width, ViewBoundsSize.height);
    return view;
}

- (void)chatEmotionKeyboardView:(LSChatEmotionKeyboardView *)chatEmotionKeyboardView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    if (index == 0) {
        // 普通表情
        [self.chatNomalEmotionView reloadData];
        
    } else if (index == 1) {
        // 高级表情
    }
}

- (void)LSLiveStandardEmotionView:(LSLiveStandardEmotionView *)LSLiveStandardEmotionView didSelectNomalItem:(NSInteger)item {
    // TODO: 插入表情到TextView
    if ([self.emotionDelegate respondsToSelector:@selector(didStandardEmotionViewItem:)]) {
        [self.emotionDelegate didStandardEmotionViewItem:item];
    }
}

- (void)chatEmotionKeyboardViewSendEmotion {
    // TODO: 表情列表发送逻辑
    if ([self.emotionDelegate respondsToSelector:@selector(emotionKeyboardViewClickSend)]) {
        [self.emotionDelegate emotionKeyboardViewClickSend];
    }
}

@end
