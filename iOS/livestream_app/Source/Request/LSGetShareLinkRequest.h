//
//  LSGetShareLinkRequest.h
//  dating
//  6.11.获取分享链接接口
//  Created by Max on 17/12/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetShareLinkRequest : LSSessionRequest
/*
 *  @param shareuserId          发起分享的主播/观众ID
 *  @param anchorId             被分享的主播ID
 *  @param shareType            分享渠道（SHARETYPE_OTHER：其它，SHARETYPE_FACEBOOK：Facebook，SHARETYPE_TWITTER：Twitter）
 *  @param sharePageType        分享类型（SHAREPAGETYPE_ANCHOR：主播资料页，SHAREPAGETYPE_FREEROOM：免费公开直播间）
 */
@property (nonatomic, copy) NSString* _Nonnull shareuserId;
@property (nonatomic, copy) NSString* _Nonnull anchorId;
@property (nonatomic, assign) ShareType shareType;
@property (nonatomic, assign) SharePageType sharePageType;
@property (nonatomic, strong) GetShareLinkFinishHandler _Nullable finishHandler;
@end
