//
//  LSSayHiDetailHeadView.m
//  livestream
//
//  Created by Calvin on 2019/4/18.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiDetailHeadView.h"
#import "LSDateTool.h"
@interface LSSayHiDetailHeadView ()

@end

@implementation LSSayHiDetailHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiDetailHeadView" owner:self options:0].firstObject;
        
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.ladyHead.layer.borderWidth = 2.0f;
    self.ladyHead.layer.borderColor = [UIColor whiteColor].CGColor;
    self.ladyHead.layer.cornerRadius = self.ladyHead.tx_height/2;
    self.ladyHead.layer.masksToBounds = YES;
    
    self.noteBtn.layer.masksToBounds = YES;
    self.noteBtn.layer.cornerRadius = 5;
}

- (void)loadData:(LSSayHiDetailItemObject*)obj {
    
    if (obj.nickName.length > 0 & obj.age > 0) {
          self.titleLabel.text =[NSString stringWithFormat:@"To: %@,%d",obj.nickName,obj.age];
    }
    else {
        self.titleLabel.text = @"To:";
    }

    if (obj.sendTime > 0) {
          self.timeLabel.text = [LSDateTool getTime:obj.sendTime];
    }
    else {
     self.timeLabel.text = @"";
    }
    
    self.imageLoader = [LSImageViewLoader loader];
    
    [self.imageLoader loadImageFromCache:self.ladyHead options:0 imageUrl:obj.avatar placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
    }];
    
    self.backgroundImageloader = [LSImageViewLoader loader];
    [self.backgroundImageloader loadImageWithImageView:self.bgImage options:0 imageUrl:obj.img placeholderImage:[UIImage imageNamed:@"LS_Sayhi_DetailHeadBG"] finishHandler:^(UIImage *image) {
    }];
}

- (IBAction)headImageTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sayHiDetailHeadViewDidHeadImage)]) {
        [self.delegate sayHiDetailHeadViewDidHeadImage];
    }
}


- (IBAction)noteBtnDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(sayHiDetailHeadViewDidNoteBtn)]) {
        [self.delegate sayHiDetailHeadViewDidNoteBtn];
    }
}

- (NSString *)getTime:(NSInteger)time type:(NSString *)type {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:type];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *TimespStr = [formatter stringFromDate:confromTimesp];
    return TimespStr;
}
@end
