
/*
 * author: Samson.Fan
 *   date: 2015-03-19
 *   file: LSLiveChatManManager.cpp
 *   desc: LiveChat客户端实现类
 */

#include "LSLiveChatManManager.h"

#include <httpclient/HttpRequestDefine.h>

#include <common/CommonFunc.h>
#include <common/KLog.h>
#include <common/IAutoLock.h>
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

#include <livechat/ILSLiveChatClient.h>

// 消息管理器
#include "LSLCTextManager.h"
#include "LSLCEmotionManager.h"
#include "LSLCVoiceManager.h"
#include "LSLCPhotoManager.h"
#include "LSLCVideoManager.h"
#include "LSLCWarningItem.h"

// 用户管理器
#include "LSLCUserManager.h"
#include "LSLCInviteManager.h"
#include "LSLCBlockManager.h"
#include "LSLCContactManager.h"
#include "LSLiveChatEnumDefine.h"
#include <ProtocolCommon/DeviceTypeDef.h>
static const int s_msgIdBegin = 1;		// 消息ID起始值

const char* LOG_DIR = "log/";						// log目录路径
const char* HTTP_LOG_DIR = LOG_DIR;					// http log目录路径
const char* HTTP_COOKIE_DIR = "cookie/";			// http cookie目录路径
const char* EMOTION_DIR = "livechat/emotion";		// 高级表情目录路径
const char* VOICE_DIR = "livechat/voice";			// 语音目录路径
const char* PHOTO_DIR = "livechat/photo";			// 图片目录路径
const char* PHOTO_TEMP_DIR = "livechat/temp/photo";	// 图片临时目录路径
const char* VIDEO_DIR = "livechat/video";			// 视频目录路径
const char* MAGICICON_DIR = "livechat/magicicon";   //小高级表情目录路径

// 定时业务类型
typedef enum {
    REQUEST_TASK_Unknow,						// 未知请求类型
    REQUEST_TASK_GetEmotionConfig,				// 获取高级表情配置
    REQUEST_TASK_GetMagicIconConfig,            // alex获取小高级表情配置
    REQUEST_TASK_AutoRelogin,					// 执行自动重登录流程
    REQUEST_TASK_LoginManagerLogout,            // LoginManager注销
    REQUEST_TASK_SendMessageListNoMoneyFail,    // 处理指定用户的待发消息发送不成功(余额不足)
    REQUEST_TASK_SendMessageListConnectFail,    // 处理指定用户的待发消息发送不成功(连接失败)
    REQUEST_TASK_GetUsersHistoryMessage,        // 获取用户的聊天历史记录
    REQUEST_TASK_ReleaseEmotionDownloader,		// 释放高级表情downloader
    REQUEST_TASK_ReleasePhotoDownloader,		// 释放图片downloader
    REQUEST_TASK_ReleaseVideoPhotoDownloader,	// 释放视频图片downloader
    REQUEST_TASK_ReleaseVideoDownloader,		// 释放视频downloader
    REQUEST_TASK_ReleaseMagicIconDownloader,	// 释放高级表情downloader
    REQUEST_TASK_CheckPhotoList,	            // 检查私密照是否收费
    REQUEST_TASK_SendPhotoWithURL,              // http发送私密照片（由http 12.16.上传LiveChat相关附件）
    REQUEST_TASK_GetVideo,                      // 获取视频（用于获取视频时，而url又没有，先feevideo，feevideo返回后再getvideo）
    REQUEST_TASK_NOPRIV_SENDMESSAGE,            // 没有发送消息权限，线程返回发送成功
    REQUEST_TASK_NOLOGIN_PHOTOANDVIDEOFEE,      // IM没有登录购买私密照和视频，线程返回网络失败
} REQUEST_TASK_TYPE;

// 定时业务结构体
class RequestItem
{
public:
    RequestItem()
    {
        requestType = REQUEST_TASK_Unknow;
        param = 0;
    }
    
    RequestItem(const RequestItem& item)
    {
        requestType = item.requestType;
        param = item.param;
    }
    
    ~RequestItem(){};
    
    REQUEST_TASK_TYPE requestType;
    unsigned long long param;
};

LSLiveChatManManager::LSLiveChatManManager()
{
	m_listener = NULL;

	m_dirPath = "";
	m_port = 0;
	m_siteType = OTHER_SITE_UNKNOW;
	m_appVer = "";

	m_userId = "";
    m_userName = "";
	m_sId = "";
    m_myServer = "";
    m_clientType = CLIENT_UNKNOW;
	m_deviceId = "";
	m_riskControl = LIVECHATINVITE_RISK_NOLIMIT;
    m_riskLiveChat = false;
    m_riskCamShare = false;
    m_isSendPhotoPriv = true;
    m_isSendVoicePriv = true;
    m_liveChatPriv = true;
	m_isLogin = false;
    m_isGetHistory = false;
    m_isResetParam = false;
	m_isAutoLogin = false;
	m_getUsersHistoryMsgRequestId = HTTPREQUEST_INVALIDREQUESTID;
	m_msgIdBuilder.Init(s_msgIdBegin);

	// LiveChat客户端
	m_client = ILSLiveChatClient::CreateClient();
    m_client->AddListener(this);
    
	// 消息管理器
	m_textMgr = new LSLCTextManager;			// 文本管理器
	m_emotionMgr = new LSLCEmotionManager;	// 高级表情管理器
	m_voiceMgr = new LSLCVoiceManager;		// 语音管理器
	m_photoMgr = new LSLCPhotoManager;		// 图片管理器
	m_videoMgr = new LSLCVideoManager;		// 视频管理器
    m_magicIconMgr = new LSLCMagicIconManager; //小高级表情管理器
    m_autoInviteFilter = NULL; // 自动邀请过滤器

	// 用户管理器
	m_userMgr = new LSLCUserManager;			// 用户管理器
	m_inviteMgr = new LSLCInviteManager;		// 邀请管理器
	m_blockMgr = new LSLCBlockManager;		// 黑名单管理器
	m_contactMgr = new LSLCContactManager;	// 联系人管理器

	// 请求线程
	m_requestThread = NULL;
	m_requestThreadStart = false;
	m_requestQueueLock = IAutoLock::CreateAutoLock();
	m_requestQueueLock->Init();
    
	// 请求管理器及控制器
	m_httpRequestManager = NULL;
	m_httpRequestHostManager = NULL;
	m_requestController = NULL;
	m_requestOtherController = NULL;
    
    m_liveChatSender = NULL;
    m_liveChatSessionManager = NULL;
    m_liveChatCamshareManager = NULL;
    
    m_minCamshareBalance = 0.0;
}

LSLiveChatManManager::~LSLiveChatManManager()
{
    // 停止所有请求
    StopRequestThread();
    IAutoLock::ReleaseAutoLock(m_requestQueueLock);

    // Livechat会话管理器
    if( m_liveChatSessionManager ) {
        delete m_liveChatSessionManager;
        m_liveChatSessionManager = NULL;
    }
    
    // Camshare会话管理器
    if( m_liveChatCamshareManager ) {
        delete m_liveChatCamshareManager;
        m_liveChatCamshareManager = NULL;
    }
    
    // 消息发送器
    if( m_liveChatSender ) {
        delete m_liveChatSender;
        m_liveChatSender = NULL;
    }
    
    // 去除回调
    if( m_client ) {
        m_client->RemoveListener(this);
    }
    
    // 释放连接
	ILSLiveChatClient::ReleaseClient(m_client);

	delete m_textMgr;
	delete m_emotionMgr;
	delete m_voiceMgr;
	delete m_photoMgr;
	delete m_videoMgr;
    // 释放小高级表情管理器
    delete m_magicIconMgr;

	delete m_userMgr;
	delete m_inviteMgr;
	delete m_blockMgr;
	delete m_contactMgr;

	delete m_requestController;
	delete m_requestOtherController;

	delete m_httpRequestManager;
	delete m_httpRequestHostManager;

}

bool LSLiveChatManManager::IsAutoLogin() {
    return m_isAutoLogin;
}

string LSLiveChatManManager::GetUserId() {
    return m_userId;
}

string LSLiveChatManManager::GetUserName() {
    return m_userName;
}

string LSLiveChatManManager::GetSid() {
    return m_sId;
}

int LSLiveChatManManager::GetSiteType() {
    return m_siteType;
}

double LSLiveChatManManager::GetMinBalance() {
    return m_minBalance;
}

int LSLiveChatManManager::GetSocket() {
    return m_client->GetSocket();
}

bool LSLiveChatManManager::IsNoMoneyWithErrCode(const string& errCode) {
    return IsNotSufficientFundsWithErrCode(errCode);
}

// 设置本地缓存目录路径
bool LSLiveChatManManager::SetDirPath(const string& path)
{
	bool result = false;

	FileLog("LiveChatManager", "LiveChatManager::SetDirPath() path:%s", path.c_str());

	if (!path.empty()
		&& MakeDir(path))
	{
		result = true;

		m_dirPath = path;
		if (m_dirPath.at(m_dirPath.length()-1) != '/'
			&& m_dirPath.at(m_dirPath.length()-1) != '\\')
		{
			m_dirPath += '/';
		}

		// http log目录
		string httpLogPath = m_dirPath + HTTP_LOG_DIR;
		HttpClient::SetLogDirectory(httpLogPath);
		// http cookie目录
		string httpCookiePath = m_dirPath + HTTP_COOKIE_DIR;
		HttpClient::SetCookiesDirectory(httpCookiePath);

		// log目录
		string logPath = m_dirPath + LOG_DIR;
		KLog::SetLogDirectory(logPath);

		// 设置emotion manager本地缓存目录
		string emotionPath = m_dirPath + EMOTION_DIR;
		result = result && m_emotionMgr->SetDirPath(emotionPath, logPath);

		FileLog("LiveChatManager", "LiveChatManager::SetDirPath() m_emotionMgr->SetDirPath() logPath:%s, result:%d", logPath.c_str(), result);

		// 设置voice manager本地缓存目录
		string voicePath = m_dirPath + VOICE_DIR;
		result = result && m_voiceMgr->Init(voicePath);

		FileLog("LiveChatManager", "LiveChatManager::SetDirPath() m_voiceMgr->Init() voicePath:%s, result:%d", voicePath.c_str(), result);

		// 设置photo manager本地缓存目录
		string photoPath = m_dirPath + PHOTO_DIR;
		result = result && m_photoMgr->SetDirPath(photoPath);
        
        FileLog("LiveChatManager", "LiveChatManager::SetDirPath() m_photoMgr->SetDirPath() photoPath:%s, result:%d", photoPath.c_str(), result);
        
        // 设置photo manager临时本地缓存目录
        string photoTempPath = m_dirPath + PHOTO_TEMP_DIR;
        result = result && m_photoMgr->SetTempDirPath(photoTempPath);

		FileLog("LiveChatManager", "LiveChatManager::SetDirPath() m_photoMgr->SetTempDirPath() photoTempPath:%s, result:%d", photoTempPath.c_str(), result);

		// 设置video manager本地缓存目录
		string videoPath = m_dirPath + VIDEO_DIR;
		result = result && m_videoMgr->SetDirPath(videoPath);

		FileLog("LiveChatManager", "SetDirPath() m_videoMgr->SetDirPath() videoPath:%s, result:%d", videoPath.c_str(), result);
        
        // 设置magicIcon manager本地缓存目录
        string MagicIconPath = m_dirPath + MAGICICON_DIR;
        result = result && m_magicIconMgr->SetDirPath(MagicIconPath, logPath);
        
        FileLog("LiveChatManager", "LiveChatManager::SetDirPath() m_magicIconMgr->SetDirPath() MagicIconPath:%s, logPath:%s, result:%d", MagicIconPath.c_str(), logPath.c_str(), result);
	}
	return result;
}

// 初始化
bool LSLiveChatManManager::Init(list<string> ipList
							, int port
							, OTHER_SITE_TYPE siteType
							, const string& webHost
							, const string& appHost
							, const string& chatVoiceHost
							, const string& httpUser
							, const string& httpPassword
							, const string& appVer
                            , const string& appId
							, const string& path
							, double minBalance
                            , double minCamshareBalance
							, ILSLiveChatManManagerListener* listener)
{
	bool result = false;

	FileLog("LiveChatManager", "LiveChatManager::Init() begin, ipList.size:%d, port:%d, webHost:%s"
			, ipList.size(), port, webHost.c_str());

	if (!ipList.empty()
		&& port > 0
		&& !webHost.empty()
		&& !appHost.empty()
		&& !chatVoiceHost.empty()
		&& !appVer.empty()
		&& siteType != OTHER_SITE_UNKNOW
		&& SetDirPath(path))
	{
		FileLog("LiveChatManager", "LiveChatManager::Init() emotionMgr->Init() begin");
		result = m_emotionMgr->Init(webHost, this);
		FileLog("LiveChatManager", "LiveChatManager::Init() emotionMgr->Init() result:%d", result);
		result = result && m_photoMgr->Init(this);
		FileLog("LiveChatManager", "LiveChatManager::Init() m_photoMgr->Init() result:%d", result);
		result = result && m_videoMgr->Init(this, m_userMgr);
		FileLog("LiveChatManager", "LiveChatManager::Init() m_videoMgr->Init() result:%d", result);
        result = result && m_inviteMgr->Init(m_userMgr, m_blockMgr, m_contactMgr, m_client);
        FileLog("LiveChatManager", "LiveChatManager::Init() Mm_inviteMgr->Init() result:%d", result);
        //初始化小高级表情管理器 alex 2016-09-09
        result = result && m_magicIconMgr->Init(webHost, this);
        FileLog("LiveChatManager", "LiveChatManager::Init() magicIconMgr->Init() result:%d", result);
		result = result && m_client->Init(ipList, port);
		FileLog("LiveChatManager", "LiveChatManager::Init() client->Init() result:%d", result);
		if (result) {
			delete m_httpRequestHostManager;
			m_httpRequestHostManager = new LSLiveChatHttpRequestHostManager();
			result = (NULL != m_httpRequestHostManager);
		}
		FileLog("LiveChatManager", "LiveChatManager::Init() new HttpRequestHostManager result:%d", result);
		if (result) {
			delete m_httpRequestManager;
			m_httpRequestManager = new LSLiveChatHttpRequestManager();
			if (NULL != m_httpRequestManager) {
				m_httpRequestManager->SetHostManager(m_httpRequestHostManager);
			}
			result = (NULL != m_httpRequestManager);
		}
		FileLog("LiveChatManager", "LiveChatManager::Init() new LSLiveChatHttpRequestManager result:%d", result);
		if (result) {
			delete m_requestController;
			m_requestController = new LSLiveChatRequestLiveChatController(m_httpRequestManager, this);
			result = (NULL != m_requestController);
		}
		FileLog("LiveChatManager", "LiveChatManager::Init() new requestLiveChatController result:%d", result);
		if (result) {
			delete m_requestOtherController;
			m_requestOtherController = new LSLiveChatRequestOtherController(m_httpRequestManager, this);
			result = (NULL != m_requestOtherController);
		}
		FileLog("LiveChatManager", "LiveChatManager::Init() new requestOtherController result:%d", result);
	}

	if (result)
	{
		// 设置http参数
		m_httpRequestManager->SetVersionCode(appVer);
		if (!httpUser.empty()) {
			m_httpRequestManager->SetAuthorization(httpUser, httpPassword);
		}
        if (!appId.empty()) {
            m_httpRequestManager->SetAppId(appId);
        }
		m_httpRequestHostManager->SetWebSite(webHost);
		m_httpRequestHostManager->SetAppSite(appHost);
		m_httpRequestHostManager->SetChatVoiceSite(chatVoiceHost);

		// 设置高级表情管理器的http参数
		m_emotionMgr->SetAuthorization(httpUser, httpPassword);
        
        // 设置高级表情管理器的http参数
        m_magicIconMgr->SetAuthorization(httpUser, httpPassword);

		// 设置图片管理器的http控制器
		m_photoMgr->SetHttpRequest(m_httpRequestManager, m_requestController);

		// 设置视频管理器的http参数
		m_videoMgr->SetAuthorization(httpUser, httpPassword);
		// 设置视频管理器的http控制器
		m_videoMgr->SetHttpRequest(m_httpRequestManager, m_requestController);

		// 设置参数
		m_listener = listener;
		m_siteType = siteType;
		m_appVer = appVer;
		m_minBalance = minBalance;
        m_minCamshareBalance = minCamshareBalance;

		// 清除资源文件
		// RemoveSourceFile();
        
        // 消息发送器
        if( m_liveChatSender ) {
            delete m_liveChatSender;
            m_liveChatSender = NULL;
        }
        m_liveChatSender = new LSLiveChatSender(
                                              this,
                                              m_listener,
                                              m_client,
                                              m_textMgr,
                                              m_emotionMgr,
                                              m_voiceMgr,
                                              m_photoMgr,
                                              m_videoMgr,
                                              m_magicIconMgr,
                                              m_userMgr,
                                              m_inviteMgr,
                                              m_httpRequestManager
                                              );
        
        // Livechat会话管理器
        if( m_liveChatSessionManager ) {
            delete m_liveChatSessionManager;
            m_liveChatSessionManager = NULL;
        }
        m_liveChatSessionManager = new LSLiveChatSessionManager(
                                                              this,
                                                              m_listener,
                                                              m_client,
                                                              m_liveChatSender,
                                                              m_userMgr,
                                                              m_httpRequestManager
                                                              );
        
        // Camshare会话管理器
        if( m_liveChatCamshareManager ) {
            delete m_liveChatCamshareManager;
            m_liveChatCamshareManager = NULL;
        }
        
        m_liveChatCamshareManager = new LSLiveChatCamshareManager(
                                                                this,
                                                                m_listener,
                                                                m_client,
                                                                m_liveChatSender,
                                                                m_userMgr,
                                                                m_blockMgr,
                                                                m_httpRequestManager
                                                                );
        
        m_liveChatCamshareManager->SetMinCamshareBalance(minCamshareBalance);
        
        if (m_autoInviteFilter) {
            delete m_autoInviteFilter;
            m_autoInviteFilter = NULL;
        }
        m_autoInviteFilter = new LSLCAutoInviteFilter(this, m_client);

    }
    
	FileLog("LiveChatManager", "LiveChatManager::Init() end, result:%d", result);
	return result;
}

// 重置参数（用于非自动登录时重置参数）
void LSLiveChatManManager::ResetParamWithNotAutoLogin()
{
    if (m_isResetParam) {
        // 停止请求队列处理线程
        StopRequestThread();
        // 清空请求队列
        CleanRequestTask();
        
        // 停止所有请求中的操作
        if (NULL != m_httpRequestManager) {
            // 修改StopAllRequest的ture为false， 不修改会导致死锁，stopallrequest->加锁停止request请求线程——》request停止线程会返回onfail里面又有锁导致死锁
            m_httpRequestManager->StopAllRequest(true);
        }

        m_userId = "";
        m_userName = "";
        m_sId = "";
        m_myServer = "";
        m_deviceId = "";
        m_riskControl = LIVECHATINVITE_RISK_NOLIMIT;
        m_riskLiveChat = false;
        m_riskCamShare = false;
        m_isSendPhotoPriv = true;
        m_liveChatPriv = true;
        m_msgIdBuilder.Init(s_msgIdBegin);

        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear emotion begin");
        // 停止获取高级表情配置请求
        if (HTTPREQUEST_INVALIDREQUESTID != m_emotionMgr->m_emotionConfigReqId) {
    //			RequestJni.StopRequest(m_emotionMgr->m_emotionConfigReqId);
            m_emotionMgr->m_emotionConfigReqId = HTTPREQUEST_INVALIDREQUESTID;
        }
        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear emotion StopAllDownloadImage");
        m_emotionMgr->StopAllDownloadImage();
        // 停止播放文件下载(注意之前没有调用这个，可能漏了，之后要注意添加后会不会有问题)
        m_emotionMgr->StopAllDownloadPlayImage();
        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear emotion removeAllSendingItems");
        m_emotionMgr->RemoveAllSendingItems();
        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear emotion ClearAllDownloader");
        m_emotionMgr->ClearAllDownloader();

        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear photo begin");
        // 停止所有图片请求
        m_photoMgr->ClearAllRequestItems();
        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear photo clearAllSendingItems");
        m_photoMgr->ClearAllSendingItems();
        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear photo ClearAllDownload");
        m_photoMgr->ClearAllDownload();
        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear photo ClearPhotoMap");
        m_photoMgr->ClearPhotoMap();
        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear photo ClearBindMap");
        m_photoMgr->ClearBindMap();

        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear voice begin");
        // 停止所有语音请求
        m_voiceMgr->ClearAllRequestItem();
    //		ArrayList<Long> voiceRequestIds = m_voiceMgr->clearAllRequestItem();
    //		if (NULL != voiceRequestIds) {
    //			for (Iterator<Long> iter = voiceRequestIds.iterator(); iter.hasNext(); ) {
    //				long requestId = iter.next();
    //				RequestJni.StopRequest(requestId);
    //			}
    //		}
        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear voice clearAllSendingItems");
        m_voiceMgr->ClearAllSendingItems();

        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear video begin");
        // 停止所有视频请求
        m_videoMgr->ClearAllDownloadVideoPhoto();
        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear video ClearAllDownloadVideoPhoto");
        m_videoMgr->ClearAllDownloadVideo();
        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear video ClearAllDownloadVideo");
        m_videoMgr->ClearAllPhotoFee();

        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear other begin");
        m_textMgr->RemoveAllSendingItems();
        FileLog("LiveChatManager", "LiveChatManager::ResetParamWithNotAutoLogin() clear other removeAllUserItem");
        m_userMgr->RemoveAllUserItem();
        
        // 停止所有小高表请求
        if(HTTPREQUEST_INVALIDREQUESTID != m_magicIconMgr->m_magicIconConfigReqId){
            m_magicIconMgr->m_magicIconConfigReqId = HTTPREQUEST_INVALIDREQUESTID;
        }
        // 停止所有下载的母子图
        m_magicIconMgr->StopAllDownloadThumbImage();
        // 停止所有下载的原图
        m_magicIconMgr->StopAllDownloadSourceImage();
        // 删除所有待发送的message
        m_magicIconMgr->RemoveAllSendingItems();
        // 清除所有的小高级表情的下载器
        m_magicIconMgr->ClearAllDownloader();
        
        // 会话管理器参数清空
        m_liveChatSessionManager->Reset();
        
        // 清除HttpClient的cookies(注释掉，换站时，http登录比清除快时，导致清除cookies，其他的http接口就失败了，Alex，2019-07-31)
        //HttpClient::CleanCookies();
        m_cookies.clear();
    }
}

