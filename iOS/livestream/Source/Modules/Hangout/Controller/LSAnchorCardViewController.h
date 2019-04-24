//
//  LSAnchorCardViewController.h
//  livestream
//
//  Created by test on 2019/1/30.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LSAnchorCardViewController : LSViewController
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageAndCountryLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendID;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *anchorPhotourl;
- (void)showAnchorCardView:(UIViewController *)vc;
@end
