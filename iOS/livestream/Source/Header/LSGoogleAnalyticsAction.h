//
//  LSGoogleAnalyticsAction.h
//  livestream
//
//  Created by test on 2017/11/8.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef LSGoogleAnalyticsAction_h
#define LSGoogleAnalyticsAction_h

#pragma mark - 登录
#define LoginUserIdCategory @"QPID_GA_UID"
#define LoginUserIdAction @"User Sign In"

#pragma mark - 其他
#define EventCategoryQN @"QN"
#define EventCategoryenterBroadcast @"enterBroadcast"
#define EventCategoryBroadcast @"Broadcast"
#define EventCategoryTransition @"Transition"
#define EventCategoryGobal @"Global"
#define EventCategoryShowCalendar @"showCalendar"

#define EventCategorySettings @"Settings"
#define EventCategoryMessage @"Message"
#define EventCategoryMail @"Mail"
#define EventCategoryGreetings @"Greetings"
#define EventCategoryCredit @"GetCredit"
#define EventCategorySendMessage @"message"
#define EventCategoryLiveChat @"LiveChat"
#define EventCategorySayHi @"SayHi"

// 广告
#define LiveChannelCloseAd @"close_Ad"
#define LiveChannelClickCover @"click_BroadcasterCover"
#define LiveChannelClickLivebanner @"click_livebanner"
#define LiveChannelClickGoWatch @"click_GoWatch"
#define LiveChannelClickLiveAd @"click_LiveAd"
// 进入直播间
#define EnterPublicBroadcast @"enter_PublicBroadcast"
#define EnterVipBroadcast @"enter_VIPPublicBroadcast"
#define EnterPrivateBroadcast @"start_PrivateBroadcast"
#define EnterVipPrivateBroadcast @"start_VIPPrivateBroadcast"
#define SendRequestBooking @"send_RequestBooking"

// 女士资料页
#define AnchorDetailCLickFollow @"click_Follow"
#define AnchorDetailClickUnFollow @"click_Unfollow"
#define AnchorDetailClickPhoto  @"click_Photo"
#define AnchorDetailCLiclVideo @"click_Video"
#define AnchorDetailClickText @"click_Text"

// 直播
#define BroadcastClickFollow @"click_Follow"
#define BroadcastClickGiftList @"click_GiftList"
#define BroadcastClickMyBalance @"click_MyBalance"
#define BroadcastClickBroadcastInfo @"click_BroadcastInfo"


//买点
#define BuyCredit @"add_Credit"


#define VipBroadcastClickReward @"click_RewardedCredit"
#define PrivateBroadcastClickVideo @"click_TwoWayVideo"
#define PrivateBroadcastClickRecommendGift @"click_RecommendGift"
#define PrivateBroadcastClickTalent @"click_Talent"


#define BroadcastTransitionClickContinue @"continue_SendInvitation"
#define BroadcastTransitionClickRecommend @"click_Recommend"
#define BroadcastTransitionClickStartVip @"start_VIPPrivateBroadcast"

#define ShowBooking @"show_BookingStart"
#define ShowInvitation @"show_Invitation"
#define ClickBooking @"click_BookingStart"
#define ClickInvitation @"click_Invitation"

//节目列表
#define ShowCalendarClickGetTicket @"click_GetTicket"
#define ShowCalendarConfirmGetTicket @"confirm_GetTicket"
#define ShowCalendarClickMyOtherShows @"click_MyOtherShows"
#define ShowCalendarClickFollowShow @"click_FollowShow"
#define ShowCalendarClickUnFollowShow @"click_UnfollowShow"

#define ShowEnterShowBroadcast @"enter_ShowBroadcast"


#define ShowCalendarClickRecommendShow @"click_RecommendShow"
#define ShowShowStart @"show_ShowStart"
#define ClickShowStart @"click_ShowStart"

//多人直播
#define ClickHangOut @"click_HangOut"
#define EnterHangOut @"enter_HangOutBroadcast"

#define InviteHangOut @"Invite_ToHangOut"
#define ClickTwoWay @"click_TwoWayVideo"
#define ClickHangOutInviteBroadcaster @"click_InviteBroadcaster"
#define ClickSendInviteBroadcast @"send_HangOutInvitation"
#define ClickHangOutNow @"click_HangOutNow"
#define ClickOpenDoor @"click_OpenDoor"


//用户设置
#define ClickLiveLogout @"click_LogOut"
#define TurnOnMessagePush @"turnon_MessagePush"
#define TurnOffMessagePush @"turnoff_MessagePush"
#define TurnOnNewMailPush @"turnon_NewMailPush"
#define TurnOffNewMailPush @"turnoff_NewMailPush"
#define ClickCredit @"click_CreditBalance"

#define ClickPushNewMsg @"click_PushNewMsg"
#define ClickPushNewMail @"click_PushNewMail"
//私信
#define SendPrivateMessage @"send_message"


//QN聊天
#define SendLivechatMessage @"send_message"
#define SendLivechatSticker @"send_Sticker"
#define SendLivechatVoiceMessage @"send_VoiceMessage"

#define ClickLivechatPush @"click_LiveChatPush"
#define ShowLiveChatInvitation @"show_LiveChatInvitation"
#define ShowLiveChatMessage @"show_LiveChatMessage"
#define ClickLiveChatInvitation @"click_LiveChatInvitation"
#define ClickLiveChatMessage @"click_LiveChatMessage"

//意向信
#define GreetingMailClickReply @"click_Reply"
#define GreetingMailClickPhoto @"click_Photo"
#define GreetingMailClickVideo @"click_Video"
#define GreetingMailClickVideoReply @"click_VideoReply"
#define GreetingMailClickQuickReply @"click_QuickReply"
#define GreetingMailClickFullScreen @"click_FullScreen"

//MAil
#define MailClickReply @"click_Reply"
#define MailClickPhoto @"click_Photo"
#define MailClickQuickReply @"click_QuickReply"
#define MailClickFullScreen @"click_FullScreen"
#define MailClickPaidPhoto @"view_PaidPhoto"
#define MailClickPaidVideo @"view_PaidVideo"

#define ReplyMailUploadPhoto @"upload_Photo"
#define ReplyMailClickSendMail @"click_SendMail"
#define ReplyMailConfirmSendMail @"confirm_SendMail"

//Sayhi
#define SayHiDetailClickReply @"click_Reply"
#define SayHiEditClickSendNow @"click_SendNow"
#endif /* LSGoogleAnalyticsAction_h */