// 重置参数（用于自动登录时重置参数）
void LSLiveChatManManager::ResetParamWithAutoLogin()
{
    // 删除图片关联
//    m_photoMgr->ClearAllRequestItems();
//    m_photoMgr->ClearAllDownload();
//    m_photoMgr->ClearBindMap();
//    m_isGetHistory = false;
    
    
//   LCUserList userList = m_userMgr->GetChatingUsers();
//    for(LCUserList::iterator itr = userList.begin(); itr != userList.end(); itr++) {
//        LSLCUserItem *userItem = *itr;
//        userItem->m_getHistory = false;
//    }
}

// 登录
bool LSLiveChatManManager::Login(const string& userId, const string& userName, const string& sid, CLIENT_TYPE clientType, const list<string>& cookies, const string& deviceId, LIVECHATINVITE_RISK_TYPE riskType, bool liveChatRisk, bool camShareRisk, bool isSendPhotoPriv, bool liveChatPriv, bool isSendVoicePriv)
{
	string strCookies("");
	if (!cookies.empty()) {
		for (list<string>::const_iterator iter = cookies.begin();
			iter != cookies.end();
			iter++)
		{
			if (!strCookies.empty()) {
				strCookies += ", ";
			}
			strCookies += (*iter);
		}
	}

	FileLog("LiveChatManager", "LiveChatManager::Login() begin, userId:%s, userName:%s, sid:%s, clientType:%d, deviceId:%s, m_isLogin:%d, cookies:%s"
			, userId.c_str(), userName.c_str(), sid.c_str(), clientType, deviceId.c_str(), m_isLogin, strCookies.c_str());

	bool result = false;
	if (m_isLogin) {
		result = m_isLogin;
	}
	else {
		if (!m_isAutoLogin) {
			// 重置参数
			ResetParamWithNotAutoLogin();
		}

		// LiveChat登录
		result = m_client->Login(userId, sid, deviceId, clientType, USER_SEX_MALE);
		if (result && !m_isAutoLogin)
		{
			// 启动请求队列处理线程
			StartRequestThread();
			// 设置参数
			m_isAutoLogin = true;
			m_userId = userId;
            m_userName = userName;
			m_sId = sid;
            m_clientType = clientType;
			m_deviceId = deviceId;
			m_cookies = cookies;
			HttpClient::SetCookiesInfo(cookies);
            m_riskControl = riskType;
            m_riskLiveChat = liveChatRisk;
            m_riskCamShare = camShareRisk;
            m_isSendPhotoPriv = isSendPhotoPriv;
            m_isSendVoicePriv = isSendVoicePriv;
            m_liveChatPriv = liveChatPriv;

			{
				// for test
				string strCookies("");
				list<string> getCookies = HttpClient::GetCookiesInfo();
				FileLog("LiveChatManager", "LiveChatManager::Login() cookies.size:%d", getCookies.size());

				for (list<string>::const_iterator iter = getCookies.begin();
					iter != getCookies.end();
					iter++)
				{
					if (!strCookies.empty()) {
						strCookies += ", ";
					}

					strCookies += (*iter);
				}

				FileLog("LiveChatManager", "LiveChatManager::Login() GetCookiesInfo() cookies:%s", strCookies.c_str());
			}
		}
	}

	FileLog("LiveChatManager", "LiveChatManager::Login() end, userId:%s, result:%d", userId.c_str(), result);
	return result;
}

// 注销
bool LSLiveChatManManager::Logout(bool isResetParam)
{
	FileLog("LiveChatManager", "LiveChatManager::Logout() begin");
    
    // 设置是否重置参数
    m_isResetParam = isResetParam;

    // 设置不自动重登录
	m_isAutoLogin = false;
    
	bool result =  m_client->Logout();

	FileLog("LiveChatManager", "LiveChatManager::Logout() end, isResetParam:%b, result:%b", isResetParam, result);

	return result;
}

// 重新登录
bool LSLiveChatManManager::Relogin()
{
//    bool result =  m_client->Logout();
    bool result =  true;
    
    if (!IsLogin()) {
        // 立即重登录
        long time = 3 * 1000;	// 每3秒重登录一次
        
        RequestItem* requestItem = new RequestItem();
        requestItem->requestType = REQUEST_TASK_AutoRelogin;
        InsertRequestTask(this, (TaskParam)requestItem, time);
    }

    return result;
}

// 清除所有图片、视频等资源文件
void LSLiveChatManManager::RemoveSourceFile()
{
	// 清除图片文件
	m_photoMgr->RemoveAllPhotoFile();
    // 清除图片临时文件
    m_photoMgr->RemoveAllTempPhotoFile();
	// 清除视频文件
	m_videoMgr->RemoveAllVideoFile();
}

// 设置用户在线状态，若用户在线状态改变则callback通知listener
void LSLiveChatManManager::SetUserOnlineStatus(LSLCUserItem* userItem, USER_STATUS_TYPE statusType)
{
	if (userItem->SetUserOnlineStatus(statusType))
	{
		m_listener->OnChangeOnlineStatus(userItem);
	}
}

// 根据错误类型设置用户在线状态，若用户在线状态改变则callback通知listener
void LSLiveChatManManager::SetUserOnlineStatusWithLccErrType(LSLCUserItem* userItem, LSLIVECHAT_LCC_ERR_TYPE errType)
{
    if (LSLIVECHAT_LCC_ERR_SUCCESS == errType) {
        SetUserOnlineStatus(userItem, USTATUS_ONLINE);
    }
    else if (LSLIVECHAT_LCC_ERR_SIDEOFFLINE == errType) {
        SetUserOnlineStatus(userItem, USTATUS_OFFLINE_OR_HIDDEN);
    }
}

// 自动过滤器回调自动邀请消息到livechatmanmanager
void LSLiveChatManManager::OnAutoInviteFilterCallback(LSLCAutoInviteItem* autoInviteItem, const string& message) {
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLiveChatManManager::OnAutoInviteFilterCallback(autoInviteItem : %p, message : %s, m_inviteMgr : %p) begin", autoInviteItem, message.c_str(), m_inviteMgr);
    LSLCMessageItem* item = NULL;
    //自动邀请过滤完成回调，插入自动邀请消息列表
    if(m_inviteMgr != NULL){
        m_inviteMgr->HandleAutoInviteMessage(m_msgIdBuilder.GetAndIncrement(), autoInviteItem, message);
        item = m_inviteMgr->GetInviteMessage();
    }
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLiveChatManManager::OnAutoInviteFilterCallback(m_listener : %p, item : %p)", m_listener, item);
    // 回调
    if (NULL != m_listener && NULL != item) {

        m_listener->OnRecvMessage(item);
    }
        FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLiveChatManManager::OnAutoInviteFilterCallback(autoInviteItem : %p, message : %s, m_inviteMgr : %p) end", autoInviteItem, message.c_str(), m_inviteMgr);
}

void LSLiveChatManManager::OnUploadPhoto(LSLCMessageItem* photoItem) {
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLiveChatManManager::OnUploadPhoto() begin");
//    LSLCMessageItem* item = NULL;
//    //自动邀请过滤完成回调，插入自动邀请消息列表
//    if(m_inviteMgr != NULL){
//        m_inviteMgr->HandleAutoInviteMessage(m_msgIdBuilder.GetAndIncrement(), autoInviteItem, message);
//        item = m_inviteMgr->GetInviteMessage();
//    }
//    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLiveChatManManager::OnAutoInviteFilterCallback(m_listener : %p, item : %p)", m_listener, item);
//    // 回调
//    if (NULL != m_listener && NULL != item) {
//        m_listener->OnRecvMessage(item);
//    }
    // 检查私密照是否收费
    RequestItem* requestItem = new RequestItem();
    requestItem->requestType = REQUEST_TASK_SendPhotoWithURL;
    requestItem->param = (TaskParam)photoItem;
    InsertRequestTask(this, (TaskParam)requestItem);
    
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLiveChatManManager::OnUploadPhoto() end");
}

// 是否自动重登录
bool LSLiveChatManManager::IsAutoRelogin(LSLIVECHAT_LCC_ERR_TYPE err)
{
	if (m_isAutoLogin)
	{
		m_isAutoLogin = (LSLIVECHAT_LCC_ERR_CONNECTFAIL == err);
	}
	return m_isAutoLogin;
}

// 插入重登录任务
void LSLiveChatManManager::InsertReloginTask()
{
	FileLog("LiveChatManager", "LiveChatManager::InsertReloginTask() begin");

	long time = 5 * 1000;	// 每30秒重登录一次
    
    RequestItem* requestItem = new RequestItem();
    requestItem->requestType = REQUEST_TASK_AutoRelogin;
    InsertRequestTask(this, (TaskParam)requestItem, time);

	FileLog("LiveChatManager", "InsertReloginTask() end");
}

// 自动重登录
void LSLiveChatManManager::AutoRelogin()
{
	FileLog("LiveChatManager", "LiveChatManager::AutoRelogin() begin, m_userId:%s, m_userName:%s, m_sId:%s, m_deviceId:%s"
			, m_userId.c_str(), m_userName.c_str(), m_sId.c_str(), m_deviceId.c_str());

	if (!m_userId.empty()
		&& !m_sId.empty()
		&& !m_deviceId.empty())
	{
        Login(m_userId, m_userName, m_sId, m_clientType, m_cookies, m_deviceId, m_riskControl, m_riskLiveChat, m_riskCamShare, m_isSendPhotoPriv, m_liveChatPriv, m_isSendVoicePriv);
	}

	FileLog("LiveChatManager", "LiveChatManager::AutoRelogin() end");
}

// 是否已经登录
bool LSLiveChatManManager::IsLogin()
{
	return m_isLogin;
}

// 是否获取历史记录
bool LSLiveChatManManager::IsGetHistory()
{
    return m_isGetHistory;
}

/**
 * 是否处理发送操作
 * @return
 */
bool LSLiveChatManManager::IsHandleSendOpt()
{
	bool result = false;
    bool isSendRisk = false;
    if (m_riskControl == LIVECHATINVITE_RISK_LIMITSEND || m_riskControl == LIVECHATINVITE_RISK_LIMITALL) {
        isSendRisk = true;
    }
    
	if (!isSendRisk
		 && m_isAutoLogin)
	{
		// 没有风控且自动重连
		result = true;
	}
	return result;
}

// 是否处理发送操作
bool LSLiveChatManManager::IsHandleRecvOpt()
{
    bool result = false;
    bool isRecvRisk = false;
    if (m_riskControl == LIVECHATINVITE_RISK_LIMITREV || m_riskControl == LIVECHATINVITE_RISK_LIMITALL) {
        isRecvRisk = true;
    }
    if (!isRecvRisk)
    {
        // 没有风控
        result = true;
    }
    return result;
}

// 获取用户状态(多个)
bool LSLiveChatManManager::GetUserStatus(const list<string>& userIds)
{
    bool result = false;
    if (IsLogin()) {
        result = m_client->GetUserStatus(userIds);
    }
    return result;
}

// 获取用户信息
int LSLiveChatManManager::GetUserInfo(const string& userId)
{
    int result = -1;
    if (IsLogin()) {
        result = m_client->GetUserInfo(userId);
    }
    return result;
}

// 获取多个用户信息
int LSLiveChatManManager::GetUsersInfo(const list<string>& userList)
{
    int seq = HTTPREQUEST_INVALIDREQUESTID;
    if (IsLogin()) {
        seq = m_client->GetUsersInfo(userList) >= 0;
    }
    return seq;
}

// 获取登录用户server
string LSLiveChatManManager::GetMyServer(){
    return m_myServer;
}


// 获取邀请的用户列表（使用前需要先完成GetTalkList()调用）
LCUserList LSLiveChatManManager::GetInviteUsers()
{
	return m_userMgr->GetInviteUsers();
}

// 获取最后一个邀请用户
LSLCUserItem* LSLiveChatManManager::GetLastInviteUser()
{
	LSLCUserItem* userItem = NULL;
	LCUserList inviteUsers = m_userMgr->GetInviteUsers();
	if (inviteUsers.begin() != inviteUsers.end())
	{
		userItem = (*inviteUsers.begin());
	}
	return userItem;
}

// 获取在聊用户列表（使用前需要先完成GetTalkList()调用）
LCUserList LSLiveChatManManager::GetChatingUsers()
{
	return m_userMgr->GetChatingUsers();
}

// 获取男士自动邀请用户列表（使用前需要先完成GetTalkList()调用）
LCUserList LSLiveChatManManager::GetManInviteUsers()
{
    return m_userMgr->GetManInviteUsers();
}

// 获取在聊用户列表某个用户InChat状态
bool LSLiveChatManManager::IsChatingUserInChatState(const string& userId) {
    bool result = false;
    LCUserList chatingUsers = m_userMgr->GetChatingUsers();
    for (LCUserList::const_iterator iter = chatingUsers.begin();
         iter != chatingUsers.end();
         iter++)
    {
        if ((*iter)->m_userId == userId) {
            result = true;
            break;
        }
    }
    
    return result;
}

//// 获取用户最后一条聊天消息
//LSLCMessageItem* LSLiveChatManManager::GetLastMessage(const string& userId)
//{
//    LSLCMessageItem* msgItem = NULL;
//    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
//    if (NULL != userItem) {
//        LCMessageList msgList = userItem->GetMsgList();
//        if (!msgList.empty()) {
//            for (LCMessageList::const_reverse_iterator iter = msgList.rbegin();
//                 iter != msgList.rend();
//                 iter++)
//            {
//                if ((*iter)->IsChatMessage()) {
//                    msgItem = (*iter);
//                    break;
//                }
//            }
//        }
//    }
//    return msgItem;
//}
//
//
//// 获取用户最后一条聊天消息
//LSLCMessageItem* LSLiveChatManManager::GetTheOtherLastMessage(const string& userId)
//{
//    LSLCMessageItem* msgItem = NULL;
//    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
//    if (NULL != userItem) {
//        msgItem = userItem->GetTheOtherLastMessage();
//    }
//    return msgItem;
//}

// 获取对方最后一条聊天消息(返回MessageItem类型，不是指针，防止LCMessageItem转换OC类型时，指针被其他线程清除记录, 不过m_userItem为NULL就是了)
bool LSLiveChatManManager::GetOtherUserLastRecvMessage(const string& userId, LSLCMessageItem& messageItem) {
    bool result = false;
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if (NULL != userItem) {
        result = userItem->GetOtherUserLastRecvMessage(messageItem);
    }
    return result;
}

bool LSLiveChatManManager::GetOtherUserLastMessage(const string& userId, LSLCMessageItem& messageItem) {
    bool result = false;
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if (NULL != userItem) {
        result = userItem->GetOtherUserLastMessage(messageItem);
    }
    return result;
}

LCMessageList LSLiveChatManManager::GetPrivateAndVideoMessageList(const string& userId) {
    LCMessageList msgList;
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if (NULL != userItem) {
        msgList = userItem->GetPrivateAndVideoMessageList();
    }
    return msgList;
}

// 获取用户第一条邀请聊天记录是否超过1分钟
bool LSLiveChatManManager::IsInManInviteCanCancel(const string& userId)
{
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    return userItem->IsInManInviteCanCancel();
}


// 是否处于男士邀请状态
bool  LSLiveChatManManager::IsInManInvite(const string& userId) {
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    return userItem->IsInManInvite();
}

// 检测是否可使用试聊券
bool LSLiveChatManManager::CheckCoupon(const string& userId)
{
	bool result = false;

	FileLog("LiveChatManager", "LiveChatManager::CheckCoupon() userId:%s", userId.c_str());
    
    long requestId = m_requestController->CheckCoupon(userId);
    result = HTTPREQUEST_INVALIDREQUESTID != requestId;
    
	FileLog("LiveChatManager", "LiveChatManager::CheckCoupon() userId:%s, end", userId.c_str());

	return result;
}

// 获取单个用户历史聊天记录（包括文本、高级表情、语音、图片）
bool LSLiveChatManManager::GetHistoryMessage(const string& userId)
{
	bool result = false;
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL != userItem) {
		if (!userItem->GetMsgList().empty()
			&& m_getUsersHistoryMsgRequestId == HTTPREQUEST_INVALIDREQUESTID) // 已完成获取多个用户历史聊天记录的请求
		{
			result = true;
			m_listener->OnGetHistoryMessage(true, "", "", userItem);
		}
		else if (!userItem->m_inviteId.empty())
		{
			long requestId = m_requestController->QueryChatRecord(userItem->m_inviteId);
			result = (requestId != HTTPREQUEST_INVALIDREQUESTID);
		}
	}

	return result;
}

// 获取多个用户历史聊天记录（包括文本、高级表情、语音、图片）
bool LSLiveChatManManager::GetUsersHistoryMessage(const list<string>& userIds)
{
	bool result = false;

	list<string> inviteIds;
	for (list<string>::const_iterator iter = userIds.begin();
		iter != userIds.end();
		iter++)
	{
		LSLCUserItem* userItem = m_userMgr->GetUserItem((*iter));
		if (NULL != userItem
			&& !userItem->m_inviteId.empty())
		{
			inviteIds.push_back(userItem->m_inviteId);
			FileLog("LiveChatManager", "LiveChatManager::GetUsersHistoryMessage() userId:%s, inviteId:%s"
					, userItem->m_userId.c_str(), userItem->m_inviteId.c_str());
		}
	}

	if (!inviteIds.empty())
	{
		m_getUsersHistoryMsgRequestId = m_requestController->QueryChatRecordMutiple(inviteIds);
		result = (m_getUsersHistoryMsgRequestId != HTTPREQUEST_INVALIDREQUESTID);
	}

	return result;
}

// 判断是否是邀请状态（只包括男士要求，不包括女士邀请为了发送风控）
bool LSLiveChatManManager::IsManInviteChatState(const LSLCUserItem* userItem) {
    bool result = false;
    if (userItem->m_chatType == LC_CHATTYPE_MANINVITE ||  userItem->m_chatType == LC_CHATTYPE_OTHER) {
        result = true;
    }
    return result;
}

// 清空用户历史记录（当endtalk的返回不是断网时就清空历史， 1.endtalk没发出去 2，onendtalk因为断网，返回ondisconnect 都不用清空历史）
void LSLiveChatManManager::CleanHistotyMessage(const string& userId) {
    LSLCUserItem* userItem = m_userMgr->GetUserItem((userId));
    userItem->ClearMsgList();
    // 清除一些私密照关联的messageItem
    if (m_photoMgr != NULL) {
        m_photoMgr->ClearBindMapWithUserId(userId);
    }
}

void LSLiveChatManManager::HandleTokenOver(const string& errNo, const string& errmsg) {
    if (IsTokenOverWithString(errNo)) {
        m_listener->OnTokenOverTimeHandler(errNo, errmsg);
    }
}

bool LSLiveChatManManager::SendMsg(LSLCUserItem* userItem, LSLCMessageItem* msgItem) {
    bool bFlag = false;
    
    // 因为不是Camshare就是Livechat会话，所有暂时不把发送消息抽象成接口，Livechat也没有做会话管理
    
    // 通知Camshare会话管理器
    bFlag = m_liveChatCamshareManager->SendMsg(userItem, msgItem);
    
    if( !bFlag ) {
        // 通知Livechat会话管理器
        bFlag = m_liveChatSessionManager->SendMsg(userItem, msgItem);
    }
    
    return bFlag;
}

