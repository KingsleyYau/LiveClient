//
//  NoChatListView.m
//  livestream
//
//  Created by randy on 2017/8/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "NoChatListView.h"

@implementation NoChatListView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.reloadNewBtn.layer.cornerRadius = 8;
        self.reloadNewBtn.layer.masksToBounds = YES;
        self.reloadNewBtn.hidden = YES;
    }
    
    return self;
}

+ (instancetype)initNoChatListViewXib {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:@"NoChatListView" owner:nil options:nil];
    NoChatListView* view = [nibs objectAtIndex:0];
    
    return view;
}

- (IBAction)reloadList:(id)sender {
 
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadNewList:)]) {
        
        [self.delegate reloadNewList:self];
    }
}

- (void)isHavePrivateList:(BOOL)isNum {
    
    self.reloadNewBtn.hidden = isNum;
    
    if (isNum) {
        
        self.tipLabel.text = @"Your contact list is empty";
        self.tipLabelBootomDistance.constant = -20;
    }else{
        
        self.tipLabel.text = @"Failed to load.\n Please reload.";
        self.tipLabelBootomDistance.constant = -70;
    }
}

@end
