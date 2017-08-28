//
//  NoChatListView.h
//  livestream
//
//  Created by randy on 2017/8/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoChatListView;
@protocol NoChatListViewDelagate <NSObject>
@optional

- (void)reloadNewList:(NoChatListView *)noChatListView;

@end

@interface NoChatListView : UIView

@property (weak, nonatomic) IBOutlet UIButton *reloadNewBtn;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelBootomDistance;

@property (strong, nonatomic) id<NoChatListViewDelagate> delegate;

- (void)isHavePrivateList:(BOOL)isNum;

+ (instancetype)initNoChatListViewXib;

@end