// 结束会话, 判断是否是livechat 还是camshare endtalk
bool LSLiveChatManManager::EndTalk(const string& userId, bool isLiveChat)
{
    bool bFlag = false;
    
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        
        if(isLiveChat) {
            // 通知Livechat会话管理器
            bFlag = m_liveChatSessionManager->EndTalk(userItem);
        } else {
            // 通知Camshare会话管理器
            bFlag = m_liveChatCamshareManager->EndTalk(userItem);
        }
    }

    return bFlag;
}

// 结束会话，没有根据是否是livechat还是camshare会话（用于停止所有会话）
bool LSLiveChatManManager::EndTalkWithNoType(const string& userId) {
    bool bFlag = false;
    
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        // 通知Camshare会话管理器
        bFlag = m_liveChatCamshareManager->EndTalk(userItem);
        
        if( !bFlag ) {
            // 通知Livechat会话管理器
            bFlag = m_liveChatSessionManager->EndTalk(userItem);
        }
    }
    
    return bFlag;
}

// 插入历史消息记录
bool LSLiveChatManManager::InsertHistoryMessage(const string& userId, LSLCMessageItem* msgItem)
{
	bool result = false;

	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL != userItem) {
		result = userItem->InsertSortMsgList(msgItem);
		msgItem->m_msgId = m_msgIdBuilder.GetAndIncrement();
		msgItem->m_createTime = LSLCMessageItem::GetCreateTime();
	}

	return result;
}

// 删除历史消息记录
bool LSLiveChatManManager::RemoveHistoryMessage(const string& userId, int msgId)
{
	bool result = false;
	LSLCMessageItem* item = GetMessageWithMsgId(userId, msgId);
	if (NULL != item && NULL != item->GetUserItem())
	{
		LSLCUserItem* userItem = item->GetUserItem();
		result = userItem->RemoveSortMsgList(item);
	}
	return result;
}

// 获取指定消息Id的消息Item
LSLCMessageItem* LSLiveChatManManager::GetMessageWithMsgId(const string& userId, int msgId)
{
	LSLCMessageItem* item = NULL;
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (userItem != NULL) {
		item = userItem->GetMsgItemWithId(msgId);
	}
	return item;
}

//  获取指定用户Id的用户item
LSLCUserItem* LSLiveChatManManager::GetUserWithId(const string& userId)
{
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	return userItem;
}

// 获取消息处理状态
StatusType LSLiveChatManManager::GetMessageItemStatus(const string& userId, int msgId)
{
	StatusType statusType = StatusType_Unprocess;
	LSLCMessageItem* item = GetMessageWithMsgId(userId, msgId);
	if (NULL != item) {
		statusType = item->m_statusType;
	}
	return statusType;
}

// ---------------- 文字聊天操作函数(message) ----------------
LSLCMessageItem* LSLiveChatManManager::SendTextMessage(const string& userId, const string& message)
{
	FileLog("LiveChatManager", "LiveChatManager::SendTextMessage() begin, userId:%s, message:%s"
			, userId.c_str(), message.c_str());

//    // 判断是否处理发送操作
//    if (!IsHandleSendOpt()) {
//        FileLog("LiveChatManager", "LiveChatManager::SendTextMessage() IsHandleSendOpt()==false");
//        return NULL;
//    }

	// 获取用户item
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL == userItem) {
		FileLog("LiveChatManager", "LiveChatManager::SendTextMessage() getUserItem fail, userId:%s", userId.c_str());
		return NULL;
	}

	// 构造消息item
	LSLCMessageItem* item = NULL;
	if (!message.empty()) {
		// 生成MessageItem
		item = new LSLCMessageItem();
		item->Init(m_msgIdBuilder.GetAndIncrement()
				, SendType_Send
				, m_userId
				, userItem->m_userId
				, userItem->m_inviteId
				, StatusType_Processing);
		// 生成TextItem
		LSLCTextItem* textItem = new LSLCTextItem();
		textItem->Init(message, true);
		// 把TextItem加到MessageItem
		item->SetTextItem(textItem);
		// 添加到历史记录
		userItem->InsertSortMsgList(item);
        
       // 没有风控和自动连接才发送，（之前在上面，现在有风控也要在ios层显示）
       if (IsHandleSendOpt() || !IsManInviteChatState(userItem)) {
        // 分发会话管理器
           SendMsg(userItem, item);
       }
       else
       {
//           item->m_statusType = StatusType_Finish;
//           m_listener->OnSendTextMessage(LSLIVECHAT_LCC_ERR_SUCCESS, "", item);
           // 插入线程回调
           InsertSendBackcall(item);
       }
	}
	else {
		FileLog("LiveChatManager", "LiveChatManager::SendTextMessage() param error, userId:%s, message:%s", userId.c_str(), message.c_str());
	}

	return item;
}

// 根据错误类型生成警告消息
void LSLiveChatManManager::BuildAndInsertWarningWithErrType(const string& userId, LSLIVECHAT_LCC_ERR_TYPE errType)
{
	if (errType == LSLIVECHAT_LCC_ERR_NOMONEY)
	{
		// 生成余额不足的警告消息
		BuildAndInsertWarningMsg(userId, WARNING_NOMONEY);
	}
    
    
}

// 生成警告消息
void LSLiveChatManManager::BuildAndInsertWarningMsg(const string& userId, WarningCodeType codeType)
{
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL != userItem) {
		// 生成warning消息
		LSLCWarningItem* warningItem = new LSLCWarningItem();
		warningItem->m_codeType = codeType;
		// 生成message消息
		LSLCMessageItem* item = new LSLCMessageItem();
		item->Init(m_msgIdBuilder.GetAndIncrement(), SendType_System, userItem->m_userId, m_userId, userItem->m_inviteId, StatusType_Finish);
		item->SetWarningItem(warningItem);
		// 插入到聊天记录列表中
		userItem->InsertSortMsgList(item);

		// 回调
		if (NULL != m_listener) {
			m_listener->OnRecvWarningMsg(item);
		}
	}
}

// 生成系统消息
void LSLiveChatManManager::BuildAndInsertSystemMsg(const string& userId, CodeType codeType)
{
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL != userItem) {
		// 生成系统消息
		LSLCSystemItem* systemItem = new LSLCSystemItem();
		systemItem->m_codeType = codeType;
		// 生成message消息
		LSLCMessageItem* item = new LSLCMessageItem();
		item->Init(m_msgIdBuilder.GetAndIncrement(), SendType_System, userId, m_userId, userItem->m_inviteId, StatusType_Finish);
		item->SetSystemItem(systemItem);
		// 插入到聊天记录列表中
		userItem->InsertSortMsgList(item);

		// 回调
		if (NULL != m_listener) {
			m_listener->OnRecvSystemMsg(item);
		}
	}
}

// ---------------- 高级表情操作函数(Emotion) ----------------
// 获取高级表情配置
bool LSLiveChatManManager::GetEmotionConfig()
{
	if (m_emotionMgr->m_emotionConfigReqId != HTTPREQUEST_INVALIDREQUESTID) {
		return true;
	}

	m_emotionMgr->m_emotionConfigReqId = m_requestOtherController->EmotionConfig();
	return m_emotionMgr->m_emotionConfigReqId != HTTPREQUEST_INVALIDREQUESTID;
}

// 获取高级表情配置item（PS：本次获取可能是旧的，当收到OnGetEmotionConfig()回调时，需要重新调用本函数获取）
LSLCOtherEmotionConfigItem LSLiveChatManManager::GetEmotionConfigItem() const
{
	return m_emotionMgr->GetConfigItem();
}

// 获取高级表情item
LSLCEmotionItem* LSLiveChatManManager::GetEmotionInfo(const string& emotionId)
{
	return m_emotionMgr->GetEmotion(emotionId);
}

// 发送高级表情
LSLCMessageItem* LSLiveChatManManager::SendEmotion(const string& userId, const string& emotionId)
{
//    // 判断是否处理发送操作
//    if (!IsHandleSendOpt()) {
//        FileLog("LiveChatManager", "LiveChatManager::SendEmotion() IsHandleSendOpt()==false");
//        return NULL;
//    }

	// 获取用户item
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL == userItem) {
		FileLog("LiveChatManager", "LiveChatManager::SendEmotion() getUserItem fail, userId:%s", userId.c_str());
		return NULL;
	}

	LSLCMessageItem* item = NULL;
	if (!emotionId.empty()) {
		// 生成MessageItem
		item = new LSLCMessageItem();
		item->Init(m_msgIdBuilder.GetAndIncrement()
				, SendType_Send
				, m_userId
				, userId
				, userItem->m_inviteId
				, StatusType_Processing);
		// 获取EmotionItem
		LSLCEmotionItem* emotionItem = m_emotionMgr->GetEmotion(emotionId);
		// 把EmotionItem添加到MessageItem
		item->SetEmotionItem(emotionItem);
		// 添加到历史记录
		userItem->InsertSortMsgList(item);

        // 没有风控和自动连接才发送，（之前在上面，现在有风控也要在ios层显示）,或者是聊天中都发送（聊天中的风控在ios限制了）
        if (IsHandleSendOpt() || !IsManInviteChatState(userItem)) {
            // 分发会话管理器
            SendMsg(userItem, item);
        }
        else
        {
//            item->m_statusType = StatusType_Finish;
//            m_listener->OnSendEmotion(LSLIVECHAT_LCC_ERR_SUCCESS, "", item);
            // 插入线程回调
            InsertSendBackcall(item);
        }
	}
	else {
		FileLog("LiveChatManager", "LiveChatManager::SendEmotion() param error, userId:%s, emotionId:%s", userId.c_str(), emotionId.c_str());
	}
	return item;
}

// 手动下载/更新高级表情图片文件（缩略图）
bool LSLiveChatManManager::GetEmotionImage(const string& emotionId)
{
	LSLCEmotionItem* emotionItem = m_emotionMgr->GetEmotion(emotionId);

	FileLog("LiveChatManager", "LiveChatManager::GetEmotionImage() emotionId:%s, emotionItem:%p"
			, emotionId.c_str(), emotionItem);

	bool result = false;
	// 判断文件是否存在，若不存在则下载
	if (!emotionItem->m_imagePath.empty())
	{
		if (IsFileExist(emotionItem->m_imagePath))
		{
			if (NULL != m_listener) {
				m_listener->OnGetEmotionImage(true, emotionItem);
			}
			result = true;
		}
	}

	// 文件不存在，需要下载
	if (!result) {
		FileLog("LiveChatManager", "LiveChatManager::GetEmotionImage() begin download, emotionId:%s"
				, emotionId.c_str());

		result = m_emotionMgr->StartDownloadImage(emotionItem);
	}

	FileLog("LiveChatManager", "LiveChatManager::GetEmotionImage() emotionId:%s, result:%d"
			, emotionId.c_str(), result);
	return result;
}

// 手动下载/更新高级表情图片文件(大图)
bool LSLiveChatManManager::GetEmotionPlayImage(const string& emotionId)
{
	LSLCEmotionItem* emotionItem = m_emotionMgr->GetEmotion(emotionId);

	FileLog("LiveChatManager", "LiveChatManager::GetEmotionPlayImage() emotionId:%s, emotionItem:%p"
			, emotionId.c_str(), emotionItem);

	bool result = false;
	// 判断文件是否存在，若不存在则下载
	if (!emotionItem->m_playBigPath.empty()) {
		if (IsFileExist(emotionItem->m_playBigPath)) {
			if (!emotionItem->m_playBigPaths.empty()) {
				result = true;
				for (LCEmotionPathVector::const_iterator iter = emotionItem->m_playBigPaths.begin();
					iter != emotionItem->m_playBigPaths.end();
					iter++)
				{
					if (!IsFileExist((*iter))) {
						result = false;
						break;
					}
				}
			}

			// 所有文件都存在
			if (result) {
				m_listener->OnGetEmotionPlayImage(true, emotionItem);
			}
		}
	}

	// 有文件不存在，需要下载
	if (!result) {
		FileLog("LiveChatManager", "LiveChatManager::GetEmotionPlayImage() begin download, emotionId:%s"
				, emotionId.c_str());

		result = m_emotionMgr->StartDownloadPlayImage(emotionItem);
	}

	FileLog("LiveChatManager", "LiveChatManager::GetEmotionPlayImage() begin download, emotionId:%s, result:%d"
			, emotionId.c_str(), result);

	return result;
}

// ---------------- 图片操作函数(Private Album) ----------------
// 发送图片（包括上传图片文件(php)、发送图片(livechat)）
LSLCMessageItem* LSLiveChatManManager::SendPhoto(const string& userId, const string& photoPath)
{
//    // 判断是否处理发送操作
//    if (!IsHandleSendOpt()) {
//        FileLog("LiveChatManager", "LiveChatManager::SendPhoto() IsHandleSendOpt()==false");
//        return NULL;
//    }
//    

	// 获取用户item
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL == userItem) {
		FileLog("LiveChatManager", "LiveChatManager::SendPhoto() getUserItem fail, userId:%s", userId.c_str());
		return NULL;
	}
    
    // 复制文件至临时目录
    string tempPath("");
    if (!m_photoMgr->CopyPhotoToTempDir(photoPath, tempPath)) {
        FileLog("LiveChatManager", "LiveChatManager::SendPhoto() copy file to temp dir fail, userId:%s photoPath:%s", userId.c_str(), photoPath.c_str());
        return NULL;
    }

	// 生成MessageItem
	LSLCMessageItem* item = new LSLCMessageItem();
	item->Init(m_msgIdBuilder.GetAndIncrement()
			, SendType_Send
			, m_userId
			, userId
			, userItem->m_inviteId
			, StatusType_Processing);
	// 生成PhotoItem
	LSLCPhotoItem* photoItem = new LSLCPhotoItem();
	photoItem->Init(
			""
			, ""
			, ""
			, ""
			, ""
			, tempPath
			, ""
			, ""
			, true);
	// 把PhotoItem添加到MessageItem
	item->SetPhotoItem(photoItem);
	// 添加到历史记录
	userItem->InsertSortMsgList(item);
    
    // 私密照发送被禁，或者,按照网络不通处理
    if (!m_isSendPhotoPriv) {
//        item->m_statusType = StatusType_Finish;
//        m_listener->OnSendPhoto(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", "", item);
        // 插入线程回调
        InsertSendBackcall(item);
    } else {
        // 没有风控和自动连接才发送，（之前在上面，现在有风控也要在ios层显示）
        if (IsHandleSendOpt() || !IsManInviteChatState(userItem)) {
            // 分发会话管理器
            SendMsg(userItem, item);
        }
        else
        {
//            item->m_statusType = StatusType_Finish;
//            m_listener->OnSendPhoto(LSLIVECHAT_LCC_ERR_SUCCESS, "", "", item);
            // 插入线程回调
            InsertSendBackcall(item);
        }
    }

	return item;
}

// 购买图片（包括付费购买图片(php)）
bool LSLiveChatManManager::PhotoFee(const string& userId, const string& photoId, const string& inviteId)
{
	bool result = false;
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LiveChatManager::PhotoFee() start, userId:%s, photoId:%s, inviteId:%s isLogin:%d", userId.c_str(), photoId.c_str(), photoId.c_str(),  IsLogin());
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if (NULL == userItem) {
        FileLog("LiveChatManager", "LiveChatManager::PhotoFee() get user item fail, userId:%s", userId.c_str());
        return false;
    }
    
    LSLCMessageItem* item = NULL;
    LCMessageList listItem = m_photoMgr->GetMsgListWithBindMap(photoId);
    // 根据私密照ID和inviteId获取msgItem，防止断网前后2个会话接收相同的私密照
    for (LCMessageList::const_iterator msgIter = listItem.begin();  msgIter != listItem.end(); msgIter++) {
        if ( (*msgIter)->m_inviteId == inviteId) {
            item = *msgIter;
            break;
        }
    }
    if (NULL == item) {
        FileLog("LiveChatManager", "LiveChatManager::GetPhoto() get message item fail, photoId;%s", photoId.c_str());
        return false;
    }
    if (IsLogin()) {
        
        result = PhotoFee(item);
    } else {
        //HandleFeebackcall(item);
        InsertFeeBackcall(item);
    }


	return result;
}

// 购买图片（包括付费购买图片(php)）
bool LSLiveChatManManager::PhotoFee(LSLCMessageItem* item)
{
	// 判断参数是否有效
	if (item->m_msgType != MT_Photo
		|| item->m_fromId.empty()
		|| item->m_inviteId.empty()
		|| item->GetPhotoItem()->m_photoId.empty())
	{
		FileLog("LiveChatManager", "LiveChatManager::PhotoFee() param error, msgType:%d, fromId:%s, inviteId%s, photoId:%s"
				, item->m_msgType, item->m_fromId.c_str(), item->m_inviteId.c_str(), item->GetPhotoItem()->m_photoId.c_str());
		return false;
	}

	bool result = item->GetPhotoItem()->IsFee();

	// 若当前并未请求购买
	if (!result)
	{
		result = false;

		// 请求付费获取图片
		long requestId = m_requestController->PhotoFee(item->m_fromId, item->m_inviteId, m_userId, m_sId, item->GetPhotoItem()->m_photoId);
		if (requestId != HTTPREQUEST_INVALIDREQUESTID)
		{
			// 请求成功
			LSLCPhotoItem* photoItem = item->GetPhotoItem();
			photoItem->AddFeeStatus();

			result = m_photoMgr->AddRequestItem(requestId, item);
			if (!result) {
				FileLog("LiveChatManager", "LiveChatManager::PhotoFee() requestId:%d AddRequestItem fail", requestId);
			}
		}
		else {
			item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, "request fail", "");
			m_listener->OnPhotoFee(false, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
		}
	}

	return result;
}

// 检查私密照片是否已付费
bool LSLiveChatManManager::CheckPhoto(const string& userId, const string& photoId)
{
    bool result = false;
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if (NULL == userItem) {
        FileLog("LiveChatManager", "LiveChatManager::PhotoFee() get user item fail, userId:%s", userId.c_str());
        return false;
    }
    
    
    
    LSLCMessageItem* item = NULL;
    LCMessageList listItem = m_photoMgr->GetMsgListWithBindMap(photoId);
    for (LCMessageList::const_iterator msgIter = listItem.begin();  msgIter != listItem.end(); msgIter++) {
        if ( (*msgIter)->GetUserItem() == userItem && (*msgIter)->m_sendType == SendType_Recv) {
            item = *msgIter;
            break;
        }
    }
    if (NULL == item) {
        FileLog("LiveChatManager", "LiveChatManager::GetPhoto() get message item fail, photoId;%s", photoId.c_str());
        return false;
    }
    
    if (!m_isLogin) {
        FileLog("LiveChatManager", "LiveChatManager::PhotoFee() m_isLogin:%d, msgId:%d", m_isLogin);
        return false;
    }
    
    result = CheckPhoto(item);
    
    return result;
}

// 检查私密照片是否已付费
bool LSLiveChatManManager::CheckPhoto(LSLCMessageItem* item)
{
	// 判断参数是否有效
	if (item->m_msgType != MT_Photo
		|| item->m_fromId.empty()
		|| item->m_inviteId.empty()
		|| item->GetPhotoItem()->m_photoId.empty())
	{
		FileLog("LiveChatManager", "LiveChatManager::CheckPhoto() param error, msgType:%d, fromId:%s, inviteId%s, photoId:%s"
				, item->m_msgType, item->m_fromId.c_str(), item->m_inviteId.c_str(), item->GetPhotoItem()->m_photoId.c_str());
		return false;
	}


	bool result = false;

	// 请求检查私密照片是否已付费
    m_photoMgr->RequestCheckPhoto(item, m_userId, m_sId);

	return result;
}


// 根据消息ID获取图片(模糊或清晰)（包括获取/下载对方私密照片(php)、显示图片(livechat)）
bool LSLiveChatManManager::GetPhoto(const string& userId, const string& photoId, GETPHOTO_PHOTOSIZE_TYPE sizeType, SendType sendType)
{

    bool result = false;
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if (NULL == userItem) {
        FileLog("LiveChatManager", "LiveChatManager::GetPhoto() get user item fail, userId;%s", userId.c_str());
        return false;
    }
    
    LSLCMessageItem* item = NULL;
    LCMessageList listItem = m_photoMgr->GetMsgListWithBindMap(photoId);
    for (LCMessageList::const_iterator msgIter = listItem.begin();  msgIter != listItem.end(); msgIter++) {
        if ( (*msgIter)->m_sendType == sendType && (*msgIter)->GetUserItem() == userItem) {
            item = *msgIter;
            break;
        }
    }
    if (NULL == item) {
        FileLog("LiveChatManager", "LiveChatManager::GetPhoto() get message item fail, photoId;%s", photoId.c_str());
        return false;
    }
    
    result = GetPhoto(item, sizeType);
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LiveChatManager::GetPhoto() param, msgType:%d, fromId:%s, photoId:%s charge:%d sizeType:%d sendType:%d"
            , item->m_msgType, item->m_fromId.c_str(), item->GetPhotoItem()->m_photoId.c_str(), item->GetPhotoItem()->m_charge, sizeType, sendType);
    return result;
}


