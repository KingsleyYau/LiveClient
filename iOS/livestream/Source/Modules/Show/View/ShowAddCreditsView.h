//
//  ShowAddCreditsView.h
//  livestream
//
//  Created by Calvin on 2018/4/18.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSProgramItemObject.h"
@protocol ShowAddCreditsViewDelegate <NSObject>

- (void)showAddCreditsViewGetTicketBtnDid:(NSString *)showId;

@end

@interface ShowAddCreditsView : UIView 

@property (nonatomic, strong) LSProgramItemObject * obj;
@property (nonatomic, weak) id<ShowAddCreditsViewDelegate> delegate;

- (void)updateUI:(LSProgramItemObject *)item;
@end
