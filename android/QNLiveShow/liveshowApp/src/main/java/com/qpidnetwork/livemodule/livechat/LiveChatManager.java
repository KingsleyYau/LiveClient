package com.qpidnetwork.livemodule.livechat;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetAccountBalanceCallback;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.livechat.LCMagicIconManager.LCMagicIconManagerCallback;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.MessageType;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.SendType;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.StatusType;
import com.qpidnetwork.livemodule.livechat.LCNormalInviteManager.HandleInviteMsgType;
import com.qpidnetwork.livemodule.livechat.LCNotifyItem.NotifyType;
import com.qpidnetwork.livemodule.livechat.LCSystemLinkItem.SystemLinkOptType;
import com.qpidnetwork.livemodule.livechat.LCThemeManager.LCThemeDownloadCallback;
import com.qpidnetwork.livemodule.livechat.LCThemeManager.ThemeStatus;
import com.qpidnetwork.livemodule.livechat.LCUserItem.ChatServiceType;
import com.qpidnetwork.livemodule.livechat.LCUserItem.ChatType;
import com.qpidnetwork.livemodule.livechat.LCWarningLinkItem.LinkOptType;
import com.qpidnetwork.livemodule.livechat.camshare.LCCamShareClient.CamShareClientErrorType;
import com.qpidnetwork.livemodule.livechat.camshare.LCCamShareClient.CamShareClientStatus;
import com.qpidnetwork.livemodule.livechat.camshare.LCCamShareClient.OnLCCamShareClientListener;
import com.qpidnetwork.livemodule.livechat.camshare.LCCamShareManager;
import com.qpidnetwork.livemodule.livechat.contact.ContactBean;
import com.qpidnetwork.livemodule.livechat.jni.LCPaidThemeInfo;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.CamshareInviteType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.CamshareLadyInviteType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.CamshareLadySoundType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.ClientType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.InviteStatusType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserCamStatusType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserSexType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserStatusProtocol;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserStatusType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatLadyCondition;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatSessionInfoItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkListInfo;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkSessionListItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatUserCamStatus;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatUserStatus;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJni;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.PhotoModeType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.PhotoSizeType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.ServiceType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.ToFlagType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.VideoPhotoType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.VideoToFlagType;
import com.qpidnetwork.livemodule.livechathttprequest.OnCheckCouponCallCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCGetMagicIconConfigCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCGetPhotoCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCGetThemeDetailCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCGetVideoCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCPhotoFeeCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCPlayVoiceCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCRequestFileCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCUploadVoiceCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCUseCouponCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnQueryChatRecordCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnQueryChatRecordMutipleCallback;
import com.qpidnetwork.livemodule.livechathttprequest.item.Coupon;
import com.qpidnetwork.livemodule.livechathttprequest.item.Coupon.CouponStatus;
import com.qpidnetwork.livemodule.livechathttprequest.item.LCRequestEnum.LivechatInviteRiskType;
import com.qpidnetwork.livemodule.livechathttprequest.item.LCSendPhotoItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconConfig;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.Record;
import com.qpidnetwork.livemodule.livechathttprequest.item.RecordMutiple;
import com.qpidnetwork.livemodule.livechathttprequest.item.ThemeConfig;
import com.qpidnetwork.livemodule.livechathttprequest.item.ThemeItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.model.http.RequestBaseResponse;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.bean.WebSiteBean;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * LiveChat管理类
 * @author Samson Fan
 *
 */