// 获取图片(模糊或清晰)（包括获取/下载对方私密照片(php)、显示图片(livechat)）
bool LSLiveChatManManager::GetPhoto(LSLCMessageItem* item, GETPHOTO_PHOTOSIZE_TYPE sizeType)
{
	FileLog("LiveChatManager", "LiveChatManager::GetPhoto() begin");

	if (item->m_msgType != MT_Photo
		|| item->m_fromId.empty()
		|| item->GetPhotoItem()->m_photoId.empty())
	{
		FileLog("LiveChatManager", "LiveChatManager::GetPhoto() param error, msgType:%d, fromId:%s, photoId:%s"
				, item->m_msgType, item->m_fromId.c_str(), item->GetPhotoItem()->m_photoId.c_str());
		return false;
	}

	bool result = false;

	// 请求下载图片
	GETPHOTO_PHOTOMODE_TYPE modeType;
	if (item->m_sendType == SendType_Send) {
		// 男士发送（直接获取清晰图片）
		modeType = GMT_CLEAR;
	}
	else  {
		// 女士发送（判断是否已购买）
		modeType = (item->GetPhotoItem()->m_charge ? GMT_CLEAR : GMT_FUZZY);
	}

	// 下载图片
	result = m_photoMgr->DownloadPhoto(item, m_userId, m_sId, sizeType, modeType);

	FileLog("LiveChatManager", "GetPhoto() end, result:%d", result);

	return result;
}

// ---------------- 语音操作函数(Voice) ----------------
// 发送语音（包括获取语音验证码(livechat)、上传语音文件(livechat)、发送语音(livechat)）
LSLCMessageItem* LSLiveChatManManager::SendVoice(const string& userId, const string& voicePath, const string& fileType, int timeLength)
{
//    // 判断是否处理发送操作
//    if (!IsHandleSendOpt()) {
//        FileLog("LiveChatManager", "SLiveChatManager::endVoice() IsHandleSendOpt()==false");
//        return NULL;
//    }

	// 获取用户item
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL == userItem) {
		FileLog("LiveChatManager", "LiveChatManager::SendVoice getUserItem fail, userId:%s", userId.c_str());
		return NULL;
	}

	// 生成MessageItem
	LSLCMessageItem* item = new LSLCMessageItem();
	item->Init(m_msgIdBuilder.GetAndIncrement()
			, SendType_Send
			, m_userId
			, userId
			, userItem->m_inviteId
			, StatusType_Processing);
	// 生成VoiceItem
	LSLCVoiceItem* voiceItem = new LSLCVoiceItem();
	voiceItem->Init(""
			, voicePath
			, timeLength
			, fileType
			, ""
			, true);
	// 把VoiceItem添加到MessageItem
	item->SetVoiceItem(voiceItem);
	// 添加到聊天记录中
	userItem->InsertSortMsgList(item);
    
    if (!m_isSendVoicePriv) {
//        item->m_statusType = StatusType_Finish;
//        m_listener->OnSendVoice(LSLIVECHAT_LCC_ERR_SUCCESS, "", "", item);
        // 插入线程回调
        InsertSendBackcall(item);
    } else {
        // 没有风控和自动连接才发送，（之前在上面，现在有风控也要在ios层显示）
        if (IsHandleSendOpt() || !IsManInviteChatState(userItem)) {
            // 分发会话管理器
            SendMsg(userItem, item);
        }
        else {
//            item->m_statusType = StatusType_Finish;
//            m_listener->OnSendVoice(LSLIVECHAT_LCC_ERR_SUCCESS, "", "", item);
            // 插入线程回调
            InsertSendBackcall(item);
        }
    }

	return item;
}

// 获取语音（包括下载语音(livechat)）
bool LSLiveChatManManager::GetVoice(const string& userId, int msgId)
{
	LSLCMessageItem* item = NULL;
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL != userItem) {
		item = userItem->GetMsgItemWithId(msgId);
	}

	if (NULL != item
		&& item->m_msgType != MT_Voice
		&& NULL == item->GetVoiceItem())
	{
		FileLog("LiveChatManager", "LiveChatManager::GetVoice() param error.");
		return false;
	}

	bool result = false;
	LSLCVoiceItem* voiceItem = item->GetVoiceItem();
	voiceItem->m_filePath = m_voiceMgr->GetVoicePath(item);
    if (!voiceItem->m_processing) {
        long requestId = m_requestController->PlayVoice(voiceItem->m_voiceId, (OTHER_SITE_TYPE)m_siteType, voiceItem->m_filePath);
        if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
            // 添加至请求map
            m_voiceMgr->AddRequestItem(requestId, item);
            voiceItem->m_processing = true;
            result = true;
            
            FileLog("LiveChatManager", "LiveChatManager::GetVoice() requestId:%d", requestId);
        }
        else {
            FileLog("LiveChatManager", "GetVoice() RequestOperator.getInstance().PlayVoice fail, voiceId:%s, siteType:%d, filePath:%s"
                    , voiceItem->m_voiceId.c_str(), m_siteType, voiceItem->m_filePath.c_str());
            item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, "", "");
            m_listener->OnGetVoice(item->m_procResult.m_errType, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
            result = false;
        }
    }
    
    return result;
}

// ---------------- 视频操作函数(Video) ----------------
// 获取微视频图片
bool LSLiveChatManManager::GetVideoPhoto(const string& userId, const string& videoId, const string& inviteId)
{
	bool result = false;
    
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if (NULL == userItem) {
        FileLog("LiveChatManager", "LiveChatManager::GetVideoPhoto() get user item fail, userId;%s", userId.c_str());
        return false;
    }
    
    LSLCMessageItem* item = NULL;
    LCMessageList listItem = m_videoMgr->GetMessageItem(userId, videoId);
    for (LCMessageList::const_iterator msgIter = listItem.begin();  msgIter != listItem.end(); msgIter++) {
        if ( (*msgIter)->m_sendType == SendType_Recv && (*msgIter)->GetUserItem() == userItem) {
            item = *msgIter;
            break;
        }
    }
    if (NULL == item) {
        FileLog("LiveChatManager", "LiveChatManager::GetVideoPhoto() get message item fail, videoId;%s", videoId.c_str());
        return false;
    }

	result = m_videoMgr->DownloadVideoPhoto(m_userId, m_sId, userId, videoId, inviteId, VPT_BIG, item);

	return result;
}

// 购买微视频
bool LSLiveChatManManager::VideoFee(const string& userId, const string& videoId, const string& inviteId)
{
	bool result = false;
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LiveChatManager::VideoFee() start, userId:%s, videoId:%s, inviteId:%s, IsLogin:%d", userId.c_str(), videoId.c_str(), inviteId.c_str(), IsLogin());
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if (NULL == userItem) {
        return false;
    }
    // 根据私密照ID和inviteId获取msgItem，防止断网前后2个会话接收相同的私密照
    LSLCMessageItem* msgItem = userItem->GetMsgItemWithVideoId(videoId, inviteId);
    if (NULL == msgItem) {
        return false;
    }
    if (IsLogin()) {

        lcmm::LSLCVideoItem* videoItem = msgItem->GetVideoItem();
        if (msgItem->m_msgType == MT_Video
            && NULL != videoItem)
        {
            result = videoItem->IsFee();
            if (!result) {
                // 未付费，现在付费
                long requestId = m_requestController->GetVideo(
                                                               m_sId
                                                               , m_userId
                                                               , userItem->m_userId
                                                               , videoItem->m_videoId
                                                               , msgItem->m_inviteId
                                                               , GVCT_MAN
                                                               , videoItem->m_sendId);
                if (HTTPREQUEST_INVALIDREQUESTID != requestId)
                {
                    m_videoMgr->AddPhotoFee(msgItem, requestId);
                    videoItem->AddProcessStatusFee();
                    result = true;
                }
            }
        }
    } else {
        InsertFeeBackcall(msgItem);
    }

	return result;
}

// 获取微视频播放文件
bool LSLiveChatManManager::GetVideo(const string& userId, const string& videoId, const string& inviteId, const string& videoUrl, int msgId)
{
	bool result = false;
    // 如果videoUrl为空时，先获取url
    if (videoUrl.empty()) {
        result = VideoFee(userId, videoId, inviteId);
    } else {
        // 判断是否已在下载
        result = m_videoMgr->IsDownloadVideo(videoId);
        if (!result)
        {
            // 还没请求下载，现在下载
            result = m_videoMgr->DownloadVideo(m_userId, m_sId, userId, videoId, inviteId, videoUrl);
        }
    }

	return result;
}

// 获取视频当前下载状态
bool LSLiveChatManManager::IsGetingVideo(const string& videoId)
{
	return m_videoMgr->IsDownloadVideo(videoId);
}

// 获取视频图片文件路径（仅文件存在）
string LSLiveChatManManager::GetVideoPhotoPathWithExist(const string& userId, const string& inviteId, const string& videoId, VIDEO_PHOTO_TYPE type)
{
	return m_videoMgr->GetVideoPhotoPathWithExist(userId, inviteId, videoId, type);
}

// 获取视频文件路径（仅文件存在）
string LSLiveChatManManager::GetVideoPathWithExist(const string& userId, const string& inviteId, const string& videoId)
{
	return m_videoMgr->GetVideoPathWithExist(userId, inviteId, videoId);
}

// ---------------- 小高级表情（小高表）操作函数(MagicIcon) ----------------
////获取小高级表情配置
bool LSLiveChatManManager::GetMagicIconConfig()
{
    if (m_magicIconMgr->m_magicIconConfigReqId != HTTPREQUEST_INVALIDREQUESTID) {
        return true;
    }
    
    m_magicIconMgr->m_magicIconConfigReqId = m_requestController->GetMagicIconConfig();
    return m_magicIconMgr->m_magicIconConfigReqId != HTTPREQUEST_INVALIDREQUESTID;
}

// --------- 视频 ---------------
// 由上传成功私密照后，发送http私密照
void LSLiveChatManManager::SendPhotoWithUrl(LSLCMessageItem* msgItem) {
    //
    LSLCUserItem* userItem = m_userMgr->GetUserItem(msgItem->m_toId);
    
    // 没有风控和自动连接才发送，（之前在上面，现在有风控也要在ios层显示）
    if (IsHandleSendOpt() || !IsManInviteChatState(userItem)) {
        // 分发会话管理器
        SendMsg(userItem, msgItem);
    }
    else
    {
        msgItem->m_statusType = StatusType_Finish;
        m_listener->OnSendPhoto(LSLIVECHAT_LCC_ERR_SUCCESS, "", "", msgItem);
    }
}

// --------- 风控操作 ---------
// 判断接收风控
bool LSLiveChatManManager::IsRecvInviteRisk(bool charge, TALK_MSG_TYPE msgType, INVITE_TYPE inviteType) {
    bool result = false;
    // 如果是有接收风控就不回调上层 而且是邀请消息的(这是邀请风控)
    if (!IsHandleRecvOpt() && LC_CHATTYPE_INVITE == LSLCUserItem::GetChatTypeWithTalkMsgType(charge, msgType)) {
        result = true;
    }
    
    // 当风控是livechat聊天，livechat的邀请也要风控
    if (m_riskLiveChat && LC_CHATTYPE_INVITE == LSLCUserItem::GetChatTypeWithTalkMsgType(charge, msgType) && inviteType == INVITE_TYPE_CHAT) {
        result = true;
    }
    // 当风控是camshare聊天，camshare的邀请也要风控
    if (m_riskCamShare && LC_CHATTYPE_INVITE == LSLCUserItem::GetChatTypeWithTalkMsgType(charge, msgType) && inviteType == INVITE_TYPE_CAMSHARE) {
        result = true;
    }
    // 当livechat总权限被禁时，不能接收所有数据
    if (!IsLiveChatPriv()) {
        result = true;
    }
    
    return result;
}

// 判断能不能接收邀请（ps：上面那个也有判断能不能接收邀请， 还包含聊天权限处理）这个是android处理，自动邀请也根据android
bool LSLiveChatManManager::IsRecvMessageLimited(const string& userId) {
    bool result = false;
    // 添加用户到列表中（若列表中用户不存在）
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if (NULL != userItem) {
        if (!IsHandleRecvOpt() && (userItem->m_chatType == LC_CHATTYPE_INVITE || userItem->m_chatType == LC_CHATTYPE_OTHER)) {
            result = true;
        }
    }

    return result;
}

bool LSLiveChatManManager::IsLiveChatPriv() {
    return m_liveChatPriv;
}

bool LSLiveChatManManager::InsertSendBackcall(LSLCMessageItem* item) {
    bool result = false;
    RequestItem* requestItem = new RequestItem();
    requestItem->requestType = REQUEST_TASK_NOPRIV_SENDMESSAGE;
    requestItem->param = (TaskParam)item;
    InsertRequestTask(this, (TaskParam)requestItem);
    return result;
}

