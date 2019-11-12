//
//  LSUserSettingFollowCell.m
//  livestream
//
//  Created by Calvin on 2018/9/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSUserSettingFollowCell.h"
#import "FollowItemObject.h"
#import "LSImageViewLoader.h"

@interface LSUserSettingFollowCell ()
@property (nonatomic, strong) NSArray * items;
@end

@implementation LSUserSettingFollowCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//标识符
+ (NSString *)cellIdentifier{
    return @"LSUserSettingFollowCell";
}
//高度
+ (NSInteger)cellHeight{
    return 150;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSUserSettingFollowCell *cell = (LSUserSettingFollowCell *)[tableView dequeueReusableCellWithIdentifier:[LSUserSettingFollowCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSUserSettingFollowCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)loadFollowData:(NSArray *)items {
    
    self.items = items;
    
    self.followInfoView.hidden = NO;
    
    CGFloat w = 56.0f;
    CGFloat spacing = 15.0f;
    
    NSInteger count = screenSize.width / (w + spacing);
    
    if (count > items.count) {
        count = items.count;
    }
    
    for (int i = 0; i < count; i++) {
        
        FollowItemObject * item = items[i];
        
        UIView * headView = [[UIView alloc]initWithFrame:CGRectMake((w+spacing) * i + spacing, 0, w, w)];
        [self.followInfoView addSubview:headView];

        UIImageView * headImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, w, w)];
        headImage.layer.cornerRadius = w/2;
        headImage.layer.masksToBounds = YES;
        headImage.contentMode = UIViewContentModeScaleAspectFill;
        headImage.backgroundColor = COLOR_WITH_16BAND_RGB(0xECEDF1);
        headImage.userInteractionEnabled = YES;
        headView.tag = i + 99;
        [headView addSubview:headImage];
        [headView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headImageTap:)]];
        
        [[LSImageViewLoader loader] loadImageFromCache:headImage options:0 imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
        }];
        
        if (item.roomType != HTTPROOMTYPE_NOLIVEROOM) {
            if (item.onlineStatus == ONLINE_STATUS_LIVE) {
                
                UIView * onlineView = [[UIView alloc]initWithFrame:CGRectMake(w/2 - 48/2, headView.tx_height - 9, 48, 15)];
                onlineView.backgroundColor = [UIColor redColor];
                onlineView.layer.cornerRadius = onlineView.tx_height/2;
                onlineView.layer.masksToBounds = YES;
                [headView addSubview:onlineView];
                
                UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(21, 0, 26, 15)];
                label.text = @"Live";
                label.font = [UIFont boldSystemFontOfSize:12];
                label.textColor = [UIColor whiteColor];
                [onlineView addSubview:label];
                
                UIImageView * onLiveView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 2, 10, 10)];
                [onlineView addSubview:onLiveView];
                
                NSArray * images = @[[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Live1"],[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Live2"],[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Live3"]];
                
                onLiveView.animationImages = images;
                onLiveView.animationRepeatCount = 0;
                onLiveView.animationDuration = 0.6;
                [onLiveView startAnimating];
            }
        }
        else {
            if (item.onlineStatus != ONLINE_STATUS_OFFLINE) {
                UIImageView * onlineView = [[UIImageView alloc]initWithFrame:CGRectMake(headView.tx_width/2 + 10, headView.tx_height - 7, 7, 7)];
                onlineView.backgroundColor = COLOR_WITH_16BAND_RGB(0x3AFF5A);
                onlineView.layer.cornerRadius = onlineView.tx_height/2;
                onlineView.layer.masksToBounds = YES;
                [headView addSubview:onlineView];
            }
        }
    }
}

- (void)headImageTap:(UITapGestureRecognizer *)tap {
    
    if ([self.cellDelegate respondsToSelector:@selector(pushFollowLadyDetails:)]) {
        NSInteger tag = tap.view.tag - 99;
        FollowItemObject * item = self.items[tag];
        [self.cellDelegate pushFollowLadyDetails:item.userId];
    }
}

@end
