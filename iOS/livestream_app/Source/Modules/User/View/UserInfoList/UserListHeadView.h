//
//  UserListHeadView.h
//  livestream
//
//  Created by Calvin on 2017/12/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserListHeadViewDelegate <NSObject>
@optional;

- (void)headViewBackBtnDid;
- (void)headViewEditBtnDid;

@end

@interface UserListHeadView : UIView

@property (weak, nonatomic) id<UserListHeadViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UIImageView *levelImage;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
- (void)reloadHeaderView;
@end
