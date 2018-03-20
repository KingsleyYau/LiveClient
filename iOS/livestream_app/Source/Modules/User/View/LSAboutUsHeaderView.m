//
//  LSAboutUsHeaderView.m
//  livestream
//
//  Created by test on 2017/12/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSAboutUsHeaderView.h"

@implementation LSAboutUsHeaderView


- (instancetype)init
{
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil].firstObject;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *curVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    self.versionCode.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedStringFromSelf(@"Version"),curVersion];
}



@end