void LSLiveChatManManager::HandleSendbackcall(LSLCMessageItem* item) {
    if (NULL != item) {
        switch (item->m_msgType) {
            case MT_Text:
            {
                item->m_statusType = StatusType_Finish;
                m_listener->OnSendTextMessage(LSLIVECHAT_LCC_ERR_SUCCESS, "", item);
            }
                break;
            case MT_Emotion:
            {
                item->m_statusType = StatusType_Finish;
                m_listener->OnSendEmotion(LSLIVECHAT_LCC_ERR_SUCCESS, "", item);
            }
                break;
                
            case MT_Voice:
            {

                if (!m_isSendVoicePriv) {
                    item->m_statusType = StatusType_Fail;
                    m_listener->OnSendVoice(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", "", item);
                } else {
                    item->m_statusType = StatusType_Finish;
                   m_listener->OnSendVoice(LSLIVECHAT_LCC_ERR_SUCCESS, "", "", item);
                }
                
            }
                break;
                
            case MT_MagicIcon:
            {
                item->m_statusType = StatusType_Finish;
                m_listener->OnSendMagicIcon(LSLIVECHAT_LCC_ERR_SUCCESS, "", item);
            }
                break;
                
            case MT_Photo:
            {
                if (!m_isSendPhotoPriv || !IsLogin()) {
                    item->m_statusType = StatusType_Fail;
                     m_listener->OnSendPhoto(LSLIVECHAT_LCC_ERR_CONNECTFAIL, "", "", item);
                } else {
                    item->m_statusType = StatusType_Finish;
                    m_listener->OnSendPhoto(LSLIVECHAT_LCC_ERR_SUCCESS, "", "", item);
                }
                
            }
                break;
                
                
            default:
                break;
        }
    }
}

bool LSLiveChatManManager::InsertFeeBackcall(LSLCMessageItem* item) {
    bool result = false;
    RequestItem* requestItem = new RequestItem();
    requestItem->requestType = REQUEST_TASK_NOLOGIN_PHOTOANDVIDEOFEE;
    requestItem->param = (TaskParam)item;
    InsertRequestTask(this, (TaskParam)requestItem);
    return result;
}

void LSLiveChatManManager::HandleFeebackcall(LSLCMessageItem* item) {
    if (NULL != item) {
        switch (item->m_msgType) {
            case MT_Photo: 
            {
                item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_CONNECTFAIL, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
                m_listener->OnPhotoFee(false, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
                
            }
                break;
                
            case MT_Video:
            {
                item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_CONNECTFAIL, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
                // callback
                m_listener->OnVideoFee(false, "request fail", "", item);
                
            }
                break;
                
                
            default:
                break;
        }
    }
}


void LSLiveChatManManager::GetTalkInfo(const string& userId) {
    if (NULL != m_client) {
        m_client->GetTalkInfo(userId);
    }
}

// -------- 回调获取聊天列表处理 ---------
// livechat的获取聊天列表处理
void LSLiveChatManManager::OnGetTalkListLiveChatProc(const TalkListInfo& talkListInfo)
{
//    TalkUserList::const_iterator iter;
//    TalkSessionList::const_iterator iterSession;
//    
//    // ------- 在线列表 -------
//    // 在线session列表
//    for (iterSession = talkListInfo.chatingSession.begin();
//         iterSession != talkListInfo.chatingSession.end();
//         iterSession++)
//    {
//        if ((*iterSession).serviceType == TalkSessionServiceType_Livechat) {
//            LSLCUserItem* userItem = m_userMgr->GetUserItem((*iterSession).targetId);
//            if (NULL != userItem)
//            {
//                userItem->m_inviteId = (*iterSession).invitedId;
//                
//                FileLog("LiveChatManager", "LiveChatManager::OnGetTalkList() chating userId:%s, inviteId:%s"
//                        , userItem->m_userId.c_str(), userItem->m_inviteId.c_str());
//            }
//        }
//    }
//    // 在线列表
//    for (iter = talkListInfo.chating.begin();
//         iter != talkListInfo.chating.end();
//         iter++)
//    {
//        LSLCUserItem* userItem = m_userMgr->GetUserItem((*iter).userId);
//        if ((*iterSession).serviceType == TalkSessionServiceType_Livechat) {
//            if (NULL != userItem
//                && !userItem->m_inviteId.empty())
//            {
//                userItem->m_chatType = LSLCUserItem::LC_CHATTYPE_IN_CHAT_CHARGE;
//            }
//        }
//    }
//    
//    // ------- 在聊已暂停列表 -------
//    // 在线已暂停session列表
//    for (iterSession = talkListInfo.pauseSession.begin();
//         iterSession != talkListInfo.pauseSession.end();
//         iterSession++)
//    {
//        if ((*iterSession).serviceType == TalkSessionServiceType_Livechat) {
//            LSLCUserItem* userItem = m_userMgr->GetUserItem((*iterSession).targetId);
//            if (NULL != userItem)
//            {
//                userItem->m_inviteId = (*iterSession).invitedId;
//                
//                FileLog("LiveChatManager", "LiveChatManager::OnGetTalkList() pause userId:%s, inviteId:%s"
//                        , userItem->m_userId.c_str(), userItem->m_inviteId.c_str());
//            }
//        }
//    }
//    
//    // ------- 邀请列表 -------
//    // 邀请session列表
//    for (iterSession = talkListInfo.inviteSession.begin();
//         iterSession != talkListInfo.inviteSession.end();
//         iterSession++)
//    {
//        if ((*iterSession).serviceType == TalkSessionServiceType_Livechat) {
//            LSLCUserItem* userItem = m_userMgr->GetUserItem((*iterSession).targetId);
//            if (NULL != userItem)
//            {
//                userItem->m_inviteId = (*iterSession).invitedId;
//                
//                FileLog("LiveChatManager", "LiveChatManager::OnGetTalkList() invite userId:%s, inviteId:%s"
//                        , userItem->m_userId.c_str(), userItem->m_inviteId.c_str());
//            }
//        }
//    }
//    
//    // ------- 被邀请列表 -------
//    // 被邀请session列表
//    for (iterSession = talkListInfo.invitedSession.begin();
//         iterSession != talkListInfo.invitedSession.end();
//         iterSession++)
//    {
//        if ((*iterSession).serviceType == TalkSessionServiceType_Livechat) {
//            LSLCUserItem* userItem = m_userMgr->GetUserItem((*iterSession).targetId);
//            if (NULL != userItem)
//            {
//                userItem->m_inviteId = (*iterSession).invitedId;
//                
//                FileLog("LiveChatManager", "LiveChatManager::OnGetTalkList() invited userId:%s, inviteId:%s"
//                        , userItem->m_userId.c_str(), userItem->m_inviteId.c_str());
//            }
//        }
//    }
}
// 公共获取聊天列表处理
void LSLiveChatManManager::OnGetTalkListPublicProc(const TalkListInfo& talkListInfo)
{
//    TalkUserList::const_iterator iter;
//    TalkSessionList::const_iterator iterSession;
//    
//    // ------- 在线列表 -------
//    // 在线session列表
//    for (iterSession = talkListInfo.chatingSession.begin();
//         iterSession != talkListInfo.chatingSession.end();
//         iterSession++)
//    {
//        LSLCUserItem* userItem = m_userMgr->GetUserItem((*iterSession).targetId);
//        if (NULL != userItem)
//        {
//            userItem->m_inviteId = (*iterSession).invitedId;
//            
//            FileLog("LiveChatManager", "LiveChatManager::OnGetTalkList() chating userId:%s, inviteId:%s"
//                    , userItem->m_userId.c_str(), userItem->m_inviteId.c_str());
//        }
//    }
//    // 在线列表
//    for (iter = talkListInfo.chating.begin();
//         iter != talkListInfo.chating.end();
//         iter++)
//    {
//        LSLCUserItem* userItem = m_userMgr->GetUserItem((*iter).userId);
//        if (NULL != userItem
//            && !userItem->m_inviteId.empty())
//        {
//            userItem->m_userName = (*iter).userName;
//            userItem->m_sexType = USER_SEX_FEMALE;
//            SetUserOnlineStatus(userItem, USTATUS_ONLINE);
//            userItem->m_chatType = LSLCUserItem::LC_CHATTYPE_IN_CHAT_CHARGE;
//            userItem->m_clientType = (*iter).clientType;
//            userItem->m_order = (*iter).orderValue;
//        }
//    }
//    
//    // 在聊已暂停列表
//    for (iter = talkListInfo.pause.begin();
//         iter != talkListInfo.pause.end();
//         iter++)
//    {
//        LSLCUserItem* userItem = m_userMgr->GetUserItem((*iter).userId);
//        if (NULL != userItem
//            && !userItem->m_inviteId.empty())
//        {
//            userItem->m_userName = (*iter).userName;
//            userItem->m_sexType = USER_SEX_FEMALE;
//            SetUserOnlineStatus(userItem, USTATUS_ONLINE);
//            userItem->m_chatType = LSLCUserItem::LC_CHATTYPE_IN_CHAT_CHARGE;
//            userItem->m_clientType = (*iter).clientType;
//            userItem->m_order = (*iter).orderValue;
//        }
//    }
//    
//    // 邀请列表
//    for (iter = talkListInfo.invite.begin();
//         iter != talkListInfo.invite.end();
//         iter++)
//    {
//        LSLCUserItem* userItem = m_userMgr->GetUserItem((*iter).userId);
//        if (NULL != userItem
//            && !userItem->m_inviteId.empty())
//        {
//            userItem->m_userName = (*iter).userName;
//            userItem->m_sexType = USER_SEX_FEMALE;
//            SetUserOnlineStatus(userItem, USTATUS_ONLINE);
//            userItem->m_chatType = LSLCUserItem::LC_CHATTYPE_MANINVITE;
//            userItem->m_clientType = (*iter).clientType;
//            userItem->m_order = (*iter).orderValue;
//        }
//    }
//    
//    // 被邀请列表
//    for (iter = talkListInfo.invited.begin();
//         iter != talkListInfo.invited.end();
//         iter++)
//    {
//        LSLCUserItem* userItem = m_userMgr->GetUserItem((*iter).userId);
//        if (NULL != userItem
//            && !userItem->m_inviteId.empty())
//        {
//            userItem->m_userName = (*iter).userName;
//            userItem->m_sexType = USER_SEX_FEMALE;
//            SetUserOnlineStatus(userItem, USTATUS_ONLINE);
//            userItem->m_chatType = LSLCUserItem::LC_CHATTYPE_INVITE;
//            userItem->m_clientType = (*iter).clientType;
//            userItem->m_order = (*iter).orderValue;
//        }
//    }
}


// 发送小高级表情
LSLCMessageItem* LSLiveChatManManager::SendMagicIcon(const string& userId, const string& iconId)
{
//    if(!IsHandleSendOpt()){
//        FileLog("LiveChatManager", "LiveChatManager::SendMagicIcon() IsHandleSendOpt()==false");
//        return NULL;
//    }
    
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if(NULL == userItem){
        FileLog("LiveChatManager", "LiveChatManager::SendMagicIcon() getUserItem fail, userId:%s", userId.c_str());
        return NULL;
    }
    
    LSLCMessageItem* item = NULL;
    if(!iconId.empty()) {
        item = new LSLCMessageItem();
        item->Init(m_msgIdBuilder.GetAndIncrement()
                   , SendType_Send
                   , m_userId
                   , userId
                   , userItem->m_inviteId
                   , StatusType_Processing);
        // 获取MagicIconItem
        LSLCMagicIconItem* magicIconItem = m_magicIconMgr->GetMagicIcon(iconId);
        // 把MagicIconItem添加到MessageItem
        item->SetMagicIconItem(magicIconItem);
        // 添加到历史记录
        userItem->InsertSortMsgList(item);
        
        // 没有风控和自动连接才发送，（之前在上面，现在有风控也要在ios层显示）
        if (IsHandleSendOpt() || !IsManInviteChatState(userItem)) {
            // 分发会话管理器
            SendMsg(userItem, item);
        }
        else {
//            item->m_statusType = StatusType_Finish;
//            m_listener->OnSendMagicIcon(LSLIVECHAT_LCC_ERR_SUCCESS, "", item);
            // 插入线程回调
            InsertSendBackcall(item);
        }
        
    }
    else{
        FileLog("LiveChatManager", "LiveChatManager::SendMagicIcon() param error, userId:%s, iconId:%s", userId.c_str(), iconId.c_str());
    }
    return item;
}

// 获取小高级表情配置item
LSLCMagicIconConfig LSLiveChatManManager::GetMagicIconConfigItem() const
{
    return m_magicIconMgr->GetConfigItem();
}

// 获取小高级表情item
LSLCMagicIconItem* LSLiveChatManManager::GetMagicIconInfo(const string& magicIconId)
{
    return m_magicIconMgr->GetMagicIcon(magicIconId);
}

// 手动下载／更新小高级表情原图
bool LSLiveChatManManager::GetMagicIconSrcImage(const string& magicIconId)
{
    LSLCMagicIconItem* magicIconItem = m_magicIconMgr->GetMagicIcon(magicIconId);
    FileLog("LiveChatManager", "LiveChatManager::GetMagicIconSrcImage() magicIconId:%s, magicIconItem:%p", magicIconId.c_str(), magicIconItem);;
    
    bool result = false;
    if (!magicIconItem->m_sourcePath.empty()) {
        if (IsFileExist(magicIconItem->m_sourcePath)) {
            if(NULL != m_listener){
                m_listener->OnGetMagicIconSrcImage(true, magicIconItem);
            }
            result = true;
        }
    }
    
    // 文件不存在，需要下载
    if(!result){
        FileLog("LiveChatManager", "LiveChatManager::GetMagicIconSrcImage() magicIconId:%s", magicIconId.c_str());
        result = m_magicIconMgr->StartDownloadSourceImage(magicIconItem);
    }
    
    FileLog("LiveChatManager", "LiveChatManager::GetManicIconSrcImage() magicIconId:%s, result:%d", magicIconId.c_str(), result);
    return result;
    
}

// 手动下载／更新小高级表情拇子图
bool LSLiveChatManManager::GetMagicIconThumbImage(const string& magicIconId)
{
    LSLCMagicIconItem* magicIconItem = m_magicIconMgr->GetMagicIcon(magicIconId);
    FileLog("LiveChatManager", "LiveChatManager::GetMagicIconThumnImage() magicIconId:%s, magicIconItem:%p", magicIconId.c_str(), magicIconItem);
    
    bool result = false;
    
    if (!magicIconItem->m_thumbPath.empty()) {
        if (IsFileExist(magicIconItem->m_thumbPath)) {
            if (NULL != m_listener) {
                m_listener->OnGetMagicIconThumbImage(true, magicIconItem);
            }
            result = true;
        }
    }
    
    if (!result) {
        FileLog("LiveChatManager", "LiveChatManager::GetMagicIconThumbImage() magicIconId:%s", magicIconId.c_str());
        result = m_magicIconMgr->StartDownloadThumbImage(magicIconItem);
    }
    FileLog("LiveChatManager", "LiveChatManager::GetMagicIconThumbImage() magicIconId:%s, result:%d", magicIconId.c_str(), result);
    
    return result;
}

//获取小高级表情原图的路径
string LSLiveChatManManager::GetMagicIconThumbPath(const string& magicIconId)
{
    LSLCMagicIconItem* magicIconItem = m_magicIconMgr->GetMagicIcon(magicIconId);
    FileLog("LiveChatManager", "LiveChatManager::GetMagicIconSrcPath() magicIconId:%s, magicIconItem:%p", magicIconId.c_str(), magicIconItem);;
    
    if (!magicIconItem->m_thumbPath.empty()) {
        if (IsFileExist(magicIconItem->m_thumbPath)) {
            return magicIconItem->m_thumbPath;
        }
    }
    
    
    return "";
}

// 发送邀请语
bool LSLiveChatManManager::SendInviteMessage(const string& userId, const string& message, const string& nickName) {
    
    bool result = false;
    if (IsLogin()) {
        result = m_client->SendInviteMessage(userId, message, nickName);
    }
    return result;
    
}

// --------- Camshare --------
bool LSLiveChatManManager::SendCamShareInvite(const string& userId) {
    bool bFlag = false;
    
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        if( (userItem->m_chatType == LC_CHATTYPE_IN_CHAT_CHARGE
           && !m_liveChatCamshareManager->IsCamShareInChat(userItem))
           ) {
            // 存在会话中，但不是Camshare会话，发送结束命令
            EndTalk(userId, true);
        }
        
        if (IsHandleSendOpt()) {
            // 发送Camshare邀请
            bFlag = m_liveChatCamshareManager->SendCamShareInvite(userItem);
        }
        else
        {
            bFlag = true;
            m_listener->OnRecvCamInviteCanCancel(userId);
        }
    }
    
    return bFlag;
}

// 接受女士发过来的Camshare邀请(注意和SendCamShareInvite流程一样，分成2个为了风控，接受是不用判断风控)
bool LSLiveChatManManager::AcceptLadyCamshareInvite(const string& userId) {
    bool bFlag = false;
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        if( userItem->m_chatType == LC_CHATTYPE_IN_CHAT_CHARGE
           && !m_liveChatCamshareManager->IsCamShareInChat(userItem)
           ) {
            // 存在会话中，但不是Camshare会话，发送结束命令
            EndTalk(userId, true);
        }
        bFlag = m_liveChatCamshareManager->SendCamShareInvite(userItem);
    }
    
    return bFlag;
}

bool LSLiveChatManManager::GetLadyCamStatus(const string& userId) {
    bool bFlag = false;
    
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        bFlag = m_liveChatCamshareManager->GetCamLadyStatus(userItem);
    }
    
    return bFlag;
}

bool LSLiveChatManManager::CheckCamCoupon(const string& userId) {
    bool bFlag = false;
    
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        bFlag = m_liveChatCamshareManager->CheckCamCoupon(userItem);
    }
    
    return bFlag;
}

bool LSLiveChatManManager::UpdateRecvVideo(const string& userId) {
    bool bFlag = false;
    
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        bFlag = m_liveChatCamshareManager->UpdateRecvVideo(userItem);
    }
    
    return bFlag;
}

bool LSLiveChatManManager::IsCamshareInChat(const string& userId) {
    bool bFlag = false;
    
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        bFlag = m_liveChatCamshareManager->IsCamShareInChat(userItem);
    }
    
    return bFlag;
}

bool LSLiveChatManManager::IsUploadVideo() {
    bool bFlag = false;
    bFlag = m_liveChatCamshareManager->IsUploadVideo();
    return bFlag;
}

// 检查用户是否Camshare被邀请
bool LSLiveChatManManager::IsCamShareInvite(const string& userId) {
    bool bFlag = false;
 
    LSLCUserItem* userItem =m_userMgr->GetUserItem(userId);
    if( userItem ) {
       bFlag = m_liveChatCamshareManager->IsCamShareInvite(userItem);
    }
    
    return bFlag;
}


bool LSLiveChatManManager::IsCamshareInviteMsg(const string& userId) {
    bool bFlag = false;
    
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        LSLCMessageItem* item = userItem->GetTheOtherLastMessage();
        if (item != NULL) {
            if (item->m_inviteType == INVITE_TYPE_CAMSHARE) {
                bFlag = true;
            }
        }
    }
    
    return bFlag;
}


bool LSLiveChatManManager::SetCamShareBackground(const string& userId, bool background) {
    bool bFlag = false;
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    if( userItem ) {
        bFlag = m_liveChatCamshareManager->SetCamShareBackground(userItem, background);
    }
    return bFlag;
}

bool LSLiveChatManManager::SetCheckCamShareHeartBeatTimeStep(int timeStep) {
    bool bFlag = false;
    if( m_liveChatCamshareManager && timeStep > 0) {
        int PTimeStep = timeStep * 1000;
        bFlag = m_liveChatCamshareManager->SetCheckCamShareHeartBeatTimeStep(PTimeStep);
    }
    return bFlag;
}

// ------------------- LSLCEmotionManagerCallback -------------------
void LSLiveChatManManager::OnDownloadEmotionImage(bool result, LSLCEmotionItem* emotionItem)
{
	FileLog("LiveChatManager", "LiveChatManager::OnDownloadEmotionImage() result:%d, emotionId:%s", result, emotionItem->m_emotionId.c_str());

	if (NULL != m_listener) {
		m_listener->OnGetEmotionImage(result, emotionItem);
	}
}

void LSLiveChatManManager::OnDownloadEmotionPlayImage(bool result, LSLCEmotionItem* emotionItem)
{
	FileLog("LiveChatManager", "LiveChatManager::OnDownloadEmotionImage() result:%d, emotionId:%s", result, emotionItem->m_emotionId.c_str());

	if (NULL != m_listener) {
		m_listener->OnGetEmotionPlayImage(result, emotionItem);
	}
}

// ------------------- LSLCPhotoManagerCallback -------------------
void LSLiveChatManManager::OnDownloadPhoto(bool success, GETPHOTO_PHOTOSIZE_TYPE sizeType, const string& errnum, const string& errmsg, const LCMessageList& msgList)
{
	//FileLog("LiveChatManager", "LiveChatManager::OnDownloadPhoto() result:%d", success);
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LiveChatManager::OnDownloadPhoto() result:%d", success);
	if (NULL != m_listener) {
		LSLIVECHAT_LCC_ERR_TYPE err = (success ? LSLIVECHAT_LCC_ERR_SUCCESS : LSLIVECHAT_LCC_ERR_FAIL);
        
        if (!success && 0 == errnum.compare(LOCAL_ERROR_CODE_TIMEOUT)) {
            err = LSLIVECHAT_LCC_ERR_CONNECTFAIL;
        }
        
		m_listener->OnGetPhoto(sizeType, err, errnum, errmsg, msgList);
	}
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LiveChatManager::OnDownloadPhoto() callback end");
	//FileLog("LiveChatManager", "LiveChatManager::OnDownloadPhoto() callback end");
}

void LSLiveChatManManager::OnManagerCheckPhoto( bool success, const string& errnum, const string& errmsg, LSLCMessageItem* msgItem)
{
    FileLog("LiveChatManager", "LiveChatManager::OnManagerCheckPhoto() result:%d", success);
    
    if (NULL != m_listener) {
        m_listener->OnCheckPhoto(success, errnum, errmsg, msgItem);
    }
    
    FileLog("LiveChatManager", "LiveChatManager::OnManagerCheckPhoto() callback end");
}

// ------------------- LSLCPhotoManagerCallback -------------------
void LSLiveChatManManager::OnDownloadVideoPhoto(
					bool success
					, const string& errnum
					, const string& errmsg
					, const string& womanId
					, const string& inviteId
					, const string& videoId
					, VIDEO_PHOTO_TYPE type
					, const string& filePath
					, const LCMessageList& msgList)
{
	// callback
	LSLIVECHAT_LCC_ERR_TYPE result = success ? LSLIVECHAT_LCC_ERR_SUCCESS : LSLIVECHAT_LCC_ERR_FAIL;
    if (errnum == LOCAL_ERROR_CODE_TIMEOUT) {
        result = LSLIVECHAT_LCC_ERR_CONNECTFAIL;
    }
	m_listener->OnGetVideoPhoto(result, errnum, errmsg, womanId, inviteId, videoId, type, filePath, msgList);
}
	
// 视频下载完成回调
void LSLiveChatManManager::OnDownloadVideo(bool success, const string& userId, const string& videoId, const string& inviteId, const string& filePath, const LCMessageList& msgList)
{
	// callback
	LSLIVECHAT_LCC_ERR_TYPE result = success ? LSLIVECHAT_LCC_ERR_SUCCESS : LSLIVECHAT_LCC_ERR_FAIL;
	m_listener->OnGetVideo(result, userId, videoId, inviteId, filePath, msgList);
}

// ------------------- LSLCMagicIconManagerCallback -------------------
// 小高级表情原图下载完成回调
void LSLiveChatManManager::OnDownloadMagicIconImage(bool success, LSLCMagicIconItem* magicIconItem)
{
    FileLog("LiveChatManager", "LiveChatManager::OnDownloadMagicIconImage() result:%d, magicIconId:%s", success, magicIconItem->m_magicIconId.c_str());
    if (NULL != m_listener) {
        m_listener->OnGetMagicIconSrcImage(success, magicIconItem);
    }
}
//  小高级表情拇子图下载完成回调
void LSLiveChatManManager::OnDownloadMagicIconThumbImage(bool success, LSLCMagicIconItem* magicIconItem)
{
    FileLog("LiveChatManager", "LiveChatManager::OnDownloadMagicIconThumbImag() result:%d, magicIconId:%s", success, magicIconItem->m_magicIconId.c_str());
    if (NULL != m_listener) {
        m_listener->OnGetMagicIconThumbImage(success, magicIconItem);
    }
}

// ------------------- ILSLiveChatClientListener -------------------
// 客户端主动请求
void LSLiveChatManManager::OnLogin(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg)
{
	FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LiveChatManager::OnLogin() err:%d, errmsg:%s, m_isAutoLogin:%d", err, errmsg.c_str(), m_isAutoLogin);

	if (LSLIVECHAT_LCC_ERR_SUCCESS == err)
	{
		// 登录成功
		m_isLogin = true;

		// 上传客户端内部版本号
		m_client->UploadVer(m_appVer);
        
        // 获取自己的UserInfo（暂时只为获取sever）
        m_client->GetUserInfo(m_userId);

		// 获取黑名单列表
		m_client->GetBlockUsers();

		// 获取被屏蔽女士列表
		m_client->GetContactList(CONTACT_LIST_BLOCK);

		// 获取联系人列表
		m_client->GetContactList(CONTACT_LIST_CONTACT);

		// 获取在聊/邀请用户列表
		m_client->GetTalkList(TALK_LIST_CHATING | TALK_LIST_PAUSE | TALK_LIST_WOMAN_INVITE);
        
		// 获取高级表情配置
        RequestItem* requestItem = new RequestItem();
        requestItem->requestType = REQUEST_TASK_GetEmotionConfig;
        InsertRequestTask(this, (TaskParam)requestItem);
        
        // alex获取小高级表情配置
        requestItem = new RequestItem();
        requestItem->requestType = REQUEST_TASK_GetMagicIconConfig;
        InsertRequestTask(this, (TaskParam)requestItem);
        
		// 启动定时释放高级表情下载器任务
        requestItem = new RequestItem();
        requestItem->requestType = REQUEST_TASK_ReleaseEmotionDownloader;
        InsertRequestTask(this, (TaskParam)requestItem);
        
		// 启动定时释放图片下载器任务
        requestItem = new RequestItem();
        requestItem->requestType = REQUEST_TASK_ReleasePhotoDownloader;
        InsertRequestTask(this, (TaskParam)requestItem);
        
        // 启动定时释放小高级表情下载器任务
        requestItem = new RequestItem();
        requestItem->requestType = REQUEST_TASK_ReleaseMagicIconDownloader;
        InsertRequestTask(this, (TaskParam)requestItem);

        // modify by Samson 2017-03-23 CamShare会话管理开始放到 LSLiveChatCamshareManager::OnGetTalkList() 中
        // 通知Camshare会话管理器开始任务
//        m_liveChatCamshareManager->Start();
        
	}
	else if (IsAutoRelogin(err))
	{
		// 重置参数
		ResetParamWithAutoLogin();
		// 自动重登录
		InsertReloginTask();
	}
	else
	{
		// 重置数据
		ResetParamWithNotAutoLogin();
	}

	if (NULL != m_listener) {
		m_listener->OnLogin(err, errmsg, m_isAutoLogin);
	}
}

void LSLiveChatManManager::OnLogout(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg)
{
    if (m_isLogin)
    {
        // 已经登录
        FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LiveChatManager::OnLogout() err:%d, errmsg:%s", err, errmsg.c_str());

        // 重置登录参数
        m_isLogin = false;

        // callback
        bool isAutoLogin = IsAutoRelogin(err);
        if (NULL != m_listener) {
            m_listener->OnLogout(err, errmsg, m_isAutoLogin);
        }

        if (isAutoLogin) {
            // 重置自动登录数据
            ResetParamWithAutoLogin();
            // 自动重登录
            InsertReloginTask();
        }
        else {
            // 重置所有数据
            ResetParamWithNotAutoLogin();
        }
    }
}

void LSLiveChatManManager::OnSetStatus(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg)
{
	m_listener->OnSetStatus(err, errmsg);
}

void LSLiveChatManManager::OnGetUserStatus(const UserIdList& inList, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserStatusList& userList)
{
	LCUserList userItemList;
	for (UserStatusList::const_iterator iter = userList.begin();
		iter != userList.end();
		iter++)
	{
		LSLCUserItem* userItem = m_userMgr->GetUserItem((*iter).userId);
		if (NULL != userItem) {
			SetUserOnlineStatus(userItem, (*iter).statusType);
			userItemList.push_back(userItem);
		}
	}

	m_listener->OnGetUserStatus(err, errmsg, userItemList);
}

