/*
 * author: alex
 *   date: 2018-03-02
 *   file: IZBTask.h
 *   desc: Task（任务）接口类，一般情况下每个Task对应处理一个协议
 */

#include "IZBTask.h"

// 服务器主动请求的task
#include <common/CheckMemoryLeak.h>
#include "ZBRecvSendChatNoticeTask.h"
#include "ZBRecvEnterRoomNoticeTask.h"
#include "ZBRecvRoomCloseNoticeTask.h"
#include "ZBRecvLeaveRoomNoticeTask.h"
#include "ZBRecvLeavingPublicRoomNoticeTask.h"
#include "ZBRecvRoomKickoffNoticeTask.h"
#include "ZBKickOffTask.h"
#include "ZBRecvSendGiftNoticeTask.h"
#include "ZBRecvSendToastNoticeTask.h"
#include "ZBRecvTalentRequestNoticeTask.h"
#include "ZBRecvControlManPushNoticeTask.h"
#include "ZBRecvInstantInviteReplyNoticeTask.h"
#include "ZBRecvInstantInviteUserNoticeTask.h"
#include "ZBRecvBookingNoticeTask.h"
#include "ZBRecvSendSystemNoticeTask.h"
#include "IZBImClientDef.h"
#include "ZBRecvInvitationAcceptNoticeTask.h"


// 根据 cmd 创建 task
IZBTask* IZBTask::CreateTaskWithCmd(const string& cmd)
{
	IZBTask* task = NULL;
    if (cmd == ZB_CMD_RECVSENDCHATNOTICE) {
        // 4.2.接收直播间文本消息
      task = new ZBRecvSendChatNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVROOMCLOSENOTICE) {
        // 3.4.接收直播间关闭通知(观众端／主播端)
        task = new ZBRecvRoomCloseNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVENTERROOMNOTICE) {
        // 3.6.接收观众进入直播间通知
        task = new ZBRecvEnterRoomNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVLEAVEROOMNOTICE) {
        // 3.7.接收观众退出直播间通知
        task = new ZBRecvLeaveRoomNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVLEAVINGPUBLICROOMNOTICE) {
        // 3.8.接收关闭直播间倒数通知
        task = new ZBRecvLeavingPublicRoomNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVROOMKICKOFFNOTICE) {
        // 3.5.接收踢出直播间通知
        task = new ZBRecvRoomKickoffNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVSENDSYSTEMNOTICE) {
        //4.3.接收直播间公告消息
        task = new ZBRecvSendSystemNoticeTask();
    }
    else if (cmd == ZB_CMD_KICKOFF) {
        // 2.4.用户被挤掉线
        task = new ZBKickOffTask();
    }
    else if (cmd == ZB_CMD_RECVSENDGIFTNOTICE) {
        //5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
        task = new ZBRecvSendGiftNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVSENDTOASTNOTICE) {
        //6.1.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
        task = new ZBRecvSendToastNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVTALENTREQUESTNOTICE) {
        //7.1.接收直播间才艺点播邀请通知
        task = new ZBRecvTalentRequestNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVCONTROLMANPUSHNOTICE) {
        // 8.1.接收观众启动/关闭视频互动通知
        task = new ZBRecvControlManPushNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVINSTANTINVITEREPLYNOTICE) {
        // 9.2.接收立即私密邀请回复通知
        task = new ZBRecvInstantInviteReplyNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVINSTANTINVITEUSERNOTICE) {
        // 9.3.接收主播立即私密邀请通知
        task = new ZBRecvInstantInviteUserNoticeTask();
    }
    else if (cmd == ZB_CMD_RECBOOKINGNOTICE) {
        // 9.4.接收预约开始倒数通知
        task = new ZBRecvBookingNoticeTask();
    }
    else if (cmd == ZB_CMD_RECVINVITATIONACCEPTNOTICE) {
        // 9.6.接收观众接受预约通知
        task = new ZBRecvInvitationAcceptNoticeTask();
    }

    return task;
}

void IZBTask::OnSend() {
    
}

