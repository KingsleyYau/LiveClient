//
//  LSPrepaidInfoView.m
//  livestream
//
//  Created by Calvin on 2020/4/9.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPrepaidInfoView.h"
#import "LSConfigManager.h"
@interface LSPrepaidInfoView ()

@end

@implementation LSPrepaidInfoView

 - (instancetype)init {
     self = [super init];
     if (self) {
         self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPrepaidInfoView" owner:self options:0].firstObject;
         self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
     }
     return self;
 }

 - (void)awakeFromNib {
     [super awakeFromNib];
     
     self.purchaseView.layer.cornerRadius = 5;
     self.purchaseView.layer.masksToBounds = YES;
     
     self.aView.layer.masksToBounds = YES;
     self.aView.layer.cornerRadius = self.aView.tx_width/2;
     
      self.bView.layer.masksToBounds = YES;
      self.bView.layer.cornerRadius = self.aView.tx_width/2;
     
     self.cView.layer.masksToBounds = YES;
     self.cView.layer.cornerRadius = self.aView.tx_width/2;
     
     self.dView.layer.masksToBounds = YES;
     self.dView.layer.cornerRadius = self.aView.tx_width/2;
     
     NSString * upStr = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"discount_num"),[LSConfigManager manager].item.scheduleSaveUp];
     NSString * title = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"TITLE"),upStr];
     
     NSMutableAttributedString * attr = [[NSMutableAttributedString alloc]initWithString:title];
     [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} range:[title rangeOfString:upStr]];
     
     self.infoLabel.attributedText = attr;
 }

- (IBAction)closeBtnDid:(id)sender {
    [self removeFromSuperview];
}

@end
