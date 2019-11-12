//
//  PrivateDriveView.m
//  livestream
//
//  Created by test on 2019/9/6.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "PrivateDriveView.h"
#import "LSImageViewLoader.h"
@interface PrivateDriveView()
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *userCar;

@end



@implementation PrivateDriveView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        NSBundle *bundle = [LiveBundle mainBundle];
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];
 
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSBundle *bundle = [LiveBundle mainBundle];
        UIView *containerView = [[UINib nibWithNibName:NSStringFromClass([self class]) bundle:bundle] instantiateWithOwner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.userName.text = @"";
}


- (void)showCarAnimation:(CGPoint)point {
    self.userName.text = [NSString stringWithFormat:@"%@ Joined",self.model.nickname];
    [self.userName sizeToFit];
    [self.userCar sd_setImageWithURL:[NSURL URLWithString:self.model.riderurl]
                           placeholderImage:[UIImage imageNamed:@"Live_Room_Car"]
                                    options:0
                                  completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {

                                  }];
    
    //创建一个CABasicAnimation对象
    //位移动画
    CABasicAnimation * positionAnim = [CABasicAnimation animation];
    positionAnim.keyPath = @"position";
    
    positionAnim.toValue = [NSValue valueWithCGPoint:point];
    // 设置动画执行次数
    positionAnim.repeatCount = 1;
    // 取消动画反弹
    // 设置动画完成的时候不要移除动画
    positionAnim.removedOnCompletion = NO;
    // 设置动画执行完成要保持最新的效果
    positionAnim.fillMode = kCAFillModeForwards;
    positionAnim.duration = 1.0f;
    [self.layer addAnimation:positionAnim forKey:nil];
}

@end
