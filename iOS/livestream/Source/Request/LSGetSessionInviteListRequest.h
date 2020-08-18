//
//  LSGetSessionInviteListRequest.h
//  dating
//  17.9.获取某会话中预付费直播邀请列表
//  Created by Alex on 20/03/31
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetSessionInviteListRequest : LSSessionRequest

/**
*  17.9.获取某会话中预付费直播邀请列表接口
*
*   type             邀请来源类型（LSSCHEDULEINVITETYPE_EMF.emf  LSSCHEDULEINVITETYPE_LIVECHAT.livechat  LSSCHEDULEINVITETYPE_PUBLICLIVE.公开直播间  LSSCHEDULEINVITETYPE_PRIVATELIVE.私密直播间
*  refId            关联的ID(信件ID、livechat邀请ID、场次ID等)
*  finishHandler            接口回调
*
*  
*/
@property (nonatomic, assign) LSScheduleInviteType type;
@property (nonatomic, copy) NSString* _Nullable refId;
@property (nonatomic, strong) GetSessionInviteListFinishHandler _Nullable finishHandler;
@end