@SuppressLint("HandlerLeak")
public class LiveChatManager 
			extends LiveChatClientListener
			implements LCEmotionManager.LCEmotionManagerCallback
						,IAuthorizationListener
						,LCMagicIconManagerCallback
						,LCThemeDownloadCallback
{
	private static final String TAG = LiveChatManager.class.getName();

	private Context mContext;
	/**
	 * 用户ID
	 */
	private String mUserId;
	/**
	 * sid
	 */
	private String mSid;
	/**
	 * 设置唯一标识
	 */
	private String mDeviceId;
	/**
	 * 是否风控
	 */
	private boolean mRiskControl;
	/**
	 * 是否接收视频消息
	 */
	private boolean mIsRecvVideoMsg;
	/**
	 * 是否已登录的标志
	 */
	private boolean mIsLogin;
	/**
	 * 是否重置数据
	 */
	private boolean mIsResetParam = false;
	/**
	 * 是否自动重登录
	 */
	private boolean mIsAutoRelogin;
	private final int mAutoReloginTime = 30 * 1000;	// 30秒
	/**
	 * 获取多个用户历史聊天记录的requestId
	 */
	private long mGetUsersHistoryMsgRequestId;
	/**
	 * 消息ID生成器
	 */
	private AtomicInteger mMsgIdIndex;
	private static final int MsgIdIndexBegin = 1;
	/**
	 * 文本消息管理器
	 */
	private LCTextManager mTextMgr;
	/**
	 * 高级表情管理器
	 */
	private LCEmotionManager mEmotionMgr;
	/**
	 * 语音管理器
	 */
	private LCVoiceManager mVoiceMgr;
	/**
	 * 图片管理器
	 */
	private LCPhotoManager mPhotoMgr;
	/**
	 * 视频管理器
	 */
	private LCVideoManager mVideoMgr;
	/**
	 * 小高级表情管理器
	 */
	private LCMagicIconManager mMagicIconMgr;
	/**
	 * 用户管理器
	 */
	private LCUserManager mUserMgr;
	/**
	 * 邀请管理器
	 */
	private LCInviteManager mInviteMgr;
	/**
	 * 自动邀请过滤器
	 */
	private LCAutoInviteFilter mAutoInviteFilter;
	/**
	 * 黑名单管理器
	 */
	private LCBlockManager mBlockMgr;
	/**
	 * 联系人管理器
	 */
	private LCContactManager mContactMgr;
	/**
	 * UserDto 管理器
	 */
	private LCUserInfoManager mUserInfoManager;
	/**
	 * Livechat 相关功能对方是否支持检测
	 */
	private LCFunctionCheckManager mLCFunctionCheckManager;
	/**
	 * Livechat 主题功能管理器
	 */
	private LCThemeManager mLCThemeManager;
	/**
	 * Livechat CamShare 管理模块
	 */
	private LCCamShareManager mLCCamShareManager;
	/**
	 * 回调处理器
	 */
	private LiveChatManagerCallbackHandler mCallbackHandler;
	/**
	 * Handler
	 */
	private Handler mHandler;
	/**
	 * 单件模式
	 */
	private static LiveChatManager instanceLiveChatMgr = null;

	/**
	 * LiveChat登陆异常且非网络原因导致重连次数
	 */
	private int mLivechatLoginExceptionCount = 0;

	/**
	 * 请求操作类型
	 */
	private enum LiveChatRequestOptType {
		GetEmotionConfig,			// 获取高级表情配置
		GetMagicIconConfig,         // 获取小高级表情配置
		GetTalkList,				// 获取在聊/邀请列表
		AutoRelogin,				// 执行自动重登录流程
		GetUsersHistoryMessage,		// 获取聊天历史记录
		CheckCouponWithToSendUser,	// 有待发消息的用户调用检测试聊券流程
		SendMessageList,			// 发送指定用户的待发消息
		SendMessageListNoMoneyFail,	// 处理指定用户的待发消息发送不成功(余额不足)
		SendMessageListConnectFail,	// 处理指定用户的待发消息发送不成功(连接失败)
		LoginWithLoginItem,			// 收到OnLogin回调登录LiveChat
		TryUseTicket,				// 执行使用试聊券流程
		CheckMoneyOrAutoCharge,		// 执行检测余额或启动自动充值
		GetBlockList,				// 获取黑名单列表
		GetBlockUsers,				// 获取被屏蔽女士列表
		GetContactList,				// 获取联系人列表
		UploadClientVersion,		// 上传客户端版本
		LoginManagerLogout,			// LoginManager注销
		GetSelfUserInfo,            // 获取本信息
		ChatRechargeCallback,       //执行自动充值回调
		UploadAutoChargeFlags,      //上传自动充值标志位
		CheckFunctionsFinish,       //相关功能对方是否支持检测完成回调
		UploadThemeVersion,         //上传Theme版本号
		GetAllPaidThemes,           //获取所有已购买主题列表
		GetAllPaidThemesDetail,     //获取所有已购买主题列表详情
		CamShareOnGetTalkList,      //登录成功获取完再聊列表，Camshare模块处理
		LiveChatKickOffEvent,       //LiveChat被踢事件
		AppReloginEvent,			//LiveChat登陆异常，走重新登陆流程
	}

	public static LiveChatManager newInstance(Context context) {
		if (null == instanceLiveChatMgr) {
			instanceLiveChatMgr = new LiveChatManager(context);
		}
		return instanceLiveChatMgr;
	}

	public static LiveChatManager getInstance()
	{
		return instanceLiveChatMgr;
	}

	public LiveChatManager(Context context) {
		mContext = context;
		mUserId = "";
		mSid = "";
		mDeviceId = "";
		mRiskControl = false;
		mIsRecvVideoMsg = true;
		mIsLogin = false;
		mIsAutoRelogin = false;
		mGetUsersHistoryMsgRequestId =  LCRequestJni.InvalidRequestId;
		mTextMgr = new LCTextManager();
		mEmotionMgr = new LCEmotionManager();
		mVoiceMgr = new LCVoiceManager();
		mMagicIconMgr = new LCMagicIconManager();
		mPhotoMgr = new LCPhotoManager();
		mVideoMgr = new LCVideoManager();
		mUserMgr = new LCUserManager();
		mBlockMgr = new LCBlockManager();
		mContactMgr = new LCContactManager();
		mUserInfoManager = new LCUserInfoManager();
		mInviteMgr = new LCInviteManager(mUserMgr, mBlockMgr, mContactMgr, mUserInfoManager);
		mAutoInviteFilter = new LCAutoInviteFilter(this);
		mLCFunctionCheckManager = new LCFunctionCheckManager(mUserMgr, this, mUserInfoManager);
		mLCThemeManager = new LCThemeManager(mContext, this);
		mLCCamShareManager = new LCCamShareManager(mContext, this);
		mCallbackHandler = new LiveChatManagerCallbackHandler();
		mMsgIdIndex = new AtomicInteger(MsgIdIndexBegin);

		mHandler = new Handler() {
			@Override
			public void handleMessage(Message msg)
			{

				switch (LiveChatRequestOptType.values()[msg.what]) {
				case GetEmotionConfig: {
					GetEmotionConfig();
				}break;
				case GetMagicIconConfig: {
					GetMagicIconConfig();
				}break;
				case GetTalkList: {
					GetTalkList();
				}break;
				case AutoRelogin: {
					AutoRelogin();
				}break;
				case GetUsersHistoryMessage: {
					LiveChatManager liveChatMgr = LiveChatManager.getInstance();
//					ArrayList<LCUserItem> userArray = liveChatMgr.GetChatingUsers();
					ArrayList<LCUserItem> userArray = liveChatMgr.getChatingAndManInviteUsers();
					ArrayList<String> userIdArray = new ArrayList<String>();
					for (LCUserItem item : userArray) {
						if (null != item.userId && !item.userId.isEmpty()) {
							userIdArray.add(item.userId);
						}
					}
					String[] userIds = new String[userIdArray.size()];
					userIdArray.toArray(userIds);
					liveChatMgr.GetUsersHistoryMessage(userIds);
				}break;
				case CheckCouponWithToSendUser: {
					// 调用检测试聊券流程
					ArrayList<LCUserItem> toSendUsers = mUserMgr.getToSendUsers();
					for (LCUserItem userItem : toSendUsers) {
						CheckCouponProc(userItem);
					}
				}break;
				case SendMessageList: {
					if (msg.obj instanceof String) {
						String userId = (String)msg.obj;
						// 发送待发消息
						SendMessageList(userId);
					}
				}break;
				case SendMessageListNoMoneyFail: {
					if (msg.obj instanceof String) {
						String userId = (String)msg.obj;
						// 回调待发消息发送失败
						SendMessageListFail(userId, LiveChatErrType.NoMoney);
					}
				}break;
				case SendMessageListConnectFail: {
					if (msg.obj instanceof String) {
						String userId = (String)msg.obj;
						// 回调待发消息发送失败
						SendMessageListFail(userId, LiveChatErrType.ConnectFail);
					}
				}break;
				case LoginWithLoginItem: {
					if (msg.obj instanceof LoginItem) {
						LoginItem item = (LoginItem)msg.obj;
						LoginWithLoginItem(item);
					}
				}break;
				case TryUseTicket: {
					if (msg.obj instanceof Coupon) {
						// 执行使用试聊券流程
						Coupon coupon = (Coupon)msg.obj;
						//邀请禁发
						if(isSendMessageLimited(coupon.userId)){
							//跳过试聊券使用流程，直接发送消息的邀请禁发
							SendMessageList(coupon.userId);
						}else{
							if (!UseTryTicket(coupon.userId)) {
								// 执行失败
								Message msgSendMsg = Message.obtain();
								msgSendMsg.what = LiveChatRequestOptType.SendMessageListConnectFail.ordinal();
								msgSendMsg.obj = coupon.userId;
								mHandler.sendMessage(msgSendMsg);
							}
						}
					}
				}break;
				case ChatRechargeCallback: {
					RequestBaseResponse respose = (RequestBaseResponse)msg.obj;
					List<String> userList = AutoChargeManager.getInstatnce().getPendingList();
					Log.i("LiveChatManager", "ChatRechargeCallback isSuccess: " + respose.isSuccess + "userList.size(): " + userList.size());
					//充值结束更新当前充值状态
					AutoChargeManager.getInstatnce().setAutoCharging(false);
					for(String userId : userList){
						Log.i("LiveChatManager", "ChatRechargeCallback userId: " + userId );
						if(respose.isSuccess){
//							// 若当前状态为Other，则标记为ManInvite(男士邀请)状态,不再做试聊券及自动充值检测
//							LCUserItem userItem = mUserMgr.getUserItem(userId);
//							if (null != userItem) {
//								if (userItem.chatType == ChatType.Other
//									|| userItem.chatType == ChatType.Invite)
//								{
//									userItem.chatType = ChatType.ManInvite;
//								}
//							}
							//充值成功，重新发送AutoCharge中所有用户待发送消息
							Log.i("LiveChatManager", "ChatRechargeCallback SendMessageList userId: " + userId );
							SendMessageList(userId);
						}else{
							//充值失败，回调nomoney错误
							Log.i("LiveChatManager", "ChatRechargeCallback SendMessageListFail userId: " + userId );
							SendMessageListFail(userId, LiveChatErrType.NoMoney);
						}

					}

					List<PayingThemeItem> payingThemes = AutoChargeManager.getInstatnce().getPendingThemeList();
					for(PayingThemeItem item : payingThemes){
						if(respose.isSuccess){
							//充值成功，重新购买主题
							ManFeeTheme(item.womanId, item.themeId);
						}else{
							//充值失败，回调nomoney错误
							mCallbackHandler.OnManFeeTheme(LiveChatErrType.NoMoney, item.womanId, item.themeId, "", null);
						}
					}
				}break;
				case CheckMoneyOrAutoCharge: {
					if (msg.obj instanceof String) {
						String userId = (String)msg.obj;
						CheckMoneyOrAutoCharge(userId);
					}
				}break;
				case GetBlockList: {
					LiveChatClient.GetBlockList();
				}break;
				case GetBlockUsers: {
					LiveChatClient.GetBlockUsers();
				}break;
				case GetContactList: {
					LiveChatClient.GetContactList();
				}break;
				case UploadClientVersion: {
					String verCode = String.valueOf(SystemUtils.getVersionCode(mContext));
					LiveChatClient.UploadVer(verCode);
				}break;
				case UploadAutoChargeFlags: {
					//屏蔽上传自动充值状态
//					AutoChargeManager.getInstatnce().uploadAutoChargeFlags();
				}break;
				case GetSelfUserInfo: {
					LiveChatClient.GetUserInfo(mUserId);
				}break;
				case LoginManagerLogout: {
					if (null != LoginManager.getInstance()) {
						LoginManager.getInstance().LogoutAndClean(true);
					}
				}break;
				case CheckFunctionsFinish: {
					if (msg.obj instanceof String) {
						String userId = (String)msg.obj;
						// 回调待发消息发送失败
						LCUserItem userItem = mUserMgr.getUserItem(userId);
						CheckTryTicketAndSend(userItem);
					}
				}break;
				case UploadThemeVersion: {
					ThemeConfig themeConfig = ThemeConfigManager.newInstance().getThemeConfig();
					if(themeConfig != null){
						LiveChatClient.UploadThemeListVer(Integer.valueOf(themeConfig.themeVersion));
					}
				}break;
				case GetAllPaidThemes: {
					GetAllPaidTheme();
				}break;
				case GetAllPaidThemesDetail: {
					RequestBaseResponse response = (RequestBaseResponse)msg.obj;
					GetAllPaidThemesDetail(response);
				}break;
				case CamShareOnGetTalkList: {
					LiveChatTalkListInfo talkListInfo = (LiveChatTalkListInfo)msg.obj;
					if(talkListInfo != null){
						mLCCamShareManager.OnGetTalkList(talkListInfo);
					}
				}break;

				case LiveChatKickOffEvent: {
					LiveModule.getInstance().onModuleKickoff("");
				}break;

				case AppReloginEvent: {
					//LiveChat非网络原因登陆失败处理
					LoginManager.getInstance().logout(false);
					LoginManager.getInstance().autoLogin();
				}break;
				}
			}
		};
	}

	/**
	 * 注册Other回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterOtherListener(LiveChatManagerOtherListener listener)
	{
		return mCallbackHandler.RegisterOtherListener(listener);
	}

	/**
	 * 注销Other回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterOtherListener(LiveChatManagerOtherListener listener)
	{
		return mCallbackHandler.UnregisterOtherListener(listener);
	}

	/**
	 * 注册试聊券(TryTicket)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterTryTicketListener(LiveChatManagerTryTicketListener listener)
	{
		return mCallbackHandler.RegisterTryTicketListener(listener);
	}

	/**
	 * 注销试聊券(TryTicket)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterTryTicketListener(LiveChatManagerTryTicketListener listener)
	{
		return mCallbackHandler.UnregisterTryTicketListener(listener);
	}

	/**
	 * 注册文本消息(Message)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterMessageListener(LiveChatManagerMessageListener listener)
	{
		return mCallbackHandler.RegisterMessageListener(listener);
	}

	/**
	 * 注销文本消息(Message)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterMessageListener(LiveChatManagerMessageListener listener)
	{
		return mCallbackHandler.UnregisterMessageListener(listener);
	}

	/**
	 * 注册高级表情(Emotion)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterEmotionListener(LiveChatManagerEmotionListener listener)
	{
		return mCallbackHandler.RegisterEmotionListener(listener);
	}

	/**
	 * 注销高级表情(Emotion)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterEmotionListener(LiveChatManagerEmotionListener listener)
	{
		return mCallbackHandler.UnregisterEmotionListener(listener);
	}

	/**
	 * 注册小高级表情(MagicIcon)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterMagicIconListener(LiveChatManagerMagicIconListener listener)
	{
		return mCallbackHandler.RegisterMagicIconListener(listener);
	}

	/**
	 * 注销小高级表情(MagicIcon)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterMagicIconListener(LiveChatManagerMagicIconListener listener)
	{
		return mCallbackHandler.UnregisterMagicIconListener(listener);
	}

	/**
	 * 注册微视频(Video)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterVideoListener(LiveChatManagerVideoListener listener)
	{
		return mCallbackHandler.RegisterVideoListener(listener);
	}

	/**
	 * 注销微视频(Video)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterVideoListener(LiveChatManagerVideoListener listener)
	{
		return mCallbackHandler.UnregisterVideoListener(listener);
	}

	/**
	 * 注册私密照(Photo)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterPhotoListener(LiveChatManagerPhotoListener listener)
	{
		return mCallbackHandler.RegisterPhotoListener(listener);
	}

	/**
	 * 注销私密照(Photo)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterPhotoListener(LiveChatManagerPhotoListener listener)
	{
		return mCallbackHandler.UnregisterPhotoListener(listener);
	}

	/**
	 * 注册语音(Voice)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterVoiceListener(LiveChatManagerVoiceListener listener)
	{
		return mCallbackHandler.RegisterVoiceListener(listener);
	}

	/**
	 * 注销语音(Voice)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterVoiceListener(LiveChatManagerVoiceListener listener)
	{
		return mCallbackHandler.UnregisterVoiceListener(listener);
	}

	/**
	 * 注册主题(Theme)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterThemeListener(LiveChatManagerThemeListener listener)
	{
		return mCallbackHandler.RegisterThemeListener(listener);
	}

	/**
	 * 注销主题(Theme)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterThemeListener(LiveChatManagerThemeListener listener)
	{
		return mCallbackHandler.UnregisterThemeListener(listener);
	}

	/**
	 * 注册CamShare回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterCamShareListener(LiveChatManagerCamShareListener listener)
	{
		return mCallbackHandler.RegisterCamShareListener(listener);
	}

	/**
	 * 注销CamShare回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterCamShareListener(LiveChatManagerCamShareListener listener)
	{
		return mCallbackHandler.UnregisterCamShareListener(listener);
	}

	/**
	 * 初始化
	 * @param ips			LiveChat服务器IP数组
	 * @param port			LiveChat服务器端口
	 * @param webHost		网站host（如：http://www.chnlove.com）
	 * @return
	 */
	public boolean Init(String[] ips, int port, String webHost)
	{
		boolean result = false;

		Log.d("livechat", "LiveChatManager::Init() ips.length:%d, port:%d, webHost:%s", ips.length, port, webHost);

		if (ips.length > 0
			&& port > 0
			&& !webHost.isEmpty())
		{
			String logPath = FileCacheManager.getInstance().GetLogPath();

			// 初始化高级表情管理器
			String emotionPath = FileCacheManager.getInstance().GetLCEmotionPath();
			result = mEmotionMgr.init(mContext, emotionPath, webHost, logPath, this);

			// 初始化图片管理器
			String photoPath = FileCacheManager.getInstance().GetLCPhotoPath();
			result = result && mPhotoMgr.init(photoPath);

			// 初始化语音管理器
			String voicePath = FileCacheManager.getInstance().GetLCVoicePath();
			result = result && mVoiceMgr.init(voicePath);

			// 初始化小高级表情管理器
			mMagicIconMgr.init(mContext, webHost, this);

			// 初始化视频管理器
			String videoPath = FileCacheManager.getInstance().GetLCVideoPath();
			result = result && mVideoMgr.init(videoPath);

			// 初始化LiveChatClient
			result = result && LiveChatClient.Init(this, ips, port);

			// 初始化jni打log
			LiveChatClient.SetLogDirectory(logPath);
		}

		if (result && mIsResetParam)
		{
			// 初始化成功
			// 清除资源文件
			removeSourceFile();
		}

		Log.d("livechat", "LiveChatManager::Init() end, result:%b", result);
		return result;
	}

	/**
	 * 重置参数（用于注销后或登录前）
	 */
	private void ResetParam()
	{
		if (mIsResetParam) {
			mUserId = "";
			mSid = "";
			mDeviceId = "";
			mRiskControl = false;
			mIsRecvVideoMsg = true;
			mMsgIdIndex.set(MsgIdIndexBegin);

			Log.d("livechat", "ResetParam() clear emotion begin");
			// 停止获取高级表情配置请求
			if (LCRequestJni.InvalidRequestId != mEmotionMgr.mEmotionConfigReqId) {
	//			LCLCRequestJni.StopRequest(mEmotionMgr.mEmotionConfigReqId);
				mEmotionMgr.mEmotionConfigReqId = LCRequestJni.InvalidRequestId;
			}
			Log.d("livechat", "ResetParam() clear emotion StopAllDownload3gp");
			mEmotionMgr.StopAllDownload3gp();
			Log.d("livechat", "ResetParam() clear emotion StopAllDownloadImage");
			mEmotionMgr.StopAllDownloadImage();
			Log.d("livechat", "ResetParam() clear emotion removeAllSendingItems");
			mEmotionMgr.removeAllSendingItems();

			Log.d("livechat", "ResetParam() clear photo begin");
			// 停止所有图片请求
			mPhotoMgr.release();
	//		ArrayList<Long> photoRequestIds = mPhotoMgr.clearAllRequestItems();
	//		if (null != photoRequestIds) {
	//			for (Iterator<Long> iter = photoRequestIds.iterator(); iter.hasNext(); ) {
	//				long requestId = iter.next();
	//				LCLCRequestJni.StopRequest(requestId);
	//			}
	//		}

			Log.d("livechat", "ResetParam() clear voice begin");
			// 停止所有语音请求
			mVoiceMgr.clearAllRequestItem();
	//		ArrayList<Long> voiceRequestIds = mVoiceMgr.clearAllRequestItem();
	//		if (null != voiceRequestIds) {
	//			for (Iterator<Long> iter = voiceRequestIds.iterator(); iter.hasNext(); ) {
	//				long requestId = iter.next();
	//				LCLCRequestJni.StopRequest(requestId);
	//			}
	//		}
			Log.d("livechat", "ResetParam() clear voice clearAllSendingItems");
			mVoiceMgr.clearAllSendingItems();

			// 停止获取小高级表情配置请求
			if (LCRequestJni.InvalidRequestId != mMagicIconMgr.mGetMagicIconConfigReqId) {
				mMagicIconMgr.mGetMagicIconConfigReqId = LCRequestJni.InvalidRequestId;
			}
			Log.d("livechat", "ResetParam() clear magicIcon StopAllDownloadImage");
			mMagicIconMgr.StopAllDownloadImage();
			Log.d("livechat", "ResetParam() clear magicIcon StopAllDownloadThumbImage");
			mMagicIconMgr.StopAllDownloadThumbImage();
			Log.d("livechat", "ResetParam() clear magicIcon removeAllSendingItems");
			mMagicIconMgr.removeAllSendingItems();

			Log.d("livechat", "ResetParam() clear other begin");
			mTextMgr.removeAllSendingItems();
			Log.d("livechat", "ResetParam() clear other removeAllUserItem");
			mUserMgr.removeAllUserItem();
			Log.d("livechat", "ResetParam() clear all paid theme list");
			mLCThemeManager.clear();

			//清除本地邀请缓存，防止出现跳站点异常
			mInviteMgr.clearLocalCache();
		}
	}

	/**
	 * 清除所有图片、视频等资源文件
	 */
	private void removeSourceFile()
	{
		// 清除语音文件
		mVoiceMgr.removeAllVoiceFile();
		// 清除图片文件
		mPhotoMgr.removeAllPhotoFile();
		// 清除视频文件
		mVideoMgr.removeAllVideoFile();
	}

	/**
	 * 登录
	 * @param userId	用户ID
	 * @param deviceId	设备唯一标识
	 * @return
	 */
	public synchronized boolean Login(String userId, String sid, String deviceId, boolean isRecvVideoMsg)
	{
		Log.d("livechat", "LiveChatManager::Login() begin, userId:%s, mIsLogin:%s", userId, String.valueOf(mIsLogin));

		boolean result = false;
		if (mIsLogin) {
			result = mIsLogin;
		}
		else {
			if (!mIsAutoRelogin) {
				// 重置参数
				ResetParam();
			}

			// LiveChat登录
			result = LiveChatClient.Login(userId, sid, deviceId, ClientType.CLIENT_ANDROID, UserSexType.USER_SEX_MALE);
			if (result)
			{
				mIsAutoRelogin = true;
				mUserId = userId;
				mSid = sid;
				mDeviceId = deviceId;
				mIsRecvVideoMsg = isRecvVideoMsg;
			}
		}

		Log.d("livechat", "LiveChatManager::Login() end, userId:%s, result:%s", userId, Boolean.toString(result));
		return result;
	}

	/**
	 * 是否自动重登录
	 * @return
	 */
	private boolean IsAutoRelogin(LiveChatErrType errType)
	{
		if (mIsAutoRelogin)
		{
			mIsAutoRelogin = (errType == LiveChatErrType.ConnectFail);
		}
		return mIsAutoRelogin;
	}

	/**
	 * 自动重登录
	 */
	private void AutoRelogin()
	{
		Log.d("livechat", "LiveChatManager::AutoRelogin() begin, mUserId:%s, mSid:%s, mDeviceId:%s", mUserId, mSid, mDeviceId);

		if (null != mUserId && !mUserId.isEmpty()
			&& null != mSid && !mSid.isEmpty()
			&& null != mDeviceId && !mDeviceId.isEmpty())
		{
			Login(mUserId, mSid, mDeviceId, mIsRecvVideoMsg);
		}

		Log.d("livechat", "LiveChatManager::AutoRelogin() end");
	}

	/**
	 * 注销
	 * @return
	 */
	public synchronized boolean Logout(boolean isResetParam)
	{
		Log.d("livechat", "LiveChatManager::Logout() begin");

		// 设置是否重置数据
		mIsResetParam = isResetParam;

		// 设置不自动重登录
		mIsAutoRelogin = false;
		boolean result =  LiveChatClient.Logout();

		Log.d("livechat", "LiveChatManager::Logout() end, result:%b", result);

		return result;
	}

	/**
	 * 是否已经登录
	 * @return
	 */
	public boolean IsLogin()
	{
		return mIsLogin;
	}

	/**
	 * 是否处理发送操作
	 * @return
	 */
	private boolean IsHandleSendOpt()
	{
		boolean result = false;
		if (!mRiskControl
			 && mIsAutoRelogin)
		{
			// 没有风控且自动重连
			result = true;
		}
		return result;
	}

	/**
	 * 是否立即发送消息给用户
	 * @param userItem	用户item
	 * @return
	 */
	private boolean IsSendMessageNow(LCUserItem userItem)
	{
		boolean result = false;
		if (null != userItem)
		{
			// 已经登录及聊天状态为inchat或男士邀请
			result = IsLogin() && (userItem.isInSession()
					|| userItem.chatType == ChatType.ManInvite);
		}
		return result;
	}

	/**
	 * 是否等待登录后发送消息给用户
	 * @param userItem	用户item
	 * @return
	 */
	private boolean IsWaitForLoginToSendMessage(LCUserItem userItem)
	{
		boolean result = false;
		if (null != userItem)
		{
			// 已经登录及聊天状态为inchat或男士邀请
			result = !IsLogin() && (userItem.isInSession()
					|| userItem.chatType == ChatType.ManInvite);
		}
		return result;
	}

	/**
	 * 设置在线状态
	 * @param statusType	在线状态
	 * @return
	 */
	public boolean SetStatus(UserStatusType statusType)
	{
		return LiveChatClient.SetStatus(statusType);
	}

	/**
	 * 获取指定女士信息
	 * @param userId
	 * @return
	 */
	public boolean GetUserInfo(String userId){
		return LiveChatClient.GetUserInfo(userId);
	}

	/**
	 * 批量获取女士信息
	 * @param userIds
	 * @return
	 */
	public boolean GetUsersInfo(String[] userIds)
	{
		return LiveChatClient.GetUsersInfo(userIds);
	}

	/**
	 * 获取用户状态(多个)
	 * @param userIds	用户ID数组
	 * @return
	 */
	public boolean GetUserStatus(String[] userIds)
	{
		return LiveChatClient.GetUserStatus(userIds);
	}

	/**
	 * 是否在黑名单列表
	 * @param targetId
	 * @return
	 */
	public boolean isInBlockList(String targetId){
		return mBlockMgr.IsExist(targetId);
	}

	/**
	 * 获取在聊及邀请的用户列表
	 * @return
	 */
	private boolean GetTalkList()
	{
		int talkList = LiveChatClient.TalkListChating | LiveChatClient.TalkListPause | LiveChatClient.TalkListWomanInvite;
		return LiveChatClient.GetTalkList(talkList);
	}

	/**
	 * 获取邀请的用户列表（使用前需要先完成GetTalkList()调用）
	 * @return
	 */
	public ArrayList<LCUserItem> GetInviteUsers()
	{
		return mUserMgr.getInviteUsers();
	}

	/**
	 * 获取最后一个邀请用户
	 * @return
	 */
	public LCUserItem GetLastInviteUser()
	{
		LCUserItem userItem = null;
		ArrayList<LCUserItem> inviteUsers = mUserMgr.getInviteUsers();
		if (inviteUsers.size() > 0) {
			userItem = inviteUsers.get(0);
		}
		return userItem;
	}

	/**
	 * 设置用户在线状态，若用户在线状态改变则callback通知listener
	 * @param userItem
	 * @param statusType
	 */
	private void SetUserOnlineStatus(LCUserItem userItem, UserStatusType statusType)
	{
		if (userItem.statusType != statusType)
		{
			userItem.statusType = statusType;
			mCallbackHandler.OnChangeOnlineStatus(userItem);
		}
	}

	/**
	 * 获取在聊用户列表（使用前需要先完成GetTalkList()调用）
	 * @return
	 */
	public ArrayList<LCUserItem> GetChatingUsers()
	{
		return mUserMgr.getChatingUsers();
	}

	/**
	 * 获取在聊的用户item（包括付费和试聊券）和 男士主动邀请用户列表
	 * @return
	 */
	private ArrayList<LCUserItem> getChatingAndManInviteUsers() {
		return mUserMgr.getChatingAndManInviteUsers();
	}

	/**
	 * 执行检测是否有点或自动充值逻辑
	 * @param userId
	 */
	private void CheckMoneyOrAutoCharge(String userId){
		AutoChargeManager autoChargeManager = AutoChargeManager.getInstatnce();
		Log.i("LiveChatManager", "CheckMoneyOrAutoCharge recharge credit: " + autoChargeManager.getRechargeCredit());
		if(autoChargeManager.getRechargeCredit() > 0){
			//将当前用户添加到待发送用户列表
			autoChargeManager.addToPendingList(userId);
			//是否正在充值中，正在充值中不重复充值
			if(!autoChargeManager.isAutoCharging()){
				//更新当前状态为充值状态
				autoChargeManager.setAutoCharging(true);
				//自动充值开关打开，不检测剩余点数（依赖服务器检测），直接充值
				if(!ChatRecharge(userId)){
					//充值失败
					RequestBaseResponse response = new RequestBaseResponse(true, "", "", Double.valueOf(0));
					Message msg = Message.obtain();
					msg.what = LiveChatRequestOptType.ChatRechargeCallback.ordinal();
					msg.obj = response;
					mHandler.sendMessage(msg);
				}
			}
		}else{
			//自动充值开关未打开，检测剩余点数
			if (!CheckMoney(userId)) {
				// 执行失败
				Message msgSendMsg = Message.obtain();
				msgSendMsg.what = LiveChatRequestOptType.SendMessageListConnectFail.ordinal();
				msgSendMsg.obj = userId;
				mHandler.sendMessage(msgSendMsg);
			}
		}
	}

	/**
	 * 通知服务器充值
	 * @param womanId	对方用户ID
	 * @return
	 */
	private boolean ChatRecharge(final String womanId) {
//		Log.i("LiveChatManager", "ChatRecharge womanId: " + womanId);
//		long requestId = LCRequestJniLiveChat.ChatRecharge(womanId, mSid, mUserId, new OnLCChatRechargeCallback() {
//
//			@Override
//			public void OnLCChatRecharge(long requestId, boolean isSuccess,
//					String errno, String errmsg, double credits) {
//				Log.i("LiveChatManager", "OnLCChatRecharge isSuccess: " + isSuccess + " credits: " + credits);
//				RequestBaseResponse response = new RequestBaseResponse((credits >= 0.5 || credits < 0) ? true:false, errno, errmsg, Double.valueOf(credits));
//				Message msg = Message.obtain();
//				msg.what = LiveChatRequestOptType.ChatRechargeCallback.ordinal();
//				msg.obj = response;
//				mHandler.sendMessage(msg);
//			}
//		});
//		return requestId != LCRequestJni.InvalidRequestId;
        return true;
	}

	/**
	 * 检测用户帐号是否有足够点数
	 * @return
	 */
	private boolean CheckMoney(final String userId) {
		final double minMoney = LoginManager.getInstance().getSynConfig().minChat;
		long reuqestId = LiveRequestOperator.getInstance().GetAccountBalance(new OnGetAccountBalanceCallback() {
			@Override
			public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, double balance, int coupon) {
				if (isSuccess) {
					if (balance >= minMoney) {
						// 若当前状态为Other，则标记为ManInvite(男士邀请)状态
//								LCUserItem userItem = mUserMgr.getUserItem(userId);
//								if (null != userItem) {
//									if (userItem.chatType == ChatType.Other
//										|| userItem.chatType == ChatType.Invite)
//									{
//										userItem.chatType = ChatType.ManInvite;
//									}
//								}
						// 余额足够，发送待发消息
						Message msg = Message.obtain();
						msg.what = LiveChatRequestOptType.SendMessageList.ordinal();
						msg.obj = userId;
						mHandler.sendMessage(msg);
					}
					else {
						// 返回发送消息余额不足，发送失败
						Message msgSendMsg = Message.obtain();
						msgSendMsg.what = LiveChatRequestOptType.SendMessageListNoMoneyFail.ordinal();
						msgSendMsg.obj = userId;
						mHandler.sendMessage(msgSendMsg);
					}
				}
				else {
					// 请求失败
					Message msgSendMsg = Message.obtain();
					msgSendMsg.what = LiveChatRequestOptType.SendMessageListConnectFail.ordinal();
					msgSendMsg.obj = userId;
					mHandler.sendMessage(msgSendMsg);
				}
			}
		});
//		long reuqestId = LCRequestJniOther.GetCount(true, false, false, false, false, false, new OnLCOtherGetCountCallback() {
//
//			@Override
//			public void OnOtherGetCount(boolean isSuccess, String errno, String errmsg,
//					LCOtherGetCountItem item) {
//				// TODO Auto-generated method stub
//				if (isSuccess) {
//					if (item.money >= minMoney) {
//						// 若当前状态为Other，则标记为ManInvite(男士邀请)状态
////								LCUserItem userItem = mUserMgr.getUserItem(userId);
////								if (null != userItem) {
////									if (userItem.chatType == ChatType.Other
////										|| userItem.chatType == ChatType.Invite)
////									{
////										userItem.chatType = ChatType.ManInvite;
////									}
////								}
//						// 余额足够，发送待发消息
//						Message msg = Message.obtain();
//						msg.what = LiveChatRequestOptType.SendMessageList.ordinal();
//						msg.obj = userId;
//						mHandler.sendMessage(msg);
//					}
//					else {
//						// 返回发送消息余额不足，发送失败
//						Message msgSendMsg = Message.obtain();
//						msgSendMsg.what = LiveChatRequestOptType.SendMessageListNoMoneyFail.ordinal();
//						msgSendMsg.obj = userId;
//						mHandler.sendMessage(msgSendMsg);
//					}
//				}
//				else {
//					// 请求失败
//					Message msgSendMsg = Message.obtain();
//					msgSendMsg.what = LiveChatRequestOptType.SendMessageListConnectFail.ordinal();
//					msgSendMsg.obj = userId;
//					mHandler.sendMessage(msgSendMsg);
//				}
//			}
//		});

		if (LCRequestJni.InvalidRequestId == reuqestId) {
			// 请求失败，返回发送消息余额不足失败
			Message msgSendMsg = Message.obtain();
			msgSendMsg.what = LiveChatRequestOptType.SendMessageListConnectFail.ordinal();
			msgSendMsg.obj = userId;
			mHandler.sendMessage(msgSendMsg);
		}
		return true;
	}

	/**
	 * 查询是否能使用试聊
	 * @param userId	对方用户ID
	 * @return
	 */
	public boolean CheckCoupon(String userId) {
		long requestId = LCRequestJniLiveChat.CheckCoupon(userId, ServiceType.LiveChat, new OnCheckCouponCallCallback() {

			@Override
			public void OnCheckCoupon(long requestId, boolean isSuccess, String errno, String errmsg,
					Coupon item) {
				// TODO Auto-generated method stub
				mCallbackHandler.OnCheckCoupon(isSuccess, errno, errmsg, item);
			}
		});
		return requestId != LCRequestJni.InvalidRequestId;
	}

	/**
	 * 查询是否能使用试聊
	 * @param userItem	对方用户
	 * @return
	 */
	private boolean CheckCouponProc(LCUserItem userItem) {
		// 执行尝试使用试聊券流程
		Log.i("LiveChatManager", "CheckCouponProc userId: " + userItem.userId);
		if (!userItem.tryingSend) {
			userItem.tryingSend = true;
			long requestId = LCRequestJniLiveChat.CheckCoupon(userItem.userId, ServiceType.LiveChat, new OnCheckCouponCallCallback() {

				@Override
				public void OnCheckCoupon(long requestId, boolean isSuccess, String errno, String errmsg,
						Coupon item) {
					// TODO Auto-generated method stub
					Log.i("LiveChatManager", "OnCheckCoupon userId: " + item.userId + " CouponStatus: " + item.status.ordinal());
					if (isSuccess && (item.status == CouponStatus.Yes
							|| item.status == CouponStatus.Started))
					{
						// 尝试使用试聊券
						Message msg = Message.obtain();
						msg.what = LiveChatRequestOptType.TryUseTicket.ordinal();
						msg.obj = item;
						mHandler.sendMessage(msg);
					}
					else {
						// 检测是否有点
						Message msg = Message.obtain();
						msg.what = LiveChatRequestOptType.CheckMoneyOrAutoCharge.ordinal();
						msg.obj = item.userId;
						mHandler.sendMessage(msg);
					}
				}
			});
			return requestId != LCRequestJni.InvalidRequestId;
		}
		else {
			return true;
		}
	}

	/**
	 * 使用试聊券
	 * @param userId	对方用户ID
	 * @return
	 */
	private boolean UseTryTicket(final String userId) {
		boolean result = false;
		Log.i("LiveChatManager", "UseTryTicket userId: " + userId);
		if (!userId.isEmpty()) {
			long requestId = LCRequestJniLiveChat.UseCoupon(userId, ServiceType.LiveChat, new OnLCUseCouponCallback() {

				@Override
				public void OnLCUseCoupon(long requestId, boolean isSuccess, String errno, String errmsg, String userId, String couponid) {
					// TODO Auto-generated method stub
					Log.i("LiveChatManager", "OnLCUseCoupon userId: " + userId + " isSuccess: " + isSuccess);
					if (isSuccess) {
						LiveChatClient.UseTryTicket(userId);
					}
					else {
						// 试聊券使用不成功
						mCallbackHandler.OnUseTryTicket(LiveChatErrType.Fail, errno, errmsg, userId, TryTicketEventType.Unknow);
						// 检测帐号是否有足够的点数
						Message msg = Message.obtain();
						msg.what = LiveChatRequestOptType.CheckMoneyOrAutoCharge.ordinal();
						msg.obj = userId;
						mHandler.sendMessage(msg);
					}
				}
			});
			result = (requestId != LCRequestJni.InvalidRequestId);
		}
		return result;
	}

	/**
	 * 菜单结束会话，需等待服务器返回处理，不能本地清除会话信息
	 * @param userId
	 * @return
	 */
	public boolean EndTalkNeedWait(String userId){
//		LCUserItem userItem = mUserMgr.getUserItem(userId);
//		if (null != userItem) {
//			userItem.endTalk();
//		}
        boolean result = false;
        if(mIsLogin) {
            result = LiveChatClient.EndTalk(userId);
            if (!result) {
                OnEndTalk(LiveChatErrType.ConnectFail, mContext.getResources().getString(R.string.end_chat_normal_connect_fail_tips), userId);
            }
        }else{
            OnEndTalk(LiveChatErrType.ConnectFail, mContext.getResources().getString(R.string.end_chat_normal_connect_fail_tips), userId);
        }
		return result;
	}

	/**
	 * 结束对话
	 * @param userId	对方的用户ID
	 * @return
	 */
	public boolean EndTalk(String userId)
	{
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null != userItem) {
			userItem.endTalk();
		}
		boolean result = LiveChatClient.EndTalk(userId);
		if(!result){
			OnEndTalk(LiveChatErrType.ConnectFail, mContext.getResources().getString(R.string.end_chat_normal_connect_fail_tips), userId);
		}
		return result;
	}

	/**
	 * 获取单个用户历史聊天记录（包括文本、高级表情、语音、图片）
	 * @param userId	用户ID
	 * @return
	 */
	public boolean GetHistoryMessage(String userId)
	{
		boolean result = false;
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null != userItem) {
			boolean isMsgListEmpty = false;
			synchronized (userItem.getMsgList())
			{
				isMsgListEmpty = userItem.getMsgList().isEmpty();
			}
			if (!isMsgListEmpty
				&& mGetUsersHistoryMsgRequestId == LCRequestJni.InvalidRequestId) // 未完成获取多个用户历史聊天记录的请求
			{
				result = true;
				mCallbackHandler.OnGetHistoryMessage(true, "", "", userItem);
			}
			else if (!userItem.inviteId.isEmpty())
			{
				long requestId = LCRequestJniLiveChat.QueryChatRecord(userItem.inviteId, new OnQueryChatRecordCallback() {

					@Override
					public void OnQueryChatRecord(boolean isSuccess, String errno,
                                                  String errmsg, int dbTime, Record[] recordList, String inviteId)
					{
						// TODO Auto-generated method stub

						// 设置服务器当前数据库时间
						LCMessageItem.SetDbTime(dbTime);

						// 插入聊天记录
						LCUserItem userItem = mUserMgr.getUserItemWithInviteId(inviteId);
						if (isSuccess && userItem != null) {
							// 清除已完成的记录（保留未完成发送的记录）
							userItem.clearFinishedMsgList();
							// 插入历史记录
							for (int i = 0; i < recordList.length; i++)
							{
								LCMessageItem item = new LCMessageItem();
								if (item.InitWithRecord(
										mMsgIdIndex.getAndIncrement(),
										mUserId,
										userItem.userId,
										userItem.inviteId,
										recordList[i],
										mEmotionMgr,
										mVoiceMgr,
										mPhotoMgr,
										mVideoMgr,
										mMagicIconMgr))
								{
									userItem.insertSortMsgList(item);
								}
							}
							// 合并图片聊天记录
							mPhotoMgr.combineMessageItem(userItem.msgList);
							// 合并视频聊天记录
							mVideoMgr.combineMessageItem(userItem.msgList);
						}
						mCallbackHandler.OnGetHistoryMessage(isSuccess, errno, errmsg, userItem);
					}
				});
				result = (requestId != LCRequestJni.InvalidRequestId);
			}
		}

		return result;
	}

	/**
	 * 获取多个用户历史聊天记录（包括文本、高级表情、语音、图片）
	 * @param userIds	用户ID数组
	 * @return
	 */
	public boolean GetUsersHistoryMessage(String[] userIds)
	{
		boolean result = false;
		ArrayList<String> inviteIds = new ArrayList<String>();
		for (int i = 0; i < userIds.length; i++) {
			if (!userIds[i].isEmpty()) {
				LCUserItem userItem = mUserMgr.getUserItem(userIds[i]);
				if (null != userItem)
				{
					if (!userItem.inviteId.isEmpty())
					{
						inviteIds.add(userItem.inviteId);
					}
				}
			}
		}
		if (inviteIds.size() > 0) {
			String[] inviteArray = new String[inviteIds.size()];
			inviteIds.toArray(inviteArray);
			mGetUsersHistoryMsgRequestId = LCRequestJniLiveChat.QueryChatRecordMutiple(inviteArray, new OnQueryChatRecordMutipleCallback() {

				@Override
				public void OnQueryChatRecordMutiple(boolean isSuccess, String errno,
						String errmsg, int dbTime, RecordMutiple[] recordMutipleList)
				{
					// TODO Auto-generated method stub
					LCUserItem[] userArray = null;
					ArrayList<LCUserItem> userList = new ArrayList<LCUserItem>();
					if (isSuccess
						&& null != recordMutipleList)
					{
						// 设置服务器当前数据库时间
						LCMessageItem.SetDbTime(dbTime);

						// 插入聊天记录
						for (int i = 0; i < recordMutipleList.length; i++)
						{
							RecordMutiple record = recordMutipleList[i];
							LCUserItem userItem = mUserMgr.getUserItemWithInviteId(record.inviteId);
							if (null != record.recordList
								&& userItem != null)
							{
								// 清除已完成的记录（保留未完成发送的记录）
								userItem.clearFinishedMsgList();
								// 服务器返回的历史消息是倒序排列的
								for (int k = record.recordList.length - 1; k >= 0; k--)
								{
									LCMessageItem item = new LCMessageItem();
									if (item.InitWithRecord(
											mMsgIdIndex.getAndIncrement(),
											mUserId,
											userItem.userId,
											userItem.inviteId,
											record.recordList[k],
											mEmotionMgr,
											mVoiceMgr,
											mPhotoMgr,
											mVideoMgr,
											mMagicIconMgr))
									{
										userItem.insertSortMsgList(item);
									}
								}

								// 合并图片聊天记录
								mPhotoMgr.combineMessageItem(userItem.msgList);
								// 合并视频聊天记录
								mVideoMgr.combineMessageItem(userItem.msgList);
								// 添加到用户数组
								userList.add(userItem);
							}
						}

						userArray = new LCUserItem[userList.size()];
						userList.toArray(userArray);
					}
					mCallbackHandler.OnGetUsersHistoryMessage(isSuccess, errno, errmsg, userArray);

					// 重置ReuqestId
					mGetUsersHistoryMsgRequestId = LCRequestJni.InvalidRequestId;
				}
			});
			result = (mGetUsersHistoryMsgRequestId != LCRequestJni.InvalidRequestId);
		}

		return result;
	}

	/**
	 * 插入历史聊天记录（msgId及createTime由LiveChatManager生成）
	 * @param userId	对方用户ID
	 * @param item		消息item
	 * @return
	 */
	public boolean InsertHistoryMessage(String userId, LCMessageItem item) {
		boolean result = false;
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null != userItem) {
			result = userItem.insertSortMsgList(item);
			item.msgId = mMsgIdIndex.getAndIncrement();
			item.createTime = (int)(System.currentTimeMillis() / 1000);
		}
		else {
			Log.e("livechat", String.format("%s::%s() userId:%s is not exist", "LiveChatManager", "InsertHistoryMessage", userId));
		}

		if (!result) {
			Log.e("livechat", String.format("%s::%s() fail, userId:%s, msgId:%d", "LiveChatManager", "InsertHistoryMessage", userId, item.msgId));
		}
		return result;
	}

	/**
	 * 删除历史消息记录
	 * @param item	消息item
	 */
	public boolean RemoveHistoryMessage(LCMessageItem item)
	{
		boolean result = false;
		if (null != item && null != item.getUserItem())
		{
			LCUserItem userItem = item.getUserItem();
			result = userItem.removeSortMsgList(item);
		}
		return result;
	}

	/**
	 * 获取指定消息Id的消息Item
	 * @param userId	用户ID
	 * @param msgId		消息ID
	 * @return
	 */
	public LCMessageItem GetMessageWithMsgId(String userId, int msgId) {
		LCMessageItem item = null;
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (userItem != null) {
			item = userItem.getMsgItemWithId(msgId);
		}
		return item;
	}

	/**
	 * 获取指定用户Id的用户item
	 * @param userId	用户ID
	 * @return
	 */
	public LCUserItem GetUserWithId(String userId) {
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		return userItem;
	}

	/**
	 * 获取缓存中女士资料
	 * @param womanId
	 * @return
	 */
	public LiveChatTalkUserListItem GetLadyInfoById(String womanId){
		return mUserInfoManager.getLadyInfo(womanId);
	}

	/**
	 * 获取指定联系人信息
	 * @param userid
	 * @return
	 */
	public ContactBean getContactById(String userid){
		return new ContactBean();
	}

	/**
	 * 获取消息处理状态
	 * @param userId	用户ID
	 * @param msgId		消息ID
	 * @return
	 */
	public StatusType GetMessageItemStatus(String userId, int msgId) {
		StatusType statusType = StatusType.Unprocess;
		LCMessageItem item = GetMessageWithMsgId(userId, msgId);
		if (null != item) {
			statusType = item.statusType;
		}
		return statusType;
	}

	/**
	 * 发送待发消息列表
	 * @param userId
	 */
	private void SendMessageList(String userId)
	{
		Log.i("LiveChatManager", "SendMessageList userId: " + userId);
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		synchronized (userItem.sendMsgList)
		{
			userItem.tryingSend = false;
			for (LCMessageItem item : userItem.sendMsgList) {
				// 发送消息item, 修改普通文本消息不需要做功能支持检测，默认支持文本
				if((item.msgType == MessageType.Text) || mLCFunctionCheckManager.localCheckFunctionSupport(item)){
					SendMessageItem(item);
				}else{
					onFunctionNotSupportedError(item);
				}
			}
			userItem.sendMsgList.clear();
		}
	}

	/**
	 * 返回待发送消息错误
	 * @param errType
	 */
	private void SendMessageListFail(final String userId, final LiveChatErrType errType)
	{
		Log.i("LiveChatManager", "SendMessageListFail userId: " + userId + " errType:" + errType.ordinal());
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null != userItem) {
			synchronized (userItem.sendMsgList)
			{
				userItem.tryingSend = false;
				for (LCMessageItem item : userItem.sendMsgList)
				{
					item.statusType = StatusType.Fail;
					if(mLCFunctionCheckManager.localCheckFunctionSupport(item)){
						SendMessageFailCallback(errType, "", item);
						// 生成警告消息
						if (errType != LiveChatErrType.Success) {
							if (null != item && null != item.getUserItem()) {
								BuildAndInsertWarningWithErrType(item.getUserItem(), errType);
							}
						}
					}else{
						onFunctionNotSupportedError(item);
					}
				}

//				@SuppressWarnings("unchecked")
//				ArrayList<LCMessageItem> cloneMsgList = (ArrayList<LCMessageItem>)userItem.sendMsgList.clone();
				userItem.sendMsgList.clear();

//				mCallbackHandler.OnSendMessageListFail(errType, cloneMsgList);
			}
		}
		else {
			Log.e("livechat", "LiveChatManager::SendMessageListFail() get user item fail");
		}
	}

	/**
	 * 本地拦截，返回发送失败时，回调判断
	 * @param msgItem
	 */
	private void SendMessageFailCallback(LiveChatErrType errType, String errMsg, LCMessageItem msgItem){
		switch (msgItem.msgType) {
		case Text:
			mCallbackHandler.OnSendMessage(errType, errMsg, msgItem);
			break;
		case Emotion:
			mCallbackHandler.OnSendEmotion(errType, errMsg, msgItem);
			break;
		case Photo:
			mCallbackHandler.OnSendPhoto(errType, "", errMsg, msgItem);
			break;
		case Voice:
			mCallbackHandler.OnSendVoice(errType, "", errMsg, msgItem);
			break;
		case MagicIcon:
			mCallbackHandler.OnSendMagicIcon(errType, errMsg, msgItem);
			break;
		default:
			break;
		}
	}

	/**
	 * 功能不支持错误回掉
	 * @param msgItem
	 */
	private void onFunctionNotSupportedError(LCMessageItem msgItem){
		Log.i("LiveChatManager", "onFunctionNotSupportedError userId: " + msgItem.getUserItem().userId );
		msgItem.statusType = StatusType.Fail;
		String message = LiveChatMessageHelper.getNoSupportMessage(mContext, msgItem.msgType);
		SendMessageFailCallback(LiveChatErrType.NotSupportedFunction, message, msgItem);
		BuildAndInsertSystemMsg(msgItem.getUserItem().userId, message);
	}

	/**
	 * 发送消息item
	 * @param item	消息item
	 */
	private void SendMessageItem(LCMessageItem item)
	{
		//禁发功能处理
		if(item != null && item.getUserItem() != null
				&& isSendMessageLimited(item.getUserItem().userId)){
			item.statusType = StatusType.Finish;
			mCallbackHandler.OnSendMessage(LiveChatErrType.Success, "", item);
			return;
		}

		// 发送消息
		switch (item.msgType)
		{
		case Text:
			SendMessageProc(item);
			break;
		case Emotion:
			SendEmotionProc(item);
			break;
		case Photo:
			SendPhotoProc(item);
			break;
		case Voice:
			SendVoiceProc(item);
			break;
		case MagicIcon:
			SendMagicIconProc(item);
			break;
		default:
			Log.e("livechat", "LiveChatManager::SendMessageList() msgType error, msgType:%s", item.msgType.name());
			break;
		}
	}

	// ---------------- 文字聊天操作函数(message) ----------------
	/**
	 * 发送文本聊天消息
	 * @param userId	对方的用户ID
	 * @param message	消息内容
	 * @return
	 */
	public LCMessageItem SendMessage(String userId, String message, InviteStatusType inviteType)
	{
		// 判断是否处理发送操作
		if (!IsHandleSendOpt()) {
			Log.e("livechat", "LiveChatManager::SendMessage() IsHandleSendOpt()==false");
			return null;
		}

		// 获取用户item
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, userId:%s", "LiveChatManager", "SendPhoto", userId));
			return null;
		}

		// 构造消息item
		LCMessageItem item = null;
		if (!message.isEmpty()) {
			// 生成MessageItem
			item = new LCMessageItem();
			item.init(mMsgIdIndex.getAndIncrement()
					, SendType.Send
					, mUserId
					, userId
					, userItem.inviteId
					, StatusType.Processing);
			item.setInviteType(inviteType);

			// 生成TextItem
			LCTextItem textItem = new LCTextItem();
			textItem.init(message, SendType.Send);
			// 把TextItem加到MessageItem
			item.setTextItem(textItem);
			// 添加到历史记录
			userItem.insertSortMsgList(item);

			SendMessagePreprocess(item);

//			if (IsSendMessageNow(userItem))
//			{
//			// 发送消息
//				SendMessageProc(item);
//			}
//			else if (IsWaitForLoginToSendMessage(userItem))
//			{
//				// 登录未成功，添加到待发送列表
//				userItem.addToSendMsgList(item);
//			}
//			else
//			{
//				// 正在使用试聊券，消息添加到待发列表
//				userItem.addToSendMsgList(item);
//				if (IsLogin()) {
//					// 执行尝试使用试聊券流程
//					CheckCouponProc(userItem);
//				}
//			}
		}
		else {
			Log.e("livechat", String.format("%s::%s() param error, userId:%s, message:%s", "LiveChatManager", "SendMessage", userId, message));
		}
		return item;
	}

	/**
	 * 发送文本消息处理
	 * @param item
	 */
	private void SendMessageProc(LCMessageItem item)
	{
		if (LiveChatClient.SendMessage(item.toId, item.getTextItem().message, item.getTextItem().illegal, item.msgId, item.inviteType)) {
			mTextMgr.addSendingItem(item);
		}
		else {
			item.statusType = StatusType.Fail;
			mCallbackHandler.OnSendMessage(LiveChatErrType.Fail, "", item);
		}
	}

	/**
	 * 根据错误类型生成警告消息
	 * @param userItem	用户item
	 * @param errType	服务器返回错误类型
	 */
	private void BuildAndInsertWarningWithErrType(LCUserItem userItem, LiveChatErrType errType)
	{
		if (errType == LiveChatErrType.NoMoney)
		{
//			if(MonthlyFeeManager.getInstance().getMemberType() == MemberType.NO_FEED_FIRST_MONTHLY_MEMBER){
//				//LiveChat 系统没钱消息提示，当用户为第一次月费用户（未购买）时，提示月费逻辑
//				BuildAndInsertNotifyMsg(userItem.userId, NotifyType.Monthly_fee, null);
//			}else{
				// 获取消息内容
				String message = mContext.getString(R.string.livechat_msg_no_credit_warning);
				String linkMsg = mContext.getString(R.string.livechat_msg_no_credit_warning_link);
				// 生成余额不足的警告消息
				BuildAndInsertWarning(userItem, message, linkMsg);
//			}
		}
	}

	/**
	 * 生成警告消息
	 * @param userItem	用户item
	 * @param message	警告消息内容
	 * @param linkMsg	链接内容
	 */
	private void BuildAndInsertWarning(LCUserItem userItem, String message, String linkMsg) {
		if (!message.isEmpty()) {
			// 生成warning消息
			LCWarningItem warningItem = new LCWarningItem();
			if (!linkMsg.isEmpty()) {
				LCWarningLinkItem linkItem = new LCWarningLinkItem();
				linkItem.init(linkMsg, LinkOptType.Rechange);
				warningItem.initWithLinkMsg(message, linkItem);
				warningItem.linkItem = linkItem;
			}
			// 生成message消息
			LCMessageItem item = new LCMessageItem();
			item.init(mMsgIdIndex.getAndIncrement(), SendType.System, userItem.userId, mUserId, userItem.inviteId, StatusType.Finish);
			item.setWarningItem(warningItem);
			// 插入到聊天记录列表中
			userItem.insertSortMsgList(item);
			// 回调
			mCallbackHandler.OnRecvWarning(item);
		}
	}

	/**
	 * 生成通知类消息并回调
	 * @param userId
	 * @param type
	 * @return
	 */
	public boolean BuildAndInsertNotifyMsg(String userId, NotifyType type, Object data)
	{
		boolean result = false;
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null != userItem) {
			// 生成通知类消息并回调
			LCNotifyItem notifyItem = new LCNotifyItem(type, data);
			LCMessageItem item = new LCMessageItem();
			item.init(mMsgIdIndex.getAndIncrement(), SendType.System, userId, mUserId, userItem.inviteId, StatusType.Finish);
			item.setNotifyItem(notifyItem);
			userItem.insertSortMsgList(item);
			mCallbackHandler.OnRecvSystemMsg(item);

			result = true;
		}
		return result;
	}

	/**
	 *
	 * @param userId
	 * @param message
	 * @return
	 */
	public boolean BuildAndInsertSystemMsg(String userId, String message)
	{
		boolean result = false;
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null != userItem) {
			// 生成系统消息并回调
			LCSystemItem systemItem = new LCSystemItem();
			systemItem.message = message;
			LCMessageItem item = new LCMessageItem();
			item.init(mMsgIdIndex.getAndIncrement(), SendType.System, userId, mUserId, userItem.inviteId, StatusType.Finish);
			item.setSystemItem(systemItem);
			userItem.insertSortMsgList(item);
			mCallbackHandler.OnRecvSystemMsg(item);

			result = true;
		}
		return result;
	}

	/**
	 * 构建带链接的临时系统消息，不存入消息列表，仅用于临时展示
	 * @param userId
	 * @param message
	 * @return
	 */
	public boolean BuildTSystemLinkMsg(String userId, String message, String linkMsg, SystemLinkOptType linkOpt, Object data)
	{
		boolean result = false;
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null != userItem) {
			// 生成系统消息并回调
			LCSystemLinkItem systemLinkItem = new LCSystemLinkItem();
			systemLinkItem.init(linkMsg, linkOpt);
			LCSystemItem systemItem = new LCSystemItem();
			systemItem.initWithLinkMsg(message, systemLinkItem, data);
			LCMessageItem item = new LCMessageItem();
			item.init(mMsgIdIndex.getAndIncrement(), SendType.System, userId, mUserId, userItem.inviteId, StatusType.Finish);
			item.setSystemItem(systemItem);
			mCallbackHandler.OnRecvSystemMsg(item);
			result = true;
		}
		return result;
	}

	// ---------------- 高级表情操作函数(Emotion) ----------------
	/**
	 * 获取高级表情配置
	 */
	public synchronized boolean GetEmotionConfig()
	{
//		if (mEmotionMgr.mEmotionConfigReqId != LCRequestJni.InvalidRequestId) {
//			return true;
//		}
//
//		mEmotionMgr.mEmotionConfigReqId = LCRequestJniOther.EmotionConfig(new OnLCOtherEmotionConfigCallback() {
//
//			@Override
//			public void OnOtherEmotionConfig(boolean isSuccess, String errno,
//					String errmsg, OtherEmotionConfigItem item) {
//				// TODO Auto-generated method stub
//				Log.d("LiveChatManager", "GetEmotionConfig() OnOtherEmotionConfig begin");
//				boolean success = isSuccess;
//				OtherEmotionConfigItem configItem = item;
//				if (isSuccess) {
//					// 请求成功
//					if (mEmotionMgr.IsVerNewThenConfigItem(item.version)) {
//						// 配置版本更新
//						success = mEmotionMgr.UpdateConfigItem(item);
//					}
//					else {
//						// 使用旧配置
//						configItem = mEmotionMgr.GetConfigItem();
//					}
//				}
//				Log.d("LiveChatManager", "GetEmotionConfig() OnOtherEmotionConfig callback");
//				mCallbackHandler.OnGetEmotionConfig(success, errno, errmsg, configItem);
//				mEmotionMgr.mEmotionConfigReqId = LCRequestJni.InvalidRequestId;
//				Log.d("LiveChatManager", "GetEmotionConfig() OnOtherEmotionConfig end");
//			}
//		});
//		return mEmotionMgr.mEmotionConfigReqId != LCRequestJni.InvalidRequestId;
        return true;
	}

	/**
	 * 获取配置item（PS：本次获取可能是旧的，当收到OnGetEmotionConfig()回调时，需要重新调用本函数获取）
	 * @return
	 */
	public OtherEmotionConfigItem GetEmotionConfigItem() {
		return mEmotionMgr.GetConfigItem();
	}

	/**
	 * 获取高级表情item
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public LCEmotionItem GetEmotionInfo(String emotionId)
	{
		return mEmotionMgr.getEmotion(emotionId);
	}

	/**
	 * 发送高级表情
	 * @param userId	对方的用户ID
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public LCMessageItem SendEmotion(String userId, String emotionId)
	{
		// 判断是否处理发送操作
		if (!IsHandleSendOpt()) {
			Log.e("livechat", "LiveChatManager::SendEmotion() IsHandleSendOpt()==false");
			return null;
		}

		// 获取用户item
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, userId:%s", "LiveChatManager", "SendPhoto", userId));
			return null;
		}

		LCMessageItem item = null;
		if (!emotionId.isEmpty()) {
			// 生成MessageItem
			item = new LCMessageItem();
			item.init(mMsgIdIndex.getAndIncrement()
					, SendType.Send
					, mUserId
					, userId
					, userItem.inviteId
					, StatusType.Processing);
			// 获取EmotionItem
			LCEmotionItem emotionItem = mEmotionMgr.getEmotion(emotionId);
			// 把EmotionItem添加到MessageItem
			item.setEmotionItem(emotionItem);
			// 添加到历史记录
			userItem.insertSortMsgList(item);

			SendMessagePreprocess(item);

//			if (IsSendMessageNow(userItem))
//			{
//				// 发送消息
//				SendEmotionProc(item);
//			}
//			else if (IsWaitForLoginToSendMessage(userItem))
//			{
//				// 登录未成功，添加到待发送列表
//				userItem.addToSendMsgList(item);
//			}
//			else
//			{
//				// 正在使用试聊券，消息添加到待发列表
//				userItem.addToSendMsgList(item);
//				// 执行尝试使用试聊券流程
//				CheckCouponProc(userItem);
//			}
		}
		else {
			Log.e("livechat", String.format("%s::%s() param error, userId:%s, emotionId:%s", "LiveChatManager", "SendEmotion", userId, emotionId));
		}
		return item;
	}

	/**
	 * 发送高级表情处理
	 * @param item
	 */
	private void SendEmotionProc(LCMessageItem item)
	{
		if (LiveChatClient.SendEmotion(item.toId, item.getEmotionItem().emotionId, item.msgId)) {
			mEmotionMgr.addSendingItem(item);
		}
		else {
			item.statusType = StatusType.Fail;
			mCallbackHandler.OnSendEmotion(LiveChatErrType.Fail, "", item);
		}
	}

	/**
	 * 手动下载/更新高级表情图片文件
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public boolean GetEmotionImage(String emotionId)
	{
		LCEmotionItem emotionItem = mEmotionMgr.getEmotion(emotionId);

		boolean result = false;
		// 判断文件是否存在，若不存在则下载
		if (!emotionItem.imagePath.isEmpty()) {
			File file  = new File(emotionItem.imagePath);
			if (file.exists() && file.isFile()) {
				mCallbackHandler.OnGetEmotionImage(true, emotionItem);
				result = true;
			}
		}

		// 文件不存在，需要下载
		if (!result) {
			result = mEmotionMgr.StartDownloadImage(emotionItem);
		}
		return result;
	}

	/**
	 * 手动下载/更新高级表情图片文件
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public boolean GetEmotionPlayImage(String emotionId)
	{
		LCEmotionItem emotionItem = mEmotionMgr.getEmotion(emotionId);

		boolean result = false;
		// 判断文件是否存在，若不存在则下载
		if (!emotionItem.playBigPath.isEmpty()) {
			File file  = new File(emotionItem.playBigPath);
			if (file.exists() && file.isFile()) {
				if (emotionItem.playBigImages.size() > 0) {
					result = true;
					for (String filePath : emotionItem.playBigImages)
					{
						File subFile = new File(filePath);
						if (!subFile.exists() || !subFile.isFile()) {
							result = false;
							break;
						}
					}
				}

				// 所有文件都存在
				if (result) {
					mCallbackHandler.OnGetEmotionPlayImage(true, emotionItem);
				}
			}
		}

		// 有文件不存在，需要下载
		if (!result) {
			result = mEmotionMgr.StartDownloadPlayImage(emotionItem);
		}
		return result;
	}

	/**
	 * 手动下载/更新高级表情播放文件
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public boolean GetEmotion3gp(String emotionId)
	{
		LCEmotionItem emotionItem = mEmotionMgr.getEmotion(emotionId);

		boolean result = false;
		// 判断文件是否存在，若不存在则下载
		if (!emotionItem.f3gpPath.isEmpty()) {
			File file  = new File(emotionItem.f3gpPath);
			if (file.exists() && file.isFile()) {
				mCallbackHandler.OnGetEmotion3gp(true, emotionItem);
				result = true;
			}
		}

		// 文件不存在，下载文件
		if (!result) {
			result = mEmotionMgr.StartDownload3gp(emotionItem);
		}
		return result;
	}

	// ---------------- 图片操作函数(Private Album) ----------------
	/**
	 * 发送图片（包括上传图片文件(php)、发送图片(livechat)）
	 * @param userId	对方的用户ID
	 * @param photoPath	图片本地路径
	 * @return
	 */
	public LCMessageItem SendPhoto(
			final String userId
			, final String photoPath)
	{
		// 判断是否处理发送操作
		if (!IsHandleSendOpt()) {
			Log.e("livechat", "LiveChatManager::SendPhoto() IsHandleSendOpt()==false");
			return null;
		}

		// 获取用户item
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, userId:%s", "LiveChatManager", "SendPhoto", userId));
			return null;
		}

		// 生成MessageItem
		LCMessageItem item = new LCMessageItem();
		item.init(mMsgIdIndex.getAndIncrement()
				, SendType.Send
				, mUserId
				, userId
				, userItem.inviteId
				, StatusType.Processing);
		// 生成PhotoItem
		LCPhotoItem photoItem = new LCPhotoItem();
		photoItem.init(
				mPhotoMgr
				,""
				, ""
				, ""
				, true);
		photoItem.mClearSrcPhotoInfo = new LCPhotoInfoItem(LCPhotoInfoItem.StatusType.Success, "", "", photoPath);
		// 把PhotoItem添加到MessageItem
		item.setPhotoItem(photoItem);
		// 添加到历史记录
		userItem.insertSortMsgList(item);

		SendMessagePreprocess(item);

