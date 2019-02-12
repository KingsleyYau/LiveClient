/*
 * author: Samson.Fan
 *   date: 2015-03-24
 *   file: ILSLiveChatTask.h
 *   desc: Task（任务）接口类，一般情况下每个Task对应处理一个协议
 */

#include "ILSLiveChatTask.h"

// 服务器主动请求的task
#include "LSLiveChatRecvMsgTask.h"
#include "LSLiveChatRecvEmotionTask.h"
#include "LSLiveChatRecvVoiceTask.h"
#include "LSLiveChatRecvWarningTask.h"
#include "LSLiveChatUpdateStatusTask.h"
#include "LSLiveChatUpdateTicketTask.h"
#include "LSLiveChatRecvEditMsgTask.h"
#include "LSLiveChatRecvTalkEventTask.h"
#include "LSLiveChatRecvTryTalkBeginTask.h"
#include "LSLiveChatRecvTryTalkEndTask.h"
#include "LSLiveChatRecvEMFNoticeTask.h"
#include "LSLiveChatRecvKickOfflineTask.h"
#include "LSLiveChatRecvPhotoTask.h"
#include "LSLiveChatRecvShowPhotoTask.h"
#include "LSLiveChatRecvLadyVoiceCodeTask.h"
#include "LSLiveChatRecvIdentifyCodeTask.h"
#include "LSLiveChatRecvVideoTask.h"
#include "LSLiveChatRecvShowVideoTask.h"
#include "LSLiveChatRecvAutoInviteTask.h"
#include "LSLiveChatRecvAutoChargeResultTask.h"
#include "LSLiveChatRecvMagicIconTask.h"
#include "LSLiveChatRecvThemeMotionTask.h"
#include "LSLiveChatRecvThemeRecommendTask.h"
#include "LSLiveChatRecvLadyAutoInviteTask.h"
#include "LSLiveChatRecvLadyAutoInviteStatusTask.h"
#include "LSLiveChatRecvManFeeThemeTask.h"
#include "LSLiveChatRecvManApplyThemeTask.h"
#include "LSLiveChatRecvLadyCamStatusTask.h"
#include "LSLiveChatRecvAcceptCamInviteTask.h"
#include "LSLiveChatRecvManCamShareInviteTask.h"
#include "LSLiveChatRecvManCamShareStartTask.h"
#include "LSLiveChatRecvCamHearbeatExceptionTask.h"
#include "LSLiveChatRecvManJoinOrExitConferenceTask.h"
#include "LSLiveChatRecvManSessionInfoTask.h"
#include <common/CheckMemoryLeak.h>

// 根据 cmd 创建 task
ILSLiveChatTask* ILSLiveChatTask::CreateTaskWithCmd(int cmd)
{
	ILSLiveChatTask* task = NULL;
	switch (cmd) {
	case TCMD_RECVMSG:
		task = new LSLiveChatRecvMsgTask();
		break;
	case TCMD_RECVEMOTION:
		task = new LSLiveChatRecvEmotionTask();
		break;
	case TCMD_RECVVOICE:
		task = new LSLiveChatRecvVoiceTask();
		break;
	case TCMD_RECVWARNING:
		task = new LSLiveChatRecvWarningTask();
		break;
	case TCMD_UPDATESTATUS:
		task = new LSLiveChatUpdateStatusTask();
		break;
	case TCMD_UPDATETICKET:
		task = new LSLiveChatUpdateTicketTask();
		break;
	case TCMD_RECVEDITMSG:
		task = new LSLiveChatRecvEditMsgTask();
		break;
	case TCMD_RECVTALKEVENT:
		task = new LSLiveChatRecvTalkEventTask();
		break;
	case TCMD_RECVTRYBEGIN:
		task = new LSLiveChatRecvTryTalkBeginTask();
		break;
	case TCMD_RECVTRYEND:
		task = new LSLiveChatRecvTryTalkEndTask();
		break;
	case TCMD_RECVEMFNOTICE:
		task = new LSLiveChatRecvEMFNoticeTask();
		break;
	case TCMD_RECVKICKOFFLINE:
		task = new LSLiveChatRecvKickOfflineTask();
		break;
	case TCMD_RECVPHOTO:
		task = new LSLiveChatRecvPhotoTask();
		break;
	case TCMD_RECVSHOWPHOTO:
		task = new LSLiveChatRecvShowPhotoTask();
		break;
    case TCMD_RECVLADYVOICECODE:
        task = new LSLiveChatRecvLadyVoiceCodeTask();
        break;
    case TCMD_RECVIDENTIFYCODE:
        task = new LSLiveChatRecvIdentifyCodeTask();
        break;
    case TCMD_RECVVIDEO:
        task = new LSLiveChatRecvVideoTask();
        break;
    case TCMD_RECVSHOWVIDEO:
    	task = new LSLiveChatRecvShowVideoTask();
    	break;
    case TCMD_RECVAUTOINVITEMSG:
    	task = new LSLiveChatRecvAutoInviteTask();
    	break;
    case TCMD_RECVAUTOCHARGE:
		task = new LSLiveChatRecvAutoChargeResultTask();
		break;
    case TCMD_RECVMAGICICON:
    	task = new LSLiveChatRecvMagicIconTask();
		break;
	case TCMD_RECVTHEMEMOTION:
		task = new LSLiveChatRecvThemeMotionTask();
    	break;
	case TCMD_RECVTHEMERECOMMEND:
		task = new LSLiveChatRecvThemeRecommendTask();
		break;
	case TCMD_RECVLADYAUTOINVITE:
		task = new LSLiveChatRecvLadyAutoInviteTask();
		break;
	case TCMD_RECVLADYAUTOINVITESTATUS:
		task = new LSLiveChatRecvLadyAutoInviteStatusTask();
		break;
	case TCMD_RECVMANFEETHEME:
		task = new LSLiveChatRecvManFeeThemeTask();
		break;
	case TCMD_RECVMANAPPLYTHEME:
		task = new LSLiveChatRecvManApplyThemeTask();
		break;
	case TCMD_RECVLADYCAMSTATUS:
		task = new LSLiveChatRecvLadyCamStatusTask();
		break;
	case TCMD_RECVACCEPTCAMINVITE:
		task = new LSLiveChatRecvAcceptCamInviteTask();
		break;
	case TCMD_RECVMANCAMSHAREINVITE:
		task = new LSLiveChatRecvManCamShareInviteTask();
		break;
	case TCMD_RECVMANCAMSHARESTART:
		task = new LSLiveChatRecvManCamShareStartTask();
		break;
	case TCMD_RECVCAMHEARBEATEXCEPTION:
		task = new LSLiveChatRecvCamHearbeatExceptionTask();
		break;
	case TCMD_RECVMANCAMJOINOREXITCONF:
		task = new LSLiveChatRecvManJoinOrExitConferenceTask();
		break;
	case TCMD_RECVMANSESSIONINFO:
		task = new LSLiveChatRecvManSessionInfoTask();
		break;
	}

	return task;
}

void ILSLiveChatTask::OnSend() {
    
}