void LSLiveChatManManager::OnGetTalkInfo(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& invitedId, bool charge, unsigned int chatTime)
{
    if (NULL != m_userMgr) {
        LSLCUserItem* userItem = m_userMgr->GetUserItem(inUserId);
    }
}

void LSLiveChatManManager::OnEndTalk(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg) {
    LSLCUserItem* userItem = m_userMgr->GetUserItem(inUserId);
    if( userItem ) {
        userItem->EndTalk();
        if (err != LSLIVECHAT_LCC_ERR_CONNECTFAIL) {
            CleanHistotyMessage(inUserId);
        }
    }
    m_listener->OnEndTalk(err, errmsg, userItem);
}



void LSLiveChatManManager::OnGetTalkList(int inListType, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const TalkListInfo& talkListInfo)
{
	FileLog("LiveChatManager", "LiveChatManager::OnGetTalkList() listType:%d, err:%d, errmsg:%s" \
			", chating:%d, pause:%d, invite:%d, invited:%d"
			, inListType, err, errmsg.c_str()
			, talkListInfo.chating.size(), talkListInfo.pause.size(), talkListInfo.invite.size(), talkListInfo.invited.size());
	if (LSLIVECHAT_LCC_ERR_SUCCESS == err)
	{
		TalkUserList::const_iterator iter;
		TalkSessionList::const_iterator iterSession;

        // 通知Camshare会话管理器
        m_liveChatCamshareManager->OnGetTalkList(talkListInfo);
//        OnGetTalkListLiveChatProc(talkListInfo);
//        OnGetTalkListPublicProc(talkListInfo);
        
		// ------- 在线列表 -------
		// 在线session列表
		for (iterSession = talkListInfo.chatingSession.begin();
			iterSession != talkListInfo.chatingSession.end();
			iterSession++)
		{

            LSLCUserItem* userItem = m_userMgr->GetUserItem((*iterSession).targetId);
            if (NULL != userItem)
            {
                userItem->m_inviteId = (*iterSession).invitedId;

                FileLog("LiveChatManager", "LiveChatManager::OnGetTalkList() chating userId:%s, inviteId:%s"
                        , userItem->m_userId.c_str(), userItem->m_inviteId.c_str());
            }

		}
		// 在线列表
		for (iter = talkListInfo.chating.begin();
			iter != talkListInfo.chating.end();
			iter++)
		{
			LSLCUserItem* userItem = m_userMgr->GetUserItem((*iter).userId);
			if (NULL != userItem
				&& !userItem->m_inviteId.empty())
			{
				userItem->m_userName = (*iter).userName;
				userItem->m_sexType = USER_SEX_FEMALE;
				SetUserOnlineStatus(userItem, USTATUS_ONLINE);
				userItem->m_chatType = LC_CHATTYPE_IN_CHAT_CHARGE;
				userItem->m_clientType = (*iter).clientType;
				userItem->m_order = (*iter).orderValue;
			}
		}

		// ------- 在聊已暂停列表 -------
		// 在线已暂停session列表
		for (iterSession = talkListInfo.pauseSession.begin();
			iterSession != talkListInfo.pauseSession.end();
			iterSession++)
		{
            LSLCUserItem* userItem = m_userMgr->GetUserItem((*iterSession).targetId);
            if (NULL != userItem)
            {
                userItem->m_inviteId = (*iterSession).invitedId;

                FileLog("LiveChatManager", "LiveChatManager::OnGetTalkList() pause userId:%s, inviteId:%s"
                        , userItem->m_userId.c_str(), userItem->m_inviteId.c_str());
            }
		}
		// 在聊已暂停列表
		for (iter = talkListInfo.pause.begin();
			iter != talkListInfo.pause.end();
			iter++)
		{
			LSLCUserItem* userItem = m_userMgr->GetUserItem((*iter).userId);
			if (NULL != userItem
				&& !userItem->m_inviteId.empty())
			{
				userItem->m_userName = (*iter).userName;
				userItem->m_sexType = USER_SEX_FEMALE;
				SetUserOnlineStatus(userItem, USTATUS_ONLINE);
                if ((*iterSession).serviceType == TalkSessionServiceType_Livechat) {
                    userItem->m_chatType = LC_CHATTYPE_IN_CHAT_CHARGE;
                }
				userItem->m_clientType = (*iter).clientType;
				userItem->m_order = (*iter).orderValue;
			}
		}

		// ------- 邀请列表 -------
		// 邀请session列表
		for (iterSession = talkListInfo.inviteSession.begin();
			iterSession != talkListInfo.inviteSession.end();
			iterSession++)
		{

            LSLCUserItem* userItem = m_userMgr->GetUserItem((*iterSession).targetId);
            if (NULL != userItem)
            {
                userItem->m_inviteId = (*iterSession).invitedId;

                FileLog("LiveChatManager", "LiveChatManager::OnGetTalkList() invite userId:%s, inviteId:%s"
                        , userItem->m_userId.c_str(), userItem->m_inviteId.c_str());
            }

		}
		// 邀请列表
		for (iter = talkListInfo.invite.begin();
			iter != talkListInfo.invite.end();
			iter++)
		{
			LSLCUserItem* userItem = m_userMgr->GetUserItem((*iter).userId);
			if (NULL != userItem
				&& !userItem->m_inviteId.empty())
			{
				userItem->m_userName = (*iter).userName;
				userItem->m_sexType = USER_SEX_FEMALE;
				SetUserOnlineStatus(userItem, USTATUS_ONLINE);
				userItem->m_chatType = LC_CHATTYPE_MANINVITE;
				userItem->m_clientType = (*iter).clientType;
				userItem->m_order = (*iter).orderValue;
			}
		}

		// ------- 被邀请列表 -------
		// 被邀请session列表
		for (iterSession = talkListInfo.invitedSession.begin();
			iterSession != talkListInfo.invitedSession.end();
			iterSession++)
		{
                LSLCUserItem* userItem = m_userMgr->GetUserItem((*iterSession).targetId);
                if (NULL != userItem)
                {
                    userItem->m_inviteId = (*iterSession).invitedId;

                    FileLog("LiveChatManager", "LiveChatManager::OnGetTalkList() invited userId:%s, inviteId:%s"
                            , userItem->m_userId.c_str(), userItem->m_inviteId.c_str());
                }
		}

        
		// 被邀请列表
		for (iter = talkListInfo.invited.begin();
			iter != talkListInfo.invited.end();
			iter++)
		{
			LSLCUserItem* userItem = m_userMgr->GetUserItem((*iter).userId);
			if (NULL != userItem
				&& !userItem->m_inviteId.empty())
			{
				userItem->m_userName = (*iter).userName;
				userItem->m_sexType = USER_SEX_FEMALE;
				SetUserOnlineStatus(userItem, USTATUS_ONLINE);
				userItem->m_chatType = LC_CHATTYPE_INVITE;
				userItem->m_clientType = (*iter).clientType;
				userItem->m_order = (*iter).orderValue;
			}
		}

		// 获取用户的聊天历史记录
        RequestItem* requestItem = new RequestItem();
        requestItem->requestType = REQUEST_TASK_GetUsersHistoryMessage;
        InsertRequestTask(this, (TaskParam)requestItem);
	}

	m_listener->OnGetTalkList(err, errmsg);
}

void LSLiveChatManManager::OnShowPhoto(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket)
{

}

void LSLiveChatManManager::OnGetUserInfo(int seq, const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const UserInfoItem& userInfo)
{
	if (err == LSLIVECHAT_LCC_ERR_SUCCESS)
	{
        // 若为自己，则更新自己的用户信息
        if (m_userId == userInfo.userId) {
            FileLog("LiveChatManager", "CamShareManager::OnGetUserInfo userName:%s, server:%s"
                    , userInfo.userName.c_str(), userInfo.server.c_str());
            m_myServer = userInfo.server;
            if (m_autoInviteFilter) {
                m_autoInviteFilter->OnGetUserInfoUpdate(userInfo);
            }
        }
        else {
            // 若用户已经存在，则更新用户信息
            if (m_userMgr->IsUserExists(userInfo.userId)) {
                LSLCUserItem* userItem = m_userMgr->GetUserItem(userInfo.userId);
                if (NULL != userItem) {
                    userItem->UpdateWithUserInfo(userInfo);
                }
            }
            
            // 更新用户排序分值
            m_inviteMgr->UpdateUserOrderValue(userInfo.userId, userInfo.orderValue);
        }
	}
    
    if (NULL != m_listener)
    {
        m_listener->OnGetUserInfo(seq, inUserId, err, errmsg, userInfo);
    }
}

void LSLiveChatManManager::OnGetUsersInfo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int seq, const list<string>& userIdList,const UserInfoList& userList)
{
    if (err == LSLIVECHAT_LCC_ERR_SUCCESS)
    {
        for (UserInfoList::const_iterator iter = userList.begin();
             iter != userList.end();
             iter++)
        {
            const UserInfoItem& userInfo = (*iter);
            
            // 若用户已经存在，则更新用户信息
            if (m_userMgr->IsUserExists(userInfo.userId)) {
                LSLCUserItem* userItem = m_userMgr->GetUserItem(userInfo.userId);
                if (NULL != userItem) {
                    userItem->UpdateWithUserInfo(userInfo);
                }
            }
            
            // 更新用户排序分值
            m_inviteMgr->UpdateUserOrderValue(userInfo.userId, userInfo.orderValue);
        }
    }
    
    if (NULL != m_listener) {
//        m_listener->OnGetUsersInfo(err, errmsg, userList);
        m_listener->OnGetUsersInfo(err, errmsg, seq, userIdList, userList);
    }
}

void LSLiveChatManManager::OnGetContactList(CONTACT_LIST_TYPE inListType, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const TalkUserList& userList)
{
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LiveChatManager::OnGetContactList() listType:%d, err:%d, errmsg:%s, users.size:%d m_listener:%p"
			, inListType, err, errmsg.c_str(), userList.size(), m_listener);
	if (LSLIVECHAT_LCC_ERR_SUCCESS == err) {
		switch (inListType)
		{
		case CONTACT_LIST_BLOCK:
			m_blockMgr->UpdateWithBlockList(userList);
			break;
		case CONTACT_LIST_CONTACT:
			m_contactMgr->UpdateWithContactList(userList);
			break;
		}
	}
    if (NULL != m_listener) {
        if (inListType == CONTACT_LIST_CONTACT) {
            m_listener->OnGetContactList(inListType, err, errmsg, userList);
        }
    }
}

void LSLiveChatManManager::OnGetBlockUsers(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList)
{
	FileLog("LiveChatManager", "LiveChatManager::OnGetBlockUsers() err:%d, errmsg:%s, users.size:%d"
			, err, errmsg.c_str(), userList.size());
	if (LSLIVECHAT_LCC_ERR_SUCCESS == err)
	{
		m_blockMgr->UpdateWithBlockUsers(userList);
	}
}

void LSLiveChatManManager::OnSearchOnlineMan(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList)
{

}

void LSLiveChatManManager::OnReplyIdentifyCode(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg)
{

}

void LSLiveChatManManager::OnGetRecentContactList(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList)
{

}

void LSLiveChatManManager::OnGetFeeRecentContactList(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& userList)
{

}

void LSLiveChatManManager::OnGetLadyChatInfo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const list<string>& chattingList, const list<string>& chattingInviteIdList, const list<string>& missingList, const list<string>& missingInviteIdList)
{

}

void LSLiveChatManManager::OnPlayVideo(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, int ticket)
{

}

// Alex, 发送邀请语
void LSLiveChatManManager::OnSendInviteMessage(const string& inUserId, const string& inMessage, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& inviteId, const string& nickName) {
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LiveChatManager::OnSendInviteMessage() begin, userId:%s, message:%s, err:%d, errmsg:%s", inUserId.c_str(), inMessage.c_str(), err, errmsg.c_str());
    //if (err == LSLIVECHAT_LCC_ERR_SUCCESS) {
        LSLCMessageItem* item = NULL;
        
        if (IsRecvInviteRisk(false, TMT_FREE, INVITE_TYPE_CHAT)) {
            //        // 如果风控了，而且是邀请的，就改为other，防止获取邀请列表有这个被风控的
            //        if (userItem->m_chatType == LC_CHATTYPE_INVITE) {
            //            userItem->m_chatType = LC_CHATTYPE_OTHER;
            //        }
            return;
        }
        
        
        // 添加用户到列表中（若列表中用户不存在）
        LSLCUserItem* userItem = m_userMgr->GetUserItem(inUserId);
        if (NULL == userItem) {
            FileLog("LiveChatManager", "LiveChatManager::OnSendInviteMessage() getUserItem fail, fromId:%s", inUserId.c_str());
            return;
        }
        
        userItem->m_inviteId = inviteId;
        userItem->m_userName = nickName;
        
        if (userItem->m_chatType == LC_CHATTYPE_OTHER) {
            userItem->SetChatTypeWithTalkMsgType(false, TMT_FREE);
        }
        SetUserOnlineStatus(userItem, USTATUS_ONLINE);
        
        // 生成MessageItem
        item = new LSLCMessageItem;
        FileLog("LiveChatManager", "LiveChatManager::OnSendInviteMessage() item:%p", item);
        FileLog("LiveChatManager", "LiveChatManager::OnSendInviteMessage() inviteId:%s", userItem->m_inviteId.c_str());
        item->Init(m_msgIdBuilder.GetAndIncrement()
                   , SendType_Recv
                   , inUserId
                   , m_userId
                   , userItem->m_inviteId
                   , StatusType_Finish);
        item->m_inviteType = INVITE_TYPE_CHAT;
        // 生成TextItem
        LSLCTextItem* textItem = new LSLCTextItem();
        textItem->Init(inMessage, false);
        // 把TextItem添加到MessageItem
        item->SetTextItem(textItem);
        // Alex, 2019-08-01,设置冒泡的女士邀请为假消息
        item->m_isFalseLadyInvite = true;
        // 添加到用户聊天记录中
        if (!userItem->InsertSortMsgList(item)) {
            // 添加到用户聊天记录列表不成功
            delete item;
            item = NULL;
        }
        
        
        if (NULL != item) {
            FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LiveChatManager::OnSendInviteMessage() callback, item:%p", item);
            
            // callback
            //m_listener->OnRecvMessage(item);
            // 为了区分OnRecvMessage,这个使用在Qn冒泡跳转到直播后，发送邀请语成功，如果用OnRecvMessage，直播会再冒泡 (Alex, 2019-07-26)
            m_listener->OnRecvAutoInviteMessage(item);
        }
        
        FileLog("LiveChatManager", "LiveChatManager::OnSendInviteMessage() end, fromId:%s, message:%s"
                , inUserId.c_str(),  inMessage.c_str());
    //}

    
}

// 服务器主动请求
void LSLiveChatManManager::OnRecvShowVideo(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDec, int ticket)
{

}

void LSLiveChatManManager::OnRecvMessage(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& message,INVITE_TYPE inviteType)
{
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLiveChatManManager::OnRecvMessage()toId:%s, fromId:%s, inviteId:%s, message:%s", toId.c_str(), fromId.c_str(), inviteId.c_str(), message.c_str());
	m_client->UploadTicket(fromId, ticket);
    
	LSLCMessageItem* item = NULL;
    
    if (IsRecvInviteRisk(charge, msgType, inviteType)) {
//        // 如果风控了，而且是邀请的，就改为other，防止获取邀请列表有这个被风控的
//        if (userItem->m_chatType == LC_CHATTYPE_INVITE) {
//            userItem->m_chatType = LC_CHATTYPE_OTHER;
//        }
        return;
    }

	// 判断是否邀请消息
	LSLCNormalInviteManager::HandleInviteMsgType handleType = m_inviteMgr->IsToHandleInviteMsg(fromId, charge, msgType);
	if (handleType == LSLCNormalInviteManager::HANDLE) {
		// 处理邀请消息
		m_inviteMgr->HandleInviteMessage(m_msgIdBuilder, toId, fromId, fromName, inviteId, charge, ticket, msgType, message, inviteType);
        item = m_inviteMgr->GetInviteMessage();
        
	}
	else if (handleType == LSLCNormalInviteManager::PASS) {
		// 添加用户到列表中（若列表中用户不存在）
		LSLCUserItem* userItem = m_userMgr->GetUserItem(fromId);
		if (NULL == userItem) {
			FileLog("LiveChatManager", "LiveChatManager::OnRecvMessage() getUserItem fail, fromId:%s", fromId.c_str());
			return;
		}

		userItem->m_inviteId = inviteId;
		userItem->m_userName = fromName;
		userItem->SetChatTypeWithTalkMsgType(charge, msgType);
		SetUserOnlineStatus(userItem, USTATUS_ONLINE);

		// 生成MessageItem
		item = new LSLCMessageItem;
		FileLog("LiveChatManager", "LiveChatManager::OnRecvMessage() item:%p", item);
		FileLog("LiveChatManager", "LiveChatManager::OnRecvMessage() inviteId:%s", userItem->m_inviteId.c_str());
		item->Init(m_msgIdBuilder.GetAndIncrement()
				, SendType_Recv
				, fromId
				, toId
				, userItem->m_inviteId
				, StatusType_Finish);
        item->m_inviteType = inviteType;
		// 生成TextItem
		LSLCTextItem* textItem = new LSLCTextItem();
		textItem->Init(message, false);
		// 把TextItem添加到MessageItem
		item->SetTextItem(textItem);
        
		// 添加到用户聊天记录中
		if (!userItem->InsertSortMsgList(item)) {
			// 添加到用户聊天记录列表不成功
			delete item;
			item = NULL;
		}
	}

	if (NULL != item) {
		FileLog("LiveChatManager", "LiveChatManager::OnRecvMessage() callback, item:%p", item);
        
        
        // 收到邀请消息
        if( LC_CHATTYPE_INVITE == LSLCUserItem::GetChatTypeWithTalkMsgType(charge, msgType)) {
            // 通知Camshare管理器收到邀请
            m_liveChatCamshareManager->OnRecvInviteMessage(toId, fromId, inviteId, inviteType);
        }
        

		// callback
		m_listener->OnRecvMessage(item);
	}

	FileLog("LiveChatManager", "LiveChatManager::OnRecvMessage() end, fromId:%s, ticket:%d, message:%s"
			, fromId.c_str(), ticket, message.c_str());
}

void LSLiveChatManManager::OnRecvEmotion(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& emotionId)
{
    // 这个版本暂时不做Emtion
//    // 返回票根给服务器
//    m_client->UploadTicket(fromId, ticket);
//    // 如果livechat总权限被禁，不处理接收消息
//    if (!IsLiveChatPriv()) {
//        return;
//    }
//
//    // 添加用户到列表中（若列表中用户不存在）
//    LSLCUserItem* userItem = m_userMgr->GetUserItem(fromId);
//    if (NULL == userItem) {
//        FileLog("LiveChatManager", "LiveChatManager::OnRecvEmotion() getUserItem fail, fromId:%s", fromId.c_str());
//        return;
//    }
//    userItem->m_inviteId = inviteId;
//    userItem->m_userName = fromName;
//    userItem->SetChatTypeWithTalkMsgType(charge, msgType);
//    SetUserOnlineStatus(userItem, USTATUS_ONLINE);
//
//    // 生成MessageItem
//    LSLCMessageItem* item = new LSLCMessageItem();
//    item->Init(m_msgIdBuilder.GetAndIncrement()
//            , SendType_Recv
//            , fromId
//            , toId
//            , userItem->m_inviteId
//            , StatusType_Finish);
//    // 获取EmotionItem
//    LSLCEmotionItem* emotionItem = m_emotionMgr->GetEmotion(emotionId);
//    // 把EmotionItem添加到MessageItem
//    item->SetEmotionItem(emotionItem);
//
//    // 高级表情只有livechat邀请
//    if (IsRecvInviteRisk(charge, msgType, INVITE_TYPE_CHAT)) {
//        // 如果风控了，而且是邀请的，就改为other，防止获取邀请列表有这个被风控的
//        if (userItem->m_chatType == LC_CHATTYPE_INVITE) {
//            userItem->m_chatType = LC_CHATTYPE_OTHER;
//        }
//        return;
//    }
//
//    // 添加到用户聊天记录中
//    userItem->InsertSortMsgList(item);
//
//
//    // callback
//    if (NULL != m_listener) {
//        m_listener->OnRecvEmotion(item);
//    }
}