//		if (IsSendMessageNow(userItem))
//		{
//			// 发送消息
//			SendPhotoProc(item);
//		}
//		else if (IsWaitForLoginToSendMessage(userItem))
//		{
//			// 登录未成功，添加到待发送列表
//			userItem.addToSendMsgList(item);
//		}
//		else
//		{
//			// 正在使用试聊券，消息添加到待发列表
//			userItem.addToSendMsgList(item);
//			// 执行尝试使用试聊券流程
//			CheckCouponProc(userItem);
//		}

		return item;
	}

	/**
	 * 发送图片处理vi
	 * @param msgItem
	 * @return
	 */
	private void SendPhotoProc(final LCMessageItem msgItem)
	{
		if(msgItem.getPhotoItem() != null && !TextUtils.isEmpty(msgItem.getPhotoItem().photoId)){
			//此种情况为上传私密照成功（即扣费成功），但由于断网导致发送失败，重发特殊处理
			sendPhotoInternal(msgItem);
			return;
		}

		LCPhotoMessagePreSendTask task = new LCPhotoMessagePreSendTask();
		task.init(msgItem, mUserId, mSid);
		task.setOnLCPhotoMessagePreSendCallback(new LCPhotoMessagePreSendTask.OnLCPhotoMessagePreSendCallback() {
			@Override
			public void onLCPhotoMessagePreSendCallback(LCPhotoMessagePreSendTask task, boolean isSuccess, String errno, String errmsg, LCSendPhotoItem item, String filePath) {
				//从任务队列删除
				mPhotoMgr.getAndRemovePhotoPreSengdingtMap(task);
				if (isSuccess) {
					LCPhotoItem photoItem = msgItem.getPhotoItem();
					photoItem.photoId = item.photoId;
					photoItem.sendId = item.sendId;

					Log.i(TAG, "onLCPhotoMessagePreSendCallback task: " + task + " photoId: " + item.photoId + " sendId: " + item.sendId + " filePath: " + filePath);

					// 把源文件copy到LiveChat目录下
					mPhotoMgr.copyPhotoFileToDir(photoItem, filePath);

					sendPhotoInternal(msgItem);
				}
				else {
					Log.i(TAG, "onLCPhotoMessagePreSendCallback failed errNo: " + errno);
					// 上传文件不成功
					msgItem.statusType = StatusType.Fail;
					mCallbackHandler.OnSendPhoto(LiveChatErrType.Fail, errno, errmsg, msgItem);
					if(isNoCredits(errno)){
						if (null != msgItem && null != msgItem.getUserItem()) {
							BuildAndInsertWarningWithErrType(msgItem.getUserItem(), LiveChatErrType.NoMoney);
						}
					}
				}
			}
		});
		boolean result = task.start();

		if (result) {
			mPhotoMgr.addToPhotoPreSendingMap(task, msgItem);
		} else {
			msgItem.statusType = StatusType.Fail;
			mCallbackHandler.OnSendPhoto(LiveChatErrType.Fail, "", "", msgItem);
		}
	}

	/**
	 * 上传图片等预处理完成后，发送私密照
	 * @param msgItem
	 */
	private void sendPhotoInternal(LCMessageItem msgItem){
		if (LiveChatClient.SendPhoto(msgItem.toId
				, msgItem.getUserItem().inviteId
				, msgItem.getPhotoItem().photoId
				, msgItem.getPhotoItem().sendId
				, false
				, msgItem.getPhotoItem().photoDesc
				, msgItem.msgId))
		{
			// 添加到发送map
			mPhotoMgr.addSendingItem(msgItem);
		}
		else {
			// LiveChatClient发送不成功
			msgItem.statusType = StatusType.Fail;
			mCallbackHandler.OnSendPhoto(LiveChatErrType.Fail, "", "", msgItem);
		}
	}


	/**
	 * 购买图片（包括付费购买图片(php)）
	 * @param item
	 * @return
	 */
	public boolean PhotoFee(final LCMessageItem item)
	{
		// 判断参数是否有效
		if (item.msgType != MessageType.Photo
			|| item.fromId.isEmpty()
			|| item.inviteId.isEmpty()
			|| item.getPhotoItem().photoId.isEmpty()) //item.statusType != StatusType.Finish
		{
			Log.e("livechat", String.format("%s::%s() param error, msgType:%s, fromId:%s, inviteId%s, photoId:%s, statusType:%s", "LiveChatManager", "PhotoFee"
					, item.msgType.name(), item.fromId, item.inviteId, item.getPhotoItem().photoId, item.statusType.name()));
			return false;
		}

		// 请求付费获取图片
		long requestId = LCRequestJniLiveChat.PhotoFee(
				item.fromId
				, item.inviteId
				, mUserId
				, mSid, item.getPhotoItem().photoId
				, new OnLCPhotoFeeCallback() {
			@Override
			public void OnLCPhotoFee(long requestId, boolean isSuccess, String errno,
					String errmsg) {
				// TODO Auto-generated method stub
				LCPhotoItem photoItem = item.getPhotoItem();
				if (null == item || null == photoItem) {
					Log.e("livechat", String.format("%s::%s() OnLCPhotoFee() get request item fail, requestId:%d", "LiveChatManager", "PhotoFee", requestId));
					return;
				}

//				item.statusType = isSuccess ? StatusType.Finish : StatusType.Fail;
				photoItem.charge = isSuccess;

				if (isSuccess) {
					// 通知LiveChat服务器已经购买图片
					LiveChatClient.ShowPhoto(
						item.getUserItem().userId
						, item.getUserItem().inviteId
						, item.getPhotoItem().photoId
						, item.getPhotoItem().sendId
						, item.getPhotoItem().charge
						, item.getPhotoItem().photoDesc
						, item.msgId);

					// 清除未付费图片
//					mPhotoMgr.removeFuzzyPhotoFile(photoItem);
				}
				mCallbackHandler.OnPhotoFee(isSuccess, errno, errmsg, item);
			}
		});

		boolean result = false;
		if (requestId != LCRequestJni.InvalidRequestId) {
//			item.statusType = StatusType.Processing;
			LCPhotoItem photoItem = item.getPhotoItem();
			if (!result) {
				Log.e("livechat", String.format("%s::%s() requestId:%d addRequestItem fail", "LiveChatManager", "PhotoFee", requestId));
			}
		}
		else {
//			item.statusType = StatusType.Fail;
			mCallbackHandler.OnPhotoFee(false, "request fail", "", item);
		}

		return result;
	}

	/**
	 * 根据消息ID获取图片(模糊或清晰)（包括获取/下载对方私密照片(php)、显示图片(livechat)）
	 * @param msgId		消息ID
	 * @param sizeType	下载的照片尺寸
	 * @return
	 */
	public boolean GetPhoto(String userId, int msgId, final PhotoSizeType sizeType)
	{
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null == userItem) {
			Log.e("livechat", "LiveChatManager::GetPhoto() get user item fail, userId:%s", userId);
			return false;
		}

		LCMessageItem item = userItem.getMsgItemWithId(msgId);
		if (null == item) {
			Log.e("livechat", "LiveChatManager::GetPhoto() get message item fail, msgId:%d", msgId);
			return false;
		}

		return GetPhoto(item, sizeType);
	}

	/**
	 * 获取图片(模糊或清晰)（包括获取/下载对方私密照片(php)、显示图片(livechat)）
	 * @param item		消息item
	 * @param sizeType	下载的照片尺寸
	 * @return
	 */
	private boolean GetPhoto(final LCMessageItem item, final PhotoSizeType sizeType)
	{
		if (item.msgType != MessageType.Photo
			|| item.fromId.isEmpty()
			|| item.getPhotoItem().photoId.isEmpty())
		{
			Log.e("livechat", String.format("%s::%s() param error, msgType:%s, fromId:%s, photoId:%s, statusType:%s", "LiveChatManager", "GetPhoto"
					, item.msgType.name(), item.fromId, item.getPhotoItem().photoId, item.statusType.name()));
			return false;
		}

		// 请求下载图片
		final PhotoModeType modeType;
		ToFlagType toFlagType = LCRequestJniLiveChat.ToFlagType.ManGetWoman;
		if (item.sendType == SendType.Send) {
			// 男士发送（直接获取清晰图片）
			modeType = PhotoModeType.Clear;
			toFlagType = ToFlagType.ManGetSelf;
		}
		else  {
			// 女士发送（判断是否已购买）
			modeType = (item.getPhotoItem().charge ? PhotoModeType.Clear : PhotoModeType.Fuzzy);
			toFlagType = LCRequestJniLiveChat.ToFlagType.ManGetWoman;
		}
		boolean result = mPhotoMgr.getPrivatePhoto(toFlagType
					, item.getUserItem().userId
					, mUserId
					, mSid
					, item.getPhotoItem().photoId
					, sizeType
					, modeType
					, new OnLCGetPhotoCallback() {

						@Override
						public void OnLCGetPhoto(long requestId, boolean isSuccess, String errno,
												 String errmsg, String filePath) {
							// TODO Auto-generated method stub
							LCPhotoInfoItem.StatusType statusType = LCPhotoInfoItem.StatusType.Default;
							if (isSuccess) {
								statusType = LCPhotoInfoItem.StatusType.Success;
							} else {
								// 获取图片失败
								statusType = LCPhotoInfoItem.StatusType.Failed;
							}
							item.getPhotoItem().setPhotInfoItem(modeType, sizeType, statusType, errno, errmsg, filePath);
							mCallbackHandler.OnGetPhoto(isSuccess, errno, errmsg, item);
						}
					});
		if(result){
			item.getPhotoItem().setPhotInfoItem(modeType, sizeType, LCPhotoInfoItem.StatusType.Downloading, "", "", "");
		}
		return result;
	}

	// ---------------- 语音操作函数(Voice) ----------------
	/**
	 * 发送语音（包括获取语音验证码(livechat)、上传语音文件(livechat)、发送语音(livechat)）
	 * @param userId	对方的用户ID
	 * @param voicePath	语音文件本地路径
	 * @return
	 */
	public LCMessageItem SendVoice(String userId, String voicePath, String fileType, int timeLength)
	{
		// 判断是否处理发送操作
		if (!IsHandleSendOpt()) {
			Log.e("livechat", "LiveChatManager::SendVoice() IsHandleSendOpt()==false");
			return null;
		}

		// 获取用户item
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, userId:%s", "LiveChatManager", "SendVoice", userId));
			return null;
		}

		// 生成MessageItem
		LCMessageItem item = new LCMessageItem();
		item.init(mMsgIdIndex.getAndIncrement()
				, SendType.Send
				, mUserId
				, userId
				, userItem.inviteId
				, StatusType.Processing);
		// 生成VoiceItem
		LCVoiceItem voiceItem = new LCVoiceItem();
		voiceItem.init(""
				, voicePath
				, timeLength
				, fileType
				, ""
				, true);
		// 把VoiceItem添加到MessageItem
		item.setVoiceItem(voiceItem);
		// 添加到聊天记录中
		userItem.insertSortMsgList(item);

		if(!LoginManager.getInstance().isLivechatSendVoicePermit()){
			item.statusType = StatusType.Fail;
			//不赋值界面会异常
			item.setLiveChatErrType(LiveChatErrType.ConnectFail);
		}else{
			SendMessagePreprocess(item);
		}
