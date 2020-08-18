//
//  LSMailVideoKeyView.h
//  livestream
//
//  Created by Albert on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSDurationLabel.h"
#import "LSAccessKeyinfoItemObject.h"

@protocol LSMailVideoKeyViewDelegate <NSObject>

- (void)mailVideoKeyViewGotoVideoDetail;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LSMailVideoKeyView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet LSDurationLabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *validLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewButton;

@property (weak, nonatomic) IBOutlet UIImageView *usedImgView;
@property (nonatomic, weak) id<LSMailVideoKeyViewDelegate> delegate;

-(void)setVideoItem:(LSAccessKeyinfoItemObject *)item;

-(IBAction)viewVideoBtnOnClicked:(id)sender;

@end

NS_ASSUME_NONNULL_END
