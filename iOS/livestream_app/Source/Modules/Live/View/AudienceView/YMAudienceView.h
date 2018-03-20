//
//  YMAudienceView.h
//  YueMao
//
//  Created by 范明玮 on 16/5/20.
//
//

#import <UIKit/UIKit.h>

@class YMAudienceView;
@protocol YMAudienceViewDelegate <NSObject>

//- (void)liveAudidenceView:(YMAudienceView *)audienceView didTapHeadWithObject:(Cs_13111List *)list;
- (void)liveReloadAudidenceView:(YMAudienceView *)audienceView;
- (void)liveLoadingAudienceView:(YMAudienceView *)audienceView;
- (void)liveAudidenveViewDidScroll;
- (void)liveAudidenveViewDidEndScrolling;

@end

@interface YMAudienceView : UIView

@property(nonatomic, weak) id<YMAudienceViewDelegate> delegate;
@property(nonatomic, strong) NSMutableArray *audienceArray;

@end
