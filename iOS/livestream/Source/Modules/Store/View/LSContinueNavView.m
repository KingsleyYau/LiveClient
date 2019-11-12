//
//  LSContinueNavView.m
//  livestream
//
//  Created by Calvin on 2019/10/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSContinueNavView.h"
#import "LSImageViewLoader.h"
@interface LSContinueNavView ()
@property (nonatomic, strong) LSImageViewLoader * imageViewLoader;
@end

@implementation LSContinueNavView

- (instancetype)initWithFrame:(CGRect)frame {
     self = [super initWithFrame:frame];
     if (self) {
         self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSContinueNavView" owner:self options:0].firstObject;
         self.frame = frame;
     }
     return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headImage.layer.cornerRadius = self.headImage.tx_height/2;
    self.headImage.layer.masksToBounds = YES;
    
    self.imageViewLoader = [LSImageViewLoader loader];
}

- (void)setName:(NSString *)name andHeadImage:(NSString *)imageUrl {
    
    if (name.length > 0) {
            CGFloat nameW = [name sizeWithAttributes:@{NSFontAttributeName:self.nameLabel.font}].width;
        if (nameW > self.tx_width - 185) {
            nameW = self.tx_width - 185;
        }
        self.nameLabel.tx_width = nameW;
        self.nameLabel.text = name;
        
        self.headImage.tx_x = self.nameLabel.tx_width + self.nameLabel.tx_x + 10;
    }
    
    if (imageUrl.length > 0) {
          [self.imageViewLoader loadImageWithImageView:self.headImage options:0 imageUrl:imageUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
             
          }];
    }
}

- (IBAction)checkoutBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(continueNavViewCheckoutBtnDid)]) {
        [self.delegate continueNavViewCheckoutBtnDid];
    }
}

@end
