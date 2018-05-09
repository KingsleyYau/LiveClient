//
//  LiveFinshViewController.h
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LiveRoom.h"
#import "ShowListView.h"
@interface LiveFinshViewController : LSGoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIView *recommandView;

@property (weak, nonatomic) IBOutlet UICollectionView *recommandCollectionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recommandViewWidth;

@property (weak, nonatomic) IBOutlet UIButton *bookPrivateBtn;

@property (weak, nonatomic) IBOutlet UIButton *viewHotBtn;

@property (weak, nonatomic) IBOutlet UIButton *addCreditBtn;
@property (weak, nonatomic) IBOutlet ShowListView *showView;
@property (nonatomic, assign) LCC_ERR_TYPE errType;
@property (nonatomic, copy) NSString *errMsg;

@property (nonatomic, strong) LiveRoom *liveRoom;

- (void)handleError:(LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg;

@end