void LSLiveChatManManager::OnRecvVoice(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, TALK_MSG_TYPE msgType, const string& voiceId, const string& fileType, int timeLen)
{
    
    // 只有livechat邀请
    if (IsRecvInviteRisk(charge, msgType, INVITE_TYPE_CHAT)) {
//        // 如果风控了，而且是邀请的，就改为other，防止获取邀请列表有这个被风控的
//        if (userItem->m_chatType == LC_CHATTYPE_INVITE) {
//            userItem->m_chatType = LC_CHATTYPE_OTHER;
//        }
        return;
    }
	// 添加用户到列表中（若列表中用户不存在）
	LSLCUserItem* userItem = m_userMgr->GetUserItem(fromId);
	if (NULL == userItem) {
		FileLog("LiveChatManager", "LiveChatManager::OnRecvVoice() getUserItem fail, fromId:%s", fromId.c_str());
		return;
	}
	userItem->m_userName = fromName;
	userItem->m_inviteId = inviteId;
	userItem->SetChatTypeWithTalkMsgType(charge, msgType);
	SetUserOnlineStatus(userItem, USTATUS_ONLINE);

	// 生成MessageItem
	LSLCMessageItem* item = new LSLCMessageItem();
	item->Init(m_msgIdBuilder.GetAndIncrement()
			, SendType_Recv
			, fromId
			, toId
			, userItem->m_inviteId
			, StatusType_Finish);
	// 生成VoiceItem
	LSLCVoiceItem* voiceItem = new LSLCVoiceItem();
	voiceItem->Init(voiceId
			, m_voiceMgr->GetVoicePath(voiceId, fileType)
			, timeLen
			, fileType
			, ""
			, charge);

	// 把VoiceItem添加到MessageItem
	item->SetVoiceItem(voiceItem);
    

    
	// 添加到聊天记录中
	userItem->InsertSortMsgList(item);
    
	// callback
	m_listener->OnRecvVoice(item);
}

void LSLiveChatManManager::OnRecvWarning(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& message)
{
	// 返回票根给服务器
	m_client->UploadTicket(fromId, ticket);
    
    if (IsRecvInviteRisk(charge, msgType, INVITE_TYPE_CHAT)) {
//        // 如果风控了，而且是邀请的，就改为other，防止获取邀请列表有这个被风控的
//        if (userItem->m_chatType == LC_CHATTYPE_INVITE) {
//            userItem->m_chatType = LC_CHATTYPE_OTHER;
//        }
        return;
    }

	// 添加用户到列表中（若列表中用户不存在）
	LSLCUserItem* userItem = m_userMgr->GetUserItem(fromId);
	if (NULL == userItem) {
		FileLog("LiveChatManager", "LiveChatManager::OnRecvWarning() getUserItem fail, fromId:%s", fromId.c_str());
		return;
	}
	userItem->m_inviteId = inviteId;
	userItem->SetChatTypeWithTalkMsgType(charge, msgType);
	userItem->m_userName = fromName;
	SetUserOnlineStatus(userItem, USTATUS_ONLINE);

	// 生成MessageItem
	LSLCMessageItem* item = new LSLCMessageItem();
	item->Init(m_msgIdBuilder.GetAndIncrement()
			, SendType_Recv
			, fromId
			, toId
			, userItem->m_inviteId
			, StatusType_Finish);
	// 生成WarningItem
	LSLCWarningItem* warningItem = new LSLCWarningItem;
	warningItem->Init(message);
	// 把WarningItem添加到MessageItem
	item->SetWarningItem(warningItem);
    

	// 添加到用户聊天记录中
	userItem->InsertSortMsgList(item);

	// callback
	m_listener->OnRecvWarningMsg(item);
}

void LSLiveChatManManager::OnUpdateStatus(const string& userId, const string& server, CLIENT_TYPE clientType, USER_STATUS_TYPE statusType)
{
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL == userItem) {
		FileLog("LiveChatManager", "LiveChatManager::OnUpdateStatus() getUserItem fail, userId:%s", userId.c_str());
		return;
	}
	userItem->m_clientType = clientType;
	SetUserOnlineStatus(userItem, statusType);

	m_listener->OnUpdateStatus(userItem);
}

void LSLiveChatManManager::OnUpdateTicket(const string& fromId, int ticket)
{
	// 不用处理
}

void LSLiveChatManManager::OnRecvEditMsg(const string& fromId)
{
	m_listener->OnRecvEditMsg(fromId);
}

void LSLiveChatManManager::OnRecvTalkEvent(const string& userId, TALK_EVENT_TYPE eventType)
{
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL == userItem) {
		FileLog("LiveChatManager", "LiveChatManager::OnRecvTalkEvent() getUserItem fail, userId:%s, eventType:%d", userId.c_str(), eventType);
		return;
	}
	userItem->SetChatTypeWithEventType(eventType);
	m_listener->OnRecvTalkEvent(userItem);

	if (eventType == TET_NOMONEY
		|| eventType == TET_VIDEONOMONEY)
	{
		BuildAndInsertWarningWithErrType(userId, LSLIVECHAT_LCC_ERR_NOMONEY);
	}
}

void LSLiveChatManManager::OnRecvTryTalkBegin(const string& toId, const string& fromId, int time)
{
	// 改变用户聊天状态并回调
	LSLCUserItem* userItem = m_userMgr->GetUserItem(toId);
	if (NULL == userItem) {
		FileLog("LiveChatManager", "LiveChatManager::OnRecvTryTalkBegin() getUserItem fail, toId:%s", toId.c_str());
		return;
	}
	userItem->m_chatType = LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET;
	m_listener->OnRecvTryTalkBegin(userItem, time);
}

void LSLiveChatManManager::OnRecvTryTalkEnd(const string& userId)
{
	// 改变用户聊天状态并回调
	LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
	if (NULL == userItem) {
		FileLog("LiveChatManager", "LiveChatManager::OnRecvTryTalkEnd() getUserItem fail, userId:%s", userId.c_str());
		return;
	}
	userItem->m_chatType = LC_CHATTYPE_IN_CHAT_CHARGE;
	m_listener->OnRecvTryTalkEnd(userItem);

	// 插入系统消息
	BuildAndInsertSystemMsg(userId, TRY_CHAT_END);
}

void LSLiveChatManManager::OnRecvEMFNotice(const string& fromId, TALK_EMF_NOTICE_TYPE noticeType)
{
    // 暂时没有EMF功能
//    m_listener->OnRecvEMFNotice(fromId, noticeType);
}

void LSLiveChatManManager::OnRecvKickOffline(KICK_OFFLINE_TYPE kickType)
{
	FileLog("LiveChatManager", "LiveChatManager::OnRecvKickOffline() kickType:%d", kickType);

	// 用户在其它地方登录，被踢下线
	if (KOT_OTHER_LOGIN == kickType)
	{
		// 回调
		m_listener->OnRecvKickOffline(kickType);
	}

	FileLog("LiveChatManager", "LiveChatManager::OnRecvKickOffline() end");
}

void LSLiveChatManManager::OnRecvPhoto(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDesc, int ticket)
{
    
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLiveChatManManager::OnRecvPhoto()toId:%s, fromId:%s, inviteId:%s, photoId:%s", toId.c_str(), fromId.c_str(), inviteId.c_str(), photoId.c_str());
    // 暂时没有私密照片功能
    // 返回票根给服务器
    m_client->UploadTicket(fromId, ticket);
    
    // 如果livechat总权限被禁，不处理接收消息
    if (!IsLiveChatPriv()) {
        return;
    }
    
    // 添加用户到列表中（若列表中用户不存在）
    LSLCUserItem* userItem = m_userMgr->GetUserItem(fromId);
    if (NULL == userItem) {
        FileLog("LiveChatManager", "LiveChatManager::OnRecvPhoto() getUserItem fail, fromId:%s", fromId.c_str());
        return;
    }
    userItem->m_inviteId = inviteId;
    userItem->m_userName = fromName;
    SetUserOnlineStatus(userItem, USTATUS_ONLINE);

    // 生成MessageItem
    LSLCMessageItem* item = new LSLCMessageItem();
    item->Init(m_msgIdBuilder.GetAndIncrement()
            , SendType_Recv
            , fromId
            , toId
            , userItem->m_inviteId
            , StatusType_Finish);
    // 生成PhotoItem
    LSLCPhotoItem* photoItem = m_photoMgr->GetPhotoItem(photoId, item);
    photoItem->Init(photoId
            , sendId
            , photoDesc
            , m_photoMgr->GetPhotoPath(photoId, GMT_FUZZY, GPT_LARGE)
            , m_photoMgr->GetPhotoPath(photoId, GMT_FUZZY, GPT_MIDDLE)
            , m_photoMgr->GetPhotoPath(photoId, GMT_CLEAR, GPT_ORIGINAL)
            , m_photoMgr->GetPhotoPath(photoId, GMT_CLEAR, GPT_LARGE)
            , m_photoMgr->GetPhotoPath(photoId, GMT_CLEAR, GPT_MIDDLE)
            , charge);

    // 其实不用写，因为没有phote的邀请
    if (!IsHandleRecvOpt() && !IsChatingUserInChatState(fromId)) {
        return;
    }
    
    // 添加到用户聊天记录中
    userItem->InsertSortMsgList(item);
    
    // callback
    m_listener->OnRecvPhoto(item);
}

void LSLiveChatManManager::OnRecvShowPhoto(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& photoId, const string& sendId, bool charge, const string& photoDec, int ticket)
{
    
}

void LSLiveChatManManager::OnRecvLadyVoiceCode(const string& voiceCode)
{

}

void LSLiveChatManManager::OnRecvIdentifyCode(const unsigned char* data, long dataLen)
{

}

void LSLiveChatManManager::OnRecvVideo(const string& toId, const string& fromId, const string& fromName, const string& inviteId, const string& videoId, const string& sendId, bool charge, const string& videoDesc, int ticket)
{
    
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLiveChatManManager::OnRecvVideo() toId:%s, fromId:%s, inviteId:%s, videoId:%s", toId.c_str(), fromId.c_str(), inviteId.c_str(), videoId.c_str());
    // 暂时没有视频功能
    // 返回票根给服务器
    m_client->UploadTicket(fromId, ticket);
    
    // 如果livechat总权限被禁，不处理接收消息
    if (!IsLiveChatPriv()) {
        return;
    }

    // 添加用户到列表中（若列表中用户不存在）
    LSLCUserItem* userItem = m_userMgr->GetUserItem(fromId);
    if (NULL == userItem) {
        FileLog("LiveChatManager", "LiveChatManager::OnRecvVideo() getUserItem fail, fromId:%s", fromId.c_str());
        return;
    }
    userItem->m_inviteId = inviteId;
    userItem->m_userName = fromName;
    SetUserOnlineStatus(userItem, USTATUS_ONLINE);

    // 生成MessageItem
    LSLCMessageItem* item = new LSLCMessageItem();
    item->Init(m_msgIdBuilder.GetAndIncrement()
            , SendType_Recv
            , fromId
            , toId
            , userItem->m_inviteId
            , StatusType_Finish);
    // 生成VideoItem
    lcmm::LSLCVideoItem* videoItem = new lcmm::LSLCVideoItem();
    videoItem->Init(videoId
            , sendId
            , videoDesc
            , ""
            , charge
            , ""
            , ""
            , "");
    // 把PhotoItem添加到MessageItem
    item->SetVideoItem(videoItem);

    // 可以不写，因为没有video邀请
    if (!IsHandleRecvOpt() && !IsChatingUserInChatState(fromId)) {
        return;
    }

    // 添加到用户聊天记录中
    userItem->InsertSortMsgList(item);


    // callback
    m_listener->OnRecvVideo(item);
}

void LSLiveChatManManager::OnRecvMagicIcon(const string& toId, const string& fromId, const string& fromName, const string& inviteId, bool charge, int ticket, TALK_MSG_TYPE msgType, const string& iconId)
{
    // 返回票根给服务器
    m_client->UploadTicket(fromId, ticket);
    
    if (IsRecvInviteRisk(charge, msgType, INVITE_TYPE_CHAT)) {
//        // 如果风控了，而且是邀请的，就改为other，防止获取邀请列表有这个被风控的
//        if (userItem->m_chatType == LC_CHATTYPE_INVITE) {
//            userItem->m_chatType = LC_CHATTYPE_OTHER;
//        }
        return;
    }
    //
    LSLCUserItem* userItem = m_userMgr->GetUserItem(fromId);
    if (NULL == userItem) {
        FileLog("LiveChatManager", "LiveChatManager::OnRecvMagicIcon() getUserItem fail, fromId:%s", fromId.c_str());
        return;
    }
    userItem->m_inviteId = inviteId;
    userItem->m_userName = fromName;
    userItem->SetChatTypeWithTalkMsgType(charge, msgType);
    SetUserOnlineStatus(userItem, USTATUS_ONLINE);
    
    //生成MessageItem
    LSLCMessageItem* item = new LSLCMessageItem();
    item->Init(m_msgIdBuilder.GetAndIncrement()
               , SendType_Recv
               , fromId
               , toId
               , userItem->m_inviteId
               , StatusType_Finish);
    // 获取MagicIConItem
    LSLCMagicIconItem* magicIcomItem = m_magicIconMgr->GetMagicIcon(iconId);
    // 把MagicIconItem添加到MessageItem
    item->SetMagicIconItem(magicIcomItem);
    

    
    // 添加到用户聊天记录中
    userItem->InsertSortMsgList(item);
    

    // callback
    if (NULL != m_listener) {
        m_listener->OnRecvMagicIcon(item);
    }
    
}

// 接收自动邀请消息，livchatmanmanager进行处理
void LSLiveChatManManager::OnRecvAutoInviteMsg(const string& womanId, const string& manId, const string& key) {
    FileLevelLog("LiveChatManager", KLog::LOG_MSG, "LSLiveChatManManager::OnRecvAutoInviteMsg(womanId : %s, manId : %s) begin", womanId.c_str(), manId.c_str());
    // 判断是否有接收邀请风控
    if (IsRecvMessageLimited(womanId)) {
     FileLevelLog("LiveChatManager", KLog::LOG_MSG, "LSLiveChatManManager::OnRecvAutoInviteMsg(womanId : %s, manId : %s) is RecvMessageLimited end", womanId.c_str(), manId.c_str());
        return;
    }
    // 联系人过滤
    if (m_contactMgr->IsExist(womanId)) {
      FileLevelLog("LiveChatManager", KLog::LOG_MSG, "LSLiveChatManManager::OnRecvAutoInviteMsg(womanId : %s, manId : %s) is IsExist contact end", womanId.c_str(), manId.c_str());
        return;
    }
    // 条件过滤
    if (m_autoInviteFilter != NULL) {
        m_autoInviteFilter->FilterAutoInvite(womanId, manId, key);
    }
    FileLevelLog("LiveChatManager", KLog::LOG_MSG, "LSLiveChatManManager::OnRecvAutoInviteMsg(womanId : %s, manId : %s) end", womanId.c_str(), manId.c_str());
}

string LSLiveChatManManager::GetLogPath()
{
	return m_dirPath + LOG_DIR;
}

void LSLiveChatManManager::OnCheckCoupon(long requestId, bool success, const LSLCCoupon& item, const string& userId, const string& errnum, const string& errmsg) {
    LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
    
    FileLog("LiveChatManager", "LiveChatManager::OnCheckCoupon() userId:%s, userItem:%p, success:%d, errnum:%s, errmsg:%s, status:%d time:%d"
            , userId.c_str(), userItem, success, errnum.c_str(), errmsg.c_str(), item.status, item.time);
    if (NULL != userItem)
    {
        FileLog("LiveChatManager", "LiveChatManager::OnCheckCoupon() userId:%s", userId.c_str());
        
        // 判断试聊券是否可用
        bool canUse = (item.status == CouponStatus_Yes || item.status == CouponStatus_Started);
        
        // 外部操作
        CouponStatus status = (canUse ? CouponStatus_Yes : item.status);
        m_listener->OnCheckCoupon(success, errnum, errmsg, userId, status);
        // 判断是否时token过期
        HandleTokenOver(errnum, errmsg);

    }
}

void LSLiveChatManManager::OnQueryChatRecord(long requestId, bool success, int dbTime, const list<LSLCRecord>& recordList, const string& errnum, const string& errmsg, const string& inviteId)
{
	LSLCUserItem* userItem = NULL;
	if (success)
	{
		// 设置服务器当前数据库时间
		LSLCMessageItem::SetDbTime(dbTime);

		// 插入聊天记录
		userItem = m_userMgr->GetUserItemWithInviteId(inviteId);
		if (userItem != NULL) {
			// 清除已完成的记录（保留未完成发送的记录）
			userItem->ClearFinishedMsgList();
            // 上面清除了message，下面的私密照管理器就要清除相关的messageItem
            if (m_photoMgr != NULL) {
                m_photoMgr->ClearBindMapWithUserId(userItem->m_userId);
            }
			// 插入历史记录
			for (list<LSLCRecord>::const_iterator iter = recordList.begin();
				iter != recordList.end();
				iter++)
			{
                // 当消息类型是文本， 邀请， 警告， 小高级表情才记录
                if (!((*iter).messageType != LRM_EMOTION)) {
                    LSLCMessageItem* item = new LSLCMessageItem();
                    if (item->InitWithRecord(
                                             m_msgIdBuilder.GetAndIncrement(),
                                             m_userId,
                                             userItem->m_userId,
                                             userItem->m_inviteId,
                                             (*iter),
                                             m_emotionMgr,
                                             m_voiceMgr,
                                             m_photoMgr,
                                             m_videoMgr,
                                             m_magicIconMgr))
                    {
                        userItem->InsertSortMsgList(item);
                    }
                    else {
                        delete item;
                    }
                }

			}
			// 合并图片聊天记录
			m_photoMgr->CombineMessageItem(userItem);
			// 合并视频聊天记录
			m_videoMgr->CombineMessageItem(userItem);
		}
    } else {
        // 判断是否时token过期
        HandleTokenOver(errnum, errmsg);
    }

	// callback
	m_listener->OnGetHistoryMessage(success, errnum, errmsg, userItem);
}

void LSLiveChatManManager::OnQueryChatRecordMutiple(long requestId, bool success, int dbTime, const list<LSLCRecordMutiple>& recordMutiList, const string& errnum, const string& errmsg)
{
	FileLog("LiveChatManager", "LiveChatManager::OnQueryChatRecordMutiple() requestId:%d, success:%d, dbTime:%d, recordMutiList.size:%d, errnum:%s, errmsg:%s"
			, requestId, success, dbTime, recordMutiList.size(), errnum.c_str(), errmsg.c_str());

	LCUserList userList;
	if (success)
	{
		// 设置服务器当前数据库时间
		LSLCMessageItem::SetDbTime(dbTime);

		FileLog("LiveChatManager", "LiveChatManager::OnQueryChatRecordMutiple() loop record");

		// 插入聊天记录
		for (list<LSLCRecordMutiple>::const_iterator iter = recordMutiList.begin();
			iter != recordMutiList.end();
			iter++)
		{
			LSLCUserItem* userItem = m_userMgr->GetUserItemWithInviteId((*iter).inviteId);
			if (userItem != NULL
				&& !(*iter).recordList.empty())
			{
				// 清除已完成的记录（保留未完成发送的记录）
				userItem->ClearFinishedMsgList();
                // 上面清除了message，下面的私密照管理器就要清除相关的messageItem
                if (m_photoMgr != NULL) {
                    m_photoMgr->ClearBindMapWithUserId(userItem->m_userId);
                }
				// 服务器返回的历史消息是倒序排列的
				for (list<LSLCRecord>::const_iterator recordIter = (*iter).recordList.begin();
					recordIter != (*iter).recordList.end();
					recordIter++)
				{
                    if ((*recordIter).messageType != LRM_EMOTION) {
                        LSLCMessageItem* item = new LSLCMessageItem();
                        if (item->InitWithRecord(
                                m_msgIdBuilder.GetAndIncrement(),
                                m_userId,
                                userItem->m_userId,
                                userItem->m_inviteId,
                                (*recordIter),
                                m_emotionMgr,
                                m_voiceMgr,
                                m_photoMgr,
                                m_videoMgr,
                                m_magicIconMgr))
                        {
                            userItem->InsertSortMsgList(item);
                            
                        }
                        else {
                            delete item;
                        }

                        FileLog("LiveChatManager", "LiveChatManager::OnQueryChatRecordMutiple() loop record item:%p", item);
                    }
				}

				// 合并图片聊天记录
				m_photoMgr->CombineMessageItem(userItem);
                
                // 合并视频聊天记录
				m_videoMgr->CombineMessageItem(userItem);
				// 添加到用户数组
				userList.push_back(userItem);
                

				FileLog("LiveChatManager", "LiveChatManager::OnQueryChatRecordMutiple() loop user:%s", userItem->m_userId.c_str());
			}
		}
    } else {
        // 判断是否时token过期
        HandleTokenOver(errnum, errmsg);
    }
    
    // 检查私密照是否收费
    RequestItem* requestItem = new RequestItem();
    requestItem->requestType = REQUEST_TASK_CheckPhotoList;
    InsertRequestTask(this, (TaskParam)requestItem);

	FileLog("LiveChatManager", "LiveChatManager::OnQueryChatRecordMutiple() OnGetUsersHistoryMessage() requestId:%d, success:%d, listener:%p"
			, requestId, success, m_listener);
    
    // 标记已经获取聊天记录
    m_isGetHistory = true;
    
	// callback
	m_listener->OnGetUsersHistoryMessage(success, errnum, errmsg, userList);

	// 重置ReuqestId
	m_getUsersHistoryMsgRequestId = HTTPREQUEST_INVALIDREQUESTID;

    if (success) {
        // 通知Livechat会话管理器开始任务
        m_liveChatSessionManager->Start();
    }
}