//		if (IsSendMessageNow(userItem))
//		{
//			// 发送消息
//			SendVoiceProc(item);
//		}
//		else if (IsWaitForLoginToSendMessage(userItem))
//		{
//			// 登录未成功，添加到待发送列表
//			userItem.addToSendMsgList(item);
//		}
//		else
//		{
//			// 正在使用试聊券，消息添加到待发列表
//			userItem.addToSendMsgList(item);
//			// 执行尝试使用试聊券流程
//			CheckCouponProc(userItem);
//		}
		return item;
	}

	/**
	 * 发送语音处理
	 * @param item
	 */
	private void SendVoiceProc(LCMessageItem item)
	{
		if (LiveChatClient.GetVoiceCode(item.toId, item.msgId))
		{
			mVoiceMgr.addSendingItem(item.msgId, item);
		}
		else {
			item.statusType = StatusType.Fail;
			mCallbackHandler.OnSendVoice(LiveChatErrType.Fail, "", "", item);
		}
	}

	/**
	 * 获取语音（包括下载语音(livechat)）
	 * @param item		消息ID
	 * @return
	 */
	public boolean GetVoice(LCMessageItem item)
	{
		if (item.msgType != MessageType.Voice
			&& null == item.getVoiceItem())
		{
			Log.e("livechat", String.format("%s::%s() param error.", "LiveChatManager", "GetVoice"));
			return false;
		}

		boolean result = false;
		LCVoiceItem voiceItem = item.getVoiceItem();
		voiceItem.filePath = mVoiceMgr.getVoicePath(item);
		int siteType = WebSiteConfigManager.getInstance().getCurrentWebSite().getSiteId();
		long requestId = LCRequestJniLiveChat.PlayVoice(voiceItem.voiceId, siteType, voiceItem.filePath, new OnLCPlayVoiceCallback() {

			@Override
			public void OnLCPlayVoice(long requestId, boolean isSuccess, String errno,
					String errmsg, String filePath) {
				// TODO Auto-generated method stub
				LCMessageItem item = mVoiceMgr.getAndRemoveRquestItem(requestId);
				if (null != item) {
//					item.statusType = isSuccess ? StatusType.Finish : StatusType.Fail;
					LiveChatErrType errType = isSuccess ? LiveChatErrType.Success : LiveChatErrType.Fail;
					mCallbackHandler.OnGetVoice(errType, errmsg, item);
				}
				else {
					Log.e("livechat", String.format("%s::%s() item is null, requestId:%d, isSuccess:%b, errno:%s, errmsg:%s, filePath:%s"
							, "LiveChatManager", "OnLCPlayVoice", requestId, isSuccess, errno, errmsg, filePath));
				}
			}
		});

		if (requestId != LCRequestJni.InvalidRequestId) {
			// 添加至请求map
//			item.statusType = StatusType.Processing;
			mVoiceMgr.addRequestItem(requestId, item);
			result = true;

			Log.e("livechat", String.format("%s::%s() requestId:%d", "LiveChatManager", "OnLCPlayVoice", requestId));
		}
		else {
			Log.d("livechat", String.format("%s::%s() RequestOperator.getInstance().PlayVoice fail, voiceId:%s, siteType:%d, filePath:%s"
					, "LiveChatManager"
					, "GetVoice"
					, voiceItem.voiceId, siteType, voiceItem.filePath));
//			item.statusType = StatusType.Fail;
			mCallbackHandler.OnGetVoice(LiveChatErrType.Fail, "", item);
			result = false;
		}
		return result;
	}

	/**
	 * 获取语音发送/下载进度
	 * @param item	消息item
	 * @return
	 */
	public int GetVoiceProcessRate(LCMessageItem item) {
		int percent = 0;
		long requestId = mVoiceMgr.getRequestIdWithItem(item);
		if (requestId != LCRequestJni.InvalidRequestId) {
			int total = LCRequestJni.GetDownloadContentLength(requestId);
			int recv = LCRequestJni.GetRecvLength(requestId);

			if (total > 0) {
				recv = recv * 100;
				percent = recv / total;
			}
		}
		return percent;
	}

	// ---------------- 小高表相关操作（Magic Icon） ----------------

	/**
	 * 获取小高级表情配置
	 */
	public synchronized boolean GetMagicIconConfig(){
		if (mMagicIconMgr.mGetMagicIconConfigReqId != LCRequestJni.InvalidRequestId) {
			return true;
		}

		mMagicIconMgr.mGetMagicIconConfigReqId = LCRequestJniLiveChat.GetMagicIconConfig(new OnLCGetMagicIconConfigCallback() {

			@Override
			public void OnLCGetMagicIconConfig(boolean isSuccess, String errno,
					String errmsg, MagicIconConfig config) {
				Log.d("LiveChatManager", "GetMagicIconConfig() OnGetMagicIconConfig begin isSuccess: " + isSuccess);
				boolean success = isSuccess;
				MagicIconConfig configItem = config;
				if (isSuccess) {
					// 请求成功
					if (mMagicIconMgr.IsVerNewTheConfigItem(config.maxupdatetime)) {
						// 配置版本更新
						success = mMagicIconMgr.UpdateConfigItem(config);
					}
					else {
						// 使用旧配置
						configItem = mMagicIconMgr.GetConfigItem();
					}
				}
				Log.d("LiveChatManager", "GetMagicIconConfig() OnGetMagicIconConfig callback");
				mCallbackHandler.OnGetMagicIconConfig(success, errno, errmsg, configItem);
				mMagicIconMgr.mGetMagicIconConfigReqId = LCRequestJni.InvalidRequestId;
				Log.d("LiveChatManager", "GetMagicIconConfig() OnGetMagicIconConfig end");
			}
		});
		return mMagicIconMgr.mGetMagicIconConfigReqId != LCRequestJni.InvalidRequestId;
	}

	/**
	 * 获取配置item（PS：本次获取可能是旧的，当收到OnGetMagicIconConfig()回调时，需要重新调用本函数获取）
	 * @return
	 */
	public MagicIconConfig GetMagicIconConfigItem() {
		return mMagicIconMgr.GetConfigItem();
	}

	/**
	 * 获取小高级表情item
	 * @param magicIconId	小高级表情ID
	 * @return
	 */
	public LCMagicIconItem GetMagicIconInfo(String magicIconId)
	{
		return mMagicIconMgr.getMagicIcon(magicIconId);
	}

	/**
	 * 发送小高级表情
	 * @param userId	对方的用户ID
	 * @param magicIconId	小高级表情ID
	 * @return
	 */
	public LCMessageItem SendMagicIcon(String userId, String magicIconId)
	{
		// 判断是否处理发送操作
		if (!IsHandleSendOpt()) {
			Log.e("livechat", "LiveChatManager::SendMagicIcon() IsHandleSendOpt()==false");
			return null;
		}

		// 获取用户item
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, userId:%s", "LiveChatManager", "SendMagicIcon", userId));
			return null;
		}

		LCMessageItem item = null;
		if (!magicIconId.isEmpty()) {
			// 生成MessageItem
			item = new LCMessageItem();
			item.init(mMsgIdIndex.getAndIncrement()
					, SendType.Send
					, mUserId
					, userId
					, userItem.inviteId
					, StatusType.Processing);
			// 获取EmotionItem
			LCMagicIconItem magicIconItem = mMagicIconMgr.getMagicIcon(magicIconId);
			// 把EmotionItem添加到MessageItem
			item.setMagicIconItem(magicIconItem);
			// 添加到历史记录
			userItem.insertSortMsgList(item);

			SendMessagePreprocess(item);

//			if (IsSendMessageNow(userItem))
//			{
//				// 发送消息
//				SendEmotionProc(item);
//			}
//			else if (IsWaitForLoginToSendMessage(userItem))
//			{
//				// 登录未成功，添加到待发送列表
//				userItem.addToSendMsgList(item);
//			}
//			else
//			{
//				// 正在使用试聊券，消息添加到待发列表
//				userItem.addToSendMsgList(item);
//				// 执行尝试使用试聊券流程
//				CheckCouponProc(userItem);
//			}
		}
		else {
			Log.e("livechat", String.format("%s::%s() param error, userId:%s, magicIconId:%s", "LiveChatManager", "SendMagicIcon", userId, magicIconId));
		}
		return item;
	}

	/**
	 * 发送高级表情处理
	 * @param item
	 */
	private void SendMagicIconProc(LCMessageItem item)
	{
		if (LiveChatClient.SendMagicIcon(item.toId, item.getMagicIconItem().getMagicIconId(), item.msgId)) {
			mMagicIconMgr.addSendingItem(item);
		}
		else {
			item.statusType = StatusType.Fail;
			mCallbackHandler.OnSendMagicIcon(LiveChatErrType.Fail, "", item);
		}
	}

	/**
	 * 手动下载/更新小高级表情图片文件
	 * @param magicIconId	小高级表情ID
	 * @return
	 */
	public boolean GetMagicIconSrcImage(String magicIconId) {
		LCMagicIconItem magicIconItem = mMagicIconMgr.getMagicIcon(magicIconId);

		boolean result = false;
		// 判断文件是否存在，若不存在则下载
		if (!magicIconItem.getSourcePath().isEmpty()) {
			File file  = new File(magicIconItem.getSourcePath());
			if (file.exists() && file.isFile()) {
				mCallbackHandler.OnGetMagicIconSrcImage(true, magicIconItem);
				result = true;
			}
		}

		// 文件不存在，需要下载
		if (!result) {
			result = mMagicIconMgr.StartDownloadImage(magicIconItem);
		}
		return result;
	}

	/**
	 * 手动下载/更新小高级表情拇子图文件
	 * @param magicIconId	小高级表情ID
	 * @return
	 */
	public boolean GetMagicIconThumbImage(String magicIconId) {

		LCMagicIconItem magicIconItem = mMagicIconMgr.getMagicIcon(magicIconId);

		boolean result = false;
		// 判断文件是否存在，若不存在则下载
		if (!magicIconItem.getThumbPath().isEmpty()) {
			File file  = new File(magicIconItem.getThumbPath());
			if (file.exists() && file.isFile()) {
				mCallbackHandler.OnGetMagicIconThumbImage(true, magicIconItem);
				result = true;
			}
		}

		// 文件不存在，需要下载
		if (!result) {
			result = mMagicIconMgr.StartDownloadThumbImage(magicIconItem);
		}
		return result;
	}


	// ---------------- 视频操作函数(Video) ----------------
	/**
	 * 获取微视频图片
	 * @param item	消息item
	 * @param type	视频图片类型
	 * @return
	 */
	public boolean GetVideoPhoto(final LCMessageItem item, final VideoPhotoType type)
	{
		boolean result = false;
		LCUserItem userItem = item.getUserItem();
		LCVideoItem videoItem = item.getVideoItem();
		if (null != userItem
			&& !TextUtils.isEmpty(userItem.userId)
			&& !TextUtils.isEmpty(item.inviteId)
			&& null != videoItem
			&& !TextUtils.isEmpty(videoItem.videoId))
		{
			result = GetVideoPhoto(userItem.userId, videoItem.videoId, userItem.inviteId, type);
		}
		return result;
	}

	/**
	 * 获取微视频图片
	 * @param userId	女士ID
	 * @param videoItem	视频列表item
	 * @param type		视频图片类型
	 * @return
	 */
	public boolean GetVideoPhoto(final String userId, final com.qpidnetwork.livemodule.livechathttprequest.item.LCVideoItem videoItem, final VideoPhotoType type)
	{
		boolean result = false;
		if (!TextUtils.isEmpty(userId)
			&& null != videoItem
			&& !TextUtils.isEmpty(videoItem.videoid)
			&& !TextUtils.isEmpty(videoItem.inviteid))
		{
			result = GetVideoPhoto(userId, videoItem.videoid, videoItem.inviteid, type);
		}
		return result;
	}

	/**
	 * 获取微视频图片
	 * @param userId	用户ID
	 * @param videoId	视频ID
	 * @param inviteId	邀请ID
	 * @param type		视频图片类型
	 * @return
	 */
	private boolean GetVideoPhoto(final String userId, final String videoId, final String inviteId, final VideoPhotoType type)
	{
		boolean result = false;

		// 判断是否已经在下载
		if (mVideoMgr.isVideoPhotoRequest(videoId)) {
			result = true;
		}
		else {
			// 还没请求下载，现在下载
			String filePath = mVideoMgr.getVideoPhotoTempPath(userId, videoId, inviteId, type);
			long requestId = LCRequestJniLiveChat.GetVideoPhoto(mSid, mUserId, userId, videoId, type, filePath, new OnLCRequestFileCallback() {

				@Override
				public void OnLCRequestFile(long requestId, boolean isSuccess, String errno,
						String errmsg, String filePath)
				{
					boolean result = false;
					ArrayList<LCMessageItem> videoMsgList = null;
					String desPath = "";

					// 下载成功
					if (isSuccess) {
						// 把临时文件复制到正式文件目录
						desPath = mVideoMgr.getVideoPhotoPath(userId, videoId, inviteId, type);
						result = mVideoMgr.tempFileToDesFile(filePath, desPath);
					}

					// 更新视频消息
					LCUserItem userItem = mUserMgr.getUserItem(userId);
					if (null != userItem) {
						videoMsgList = mVideoMgr.getMessageItem(videoId, userItem.getMsgList());
						for (LCMessageItem item : videoMsgList) {
							// 更新视频图片路径
							if (result) {
								item.getVideoItem().updatePhotoPathWithType(desPath, type);
							}
							// 重置下载标志
							item.getVideoItem().updatePhotoDownloadSign(type, false);
						}
					}

					// 从正在下载列表中移除
					mVideoMgr.getAndRemoveRequestVideoPhoto(requestId);

					// callback
					LiveChatErrType errType = result ? LiveChatErrType.Success : LiveChatErrType.Fail;
					mCallbackHandler.OnGetVideoPhoto(errType
													, errno
													, errmsg
													, userId
													, inviteId
													, videoId
													, type
													, desPath
													, videoMsgList);
				}
			});

			// 添加到requestId对照表
			if (requestId != LCRequestJni.InvalidRequestId)
			{
				result = true;

				// 设置视频相关的所有聊天消息下载标志位为true
				LCUserItem userItem = mUserMgr.getUserItem(userId);
				if (null != userItem) {
					ArrayList<LCMessageItem> videoMsgList = mVideoMgr.getMessageItem(videoId, userItem.getMsgList());
					for (LCMessageItem item : videoMsgList) {
						item.getVideoItem().updatePhotoDownloadSign(type, true);
					}
				}

				// 添加到对照表
				mVideoMgr.addRequestVideoPhoto(requestId, videoId);
			}
		}

		return result;
	}

	/**
	 * 购买微视频
	 * @param item	消息item
	 * @return
	 */
	public boolean VideoFee(final LCMessageItem item)
	{
		boolean result = false;
		if (null != item
			&& null != item.getUserItem()
			&& item.msgType == MessageType.Video
			&& null != item.getVideoItem())
		{
			final LCUserItem userItem = item.getUserItem();
			final LCVideoItem videoItem = item.getVideoItem();

			if (videoItem.isVideoFeeding) {
				// 已在下载
				result = true;
			}
			else {
				long requestId = LCRequestJniLiveChat.GetVideo(
										mSid
										, mUserId
										, userItem.userId
										, videoItem.videoId
										, item.inviteId
										, VideoToFlagType.Man
										, videoItem.sendId
										, new OnLCGetVideoCallback() {

					@Override
					public void OnLCGetVideo(long requestId, boolean isSuccess, String errno,
							String errmsg, String url) {
						// TODO Auto-generated method stub
						videoItem.isVideoFeeding = false;
						if (isSuccess) {
							// 通知LiveChat服务器已经购买视频
							if(!videoItem.charget) {
								LiveChatClient.PlayVideo(
										userItem.userId
										, item.inviteId
										, videoItem.videoId
										, videoItem.sendId
										, videoItem.charget
										, videoItem.videoDesc
										, item.msgId);
							}
							videoItem.charget = true;
							videoItem.videoUrl = url;
						}

						// callback
						if(isNoCredits(errno)){
							//no money failed
							BuildAndInsertWarningWithErrType(userItem, LiveChatErrType.NoMoney);
						}
						mCallbackHandler.OnVideoFee(isSuccess, errno, errmsg, item);
					}
				});

				if (LCRequestJni.InvalidRequestId != requestId)
				{
					videoItem.isVideoFeeding = true;
					result = true;
				}
			}
		}
		return result;
	}

	/**
	 * 获取微视频播放文件
	 * @param item	消息item
	 * @return
	 */
	public boolean GetVideo(LCMessageItem item)
	{
		boolean result = false;
		LCUserItem userItem = item.getUserItem();
		LCVideoItem videoItem = item.getVideoItem();
		if (null != userItem
			&& !TextUtils.isEmpty(userItem.userId)
			&& !TextUtils.isEmpty(item.inviteId)
			&& null != videoItem
			&& !TextUtils.isEmpty(videoItem.videoId)
			&& videoItem.charget
			&& !TextUtils.isEmpty(videoItem.videoUrl))
		{
			result = GetVideo(userItem.userId, videoItem.videoId, userItem.inviteId, videoItem.videoUrl);
		}
		return result;
	}

	/**
	 * 获取微视频播放文件
	 * @param userId	用户ID
	 * @param videoItem	视频列表item
	 * @return
	 */
	public boolean GetVideo(final String userId, final com.qpidnetwork.livemodule.livechathttprequest.item.LCVideoItem videoItem)
	{
		boolean result = false;
		if (!TextUtils.isEmpty(userId)
			&& null != videoItem
			&& !TextUtils.isEmpty(videoItem.videoid)
			&& !TextUtils.isEmpty(videoItem.inviteid)
			&& !TextUtils.isEmpty(videoItem.video_url))
		{
			result = GetVideo(userId, videoItem.videoid, videoItem.inviteid, videoItem.video_url);
		}
		return result;
	}

	/**
	 * 获取微视频播放文件
	 * @param userId	用户ID
	 * @param videoId	视频ID
	 * @param inviteId	邀请ID
	 * @param videoUrl	视频文件下载URL
	 * @return
	 */
	private boolean GetVideo(final String userId, final String videoId, final String inviteId, final String videoUrl)
	{
		boolean result = false;

		Log.logD(TAG, "GetVideo userId: " + userId + " videoId: " + videoId + " videoId: " + videoId + " videoUrl: " + videoUrl);
		// 判断是否已在下载
		if (mVideoMgr.isVideoDownload(videoId)) {
			result = true;
		}
		else {
			// 还没请求下载，现在下载
			final String tempPath = mVideoMgr.getVideoTempPath(userId, videoId, inviteId);
			Log.logD(TAG,"GetVideo StartDownload url: " + videoUrl);
			LiveChatFileDownloader fileDownloader = new LiveChatFileDownloader(mContext);
			fileDownloader.StartDownload(videoUrl, tempPath, new LiveChatFileDownloader.LiveChatFileDownloaderCallback() {

				@Override
				public void onUpdate(LiveChatFileDownloader loader, int progress) {
					// TODO Auto-generated method stub
					// 获取所有与该视频相关的所有聊天消息
					Log.logD(TAG,"GetVideo onUpdate videoId: " + videoId);
					LCUserItem userItem = mUserMgr.getUserItem(userId);
					if (null != userItem) {
						ArrayList<LCMessageItem> videoMsgList = mVideoMgr.getMessageItem(videoId, userItem.getMsgList());
						for (LCMessageItem item : videoMsgList) {
							// 更新视频下载进度
							item.getVideoItem().videoDownloadProgress = progress;
						}
					}
				}

				@Override
				public void onSuccess(LiveChatFileDownloader loader) {
					// TODO Auto-generated method stub
					boolean result = false;
					// 把临时文件复制到正式文件目录
					String videoPath = mVideoMgr.getVideoPath(userId, videoId, inviteId);
					result = mVideoMgr.tempFileToDesFile(tempPath, videoPath);
					Log.logD(TAG,"GetVideo onSuccess videoId: " + videoId);
					ArrayList<LCMessageItem> videoMsgList = null;
					if (result) {
						// 获取所有与该视频相关的所有聊天消息
						LCUserItem userItem = mUserMgr.getUserItem(userId);
						if (null != userItem) {
							videoMsgList = mVideoMgr.getMessageItem(videoId, userItem.getMsgList());
							for (LCMessageItem item : videoMsgList) {
								// 更新视频消息的图片路径
								item.getVideoItem().videoFilePath = videoPath;
								// 重置下载标志位
								item.getVideoItem().isVideoDownloading = false;
								item.getVideoItem().videoDownloadProgress = 0;
							}
						}
					}

					// 移除下载对照表
					mVideoMgr.getAndRemoveDownloadVideo(loader);

					// callback
					LiveChatErrType errType = result ? LiveChatErrType.Success : LiveChatErrType.Fail;
					mCallbackHandler.OnGetVideo(errType
												, userId
												, videoId
												, inviteId
												, videoPath
												, videoMsgList);
				}

				@Override
				public void onFail(LiveChatFileDownloader loader) {
					// TODO Auto-generated method stub
					ArrayList<LCMessageItem> videoMsgList = null;
					// 获取所有与该视频相关的聊天消息
					Log.logD(TAG,"GetVideo onFail videoId: " + videoId);
					LCUserItem userItem = mUserMgr.getUserItem(userId);
					if (null != userItem) {
						videoMsgList = mVideoMgr.getMessageItem(videoId, userItem.getMsgList());
						for (LCMessageItem item : videoMsgList) {
							// 重置下载标志位
							item.getVideoItem().isVideoDownloading = false;
							item.getVideoItem().videoDownloadProgress = 0;
						}
					}

					// 移除下载对照表
					mVideoMgr.getAndRemoveDownloadVideo(loader);

					// callback
					mCallbackHandler.OnGetVideo(LiveChatErrType.Fail
												, userId
												, videoId
												, inviteId
												, ""
												, videoMsgList);
				}
			});

			result = true;

			ArrayList<LCMessageItem> videoMsgList = null;
			// 设置视频相关的所有聊天消息下载标志位为true
			LCUserItem userItem = mUserMgr.getUserItem(userId);
			if (null != userItem) {
				videoMsgList = mVideoMgr.getMessageItem(videoId, userItem.getMsgList());
				for (LCMessageItem item : videoMsgList) {
					item.getVideoItem().isVideoDownloading = true;
					item.getVideoItem().videoDownloadProgress = 0;
				}
			}

			// 添加到下载对照表
			mVideoMgr.addDownloadVideo(fileDownloader, videoId);

			if (null != videoMsgList) {
				// 通知回调开始下载视频
				mCallbackHandler.OnStartGetVideo(userId
											, videoId
											, inviteId
											, ""
											, videoMsgList);
			}
		}

		return result;
	}

	/**
	 * 获取视频下载状态
	 * @param videoId	视频ID
	 * @return true为正在下载，否则为不在下载状态
	 */
	public boolean isGetVideoNow(final String videoId)
	{
		return mVideoMgr.isVideoDownload(videoId);
	}

	/**
	 * 获取视频图片文件路径，若文件已存在
	 * @param userId	用户ID
	 * @param videoId	视频ID
	 * @param inviteId	邀请ID
	 * @param type		图片类型
	 * @return
	 */
	public String GetVideoPhotoPathWithExist(final String userId, final String inviteId, final String videoId, final VideoPhotoType type)
	{
		String path = "";
		String localPath = mVideoMgr.getVideoPhotoPath(userId, videoId, inviteId, type);
		if (!localPath.isEmpty())
		{
			File file = new File(localPath);
			if (file.exists())
			{
				path = localPath;
			}
		}
		return path;
	}

	/**
	 * 获取视频文件路径，若文件已存在
	 * @param userId	用户ID
	 * @param inviteId	邀请ID
	 * @param videoId	视频ID
	 * @return
	 */
	public String GetVideoPathWithExist(final String userId, final String inviteId, final String videoId)
	{
		String path = "";
		String localPath = mVideoMgr.getVideoPath(userId, videoId, inviteId);
		if (!localPath.isEmpty())
		{
			File file = new File(localPath);
			if (file.exists())
			{
				path = localPath;
			}
		}
		return path;
	}

	// ------------- LiveChatClientListener abstract function -------------
	/**
	 * 登录回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	@Override
	public void OnLogin(LiveChatErrType errType, String errmsg)
	{
		Log.d("livechat", String.format("OnLogin() begin errType:%s", errType.name()));
		boolean isAutoLogin = false;
		if (errType == LiveChatErrType.Success) {
			mIsLogin = true;

			// 上传自动充值标志到服务器
			Message msgUploadAutoCharge = Message.obtain();
			msgUploadAutoCharge.what = LiveChatRequestOptType.UploadAutoChargeFlags.ordinal();
			mHandler.sendMessage(msgUploadAutoCharge);

			// 上传客户端内部版本号
			Message msgUploadVer = Message.obtain();
			msgUploadVer.what = LiveChatRequestOptType.UploadClientVersion.ordinal();
			mHandler.sendMessage(msgUploadVer);

			// 上传主题版本号
			Message msgUploadThemeVer = Message.obtain();
			msgUploadThemeVer.what = LiveChatRequestOptType.UploadThemeVersion.ordinal();
			mHandler.sendMessage(msgUploadThemeVer);

			//获取本人用户信息
			Message msgSelfInfo = Message.obtain();
			msgSelfInfo.what = LiveChatRequestOptType.GetSelfUserInfo.ordinal();
			mHandler.sendMessage(msgSelfInfo);

			// 获取黑名单列表
			Message msgBlockList = Message.obtain();
			msgBlockList.what = LiveChatRequestOptType.GetBlockList.ordinal();
			mHandler.sendMessage(msgBlockList);

			// 获取被屏蔽女士列表
			Message msgBlockUsers = Message.obtain();
			msgBlockUsers.what = LiveChatRequestOptType.GetBlockUsers.ordinal();
			mHandler.sendMessage(msgBlockUsers);

			// 获取联系人列表
			Message msgContactList = Message.obtain();
			msgContactList.what = LiveChatRequestOptType.GetContactList.ordinal();
			mHandler.sendMessage(msgContactList);

			// 获取在聊/邀请用户列表
			Message msgGetTalkList = Message.obtain();
			msgGetTalkList.what = LiveChatRequestOptType.GetTalkList.ordinal();
			mHandler.sendMessage(msgGetTalkList);

			// 获取高级表情配置
			Message msgGetEmotionConfig = Message.obtain();
			msgGetEmotionConfig.what = LiveChatRequestOptType.GetEmotionConfig.ordinal();
			mHandler.sendMessage(msgGetEmotionConfig);

			// 获取小高级表情配置
			Message msgGetMagicIconConfig = Message.obtain();
			msgGetMagicIconConfig.what = LiveChatRequestOptType.GetMagicIconConfig.ordinal();
			mHandler.sendMessage(msgGetMagicIconConfig);

			// 获取所有已购买主题列表
			Message msgGetPaidThemes = Message.obtain();
			msgGetPaidThemes.what = LiveChatRequestOptType.GetAllPaidThemes.ordinal();
			mHandler.sendMessage(msgGetPaidThemes);

			// 使用试聊券，发送待发消息
			Message msg = Message.obtain();
			msg.what = LiveChatRequestOptType.CheckCouponWithToSendUser.ordinal();
			mHandler.sendMessage(msg);

			//启动定时刷新会话中的用户（再聊/暂停）会话状态
			startChatStatusUpdate();

			//重置重连次数
			mLivechatLoginExceptionCount = 0;

		}
		else if (IsAutoRelogin(errType)) {
			Log.d("livechat", "OnLogin() AutoRelogin() begin");
			// 自动重登录
			isAutoLogin = true;
			Message msgAutoRelogin = Message.obtain();
			msgAutoRelogin.what = LiveChatRequestOptType.AutoRelogin.ordinal();
			mHandler.sendMessageDelayed(msgAutoRelogin, mAutoReloginTime);
			Log.d("livechat", "OnLogin() AutoRelogin() end");
		}
		else if((errType == LiveChatErrType.NoSession || errType == LiveChatErrType.InvalidPassword) && !isAutoLogin){
			if(mLivechatLoginExceptionCount < 1){
				//app走全部重登录逻辑
				Message msg = Message.obtain();
				msg.what = LiveChatRequestOptType.AppReloginEvent.ordinal();
				mHandler.sendMessage(msg);
			}else{
				//连续两次异常，当服务器主动踢
				Message msg = Message.obtain();
				msg.what = LiveChatRequestOptType.LiveChatKickOffEvent.ordinal();
				mHandler.sendMessage(msg);
			}
			mLivechatLoginExceptionCount++;
		}

		Log.d("livechat", "OnLogin() callback");
		mCallbackHandler.OnLogin(errType, errmsg, isAutoLogin);
		Log.d("livechat", "OnLogin() end");
	}

	/**
	 * 注销/断线回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	@Override
	public void OnLogout(LiveChatErrType errType, String errmsg)
	{
		Log.d("livechat", "OnLogout() begin, errType:%s", errType.name());

		// 重置参数
		mIsLogin = false;
		//停止自动更新会话中用户会话状态更新逻辑
		stopChatStatusUpdate();

		// callback
		boolean isAutoLogin = IsAutoRelogin(errType);
		Log.d("livechat", "OnLogout(boolean bActive) callback OnLogout");
		mCallbackHandler.OnLogout(errType, errmsg, isAutoLogin);
		if (isAutoLogin) {
			// 自动重登录
			Log.d("livechat", "OnLogout(boolean bActive) AutoRelogin");
			Message msgAutoRelogin = Message.obtain();
			msgAutoRelogin.what = LiveChatRequestOptType.AutoRelogin.ordinal();
			mHandler.sendMessageDelayed(msgAutoRelogin, mAutoReloginTime);
		}
		else {
			// 重置参数
			ResetParam();
			//清空待发送列表及状态
			AutoChargeManager.getInstatnce().onDestroy();
		}

		Log.d("livechat", "OnLogout(boolean bActive) end");
	}

	/**
	 * 设置在线状态回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	@Override
	public void OnSetStatus(LiveChatErrType errType, String errmsg)
	{
		mCallbackHandler.OnSetStatus(errType, errmsg);
	}

	/**
	 * 结束聊天会话回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 */
	@Override
	public void OnEndTalk(LiveChatErrType errType, String errmsg, String userId)
	{
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		//抛出本地网络异常，其他成功或错误都当成endchat成功处理，即需清除本地状态
		if (errType != LiveChatErrType.ConnectFail) {
			if (null != userItem) {
				userItem.endTalk();
			}
			else {
				Log.e("livechat", String.format("%s::%s() getUserItem is null, userId:%s", "LiveChatManager", "OnEndTalk", userId));
			}
		}
		mCallbackHandler.OnEndTalk(errType, errmsg, userItem);

		// 生成警告消息
		if (errType != LiveChatErrType.Success) {
			if (null != userItem) {
				BuildAndInsertWarningWithErrType(userItem, errType);
			}
		}
	}

	/**
	 * 获取用户在线状态回调
	 * @param errType			处理结果类型
	 * @param errmsg			处理结果描述
	 * @param userStatusArray	用户在线状态数组
	 */
	@Override
	public void OnGetUserStatus(
			LiveChatErrType errType
			, String errmsg
			, LiveChatUserStatus[] userStatusArray)
	{
		ArrayList<LCUserItem> userArrayList = new ArrayList<LCUserItem>();
		if (null != userStatusArray)
		{
			for (int i = 0; i < userStatusArray.length; i++)
			{
				LiveChatUserStatus userStatusItem = userStatusArray[i];
				LCUserItem userItem = mUserMgr.getUserItem(userStatusItem.userId);
				if (null != userItem) {
					SetUserOnlineStatus(userItem, userStatusItem.statusType);
					userArrayList.add(userItem);
				}
			}
		}

		LCUserItem[] userList = new LCUserItem[userArrayList.size()];
		userArrayList.toArray(userList);
		mCallbackHandler.OnGetUserStatus(errType, errmsg, userList);
	}

	/**
	 * 获取聊天会话信息回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param invitedId	邀请ID
	 * @param charget	是否已付费
	 * @param chatTime	聊天时长
	 */
	@Override
	public void OnGetTalkInfo(
			LiveChatErrType errType
			, String errmsg
			, String userId
			, String invitedId
			, boolean charget
			, int chatTime)
	{
		// 暂时没用
	}

	/**
	 * 获取会话信息
	 * @param targetId
	 */
	public boolean GetSessionInfo(String targetId){
		return LiveChatClient.GetSessionInfo(targetId);
	}

	@Override
	public void OnGetSessionInfo(LiveChatErrType errType, String errmsg,
                                 String userId, LiveChatSessionInfoItem item) {
		LCUserItem userItem = GetUserWithId(userId);
		if(errType == LiveChatErrType.Success
				&& item != null){
			userItem.updateChatStatusBySession(item);
		}
		mCallbackHandler.OnGetSessionInfo(errType, errmsg, userId, item);
	}

	/**
	 * 发送聊天文本消息回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param message	消息内容
	 * @param ticket	票根
	 */
	@Override
	public void OnSendMessage(
			LiveChatErrType errType
			, String errmsg
			, String userId
			, String message
			, int ticket)
	{
		LCMessageItem item = mTextMgr.getAndRemoveSendingItem(ticket);

		//发送消息成功，如果会话状态为默认状态，修改为男士邀请状态
		OnSendMessageSessionProcess(item);
//		if(item != null){
//			LCUserItem userItem = mUserMgr.getUserItem(item.getUserItem().userId);
//			if(userItem != null && userItem.chatType == ChatType.Other){
//				userItem.chatType = ChatType.ManInvite;
//			}
//		}

		//当前自动充值的过程中，拦截nomoney错误返回
		if(AutoChargeManager.getInstatnce().isAutoCharging() &&
				errType == LiveChatErrType.NoMoney){
			//添加到待发送队列
			AutoChargeManager.getInstatnce().addToPendingList(item.getUserItem().userId);
			item.getUserItem().addToSendMsgList(item);
			return;
		}

		if (null != item) {
			item.statusType = (errType== LiveChatErrType.Success ? StatusType.Finish : StatusType.Fail);
			mCallbackHandler.OnSendMessage(errType, errmsg, item);
		}
		else {
			Log.e("livechat", String.format("%s::%s() get sending item fail, ticket:%d", "LiveChatManager", "OnSendMessage", ticket));
		}

		// 生成警告消息
		if (errType != LiveChatErrType.Success) {
			if (null != item && null != item.getUserItem()) {
				BuildAndInsertWarningWithErrType(item.getUserItem(), errType);
			}
		}

		Log.d("livechat", "OnSendMessage() errType:%s, userId:%s, message:%s", errType.name(), userId, message);
	}

	/**
	 * 发送高级表情消息回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param emotionId	高级表情ID
	 * @param ticket	票根
	 */
	@Override
	public void OnSendEmotion(
			LiveChatErrType errType
			, String errmsg
			, String userId
			, String emotionId
			, int ticket)
	{
		LCMessageItem item = mEmotionMgr.getAndRemoveSendingItem(ticket);

		//发送消息成功，如果会话状态为默认状态，修改为男士邀请状态
		OnSendMessageSessionProcess(item);
//		if(item != null){
//			LCUserItem userItem = mUserMgr.getUserItem(item.getUserItem().userId);
//			if(userItem != null && userItem.chatType == ChatType.Other){
//				userItem.chatType = ChatType.ManInvite;
//			}
//		}


		if(AutoChargeManager.getInstatnce().isAutoCharging() &&
				errType == LiveChatErrType.NoMoney){
			//添加到待发送队列
			AutoChargeManager.getInstatnce().addToPendingList(item.getUserItem().userId);
			item.getUserItem().addToSendMsgList(item);
			return;
		}
		if (null != item) {
			item.statusType = (errType== LiveChatErrType.Success ? StatusType.Finish : StatusType.Fail);
			mCallbackHandler.OnSendEmotion(errType, errmsg, item);
		}
		else {
			Log.e("livechat", String.format("%s::%s() get sending item fail, ticket:%d", "LiveChatManager", "OnSendEmotion", ticket));
		}

		// 生成警告消息
		if (errType != LiveChatErrType.Success) {
			if (null != item && null != item.getUserItem()) {
				BuildAndInsertWarningWithErrType(item.getUserItem(), errType);
			}
		}
	}

	/**
	 * 发送虚拟礼物回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param giftId	虚拟礼物ID
	 */
	@Override
	public void OnSendVGift(
			LiveChatErrType errType
			, String errmsg
			, String userId
			, String giftId
			, int ticket)
	{
		// 暂时没用（本版本暂时未实现本功能）
	}

	/**
	 * 获取发送语音验证码回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param ticket	票根
	 * @param voiceCode	语音ID
	 */
	@Override
	public void OnGetVoiceCode(
			LiveChatErrType errType
			, String errmsg
			, String userId
			, int ticket
			, String voiceCode)
	{
		LCMessageItem item = mVoiceMgr.getAndRemoveSendingItem(ticket);
		if (errType == LiveChatErrType.Success) {
			if (null != item
				&& item.msgType == MessageType.Voice
				&& null != item.getVoiceItem())
			{
				LCVoiceItem voiceItem = item.getVoiceItem();
				voiceItem.checkCode = voiceCode;
				LCUserItem userItem = item.getUserItem();

				int siteType = WebSiteConfigManager.getInstance().getCurrentWebSite().getSiteId();

				// 请求上传语音文件
				long requestId = LCRequestJniLiveChat.UploadVoice(
										voiceItem.checkCode
										, userItem.inviteId
										, mUserId
										, true
										, userItem.userId
										, siteType
										, voiceItem.fileType
										, voiceItem.timeLength
										, voiceItem.filePath
										, new OnLCUploadVoiceCallback()
				{
					@Override
					public void OnLCUploadVoice(long requestId, boolean isSuccess, String errno,
							String errmsg, String voiceId) {
						// TODO Auto-generated method stub
						LCMessageItem item = mVoiceMgr.getAndRemoveRquestItem(requestId);
						LCVoiceItem voiceItem = item.getVoiceItem();
						if (null == voiceItem) {
							Log.e("livechat", String.format("%s::%s() param fail. voiceItem is null.", "LiveChatManager", "OnGetVoiceCode"));
							mCallbackHandler.OnSendVoice(LiveChatErrType.Fail, "", "", item);
						}

						if (isSuccess) {
							voiceItem.voiceId = voiceId;
							if (LiveChatClient.SendVoice(item.toId, voiceItem.voiceId, voiceItem.timeLength, item.msgId)) {
								mVoiceMgr.addSendingItem(item.msgId, item);
							}
							else {
								mCallbackHandler.OnSendVoice(LiveChatErrType.Fail, "", "", item);
							}
						}
						else {
							item.statusType = StatusType.Fail;
							mCallbackHandler.OnSendVoice(LiveChatErrType.Fail, errno, errmsg, item);
							if(isNoCredits(errno)){
								if (null != item && null != item.getUserItem()) {
									BuildAndInsertWarningWithErrType(item.getUserItem(), LiveChatErrType.NoMoney);
								}
							}
						}
					}
				});

				if (requestId != LCRequestJni.InvalidRequestId) {
					// 添加item到请求map
					mVoiceMgr.addRequestItem(requestId, item);
				}
				else {
					item.statusType = StatusType.Fail;
					mCallbackHandler.OnSendVoice(LiveChatErrType.Fail, "", "", item);
				}
			}
			else {
				Log.e("livechat", String.format("%s::%s() param fail.", "LiveChatManager", "OnGetVoiceCode"));
			}
		}
		else {
			item.statusType = StatusType.Fail;
			mCallbackHandler.OnSendVoice(errType, "", errmsg, item);
		}

		// 生成警告消息
		if (errType != LiveChatErrType.Success) {
			if (null != item && null != item.getUserItem()) {
				BuildAndInsertWarningWithErrType(item.getUserItem(), errType);
			}
		}
	}

	/**
	 * 发送语音回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param voiceId	语音ID
	 */
	@Override
	public void OnSendVoice(
			LiveChatErrType errType
			, String errmsg
			, String userId
			, String voiceId
			, int ticket)
	{
		LCMessageItem item = mVoiceMgr.getAndRemoveSendingItem(ticket);

		//发送消息成功，如果会话状态为默认状态，修改为男士邀请状态
		OnSendMessageSessionProcess(item);
//		if(item != null){
//			LCUserItem userItem = mUserMgr.getUserItem(item.getUserItem().userId);
//			if(userItem != null && userItem.chatType == ChatType.Other){
//				userItem.chatType = ChatType.ManInvite;
//			}
//		}

		if(AutoChargeManager.getInstatnce().isAutoCharging() &&
				errType == LiveChatErrType.NoMoney){
			//添加到待发送队列
			AutoChargeManager.getInstatnce().addToPendingList(item.getUserItem().userId);
			item.getUserItem().addToSendMsgList(item);
			return;
		}
		if (null == item
			|| item.msgType != MessageType.Voice
			|| null == item.getVoiceItem())
		{
			Log.e("livechat", String.format("%s::%s() param fail.", "LiveChatManager", "OnSendVoice"));
			mCallbackHandler.OnSendVoice(LiveChatErrType.Fail, "", "", item);
			return;
		}

		// 发送成功
		if (errType == LiveChatErrType.Success) {
			mVoiceMgr.copyVoiceFileToDir(item);
		}

		// 回调
		item.statusType = (LiveChatErrType.Success==errType ? StatusType.Finish : StatusType.Fail);
		mCallbackHandler.OnSendVoice(errType, "", "", item);

		// 生成警告消息
		if (errType != LiveChatErrType.Success) {
			if (null != item && null != item.getUserItem()) {
				BuildAndInsertWarningWithErrType(item.getUserItem(), errType);
			}
		}
	}

	/**
	 * 发送小高级表情消息回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param magicIconId 小高级表情ID
	 * @param ticket	票根
	 */
	@Override
	public void OnSendMagicIcon(
			LiveChatErrType errType
			, String errmsg
			, String userId
			, String magicIconId
			, int ticket)
	{
		LCMessageItem item = mMagicIconMgr.getAndRemoveSendingItem(ticket);

		//发送消息成功，如果会话状态为默认状态，修改为男士邀请状态
		OnSendMessageSessionProcess(item);
//		if(item != null){
//			LCUserItem userItem = mUserMgr.getUserItem(item.getUserItem().userId);
//			if(userItem != null && userItem.chatType == ChatType.Other){
//				userItem.chatType = ChatType.ManInvite;
//			}
//		}

		if(AutoChargeManager.getInstatnce().isAutoCharging() &&
				errType == LiveChatErrType.NoMoney){
			//添加到待发送队列
			AutoChargeManager.getInstatnce().addToPendingList(item.getUserItem().userId);
			item.getUserItem().addToSendMsgList(item);
			return;
		}
		if (null != item) {
			item.statusType = (errType== LiveChatErrType.Success ? StatusType.Finish : StatusType.Fail);
			mCallbackHandler.OnSendMagicIcon(errType, errmsg, item);
		}
		else {
			Log.e("livechat", String.format("%s::%s() get sending item fail, ticket:%d", "LiveChatManager", "OnSendEmotion", ticket));
		}

		// 生成警告消息
		if (errType != LiveChatErrType.Success) {
			if (null != item && null != item.getUserItem()) {
				BuildAndInsertWarningWithErrType(item.getUserItem(), errType);
			}
		}
	}

	/**
	 * 使用试聊券回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param eventType	试聊券使用情况
	 */
	@Override
	public void OnUseTryTicket(
			LiveChatErrType errType
			, String errmsg
			, String userId
			, TryTicketEventType eventType)
	{
		mCallbackHandler.OnUseTryTicket(errType, "", errmsg, userId, eventType);

		//试聊券检测完成
		LCUserItem userItem = mUserMgr.getUserItem(userId);

		if (errType != LiveChatErrType.Success) {
			// 使用不成功，生成警告消息
			if (null != userItem) {
				BuildAndInsertWarningWithErrType(userItem, errType);
			}
			// 检测是否有足够余额
			Message msg = Message.obtain();
			msg.what = LiveChatRequestOptType.CheckMoneyOrAutoCharge.ordinal();
			msg.obj = userId;
			mHandler.sendMessage(msg);
		}
		else {
//			// 若当前状态为Other，则标记为ManInvite(男士邀请)状态
//			if (null != userItem) {
//				if (userItem.chatType == ChatType.Other
//					|| userItem.chatType == ChatType.Invite)
//				{
//					userItem.chatType = ChatType.ManInvite;
//				}
//			}
			// 使用成功，发送待发消息
			Message msg = Message.obtain();
			msg.what = LiveChatRequestOptType.SendMessageList.ordinal();
			msg.obj = userId;
			mHandler.sendMessage(msg);
		}
	}

	/**
	 * 获取邀请/在聊列表回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param listType	请求列表类型
	 * @param info		请求结果
	 */
	@Override
	public void OnGetTalkList(
			LiveChatErrType errType
			, String errmsg
			, int listType
			, LiveChatTalkListInfo info)
	{
		if (errType == LiveChatErrType.Success)
		{
			int i = 0;
			// 在聊列表
			for (i = 0; i < info.chatingArray.length; i++) {
				LiveChatTalkUserListItem item = info.chatingArray[i];
				LCUserItem userItem = mUserMgr.getUserItem(item.userId);
				Log.i("livechat", "Inchat userId: " +  item.userId);
				if (null != userItem) {
					userItem.userName = item.userName;
					userItem.sexType = UserSexType.USER_SEX_FEMALE;
//					userItem.statusType = UserStatusType.USTATUS_ONLINE;
					SetUserOnlineStatus(userItem, UserStatusType.USTATUS_ONLINE);
					userItem.chatType = ChatType.InChatCharge;
					userItem.clientType = item.clientType;
					userItem.order = item.orderValue;

					Log.d("livechat", String.format("OnGetTalkList() chatingArray, userId:%s, status:%s", item.userId, item.statusType.name()));
				}
			}
			// 在聊session列表
			for (i = 0; i < info.chatingSessionArray.length; i++) {
				LiveChatTalkSessionListItem item = info.chatingSessionArray[i];
				LCUserItem userItem = mUserMgr.getUserItem(item.userId);
				if (null != userItem) {
					userItem.inviteId = item.invitedId;
				}
			}

			// 在聊暂停列表
			for (i = 0; i < info.pauseArray.length; i++) {
				LiveChatTalkUserListItem item = info.pauseArray[i];
				LCUserItem userItem = mUserMgr.getUserItem(item.userId);
				Log.i("livechat", "Inchat pause userId: " +  item.userId);
				if (null != userItem) {
					userItem.userName = item.userName;
					userItem.sexType = UserSexType.USER_SEX_FEMALE;
//					userItem.statusType = UserStatusType.USTATUS_ONLINE;
					SetUserOnlineStatus(userItem, UserStatusType.USTATUS_ONLINE);
					userItem.chatType = ChatType.InChatCharge;
					userItem.clientType = item.clientType;
					userItem.order = item.orderValue;

					Log.d("livechat", String.format("OnGetTalkList() pauseArray, userId:%s, status:%s", item.userId, item.statusType.name()));
				}
			}
			// 在聊暂停session列表
			for (i = 0; i < info.pauseSessionArray.length; i++) {
				LiveChatTalkSessionListItem item = info.pauseSessionArray[i];
				LCUserItem userItem = mUserMgr.getUserItem(item.userId);
				if (null != userItem) {
					userItem.inviteId = item.invitedId;
				}
			}

			// 邀请列表
			for (i = 0; i < info.inviteArray.length; i++) {
				LiveChatTalkUserListItem item = info.inviteArray[i];
				LCUserItem userItem = mUserMgr.getUserItem(item.userId);
				Log.i("livechat", "Inchat invite userId: " +  item.userId);
				if (null != userItem) {
					userItem.userName = item.userName;
					userItem.sexType = UserSexType.USER_SEX_FEMALE;
//					userItem.statusType = UserStatusType.USTATUS_ONLINE;
					SetUserOnlineStatus(userItem, UserStatusType.USTATUS_ONLINE);
					userItem.chatType = ChatType.ManInvite;
					userItem.clientType = item.clientType;
					userItem.order = item.orderValue;

					Log.d("livechat", String.format("OnGetTalkList() inviteArray, userId:%s, status:%s", item.userId, item.statusType.name()));
				}
			}

			// 邀请session列表
			for (i = 0; i < info.inviteSessionArray.length; i++) {
				LiveChatTalkSessionListItem item = info.inviteSessionArray[i];
				LCUserItem userItem = mUserMgr.getUserItem(item.userId);
				if (null != userItem) {
					userItem.inviteId = item.invitedId;
				}
			}

			// 获取 inchat 用户历史聊天记录
			Message msgGetUsersHistoryMessage = Message.obtain();
			msgGetUsersHistoryMessage.what = LiveChatRequestOptType.GetUsersHistoryMessage.ordinal();
			mHandler.sendMessage(msgGetUsersHistoryMessage);

			// CamShare服务中处理
			Message msgCamShareOnGetTalkList = Message.obtain();
			msgCamShareOnGetTalkList.what = LiveChatRequestOptType.CamShareOnGetTalkList.ordinal();
			msgCamShareOnGetTalkList.obj = info;
			mHandler.sendMessage(msgCamShareOnGetTalkList);
		}

		mCallbackHandler.OnGetTalkList(errType, errmsg);
	}

	/**
	 * 发送图片回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	@Override
	public void OnSendPhoto(LiveChatErrType errType, String errmsg, int ticket)
	{
		Log.i("LiveChatManager", "OnSendPhoto errType: " + errType);
		LCMessageItem item = mPhotoMgr.getAndRemoveSendingItem(ticket);

		//发送消息成功，如果会话状态为默认状态，修改为男士邀请状态
		OnSendMessageSessionProcess(item);
//		if(item != null){
//			LCUserItem userItem = mUserMgr.getUserItem(item.getUserItem().userId);
//			if(userItem != null && userItem.chatType == ChatType.Other){
//				userItem.chatType = ChatType.ManInvite;
//			}
//		}

		if(AutoChargeManager.getInstatnce().isAutoCharging() &&
				errType == LiveChatErrType.NoMoney){
			//添加到待发送队列
			AutoChargeManager.getInstatnce().addToPendingList(item.getUserItem().userId);
			item.getUserItem().addToSendMsgList(item);
			return;
		}


		if(errType == LiveChatErrType.ConnectFail){
			//断线重连的情况下，拦截私密照发送错误，等待重连成功重新发送
			item.getUserItem().addToSendMsgList(item);
			return;
		}


		if (null != item) {
			item.statusType = (errType== LiveChatErrType.Success ? StatusType.Finish : StatusType.Fail);
			mCallbackHandler.OnSendPhoto(errType, "", errmsg, item);
		}
		else {
			Log.e("livechat", String.format("%s::%s() get sending item fail, ticket:%d", "LiveChatManager", "OnSendPhoto", ticket));
		}

		// 生成警告消息
		if (errType != LiveChatErrType.Success) {
			if (null != item && null != item.getUserItem()) {
				BuildAndInsertWarningWithErrType(item.getUserItem(), errType);
			}
		}
	}

	/**
	 * 显示图片回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	@Override
	public void OnShowPhoto(LiveChatErrType errType, String errmsg, int ticket)
	{
//		LCMessageItem item = mPhotoMgr.getAndRemoveSendingItem(ticket);
//		if (null != item) {
//			item.statusType = (errType==LiveChatErrType.Success ? StatusType.Finish : StatusType.Fail);
//			mCallbackHandler.OnGetPhoto(errType, "", errmsg, item);
//		}
//		else {
//			Log.e("livechat", String.format("%s::%s() get sending item fail, msgId:%d", "LiveChatManager", "OnShowPhoto", ticket));
//		}
//
//		// 生成警告消息
//		if (errType != LiveChatErrType.Success) {
//			if (null != item && null != item.getUserItem()) {
//				BuildAndInsertWarning(item.getUserItem(), errType);
//			}
//		}
	}

	/**
	 * 播放微视频回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	@Override
	public void OnPlayVideo(LiveChatErrType errType, String errmsg, int ticket)
	{

	}

	/**
	 * 获取用户信息
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param item		用户信息item
	 */
	@Override
	public void OnGetUserInfo(LiveChatErrType errType, String errmsg, String userId, LiveChatTalkUserListItem item)
	{
		if (errType == LiveChatErrType.Success)
		{
			//登录成功获取本人用户信息，用于作为小助手匹配使用
			if(item != null && item.userId.equals(mUserId)){
				mAutoInviteFilter.onGetUserInfoUpdate(item);
				//更新本人服务器
				mLCCamShareManager.updateUserServer(item.server);
			}
			// 更新用户排序分值
			mInviteMgr.UpdateUserOrderValue(item.userId, item.orderValue);

			//更新本地缓存女士信息
			mUserInfoManager.OnGetUserInfoUpdate(item);

			//更新用户在线状态
			LCUserItem userItem = mUserMgr.getUserItem(item.userId);
			if (null != userItem) {
				SetUserOnlineStatus(userItem, item.statusType);
			}
		}
		if(mLCFunctionCheckManager != null){
			//通知对方支持功能检测模块，女士信息更新
			mLCFunctionCheckManager.onGetWomanInfo(errType, userId, item);
		}

		//回调获取指定用户信息
		mCallbackHandler.OnGetUserInfo(errType, errmsg, userId, item);
	}

	/**
	 * 批量获取用户信息
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param itemList  用户信息
	 */
	@Override
	public void OnGetUsersInfo(LiveChatErrType errType, String errmsg, String[] userIds, LiveChatTalkUserListItem[] itemList)
	{
		if(itemList != null){
			for(LiveChatTalkUserListItem item : itemList){
				if(item != null){
					//更新用户在线状态
					LCUserItem userItem = mUserMgr.getUserItem(item.userId);
					if (null != userItem) {
						SetUserOnlineStatus(userItem, item.statusType);
					}
				}
			}
		}
		//更新本地缓存女士信息
		mUserInfoManager.OnGetUersInfoUpdate(itemList);

		mCallbackHandler.OnGetUsersInfo(errType, errmsg, userIds, itemList);
	}

	/**
	 * 获取黑名单列表
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param list		黑名单列表
	 */
	@Override
	public void OnGetBlockList(LiveChatErrType errType, String errmsg, LiveChatTalkUserListItem[] list)
	{
		if (errType == LiveChatErrType.Success) {
			mBlockMgr.UpdateWithBlockList(list);
		}
	}

	/**
	 * 获取LiveChat联系人列表
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param list		联系人列表
	 */
	@Override
	public void OnGetContactList(LiveChatErrType errType, String errmsg, LiveChatTalkUserListItem[] list)
	{
		if (errType == LiveChatErrType.Success) {
			mContactMgr.UpdateWithContactList(list);
			if(list != null) {
				for (LiveChatTalkUserListItem item : list) {
					if (item != null) {
						LCUserItem userItem = mUserMgr.getUserItem(item.userId);
						if (null != userItem) {
							SetUserOnlineStatus(userItem, item.statusType);
						}
					}
				}
			}
		}

		mCallbackHandler.OnGetContactList(errType, errmsg, list);
	}

	/**
	 * 获取被屏蔽女士列表
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param usersId	被屏蔽女士列表
	 */
	public void OnGetBlockUsers(LiveChatErrType errType, String errmsg, String[] usersId)
	{
		if (errType == LiveChatErrType.Success) {
			mBlockMgr.UpdateWithBlockUsers(usersId);
		}
	}

	/**
	 * 接收聊天文本消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param charget	是否已付费
	 * @param ticket	票根
	 * @param msgType	聊天消息类型
	 * @param message	消息内容
	 */
	@Override
	public void OnRecvMessage(
			String toId
			, String fromId
			, String fromName
			, String inviteId
			, boolean charget
			, int ticket
			, TalkMsgType msgType
			, String message
			, InviteStatusType inviteType)
	{
		// 返回票根给服务器
		LiveChatClient.UploadTicket(fromId, ticket);

		LCMessageItem item = null;

		//邀请风控处理
		if(IsRecvMessageLimited(fromId)){
			return;
		}

		// 判断是否邀请消息
		HandleInviteMsgType handleType = mInviteMgr.IsToHandleInviteMsg(fromId, charget, msgType);
		if (handleType == HandleInviteMsgType.HANDLE) {
			// 处理邀请消息
			mInviteMgr.HandleInviteMessage(mMsgIdIndex, toId, fromId, fromName, inviteId, charget, ticket, msgType, message, inviteType);
			item = mInviteMgr.getInviteMessage();
		}
		else if (handleType == HandleInviteMsgType.PASS) {
			// 添加用户到列表中（若列表中用户不存在）
			LCUserItem userItem = mUserMgr.getUserItem(fromId);
			if (null == userItem) {
				Log.e("livechat", String.format("%s::%s() getUserItem fail, fromId:%s", "LiveChatManager", "OnRecvMessage", fromId));
				return;
			}
			userItem.inviteId = inviteId;
			userItem.userName = fromName;
			userItem.setChatTypeWithTalkMsgType(charget, msgType);
//			userItem.statusType = UserStatusType.USTATUS_ONLINE;
			SetUserOnlineStatus(userItem, UserStatusType.USTATUS_ONLINE);

			// 生成MessageItem
			item = new LCMessageItem();
			item.initByInvite(mMsgIdIndex.getAndIncrement()
					, SendType.Recv
					, fromId
					, toId
					, userItem.inviteId
					, StatusType.Finish
					, inviteType);
			// 生成TextItem
			LCTextItem textItem = new LCTextItem();
			textItem.init(message, SendType.Recv);
			// 把TextItem添加到MessageItem
			item.setTextItem(textItem);
			// 添加到用户聊天记录中
			if (!userItem.insertSortMsgList(item)) {
				// 添加到用户聊天记录列表不成功
				item = null;
			}
		}

		if (null != item) {
			// callback
			mCallbackHandler.OnRecvMessage(item);
		}
	}

	/**
	 * 接收高级表情消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param charget	是否已付费
	 * @param ticket	票根
	 * @param msgType	聊天消息类型
	 * @param emotionId	高级表情ID
	 */
	@Override
	public void OnRecvEmotion(
			String toId
			, String fromId
			, String fromName
			, String inviteId
			, boolean charget
			, int ticket
			, TalkMsgType msgType
			, String emotionId)
	{
//		// 返回票根给服务器
//		LiveChatClient.UploadTicket(fromId, ticket);
//
//		//邀请风控处理
//		if(IsRecvMessageLimited(fromId)){
//			return;
//		}
//
//		// 添加用户到列表中（若列表中用户不存在）
//		LCUserItem userItem = mUserMgr.getUserItem(fromId);
//		if (null == userItem) {
//			Log.e("livechat", String.format("%s::%s() getUserItem fail, fromId:%s", "LiveChatManager", "OnRecvEmotion", fromId));
//			return;
//		}
//		userItem.inviteId = inviteId;
//		userItem.userName = fromName;
//		userItem.setChatTypeWithTalkMsgType(charget, msgType);
////		userItem.statusType = UserStatusType.USTATUS_ONLINE;
//		SetUserOnlineStatus(userItem, UserStatusType.USTATUS_ONLINE);
//
//		// 生成MessageItem
//		LCMessageItem item = new LCMessageItem();
//		item.init(mMsgIdIndex.getAndIncrement()
//				, SendType.Recv
//				, fromId
//				, toId
//				, userItem.inviteId
//				, StatusType.Finish);
//		// 获取EmotionItem
//		LCEmotionItem emotionItem = mEmotionMgr.getEmotion(emotionId);
//		// 把EmotionItem添加到MessageItem
//		item.setEmotionItem(emotionItem);
//
//		// 添加到用户聊天记录中
//		userItem.insertSortMsgList(item);
//
//		// callback
//		mCallbackHandler.OnRecvEmotion(item);
	}

	/**
	 * 接收语音消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param charget	是否已付费
	 * @param msgType	聊天消息类型
	 * @param voiceId	语音ID
	 * @param fileType	语音文件类型
	 * @param timeLen	语音时长
	 */
	@Override
	public void OnRecvVoice(
			String toId
			, String fromId
			, String fromName
			, String inviteId
			, boolean charget
			, TalkMsgType msgType
			, String voiceId
			, String fileType
			, int timeLen)
	{
		//邀请风控处理
		if(IsRecvMessageLimited(fromId)){
			return;
		}

		// 添加用户到列表中（若列表中用户不存在）
		LCUserItem userItem = mUserMgr.getUserItem(fromId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, fromId:%s", "LiveChatManager", "OnRecvVoice", fromId));
			return;
		}
		userItem.userName = fromName;
		userItem.inviteId = inviteId;
		userItem.setChatTypeWithTalkMsgType(charget, msgType);
//		userItem.statusType = UserStatusType.USTATUS_ONLINE;
		SetUserOnlineStatus(userItem, UserStatusType.USTATUS_ONLINE);

		// 生成MessageItem
		LCMessageItem item = new LCMessageItem();
		item.init(mMsgIdIndex.getAndIncrement()
				, SendType.Recv
				, fromId
				, toId
				, userItem.inviteId
				, StatusType.Finish);
		// 生成VoiceItem
		LCVoiceItem voiceItem = new LCVoiceItem();
		voiceItem.init(voiceId
				, mVoiceMgr.getVoicePath(voiceId, fileType)
				, timeLen
				, fileType
				, ""
				, charget);

		// 把VoiceItem添加到MessageItem
		item.setVoiceItem(voiceItem);

		// 添加到聊天记录中
		userItem.insertSortMsgList(item);

		// callback
		mCallbackHandler.OnRecvVoice(item);
	}

	/**
	 * 接收高级表情消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param charget	是否已付费
	 * @param ticket	票根
	 * @param msgType	聊天消息类型
	 * @param magicIconId	高级表情ID
	 */
	@Override
	public void OnRecvMagicIcon(
			String toId
			, String fromId
			, String fromName
			, String inviteId
			, boolean charget
			, int ticket
			, TalkMsgType msgType
			, String magicIconId)
	{
		// 返回票根给服务器
		LiveChatClient.UploadTicket(fromId, ticket);

		//邀请风控处理
		if(IsRecvMessageLimited(fromId)){
			return;
		}

		// 添加用户到列表中（若列表中用户不存在）
		LCUserItem userItem = mUserMgr.getUserItem(fromId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, fromId:%s", "LiveChatManager", "OnRecvMagicIcon", fromId));
			return;
		}
		userItem.inviteId = inviteId;
		userItem.userName = fromName;
		userItem.setChatTypeWithTalkMsgType(charget, msgType);
//		userItem.statusType = UserStatusType.USTATUS_ONLINE;
		SetUserOnlineStatus(userItem, UserStatusType.USTATUS_ONLINE);

		//由于服务器问题，未带toId，协商使用本地UserId现处理
		String userId = mUserId;
		if(!TextUtils.isEmpty(toId)){
			userId = toId;
		}
		// 生成MessageItem
		LCMessageItem item = new LCMessageItem();
		item.init(mMsgIdIndex.getAndIncrement()
				, SendType.Recv
				, fromId
				, userId
				, userItem.inviteId
				, StatusType.Finish);
//		// 获取EmotionItem
		LCMagicIconItem magicIconItem = mMagicIconMgr.getMagicIcon(magicIconId);
		// 把EmotionItem添加到MessageItem
		item.setMagicIconItem(magicIconItem);

		// 添加到用户聊天记录中
		userItem.insertSortMsgList(item);
		// callback
		mCallbackHandler.OnRecvMagicIcon(item);
	}

	/**
	 * 接收警告消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param charget	是否已付费
	 * @param ticket	票根
	 * @param msgType	聊天消息类型
	 * @param message	消息内容
	 */
	@Override
	public void OnRecvWarning(
			String toId
			, String fromId
			, String fromName
			, String inviteId
			, boolean charget
			, int ticket
			, TalkMsgType msgType
			, String message)
	{
		// 返回票根给服务器
		LiveChatClient.UploadTicket(fromId, ticket);

		//邀请风控处理
		if(IsRecvMessageLimited(fromId)){
			return;
		}

		// 添加用户到列表中（若列表中用户不存在）
		LCUserItem userItem = mUserMgr.getUserItem(fromId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, fromId:%s", "LiveChatManager", "OnRecvWarning", fromId));
			return;
		}
		userItem.inviteId = inviteId;
		userItem.setChatTypeWithTalkMsgType(charget, msgType);
		userItem.userName = fromName;
//		userItem.statusType = UserStatusType.USTATUS_ONLINE;
		SetUserOnlineStatus(userItem, UserStatusType.USTATUS_ONLINE);

		// 生成MessageItem
		LCMessageItem item = new LCMessageItem();
		item.init(mMsgIdIndex.getAndIncrement()
				, SendType.Recv
				, fromId
				, toId
				, userItem.inviteId
				, StatusType.Finish);
		// 生成WarningItem
		LCWarningItem warningItem = new LCWarningItem();
		warningItem.init(message);
		// 把WarningItem添加到MessageItem
		item.setWarningItem(warningItem);

		// 添加到用户聊天记录中
		userItem.insertSortMsgList(item);

		// callback
		mCallbackHandler.OnRecvWarning(item);
	}

	/**
	 * 接收更新在线状态消息回调
	 * @param userId
	 * @param server
	 * @param clientType
	 * @param statusType
	 */
	@Override
	public void OnUpdateStatus(
			String userId
			, String server
			, LiveChatClient.ClientType clientType
			, LiveChatClient.UserStatusType statusType)
	{
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, userId:%s", "LiveChatManager", "OnUpdateStatus", userId));
			return;
		}
		userItem.clientType = clientType;
		SetUserOnlineStatus(userItem, statusType);

		//更新本地缓存女士信息
		mUserInfoManager.OnUpdateStatus(userId);

		mCallbackHandler.OnUpdateStatus(userItem);
	}

	/**
	 * 接收更新票根消息回调
	 * @param fromId	发送者ID
	 * @param ticket	票根
	 */
	@Override
	public void OnUpdateTicket(String fromId, int ticket)
	{
		// 不用处理
	}

	/**
	 * 接收用户正在编辑消息回调
	 * @param fromId	用户ID
	 */
	@Override
	public void OnRecvEditMsg(String fromId)
	{
		mCallbackHandler.OnRecvEditMsg(fromId);
	}

	/**
	 * 接收聊天事件消息回调
	 * @param userId	聊天对象ID
	 * @param eventType	聊天事件
	 */
	@Override
	public void OnRecvTalkEvent(String userId, TalkEventType eventType)
	{
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, userId:%s, eventType:%s", "LiveChatManager", "OnRecvTalkEvent", userId, eventType.name()));
			return;
		}
		userItem.setChatTypeWithEventType(eventType);
		mCallbackHandler.OnRecvTalkEvent(userItem);

		if (eventType == TalkEventType.NoMoney
			|| eventType == TalkEventType.VideoNoMoney)
		{
			BuildAndInsertWarningWithErrType(userItem, LiveChatErrType.NoMoney);
		}
	}

	/**
	 * 接收试聊开始消息回调
	 * @param toId		接收者ID
	 * @param fromId	发起者ID
	 * @param time		试聊时长
	 */
	@Override
	public void OnRecvTryTalkBegin(String toId, String fromId, int time)
	{
		// 改变用户聊天状态并回调
		LCUserItem userItem = mUserMgr.getUserItem(toId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, toId:%s", "LiveChatManager", "OnRecvTryTalkBegin", toId));
			return;
		}
		userItem.chatType = ChatType.InChatUseTryTicket;
		mCallbackHandler.OnRecvTryTalkBegin(userItem, time);
	}

	/**
	 * 接收试聊结束消息回调
	 * @param userId	聊天对象ID
	 */
	@Override
	public void OnRecvTryTalkEnd(String userId)
	{
		// 改变用户聊天状态并回调
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, userId:%s", "LiveChatManager", "OnRecvTryTalkEnd", userId));
			return;
		}
		userItem.chatType = ChatType.InChatCharge;
		mCallbackHandler.OnRecvTryTalkEnd(userItem);

		// 插入系统消息
		String message = mContext.getString(R.string.livechat_msg_trychat_start_end);
		BuildAndInsertSystemMsg(userId, message);
	}


	/**
	 * 接收邮件更新消息回调
	 * @param fromId		发送者ID
	 * @param noticeType	邮件类型
	 */
	@Override
	public void OnRecvEMFNotice(String fromId, TalkEmfNoticeType noticeType)
	{
		mCallbackHandler.OnRecvEMFNotice(fromId, noticeType);
	}

	/**
	 * 接收被踢下线消息回调
	 * @param kickType	被踢下线原因
	 */
	@Override
	public void OnRecvKickOffline(KickOfflineType kickType)
	{
		Log.d("livechat", "LiveChatManager::OnRecvKickOffline() kickType:%s", kickType.name());

		// 用户在其它地方登录，被踢下线
		if (kickType == KickOfflineType.OtherLogin)
		{
			// 设置不自动重登录
			mIsAutoRelogin = false;
			
			//被踢统一处理
			Message msg = Message.obtain();
			msg.what = LiveChatRequestOptType.LiveChatKickOffEvent.ordinal();
			mHandler.sendMessage(msg);
	
			// 回调
			mCallbackHandler.OnRecvKickOffline(kickType);
		}
		
		Log.d("livechat", "LiveChatManager::OnRecvKickOffline() end");
	}

	/**
	 * 接收图片消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param photoId	图片ID
	 * @param sendId	图片发送ID
	 * @param charget	是否已付费
	 * @param photoDesc	图片描述
	 * @param ticket	票根
	 */
	@Override
	public void OnRecvPhoto(
			String toId			
			, String fromId
			, String fromName
			, String inviteId
			, String photoId
			, String sendId
			, boolean charget
			, String photoDesc
			, int ticket)
	{
		// 返回票根给服务器
		LiveChatClient.UploadTicket(fromId, ticket);

		//邀请风控处理
		if(IsRecvMessageLimited(fromId)){
			return;
		}

		// 添加用户到列表中（若列表中用户不存在）
		LCUserItem userItem = mUserMgr.getUserItem(fromId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, fromId:%s", "LiveChatManager", "OnRecvPhoto", fromId));
			return;
		}
		userItem.inviteId = inviteId;
		userItem.userName = fromName;
//		userItem.statusType = UserStatusType.USTATUS_ONLINE;
		SetUserOnlineStatus(userItem, UserStatusType.USTATUS_ONLINE);

		// 生成MessageItem
		LCMessageItem item = new LCMessageItem();
		item.init(mMsgIdIndex.getAndIncrement()
				, SendType.Recv
				, fromId
				, toId
				, userItem.inviteId
				, StatusType.Finish);
		// 生成PhotoItem
		LCPhotoItem photoItem = new LCPhotoItem();
		photoItem.init(
				mPhotoMgr,
				photoId
				, sendId
				, photoDesc
				, charget);
		// 把PhotoItem添加到MessageItem
		item.setPhotoItem(photoItem);

		// 添加到用户聊天记录中
		userItem.insertSortMsgList(item);

		// callback
		mCallbackHandler.OnRecvPhoto(item);
	}
	
	/**
	 * 接收微视频消息回调
	 * @param toId		接收者ID
	 * @param fromId	发送者ID
	 * @param fromName	发送者用户名
	 * @param inviteId	邀请ID
	 * @param videoId	视频ID
	 * @param sendId	发送ID
	 * @param charget	是否已付费
	 * @param videoDesc	视频描述
	 * @param ticket	票根
	 */
	@Override
	public void OnRecvVideo(
			String toId			
			, String fromId
			, String fromName
			, String inviteId
			, String videoId
			, String sendId
			, boolean charget
			, String videoDesc
			, int ticket)
	{
		// 返回票根给服务器
		LiveChatClient.UploadTicket(fromId, ticket);

		//邀请风控处理
		if(IsRecvMessageLimited(fromId)){
			return;
		}

		// 不允许接收视频消息
		if (!mIsRecvVideoMsg) {
			return;
		}

		// 添加用户到列表中（若列表中用户不存在）
		LCUserItem userItem = mUserMgr.getUserItem(fromId);
		if (null == userItem) {
			Log.e("livechat", String.format("%s::%s() getUserItem fail, fromId:%s", "LiveChatManager", "OnRecvVideo", fromId));
			return;
		}
		userItem.inviteId = inviteId;
		userItem.userName = fromName;
		SetUserOnlineStatus(userItem, UserStatusType.USTATUS_ONLINE);

		// 生成MessageItem
		LCMessageItem item = new LCMessageItem();
		item.init(mMsgIdIndex.getAndIncrement()
				, SendType.Recv
				, fromId
				, toId
				, userItem.inviteId
				, StatusType.Finish);
		// 生成VideoItem
		LCVideoItem videoItem = new LCVideoItem();
		videoItem.init(videoId
				, sendId
				, videoDesc
				, ""
				, ""
				, ""
				, ""
				, charget);
		// 把PhotoItem添加到MessageItem
		item.setVideoItem(videoItem);

		// 添加到用户聊天记录中
		userItem.insertSortMsgList(item);

		// callback
		mCallbackHandler.OnRecvVideo(item);
	}
	
	// --------------- 高级表情下载回调 ---------------
	/**
	 * 下载高级表情图片回调
	 * @param result		下载结果
	 * @param emotionItem	高级表情item
	 */
	@Override
	public void OnDownloadEmotionImage(boolean result, LCEmotionItem emotionItem)
	{
		mCallbackHandler.OnGetEmotionImage(result, emotionItem);
	}
	
	/**
	 * 下载高级表情播放图片回调
	 * @param result		下载结果
	 * @param emotionItem	高级表情item
	 */
	@Override
	public void OnDownloadEmotionPlayImage(boolean result, LCEmotionItem emotionItem)
	{
		mCallbackHandler.OnGetEmotionPlayImage(result, emotionItem);
	}
	
	/**
	 * 下载高级表情3gp回调
	 * @param result		下载结果
	 * @param emotionItem	高级表情item
	 */
	@Override
	public void OnDownloadEmotion3gp(boolean result, LCEmotionItem emotionItem)
	{
		mCallbackHandler.OnGetEmotion3gp(result, emotionItem);
	}

	// ----------------------- OnLoginManagerCallback -----------------------
	/**
	 * 通过 LoginItem 登录
	 * @param loginItem
	 */
	public void LoginWithLoginItem(final LoginItem loginItem)
	{
		// TODO Auto-generated method stub
		ConfigItem configItem = LoginManager.getInstance().getSynConfig();

		//更新流媒体服务器地址
		mLCCamShareManager.updateConfig(configItem.camShareHost, loginItem.userId,
				loginItem.nickName, loginItem.sessionId);

		//合并Ip
		ArrayList<String> ipList = new ArrayList<String>();
		ipList.add(configItem.host);

		WebSiteBean website = WebSiteConfigManager.getInstance().getCurrentWebSite();
		String host = website.getWebSiteHost();

		if( ipList.size() > 0 && configItem.port != -1 )
		{
			// 初始化并登录livechat
			TelephonyManager tm = (TelephonyManager) mContext.getSystemService(Context.TELEPHONY_SERVICE);
			if (IsLogin()) {
				Logout(false);
			}
			Init(
				ipList.toArray(new String[ipList.size()]),
					configItem.port,
					host
				);
			Login(loginItem.userId,
					loginItem.sessionId,
					SystemUtils.getDeviceId(mContext),
					loginItem.videoreceived);
		}
	}
	
	/**
	 * LoginManager回调（php登录回调）
	 */
	@Override
	public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
		// TODO Auto-generated method stub
		if (isSuccess) 
		{
			mRiskControl = item.livechat;
			if (!item.livechat) {
				// 登录成功且没有风控则登录LiveChat
				Message msg = Message.obtain();
				msg.what = LiveChatRequestOptType.LoginWithLoginItem.ordinal();
				msg.obj = item;
				mHandler.sendMessage(msg);
				// for test
//				Log.d("test", "sid:%s", item.sessionid);
			}
		}else{
			//登陆失败，注销Livechat，防止出现类似session过期重登陆，登陆失败，Livechat还在
			if (IsLogin()) {
				Logout(false);
			}
		}
	}

	/**
	 * LoginManager注销回调（php注销回调）
	 */
	@Override
	public void onLogout(boolean bActive) {
		// TODO Auto-generated method stub
		if (bActive) { 
			// 主动注销
			
			//结束所有Camshare聊天
			EndAllCamshareChat();
			
			//断开链接，清除参数
			Logout(true);
		}
		else {
			// 被动注销(如session超时)
			Logout(false);
		}
	}

	@Override
	public void OnGetLadyCustomTemplate(LiveChatErrType errType, String errmsg,
                                        String womanId, String[] contents, boolean[] flags) {
		// TODO Auto-generated method stub
		if(mAutoInviteFilter != null){
			mAutoInviteFilter.OnGetLadyCustomTemplate(errType, errmsg, womanId, contents, flags);
		}
	}

	@Override
	public void OnUploadPopLadyAutoInvite(LiveChatErrType errType, String errmsg, String womanId, String msgId, String key, String InviteId) {
        // 通知服务器自动邀请接收成功，更新邀请ID,解决接受自动邀请，回复语音因为无邀请ID失败
        LCUserItem userItem = mUserMgr.getUserItem(womanId);
        if(userItem != null){
			Log.i("hunter", "OnUploadPopLadyAutoInvite womanId: " + womanId + " InviteId: " + InviteId + " userItem : " + userItem);
            userItem.inviteId = InviteId;
        }
	}

	@Override
	public void OnRecvAutoInviteMsg(String womanId, String manId, String key) {
		// TODO Auto-generated method stub
		//邀请风控处理
		if(IsRecvMessageLimited(womanId)){
			return;
		}
		
		//联系人过滤 add by Jagger 2017-8-16
		if(mContactMgr.IsExist(womanId)){
			return;
		}
		
		//条件过滤
		if(mAutoInviteFilter != null){
			mAutoInviteFilter.filterAutoInvite(womanId, manId, key);
		}
	}

	@Override
	public void OnGetLadyCondition(LiveChatErrType errType, String errmsg,
                                   String womanId, LiveChatLadyCondition condition) {
		// TODO Auto-generated method stub
		if(mAutoInviteFilter != null){
			mAutoInviteFilter.OnGetLadyCondition(errType, errmsg, womanId, condition);
		}
	}

	@Override
	public void OnRecvAutoChargeResult(String manId, double money,
                                       AutoChargeType type, boolean result, String code, String msg) {
		// TODO Auto-generated method stub
		if(type == AutoChargeType.Start){
			//自动充值开始
			AutoChargeManager.getInstatnce().setAutoCharging(true);
			mHandler.postDelayed(new Runnable() {
				
				@Override
				public void run() {
					RequestBaseResponse response = new RequestBaseResponse(false, "", "", Double.valueOf(0));
					Message message = Message.obtain();
					message.what = LiveChatRequestOptType.ChatRechargeCallback.ordinal();
					message.obj = response;
					mHandler.sendMessage(message);
				}
			}, AutoChargeManager.AUTO_RECHARGE_OVERTIME);
		}else{
			//自动充值结束，通知界面刷新
			if(AutoChargeManager.getInstatnce().isAutoCharging()){
				//防止被定时器提前结束重复回调
				RequestBaseResponse response = new RequestBaseResponse(result, code, "", Double.valueOf(0));
				Message message = Message.obtain();
				message.what = LiveChatRequestOptType.ChatRechargeCallback.ordinal();
				message.obj = response;
				mHandler.sendMessage(message);
			}
		}
	}
	
	/**
	 * 小助手邀请消息异步处理后插入回调给界面处理
	 * @param autoInviteItem
	 * @param message
	 */
	public void onAutoInviteFilterCallback(LCAutoInviteItem autoInviteItem, String message){
		LCMessageItem item = null;
		//自动邀请过滤完成回调，插入自动邀请消息列表
		if(mInviteMgr != null){
			mInviteMgr.handleAutoInviteMessage(mMsgIdIndex.getAndIncrement(), autoInviteItem, message);
			item = mInviteMgr.getInviteMessage();
		}
		if (null != item) {
			// callback
			mCallbackHandler.OnRecvMessage(item);
		}
	}
	
	/******************************修改发送逻辑，优先检测功能是否开启，获取功能检测后， 走正常发送逻辑******************************************/
	/**
	 * 检测试聊券等，然后发送
	 * @param userItem
	 */
	private void CheckTryTicketAndSend(LCUserItem userItem){
		Log.i("LiveChatManager", "CheckTryTicketAndSend userItem userId: " + userItem.userId);
		if(userItem != null){
			if (IsSendMessageNow(userItem)){
				// 不需要检测直接发送
				Message msg = Message.obtain();
				msg.what = LiveChatRequestOptType.SendMessageList.ordinal();
				msg.obj = userItem.userId;
				mHandler.sendMessage(msg);
			}else {
				if (IsLogin()) {
					CheckCouponProc(userItem);
				}
			}
		}
	}
	/**
	 * 功能检测完成
	 * @param userId
	 */
	public void onFunctionCheckFinish(String userId){
		Log.i("LiveChatManager", "onFunctionCheckFinish UserId: " + userId);
		Message msg = Message.obtain();
		msg.what = LiveChatRequestOptType.CheckFunctionsFinish.ordinal();
		msg.obj = userId;
		mHandler.sendMessage(msg);
	}

	/********************************  magic icon relative *********************************************/
	@Override
	public void OnDownloadMagicIconImage(boolean result,
			LCMagicIconItem magicIconItem) {
		mCallbackHandler.OnGetMagicIconSrcImage(result, magicIconItem);
	}

	@Override
	public void OnDownloadMagicIconThumbImage(boolean result,
			LCMagicIconItem magicIconItem) {
		mCallbackHandler.OnGetMagicIconThumbImage(result, magicIconItem);		
	}
	
	/********************************  live chat theme *********************************************/
	/**
	 * 获取指定男/女士已购主题包
	 * @param userId
	 * @return
	 */
	public boolean GetPaidTheme(String userId){
		return LiveChatClient.GetPaidTheme(userId);
	}
	
	/**
	 * 获取男/女士所有已购主题包
	 * @return
	 */
	public boolean GetAllPaidTheme(){
		return LiveChatClient.GetAllPaidTheme();
	}
	
	/**
	 * 男士购买主题包
	 * @param womanId
	 * @param themeId
	 * @return
	 */
	public boolean ManFeeTheme(String womanId, String themeId){
		return mLCThemeManager.ManFeeTheme(womanId, themeId);
	}
	
	/**
	 * 男士应用主题包
	 * @param womanId
	 * @param themeId
	 * @return
	 */
	public boolean ManApplyTheme(String womanId, String themeId){
		return LiveChatClient.ManApplyTheme(womanId, themeId);
	}
	
	/**
	 * 男/女士播放主题包动画
	 * @param userId
	 * @param themeId
	 * @return
	 */
	public boolean PlayThemeMotion(String userId, String themeId){
		return LiveChatClient.PlayThemeMotion(userId, themeId);
	}
	
	@Override
	public void OnGetPaidTheme(LiveChatErrType errType, String errmsg,
                               String userId, LCPaidThemeInfo[] paidThemeList) {
		mCallbackHandler.OnGetPaidTheme(errType, errmsg, userId, paidThemeList);
	}

	@Override
	public void OnGetAllPaidTheme(LiveChatErrType errType, String errmsg,
                                  LCPaidThemeInfo[] paidThemeList) {
		mLCThemeManager.OnGetAllPaidTheme(paidThemeList);

		Message msg = Message.obtain();
		msg.what = LiveChatRequestOptType.GetAllPaidThemesDetail.ordinal();
		RequestBaseResponse response = new RequestBaseResponse(errType == LiveChatErrType.Success?true:false, "", errmsg, paidThemeList);
		msg.obj = response;
		mHandler.sendMessage(msg);
//		mCallbackHandler.OnGetAllPaidTheme(errType, errmsg, paidThemeList);		
	}

	@Override
	public void OnManFeeTheme(LiveChatErrType errType, String womanId, String themeId, String errmsg,
                              LCPaidThemeInfo paidThemeInfo) {
		if(AutoChargeManager.getInstatnce().isAutoCharging() &&
				errType == LiveChatErrType.NoMoney){
			//添加到待发送队列
			PayingThemeItem item = new PayingThemeItem(womanId, themeId);
			AutoChargeManager.getInstatnce().addToPendingThemeList(item);
			return;
		}
		mLCThemeManager.OnManFeeTheme(paidThemeInfo);
		mCallbackHandler.OnManFeeTheme(errType, womanId, themeId, errmsg, paidThemeInfo);
	}

	@Override
	public void OnManApplyTheme(LiveChatErrType errType, String womanId, String themeId, String errmsg,
                                LCPaidThemeInfo paidThemeInfo) {
		mLCThemeManager.OnManApplyTheme(paidThemeInfo);
		mCallbackHandler.OnManApplyTheme(errType, womanId, themeId, errmsg, paidThemeInfo);
	}

	@Override
	public void OnPlayThemeMotion(LiveChatErrType errType, String errmsg,
                                  String womanId, String themeId) {
		mCallbackHandler.OnPlayThemeMotion(errType, errmsg, womanId, themeId);
	}

	@Override
	public void OnRecvThemeMotion(String themeId, String manId, String womanId) {
		Log.i("LiveChatManager", "OnRecvThemeMotion themeId: " + themeId + "  womanId: " + womanId);
		mCallbackHandler.OnRecvThemeMotion(themeId, manId, womanId);
	}

	@Override
	public void OnRecvThemeRecommend(String themeId, String manId,
			String womanId) {
		Log.i("LiveChatManager", "OnRecvThemeRecommend themeId: " + themeId + "  womanId: " + womanId);
		mCallbackHandler.OnRecvThemeRecommend(themeId, manId, womanId);
	}
	
	/**
	 * 获取正对当前女士正在使用的主题
	 * @param womanId
	 * @return
	 */
	public LCPaidThemeInfo getCurrentUsedTheme(String womanId){
		return mLCThemeManager.getCurrentUsedTheme(womanId);
	}
	
	/**
	 * 删除指定女士的过期主题
	 * @param womanId
	 */
	public void removeOverTimeTheme(String womanId){
		mLCThemeManager.removeOverTimeTheme(womanId);
	}
	
	/**
	 * 指定女士指定主题是否购买中
	 * @param womanId
	 * @param themeId
	 * @return
	 */
	public boolean isThemeBuying(String womanId, String themeId){
		return mLCThemeManager.isThemeBuying(womanId, themeId);
	}
	
	/**
	 * 主题是否过期
	 * @param themeInfo
	 * @return
	 */
	public boolean isThemeExpired(LCPaidThemeInfo themeInfo){
		return mLCThemeManager.isThemeExpired(themeInfo);
	}
	
	/**
	 * 获取当前Theme状态，用于详情状态显示
	 * @param womanId
	 * @param themeId
	 * @return
	 */
	public ThemeStatus getThemeStatus(String womanId, String themeId){
		ThemeStatus status = ThemeStatus.NO_PAID;
		status = mLCThemeManager.getThemeStatus(womanId, themeId);
		return status;
	}
	
	/**
	 * 下载主题相关资源包
	 * @param themeId
	 */
	public boolean GetThemeResource(String themeId){
		boolean result = false;
		Log.i("LiveChatManager", "LiveChatManager GetThemeResource themeId: " + themeId);
		if(!TextUtils.isEmpty(themeId)){
			if(mLCThemeManager.isThemeSourceExist(themeId)){
				result = true;
				Log.i("LiveChatManager", "LiveChatManager GetThemeResource ThemeSource exist");
				mCallbackHandler.onThemeDownloadFinish(true, themeId, mLCThemeManager.getThemeSourceLocalPath(themeId));
			}else{
				result = mLCThemeManager.StartDownload(themeId);
			}
		}
		return result;
	}
	
	
	/**
	 * 获取指定主题下载进度
	 * @param themeId
	 * @return
	 */
	public int GetThemeDownloadProgress(String themeId){
		return mLCThemeManager.getThemeDownloadProgress(themeId);
	}
	
	/**
	 * 获取已购买的主题详情
	 */
	private void GetAllPaidThemesDetail(RequestBaseResponse response){
		LoginItem loginItem = LoginManager.getInstance().getLoginItem();
		if(response.isSuccess && loginItem != null){
			final LCPaidThemeInfo[] paidThemeList = (LCPaidThemeInfo[])response.body;
			if(paidThemeList != null && paidThemeList.length > 0){
				List<String> themeIdList = new ArrayList<String>();
				for(LCPaidThemeInfo info : paidThemeList){
					themeIdList.add(info.themeId);
				}
				ThemeConfigManager.newInstance().GetThemeDetail(themeIdList, loginItem.sessionId, loginItem.userId, new OnLCGetThemeDetailCallback() {
					
					@Override
					public void OnLCGetThemeDetail(boolean isSuccess, String errno,
							String errmsg, ThemeItem[] themeList) {
						mCallbackHandler.OnGetAllPaidTheme(isSuccess, errmsg, paidThemeList, themeList);
					}
				});
			}else{
				mCallbackHandler.OnGetAllPaidTheme(true, "", new LCPaidThemeInfo[0], new ThemeItem[0]);
			}
		}else{
			mCallbackHandler.OnGetAllPaidTheme(false, "", new LCPaidThemeInfo[0], new ThemeItem[0]);
		}
	}

	@Override
	public void onDownloadThemeStart(String themeId) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onDownloadThemeUpdating(String themeId, int progress) {
		mCallbackHandler.onThemeDownloadUpdate(themeId, progress);
	}

	@Override
	public void onDownloadThemeFinish(boolean isSuccess, String themeId, String sourceDir) {
		mCallbackHandler.onThemeDownloadFinish(isSuccess, themeId, sourceDir);
	}
	
	/********************************  livechat invite risk control  *********************************************/
	/**
	 * 读取邀请风控类型
	 * @return
	 */
	private LivechatInviteRiskType getLivechatInviteRiskType(){
		LivechatInviteRiskType riskType = LivechatInviteRiskType.UNLIMITED;
		LoginItem loginItem = LoginManager.getInstance().getLoginItem();
		if(loginItem != null){
			riskType = loginItem.livechatInvite;
		}
		return riskType;
	}
	
	/**
	 * 消息发送预处理
	 * @param item
	 */
	private void SendMessagePreprocess(LCMessageItem item){
		//添加消息到待发送列表
		item.getUserItem().addToSendMsgList(item);
		//获取对方支持功能列表
		mLCFunctionCheckManager.CheckFunctionSupported(item.getUserItem().userId);
	}
	
	/**
	 * 是否消息禁发
	 * @param userId
	 * @return
	 */
	public boolean isSendMessageLimited(String userId){
		boolean isLimited = false;
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if(userItem != null){
			LivechatInviteRiskType type = getLivechatInviteRiskType();
			if((type == LivechatInviteRiskType.SEND_LIMITED
					|| type == LivechatInviteRiskType.SEND_RECV_LIMITED)
					&& (userItem.chatType == ChatType.Other
					|| userItem.chatType == ChatType.ManInvite)){
				isLimited = true;
			}
		}
		return isLimited;
	}
	
	/**
	 * 邀请接收风控
	 * @return
	 */
	private boolean IsRecvMessageLimited(String userId){
		boolean isLimited = false;
		LCUserItem userItem = mUserMgr.getUserItem(userId);
		if(userItem != null){
			//邀请风控处理
			LivechatInviteRiskType type = getLivechatInviteRiskType();
			if((type == LivechatInviteRiskType.RECV_LIMITED
					|| type == LivechatInviteRiskType.SEND_RECV_LIMITED)
					&& (userItem.chatType == ChatType.Other
					|| userItem.chatType == ChatType.Invite)){
				isLimited = true;
			}
		}
		return isLimited;
	}
	
	/**
	 * 发送消息成功后，更新会话状态
	 * @param item
	 */
	private void OnSendMessageSessionProcess(LCMessageItem item){
		//发送消息成功，如果会话状态为默认状态，修改为男士邀请状态
		if(item != null){
			LCUserItem userItem = mUserMgr.getUserItem(item.getUserItem().userId);
			if(userItem != null){
				if(userItem.chatType == ChatType.Other
						|| userItem.chatType == ChatType.Invite){
					userItem.chatType = ChatType.ManInvite;
				}else if(userItem.chatType == ChatType.InChatPause){
					userItem.chatType = ChatType.InChatCharge;
				}
			}
		}
	}
	/********************************  livechat invite risk control end *********************************************/

	/********************************  livechat CamShare start *******************************************/
	
	/**
	 * 获取女士当前Cam状态
	 * @param womanId
	 */
	public boolean GetLadyCamStatus(String womanId){
		return LiveChatClient.GetLadyCamStatus(womanId);
	}
	
	@Override
	public void OnGetLadyCamStatus(LiveChatErrType errType, String errmsg,
                                   String womanId, boolean isCam) {
		//同步用户Cam状态
		LCUserItem userItem = GetUserWithId(womanId);
		userItem.updateCamstatus(isCam);
		
		mCallbackHandler.OnGetLadyCamStatus(errType, errmsg, womanId, isCam);
	}
	
	public boolean SendCamShareInvite(String userId, CamshareInviteType inviteType, int sessionId, String fromName){
		return LiveChatClient.SendCamShareInvite(userId, inviteType, sessionId, fromName);
	}

	@Override
	public void OnSendCamShareInvite(LiveChatErrType errType, String errmsg, String userId) {
		mCallbackHandler.OnSendCamShareInvite(errType, errmsg, userId);
	}
	
	/**
	 * 开启CamShare扣费，接入视频界面
	 * @param userId
	 */
	public boolean ApplyCamShare(String userId){
		return LiveChatClient.ApplyCamShare(userId);
	}

	@Override
	public void OnApplyCamShare(LiveChatErrType errType, String errmsg,
                                String userId, String inviteId) {
		if(errType == LiveChatErrType.Success){
			LCUserItem userItem = GetUserWithId(userId);
			userItem.inviteId = inviteId;
			userItem.chatType = ChatType.InChatCharge;
			userItem.serviceType = ChatServiceType.Camshare;
		}
		mCallbackHandler.OnApplyCamShare(errType, errmsg, userId, inviteId);
	}
	
	/**
	 * 批量获取CamShare状态
	 * @param userIds
	 */
	public boolean GetUsersCamStatus(String[] userIds){
		return LiveChatClient.GetUsersCamStatus(userIds);
	}
	
	/**
	 * CamShare扣费心跳处理
	 * @param userId
	 * @param inviteId
	 * @return
	 */
	public boolean CamShareHearbeat(String userId, String inviteId){
		return LiveChatClient.CamShareHearbeat(userId, inviteId);
	}

	@Override
	public void OnGetUsersCamStatus(LiveChatErrType errType, String errmsg,
                                    LiveChatUserCamStatus[] userIds) {
		if(userIds != null){
			for(LiveChatUserCamStatus userCamItem : userIds){
				LCUserItem userItem = GetUserWithId(userCamItem.userId);
				userItem.updateCamstatus(userCamItem.statusType == UserCamStatusType.USTATUS_CAM_ON?true:false);
			}
		}
		mCallbackHandler.OnGetUsersCamStatus(errType, errmsg, userIds);		
	}

	@Override
	public void OnRecvLadyCamStatus(String userId,
			UserStatusProtocol statuType, String server, ClientType ClientType,
			CamshareLadySoundType sound, String version) {
		//同步用户Cam状态
		LCUserItem userItem = GetUserWithId(userId);
		userItem.updateCamstatus(statuType == UserStatusProtocol.USTATUSPRO_CAMOPEN ? true:false);
		
		Log.i(TAG, "OnRecvLadyCamStatus userId: " + userId + " ~~~statuType: " + statuType.name());
		
		mCallbackHandler.OnRecvLadyCamStatus(userId, statuType);
	}

	@Override
	public void OnRecvAcceptCamInvite(String fromId, String toId, CamshareLadyInviteType inviteType, int sessionId, String fromName, boolean isCam) {
		mCallbackHandler.OnRecvAcceptCamInvite(fromId, toId, inviteType, sessionId, fromName, isCam);
	}
	
	@Override
	public void OnRecvCamHearbeatException(String errMsg, LiveChatErrType errType, String targetId){
		mCallbackHandler.OnRecvCamHearbeatException(errMsg, errType, targetId);
	}
	
	@Override
	public void OnCamshareUseTryTicket(LiveChatErrType errType,
			String errmsg, String userId, String ticketId, String inviteId) {
		if(errType == LiveChatErrType.Success){
			//使用试聊券启动会话成功,添加会话建立信息更新
			LCUserItem userItem = GetUserWithId(userId);
			userItem.inviteId = inviteId;
			userItem.chatType = ChatType.InChatCharge;
			userItem.serviceType = ChatServiceType.Camshare;
		}
		mCallbackHandler.OnCamshareUseTryTicket(errType, errmsg, userId, ticketId, inviteId);
	}
	
	//CamShare 业务接口
	/**
	 * 注册CamShare状态监视器
	 */
	public void registerCamShareStatusListener(OnLCCamShareClientListener listener){
		mLCCamShareManager.registerCamShareStatusListener(listener);
	}
	/**
	 * 注销CamShare状态监视器
	 */
	public void unRegisterCamShareStatusListener(OnLCCamShareClientListener listener){
		mLCCamShareManager.unRegisterCamShareStatusListener(listener);
	}
	
	/**
	 * 发起CamShare邀请
	 * @param targetId
	 * @return
	 */
	public void startCamShareInvite(String targetId, String targetName){
		mLCCamShareManager.startCamShareInvite(targetId, targetName);
	}
	
	/**
	 * 取消已发送CamShare邀请
	 * @param targetId
	 */
	public void cancelCamShareInvite(String targetId){
		mLCCamShareManager.cancelCamShareInvite(targetId);
	}
	
	/**
	 * 应邀
	 * @param targetId（非会话中，不走邀请逻辑）
	 */
	public void answerCamShareInvite(String targetId, String targetName){
		mLCCamShareManager.answerCamShareInvite(targetId, targetName);
	}
	
	/**
	 * 重新启动Camshare（会话中，不走邀请和使用试聊券逻辑）
	 * @param targetId
	 */
	public void restartCamshare(String targetId, String targetName){
		mLCCamShareManager.restartCamshareService(targetId, targetName);
	}
	
	/**
	 * 获取和指定用户的CamShare状态
	 * @param targetId
	 * @return
	 */
	public CamShareClientStatus getCamShareStatusById(String targetId){
		return mLCCamShareManager.getCamShareStatusById(targetId);
	} 
	
	/**
	 * 根据聊天对象ID获取会话Id
	 * @param targetId
	 * @return
	 */
	public String getCamshareInviteId(String targetId){
		return mLCCamShareManager.getInviteIdByUserId(targetId);
	}
	
	/**
	 * 已启动Camshare重新进入界面，只需绑定界面刷新就行
	 * @param target
	 * @param view
	 * @param viewWidth
	 * @param viewHeight
	 */
	public void bindStreamClient(String target, SurfaceView view, int viewWidth, int viewHeight){
		mLCCamShareManager.bindStreamClient(target, view, viewWidth, viewHeight);
	}
	
	/**
	 * 退出界面，解除绑定
	 * @param targetId
	 */
	public void clearStreamClientView(String targetId){
		mLCCamShareManager.clearStreamClientView(targetId);
	}
	
	/**
	 * 获取和指定用户的CamshareClient错误码
	 * @param targetId
	 * @return
	 */
	public CamShareClientErrorType getCamshareClientErrorNo(String targetId){
		return mLCCamShareManager.getCamshareClientErrorNo(targetId);
	}
	
	/**
	 * 停止当前会话
	 * @param targetId
	 */
	public void EndCamshareChat(String targetId){
		//先获取会话Id
		String inviteId = getCamshareInviteId(targetId);
		mLCCamShareManager.stopCamshare(targetId);
		LCUserItem useItem = GetUserWithId(targetId);
		if(TextUtils.isEmpty(inviteId)
				&& !TextUtils.isEmpty(useItem.inviteId)
				&& useItem.isInSession()){
			//解决重新登录在再聊列表无法根据本地缓存判断的情况
			inviteId = useItem.inviteId;
		}
		if(!TextUtils.isEmpty(inviteId)){
			useItem.clearSpecifiedMsgList(inviteId);
			//建立Camshare会话才需要Endchat
			EndTalk(targetId);
		}
	}

	/**
	 * 切换服务及注销时需要停掉所有Camshare服务
	 */
	public void EndAllCamshareChat(){
		//结束所有Camshare聊天
		List<String> userIds = mLCCamShareManager.getUsersInCamshare();
		for(String userId : userIds){
			EndCamshareChat(userId);
		}
		mLCCamShareManager.clearSendClient();//换站等需要重置发送端参数
	}
	
	/**
	 * 清除和指定用户，指定会话的消息列表
	 * @param targetId
	 * @param inviteId
	 */
	public void clearSpecifyMsgListByInviteId(String targetId, String inviteId){
		LCUserItem useItem = GetUserWithId(targetId);
		useItem.clearSpecifiedMsgList(inviteId);
	}
	
	/**
	 * 停止并清除所有LivechatCamshareClient，不结束会话
	 * @param targetId
	 */
	public void stopCamshareClient(String targetId){
		mLCCamShareManager.stopCamshare(targetId);
	}
	
	/**
	 * 是否在和某人使用Camshare服务(由于断线即失效，本地存储有效)
	 * @param targetId
	 * @return
	 */
	public boolean isInCamshareService(String targetId){
		return mLCCamShareManager.isInCamshareService(targetId);
	}
	
	/**
	 * Camshare 服务使用中
	 * @return
	 */
	public boolean isCamshareServiceUsed(){
		return mLCCamShareManager.isCamshareServiceUsed();
	}
	
	/**
	 * 获取CamShare中女士Id列表
	 * @return
	 */
	public List<String> getUsersInCamshare(){
		return mLCCamShareManager.getUsersInCamshare();
	}
	
	/**
	 * 获取正在Camshare中女士名称，用于界面显示(由于单用户取第一个就可以)
	 * @return
	 */
	public String getUserNameInCamshareService(){
		return mLCCamShareManager.getUserNameInCamshareService();
	}
	
	/**
	 * 获取对指定女士使用的试聊券Item（未使用时为null）
	 * @param targetId
	 * @return
	 */
	public Coupon GetCamshareCouponItem(String targetId){
		return mLCCamShareManager.GetCouponItem(targetId);
	}
	
	/**
	 * 开始捕捉视频流
	 * @param holder
	 */
	public void sendClientStartCapture(SurfaceHolder holder){
		mLCCamShareManager.sendClientStartCapture(holder);
	}
	
	/**
	 * 停止捕捉视频流
	 */
	public void sendClientStopCapture(){
		mLCCamShareManager.sendClientStopCapture();
	}
	
	/**
	 * Camshare 服务前后台切换
	 * @param targetId
	 * @param isBackgroud true：切换到后台  false： 切换到前台
	 */
	public void switchCamshareServiceToBackgroud(String targetId, boolean isBackgroud){
		mLCCamShareManager.updateCamshareServiceBackgroud(targetId, isBackgroud);
	}
	
	/**
	 * 判断SendClient是否正在上传中
	 * @return
	 */
	public boolean isSendClientRunning(){
		return mLCCamShareManager.isSendClientRunning();
	}

	/********************************  livechat CamShare end *********************************************/
	
	/********************************  livechat 状态定期更新 *************************************************/
	private static final int MINI_SESSION_UPDATE_DURATION = 5 * 60 * 1000;//会话更新周期最短5分钟一次
	Runnable chatStatusUpdate = new Runnable() {
		
		@Override
		public void run() {
			List<LCUserItem> chatingList = GetChatingUsers();
			if(chatingList != null){
				for(LCUserItem item : chatingList){
					GetSessionInfo(item.userId);
				}
			}
			mHandler.postDelayed(chatStatusUpdate, MINI_SESSION_UPDATE_DURATION);
		}
	};
	
	/**
	 * 开始刷新再聊列表会话状态
	 */
	private void startChatStatusUpdate(){
		mHandler.postDelayed(chatStatusUpdate, MINI_SESSION_UPDATE_DURATION);
	}
	
	/**
	 * 注销等发生时，停止刷新聊天会话状态
	 */
	private void stopChatStatusUpdate(){
		mHandler.removeCallbacks(chatStatusUpdate);
	}
	/********************************  livechat 状态定期更新 end*************************************************/

	/********************************  livechat 提供外部方法 start *************************************************/

	/**
	 * 是否信用点不足
	 * @param errno
	 * @return true:信用点不足
	 */
	public boolean isNoCredits(String errno){
		if (!TextUtils.isEmpty(errno) && (errno.equals("ERROR00003") || errno.equals("17302"))) {
			//no money failed
			return true;
		}

		return false;
	}

	/********************************  livechat 提供外部方法 end *************************************************/
}
