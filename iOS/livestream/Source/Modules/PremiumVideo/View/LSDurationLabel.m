//
//  LSDurationLabel.m
//  livestream
//
//  Created by Albert on 2020/8/4.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSDurationLabel.h"

@interface LSDurationLabel()
{
    UIView *bgView;
}
@property (strong, nonatomic) UILabel *txtLabel;

@end

@implementation LSDurationLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setBackgroundColor:[UIColor clearColor]];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 3.f;
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    [bgView setBackgroundColor:[UIColor blackColor]];
//    bgView.alpha = 0.4f;
    [bgView setBackgroundColor:[UIColor colorWithRed:56/255.0 green:56/255.0 blue:56/255.0 alpha:1/1.0]];
    
    [self addSubview:bgView];
    [bgView mas_updateConstraints:^(MASConstraintMaker *make){
        make.left.right.bottom.top.equalTo(self);
    }];
    
    self.txtLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.txtLabel setTextColor:[UIColor whiteColor]];
    [self.txtLabel setFont:[UIFont fontWithName:@"ArialMT" size:12]];
    [self.txtLabel setText:@"00:00"];
    [self.txtLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.txtLabel];
    [self.txtLabel mas_updateConstraints:^(MASConstraintMaker *make){
        make.left.right.bottom.top.equalTo(self);
    }];
}

-(NSString *)getDurationString:(int)duration
{
    NSString *str = @"";
    if (duration<60) {
        str = [NSString stringWithFormat:@"00:%02d",duration];
    }else if (duration<60*60) {
        str = [NSString stringWithFormat:@"%02d:%02d",duration/60,duration%60];
    }else{
        str = [NSString stringWithFormat:@"%02d:%02d:%02d",duration/3600,(duration%3600)/60,duration%60];
    }
    return str;
}

-(void)setText:(NSString *)text{
    [self.txtLabel setText:text];
}

-(void)setFont:(UIFont *)font{
    [self.txtLabel setFont:font];
}

-(void)setDuration:(int)duration
{
    NSString *text = [self getDurationString:duration];
    [self.txtLabel setText:text];
}

@end
