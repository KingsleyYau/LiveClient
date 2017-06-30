/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ITask.h
 *   desc: Task（任务）接口类，一般情况下每个Task对应处理一个协议
 */

#include "ITask.h"

// 服务器主动请求的task
#include <common/CheckMemoryLeak.h>
#include "RecvRoomMsgTask.h"
#include "RecvFansRoomInTask.h"
#include "RecvRoomCloseFansTask.h"
#include "RecvRoomCloseBroadTask.h"
#include "KickOffTask.h"
#include "RecvShutUpNoticeTask.h"
#include "RecvKickOffRoomNoticeTask.h"
#include "RecvPushRoomFavTask.h"
#include "RecvRoomGiftNoticeTask.h"
#include "RecvRoomToastNoticeTask.h"
#include "IImClientDef.h"


// 根据 cmd 创建 task
ITask* ITask::CreateTaskWithCmd(const string& cmd)
{
	ITask* task = NULL;
    if (cmd == CMD_RECVROOMMSG) {
      task = new RecvRoomMsgTask();
    }
    else if (cmd == CMD_RECVROOMCLOSEFANS) {
        task = new RecvRoomCloseFansTask();
    }
    else if (cmd == CMD_RECVROOMCLOSEBROAD) {
        task = new RecvRoomCloseBroadTask();
    }
    else if (cmd == CMD_RECVFANSROOMIN) {
        task = new RecvFansRoomInTask();
    }
    else if (cmd == CMD_KICKOFF) {
        task = new KickOffTask();
    }
    else if (cmd == CMD_RECVSHUTUPNOTICE) {
        task = new RecvShutUpNoticeTask();
    }
    else if (cmd == CMD_RECVKICKOFFROOMNOTICE) {
        task = new RecvKickOffRoomNoticeTask();
    }
    else if (cmd == CMD_RECVPUSHROOMFAV) {
        task = new RecvPushRoomFavTask();
    }
    else if (cmd == CMD_RECVROOMGIFTNOTICE) {
        task = new RecvRoomGiftNoticeTask();
    }
    else if (cmd == CMD_RECVROOMTOASTNOTICE) {
        task = new RecvRoomToastNoticeTask();
    }
    return task;
}

void ITask::OnSend() {
    
}