void LSLiveChatManManager::OnPhotoFee(long requestId, bool success, const string& errnum, const string& errmsg, const string& sendId)
{
	LSLCMessageItem* item = m_photoMgr->GetAndRemoveRequestItem(requestId);
    LSLCPhotoItem* photoItem = nullptr;
    // 防止清除消息导致的空指针调用
    if (item != NULL) {
        photoItem = item->GetPhotoItem();
    }
//	LSLCPhotoItem* photoItem = item->GetPhotoItem();
	if (NULL == item || NULL == photoItem) {
		FileLog("LiveChatManager", "LiveChatManager::OnPhotoFee() get request item fail, requestId:%d", requestId);
		return;
	}

    LSLIVECHAT_LCC_ERR_TYPE errType = (success ? LSLIVECHAT_LCC_ERR_SUCCESS : LSLIVECHAT_LCC_ERR_FAIL);
    if (!success && 0 == errnum.compare(LOCAL_ERROR_CODE_TIMEOUT)) {
        errType = LSLIVECHAT_LCC_ERR_CONNECTFAIL;
    }
	item->m_procResult.SetResult(errType, errnum, errmsg);
	photoItem->m_charge = success;
	photoItem->RemoveFeeStatus();

    bool showPhotoResult = false;
	if (success) {
		// 通知LiveChat服务器已经购买图片
	showPhotoResult = m_client->ShowPhoto(
			item->GetUserItem()->m_userId
			, item->GetUserItem()->m_inviteId
			, item->GetPhotoItem()->m_photoId
			, item->GetPhotoItem()->m_sendId
			, item->GetPhotoItem()->m_charge
			, item->GetPhotoItem()->m_photoDesc
			, item->m_msgId);
    
    } else {
        // 判断是否时token过期
        HandleTokenOver(errnum, errmsg);
    }
    
	m_listener->OnPhotoFee(success, errnum, errmsg, item);

}

void LSLiveChatManManager::OnCheckPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& sendId, bool isCharge)
{
	LSLCMessageItem* item = m_photoMgr->GetAndRemoveRequestItem(requestId);
	LSLCPhotoItem* photoItem = item->GetPhotoItem();
	if (NULL == item || NULL == photoItem) {
		FileLog("LiveChatManager", "LiveChatManager::OnCheckPhoto() get request item fail, requestId:%d", requestId);
		return;
	}

	//item->m_procResult.SetResult(success ? LSLIVECHAT_LCC_ERR_SUCCESS : LSLIVECHAT_LCC_ERR_FAIL, errnum, errmsg);
    photoItem->m_charge = isCharge;
    photoItem->RemoveCheckStatus();
	m_listener->OnCheckPhoto(success, errnum, errmsg, item);
    // 判断是否时token过期
    HandleTokenOver(errnum, errmsg);
}


void LSLiveChatManManager::OnGetPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath)
{
	FileLog("LiveChatManager", "LiveChatManager::OnGetPhoto() begin");
	m_photoMgr->OnGetPhoto(requestId, success, errnum, errmsg, filePath);
	FileLog("LiveChatManager", "LiveChatManager::OnGetPhoto() end");
}

void LSLiveChatManManager::OnUploadVoice(long requestId, bool success, const string& errnum, const string& errmsg, const string& voiceId)
{
	LSLCMessageItem* item = m_voiceMgr->GetAndRemoveRquestItem(requestId);
	LSLCVoiceItem* voiceItem = item->GetVoiceItem();
	if (NULL == voiceItem) {
		FileLog("LiveChatManager", "LiveChatManager::OnUploadVoice() param fail. voiceItem is NULL.");
		m_listener->OnSendVoice(LSLIVECHAT_LCC_ERR_FAIL, "", "", item);
	}

	if (success) {
		voiceItem->m_voiceId = voiceId;
		if (m_client->SendVoice(item->m_toId, voiceItem->m_voiceId, voiceItem->m_timeLength, item->m_msgId)) {
			m_voiceMgr->AddSendingItem(item->m_msgId, item);
		}
		else {
			m_listener->OnSendVoice(LSLIVECHAT_LCC_ERR_FAIL, "", "", item);
		}
	}
	else {
		item->m_statusType = StatusType_Fail;
		item->m_procResult.SetResult(LSLIVECHAT_LCC_ERR_FAIL, errnum, errmsg);
		m_listener->OnSendVoice(item->m_procResult.m_errType, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
	}
}

void LSLiveChatManManager::OnPlayVoice(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath)
{
	LSLCMessageItem* item = m_voiceMgr->GetAndRemoveRquestItem(requestId);
	if (NULL != item) {
		item->m_procResult.SetResult(success ? LSLIVECHAT_LCC_ERR_SUCCESS : LSLIVECHAT_LCC_ERR_FAIL, errnum, errmsg);

		// 处理完成
		if (NULL != item->GetVoiceItem()) {
			item->GetVoiceItem()->m_processing = false;
		}
		m_listener->OnGetVoice(item->m_procResult.m_errType, item->m_procResult.m_errNum, item->m_procResult.m_errMsg, item);
        // 判断是否时token过期
        HandleTokenOver(errnum, errmsg);
	}

	FileLog("LiveChatManager", "LiveChatManager::OnPlayVoice() end, requestId:%d, isSuccess:%d, errnum:%s, errmsg:%s, filePath:%s"
			, requestId, success, errnum.c_str(), errmsg.c_str(), filePath.c_str());
}

void LSLiveChatManManager::OnGetVideoPhoto(long requestId, bool success, const string& errnum, const string& errmsg, const string& filePath)
{
	// 回调到videoMgr
	m_videoMgr->OnGetVideoPhoto(requestId, success, errnum, errmsg, filePath);
}

void LSLiveChatManManager::OnGetVideo(long requestId, bool success, const string& errnum, const string& errmsg, const string& url)
{
	LSLCMessageItem* item = m_videoMgr->RemovePhotoFee(requestId);
    // 是否是继续
    bool isGetVideo = false;
	if (NULL != item && NULL != item->GetVideoItem())
	{
		lcmm::LSLCVideoItem* videoItem = item->GetVideoItem();
        // 不管成功和失败都删除这个，防止失败不删除，而再次购买没有调用videofee
        videoItem->RemoveProcessStatusFee();
        if (success) {
            videoItem->m_charge = true;
            
            videoItem->m_videoUrl = url;
            
            // 通知LiveChat服务器已经购买视频
            m_client->PlayVideo(
                                item->m_fromId
                                , item->m_inviteId
                                , videoItem->m_videoId
                                , videoItem->m_sendId
                                , videoItem->m_charge
                                , videoItem->m_videoDesc
                                , item->m_msgId);
        }

	}
    
    LSLIVECHAT_LCC_ERR_TYPE errType = (success ? LSLIVECHAT_LCC_ERR_SUCCESS : LSLIVECHAT_LCC_ERR_FAIL);
    if (!success && 0 == errnum.compare(LOCAL_ERROR_CODE_TIMEOUT)) {
        errType = LSLIVECHAT_LCC_ERR_CONNECTFAIL;
    }
    
    item->m_procResult.SetResult(errType, errnum, errmsg);
	// callback
	m_listener->OnVideoFee(success, errnum, errmsg, item);
    // 判断是否时token过期
    HandleTokenOver(errnum, errmsg);
}

void LSLiveChatManManager::OnGetMagicIconConfig(long requestId, bool success, const string& errnum, const string& errmsg,const LSLCMagicIconConfig& config)
{
    FileLog("LiveChatManager", "LiveChatManager::OnGetMagicIconConfig() OnMagicIconConfig begin");
    bool isSuccess = success;
    LSLCMagicIconConfig configItem = config;
    if(isSuccess){
        if (m_magicIconMgr->IsVerNewThenConfigItem(config.maxupdatetime)) {
            isSuccess = m_magicIconMgr->UpdateConfigItem(config);
        }
        else{
            configItem = m_magicIconMgr->GetConfigItem();
        }
    } else {
        // 判断是否时token过期
        HandleTokenOver(errnum, errmsg);
    }
    FileLog("LiveChatManager", "LiveChatManager::OnGetMagicIconConfig() OnMagicIconConfig callback");
    if (NULL != m_listener) {
        m_listener->OnGetMagicIconConfig(success, errnum, errmsg, config);
    }
    m_magicIconMgr->m_magicIconConfigReqId = HTTPREQUEST_INVALIDREQUESTID;
    FileLog("LiveChatManager", "LiveChatManager::OnGetMagicIconConfig() OnMagicIconCongig end");
}

void LSLiveChatManManager::OnUploadPopLadyAutoInvite(LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const string& userId, const string& msg, const string& key, const string& inviteId) {
    if (err == LSLIVECHAT_LCC_ERR_SUCCESS && !userId.empty() && m_userMgr != NULL) {
        // 添加用户到列表中（若列表中用户不存在）
        LSLCUserItem* userItem = m_userMgr->GetUserItem(userId);
        if (NULL == userItem) {
            FileLog("LiveChatManager", "LiveChatManager::OnUploadPopLadyAutoInvite() fail, userId:%s", userId.c_str());
            return;
        }
        userItem->m_inviteId = inviteId;
        // Alex, 2019-07-26, 当用邀请id后，将之前的自动邀请消息加上邀请id
        userItem->InsertSortMsgList(NULL);
    }
}

// ------------------- ILSLiveChatRequestOtherControllerCallback -------------------
void LSLiveChatManManager::OnEmotionConfig(long requestId, bool success, const string& errnum, const string& errmsg, const LSLCOtherEmotionConfigItem& item)
{
	FileLog("LiveChatManager", "LiveChatManager::OnEmotionConfig() OnOtherEmotionConfig begin");
	bool isSuccess = success;
	LSLCOtherEmotionConfigItem configItem = item;
	if (isSuccess) {
		// 请求成功
		if (m_emotionMgr->IsVerNewThenConfigItem(item.version)) {
			// 配置版本更新
			isSuccess = m_emotionMgr->UpdateConfigItem(item);
		}
		else {
			// 使用旧配置
			configItem = m_emotionMgr->GetConfigItem();
		}
    } else {
        // 判断是否时token过期
        HandleTokenOver(errnum, errmsg);
    }
	FileLog("LiveChatManager", "LiveChatManager::OnEmotionConfig() OnOtherEmotionConfig callback");
	if (NULL != m_listener) {
		m_listener->OnGetEmotionConfig(isSuccess, errnum, errmsg, item);
	}
	m_emotionMgr->m_emotionConfigReqId = HTTPREQUEST_INVALIDREQUESTID;
	FileLog("LiveChatManager", "LiveChatManager::OnEmotionConfig() OnOtherEmotionConfig end");
}

/******************************************* 定时任务处理 *******************************************/
// 请求线程启动
bool LSLiveChatManManager::StartRequestThread()
{
	bool result = false;

	// 停止之前的请求线程
	StopRequestThread();

	// 启动线程
	m_requestThread = ILSLiveChatThreadHandler::CreateThreadHandler();
	if (NULL != m_requestThread)
	{
		m_requestThreadStart = true;
		result = m_requestThread->Start(LSLiveChatManManager::RequestThread, this);

		if (!result) {
			m_requestThreadStart = false;
		}
	}

	return result;
}

// 请求线程结束
void LSLiveChatManManager::StopRequestThread()
{
	if (NULL != m_requestThread)
	{
		m_requestThreadStart = false;
		m_requestThread->WaitAndStop();
		ILSLiveChatThreadHandler::ReleaseThreadHandler(m_requestThread);
		m_requestThread = NULL;
	}
}

// 请求线程函数
TH_RETURN_PARAM LSLiveChatManManager::RequestThread(void* obj)
{
	LSLiveChatManManager* pThis = (LSLiveChatManManager*)obj;
	pThis->RequestThreadProc();
	return 0;
}

// 请求线程处理函数
void LSLiveChatManManager::RequestThreadProc()
{
	while (m_requestThreadStart)
	{
		TaskItem* item = PopRequestTask();
		if ( item )
		{
			if (getCurrentTime() >= item->delayTime)
			{
                if( item->callback ) {
                    item->callback->OnLiveChatManManagerTaskRun(item->param);
                }
                
                delete item;
			}
			else 
			{
				// 任务时间未到
				PushRequestTask(item);
				Sleep(50);
			}
		}
		else
		{
			// 请求队列为空
			Sleep(50);
		}
	}
}

// 判断请求队列是否为空
bool LSLiveChatManManager::IsRequestQueueEmpty()
{
	bool result = false;
	// 加锁
	if (NULL != m_requestQueueLock) {
		m_requestQueueLock->Lock();
	}

	// 处理
	result = m_requestQueue.empty();

	// 解锁
	if (NULL != m_requestQueueLock) {
		m_requestQueueLock->Unlock();
	}
	return result;
}

// 弹出请求队列第一个item
LSLiveChatManManager::TaskItem* LSLiveChatManManager::PopRequestTask()
{
	TaskItem* item = NULL;

	// 加锁
	if (NULL != m_requestQueueLock) {
		m_requestQueueLock->Lock();
	}

	// 处理
	if (!m_requestQueue.empty())
	{
		item = m_requestQueue.front();
		m_requestQueue.pop_front();
	}

	// 解锁
	if (NULL != m_requestQueueLock) {
		m_requestQueueLock->Unlock();
	}

	return item;
}

// 插入请求队列
bool LSLiveChatManManager::PushRequestTask(TaskItem* item)
{
	bool result = false;

	// 加锁
	if (NULL != m_requestQueueLock) {
		m_requestQueueLock->Lock();
	}

	// 处理
    if( item ) {
        m_requestQueue.push_back(item);
        result = true;
    }

	// 解锁
	if (NULL != m_requestQueueLock) {
		m_requestQueueLock->Unlock();
	}

	return result;
}

// 清空请求队列
void LSLiveChatManManager::CleanRequestTask()
{
	// 加锁
	if (NULL != m_requestQueueLock) {
		m_requestQueueLock->Lock();
	}

	// 处理
    TaskItem* item = NULL;
    while( (item = m_requestQueue.front()) ) {
        m_requestQueue.pop_front();
        
        if( item->callback ) {
            item->callback->OnLiveChatManManagerTaskClose(item->param);
        }
        
        delete item;
    }
    
	m_requestQueue.clear();

	// 解锁
	if (NULL != m_requestQueueLock) {
		m_requestQueueLock->Unlock();
	}
}

void LSLiveChatManManager::InsertRequestTask(ILSLiveChatManManagerTaskCallback* callback, TaskParam param, long long delayTime) {
    TaskItem* taskItem = new (TaskItem);
    taskItem->callback = callback;
    taskItem->param = param;
    if (delayTime > 0) {
        taskItem->delayTime = getCurrentTime() + delayTime;
    }
    PushRequestTask(taskItem);
}

void LSLiveChatManManager::OnLiveChatManManagerTaskRun(TaskParam param) {
    RequestItem* item = (RequestItem *)param;
    if( item ) {
        RequestHandler(item);
        delete item;
    }
}

void LSLiveChatManManager::OnLiveChatManManagerTaskClose(TaskParam param) {
    RequestItem* item = (RequestItem *)param;
    if( item ) {
        delete item;
    }
}

void LSLiveChatManManager::RequestHandler(RequestItem* item) {
    switch (item->requestType)
    {
        case REQUEST_TASK_Unknow:break;
        case REQUEST_TASK_GetEmotionConfig:
            // 获取高级表情配置
            GetEmotionConfig();
            break;
        case REQUEST_TASK_GetMagicIconConfig:
            // 获取小高级表情配置
            GetMagicIconConfig();
            break;
        case REQUEST_TASK_AutoRelogin:
            // 执行自动重登录流程
            AutoRelogin();
            break;
        case REQUEST_TASK_GetUsersHistoryMessage:
            // 获取聊天历史记录
        {
            list<string> userIds;
            
            // 获取在聊用户ID
            LCUserList userList = m_userMgr->GetChatingUsers();
            for (LCUserList::const_iterator iter = userList.begin();
                 iter != userList.end();
                 iter++)
            {
                userIds.push_back((*iter)->m_userId);
            }
            
            // 获取男士主动邀请用户ID
            userList = m_userMgr->GetManInviteUsers();
            for (LCUserList::const_iterator iter = userList.begin();
                 iter != userList.end();
                 iter++)
            {
                userIds.push_back((*iter)->m_userId);
            }
            
            if (!userIds.empty()) {
                GetUsersHistoryMessage(userIds);
            }
            else
            {
                // 不需要获取历史纪录
                m_isGetHistory = true;
                // 通知Livechat会话管理器开始任务,发送待发信息，延时处理
               m_liveChatSessionManager->Start();
            }
        }break;
        case REQUEST_TASK_SendMessageListNoMoneyFail:
            // 处理指定用户的待发消息发送不成功(余额不足)
            break;
        case REQUEST_TASK_SendMessageListConnectFail:
            // 处理指定用户的待发消息发送不成功(连接失败)
            break;
        case REQUEST_TASK_LoginManagerLogout:
            // LoginManager注销
            break;
        case REQUEST_TASK_ReleaseEmotionDownloader:
            // 释放高级表情downloader
        {
            m_emotionMgr->ClearFinishDownloaderWithTimer();
            static const long stepTime = 5 * 1000; // 每5秒释放一次
            RequestItem* requestItem = new RequestItem();
            requestItem->requestType = REQUEST_TASK_ReleaseEmotionDownloader;
            requestItem->param = (TaskParam)0;
            InsertRequestTask(this, (TaskParam)requestItem, stepTime);
        }
            break;
        case REQUEST_TASK_ReleasePhotoDownloader:
            // 释放图片downloader
        {
            m_photoMgr->ClearFinishDownloaderWithTimer();
            static const long stepTime = 5 * 1000; // 每5秒释放一次
            RequestItem* requestItem = new RequestItem();
            requestItem->requestType = REQUEST_TASK_ReleasePhotoDownloader;
            requestItem->param = (TaskParam)0;
            InsertRequestTask(this, (TaskParam)requestItem, stepTime);
        }
            break;
        case REQUEST_TASK_ReleaseVideoPhotoDownloader:
            // 释放视频图片downloader
        {
            m_videoMgr->ClearFinishVideoPhotoDownloaderWithTimer();
            static const long stepTime = 5 * 1000; // 每5秒释放一次
            RequestItem* requestItem = new RequestItem();
            requestItem->requestType = REQUEST_TASK_ReleaseVideoPhotoDownloader;
            requestItem->param = (TaskParam)0;
            InsertRequestTask(this, (TaskParam)requestItem, stepTime);
        }
            break;
        case REQUEST_TASK_ReleaseVideoDownloader:
            // 释放视频downloader
        {
            m_videoMgr->ClearFinishVideoDownloaderWithTimer();
            static const long stepTime = 5 * 1000; // 每5秒释放一次
            RequestItem* requestItem = new RequestItem();
            requestItem->requestType = REQUEST_TASK_ReleaseVideoDownloader;
            requestItem->param = (TaskParam)0;
            InsertRequestTask(this, (TaskParam)requestItem, stepTime);
        }
            break;
        case REQUEST_TASK_ReleaseMagicIconDownloader:
            // 释放小高级表情downloader
        {
            m_magicIconMgr->ClearFinishDownloaderWithTimer();
            static const long stepTime = 5 * 1000; // 每5秒释放一次
            RequestItem* requestItem = new RequestItem();
            requestItem->requestType = REQUEST_TASK_ReleaseMagicIconDownloader;
            requestItem->param = (TaskParam)0;
            InsertRequestTask(this, (TaskParam)requestItem, stepTime);
        }
            break;
        case REQUEST_TASK_CheckPhotoList:
            // 检查私密照是否收费
        {
            m_photoMgr->RequestCheckPhotoList(m_userId, m_sId);
        }break;
        case REQUEST_TASK_SendPhotoWithURL:
            // http发送私密照片（由http 13.6.上传附件）
        {
            LSLCMessageItem* photoItem = (LSLCMessageItem*)item->param;
            if (NULL != photoItem) {
                SendPhotoWithUrl(photoItem);
            }
        }break;
        case REQUEST_TASK_NOPRIV_SENDMESSAGE:
        {
            // 发送消息的回调
            LSLCMessageItem* msgItem = (LSLCMessageItem*)item->param;
            if (NULL != msgItem) {
                HandleSendbackcall(msgItem);
            }
        }break;
        case REQUEST_TASK_NOLOGIN_PHOTOANDVIDEOFEE:
        {
            // 发送消息的回调
            LSLCMessageItem* msgItem = (LSLCMessageItem*)item->param;
            if (NULL != msgItem) {
                HandleFeebackcall(msgItem);
            }
        }break;
    }
}
/******************************************* 定时任务处理 End *******************************************/
