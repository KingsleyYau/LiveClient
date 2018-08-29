package com.qpidnetwork.anchor.httprequest;

import android.content.Context;
import android.os.Handler;
import android.os.Message;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.httprequest.item.AnchorHangoutGiftListItem;
import com.qpidnetwork.anchor.httprequest.item.AnchorHangoutItem;
import com.qpidnetwork.anchor.httprequest.item.AnchorInfoItem;
import com.qpidnetwork.anchor.httprequest.item.AnchorKnockType;
import com.qpidnetwork.anchor.httprequest.item.AudienceBaseInfoItem;
import com.qpidnetwork.anchor.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.anchor.httprequest.item.BookInviteItem;
import com.qpidnetwork.anchor.httprequest.item.EmotionCategory;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.GiftLimitNumItem;
import com.qpidnetwork.anchor.httprequest.item.HangoutInviteReplyType;
import com.qpidnetwork.anchor.httprequest.item.HttpLccErrType;
import com.qpidnetwork.anchor.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.anchor.httprequest.item.LoginItem;
import com.qpidnetwork.anchor.httprequest.item.ProgramInfoItem;
import com.qpidnetwork.anchor.httprequest.item.SetAutoPushType;
import com.qpidnetwork.anchor.httprequest.item.TalentReplyType;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.authorization.interfaces.IAuthorizationListener;
import com.qpidnetwork.anchor.liveshow.model.http.HttpRespObject;

/**
 * Created by Hunter on 17/9/21.
 */

public class LiveRequestOperator {

    private Handler mHandler = null;
    private static LiveRequestOperator gRequestOperate;
    private Context mContext;

    /***
     * 单例初始化
     * @param context
     * @return
     */
    public static LiveRequestOperator newInstance(Context context){
        if(gRequestOperate == null){
            gRequestOperate = new LiveRequestOperator(context);
        }
        return gRequestOperate;
    }

    public static LiveRequestOperator getInstance(){
        return gRequestOperate;
    }

    private LiveRequestOperator(Context context){
        mContext = context;
        mHandler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                HttpRespObject response = (HttpRespObject)msg.obj;
                HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(response.errCode);
                switch (errType){
                    case HTTP_LCC_ERR_TOKEN_EXPIRE:
                    case HTTP_LCC_ERR_NO_LOGIN:{
                        LoginManager.getInstance().onKickedOff(mContext.getResources().getString(R.string.session_timeout_kick_off_tips));
                    }break;
                }
//                if(response.isSuccess){
//                    LoginManager.getInstance().removeListener((IAuthorizationListener)response.data);
//                }else{
//                    HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(response.errCode);
//                    switch (errType){
//                        case HTTP_LCC_ERR_TOKEN_EXPIRE:
//                        case HTTP_LCC_ERR_NO_LOGIN:{
//                            //sesssion 过期
//                            LoginManager.getInstance().addListener((IAuthorizationListener)response.data);
////                            LoginManager.getInstance().onModuleSessionOverTime();
//                        }break;
//                        default:{
//                            LoginManager.getInstance().removeListener((IAuthorizationListener)response.data);
//                        }break;
//                    }
//                }
            }
        };
    }


    /**
     * 错误公共处理
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param callback
     * @return
     */
    private boolean HandleRequestCallback(boolean isSuccess, int errCode, String errMsg, IAuthorizationListener callback){
        //判断错误码是否需要拦截
        boolean bFlag = false;
        HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(errCode);
        if(!isSuccess){
            switch (errType){
                case HTTP_LCC_ERR_TOKEN_EXPIRE:
                case HTTP_LCC_ERR_NO_LOGIN:{
                    bFlag = false;
                }break;
            }
        }

        //切换线程处理拦截任务
        Message msg = Message.obtain();
        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, callback);
        msg.obj = response;
        mHandler.sendMessage(msg);

        return bFlag;
    }

    /**************************************  模块处理 Authorization ********************************************/

    /**
     * 2.3.上传push tokenId
     * @param pushTokenId
     * @param callback
     * @return
     */
    public long UploadPushTokenId(final String pushTokenId, final OnRequestCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniAuthorization.UploadPushTokenId(pushTokenId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequestJniAuthorization.UploadPushTokenId(pushTokenId, new OnRequestCallback() {

                    @Override
                    public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                        // 公共处理VerifySms
                        boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                        if (bFlag) {
                            // 已经匹配处理, 等待回调
                        } else {
                            // 没有匹配处理, 直接回调
                            callback.onRequest(isSuccess, errCode, errMsg);
                        }
                    }
                });
    }

    /**
     * 3.1.获取直播间观众头像列表
     * @param roomId
     * @param start
     * @param step
     * @param callback
     * @return
     */
    public long GetAudienceListInRoom(final String roomId, final int start, final int step, final OnGetAudienceListCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniLiveShow.GetAudienceListInRoom(roomId, start, step, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetAudienceList(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetAudienceListInRoom(roomId, start, step, new OnGetAudienceListCallback() {

            @Override
            public void onGetAudienceList(boolean isSuccess, int errCode, String errMsg, AudienceInfoItem[] audienceList) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetAudienceList(isSuccess, errCode, errMsg, audienceList);
                }
            }
        });
    }

    /**
     * 3.2.获取指定观众信息
     * @param userId
     * @param callback
     * @return
     */
    public long GetAudienceDetailInfo(final String userId, final OnGetAudienceDetailInfoCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniLiveShow.GetAudienceDetailInfo(userId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetAudienceDetailInfo(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetAudienceDetailInfo(userId, new OnGetAudienceDetailInfoCallback() {

            @Override
            public void onGetAudienceDetailInfo(boolean isSuccess, int errCode, String errMsg, AudienceBaseInfoItem audienceInfo) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetAudienceDetailInfo(isSuccess, errCode, errMsg, audienceInfo);
                }
            }
        });
    }

    /**
     * 3.3. 获取礼物列表
     * @param callback
     * @return
     */
    public long GetAllGiftList(final OnGetGiftListCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {
            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniLiveShow.GetAllGiftList(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetGiftList(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetAllGiftList(new OnGetGiftListCallback() {

            @Override
            public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetGiftList(isSuccess, errCode, errMsg, giftList);
                }
            }
        });
    }

    /**
     * 3.4. 获取主播直播间礼物列表
     * @param roomId
     * @param callback
     * @return
     */
    public long GiftLimitNumList(final String roomId, final OnGiftLimitNumListCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniLiveShow.GiftLimitNumList(roomId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGiftLimitNumList(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GiftLimitNumList(roomId, new OnGiftLimitNumListCallback() {

            @Override
            public void onGiftLimitNumList(boolean isSuccess, int errCode, String errMsg, GiftLimitNumItem[] giftList) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGiftLimitNumList(isSuccess, errCode, errMsg, giftList);
                }
            }
        });
    }

    /**
     * 3.5. 获取指定礼物详情
     * @param giftId
     * @param callback
     * @return
     */
    public long GetGiftDetail(final String giftId, final OnGetGiftDetailCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniLiveShow.GetGiftDetail(giftId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetGiftDetail(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetGiftDetail(giftId, new OnGetGiftDetailCallback() {

            @Override
            public void onGetGiftDetail(boolean isSuccess, int errCode, String errMsg, GiftItem giftDetail) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetGiftDetail(isSuccess, errCode, errMsg, giftDetail);
                }
            }
        });
    }

    /**
     * 3.6.获取文本表情列表
     * @param callback
     * @return
     */
    public long GetEmotionList(final OnGetEmotionListCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniLiveShow.GetEmotionList(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetEmotionList(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetEmotionList(new OnGetEmotionListCallback() {

            @Override
            public void onGetEmotionList(boolean isSuccess, int errCode, String errMsg, EmotionCategory[] emotionCategoryList) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetEmotionList(isSuccess, errCode, errMsg, emotionCategoryList);
                }
            }
        });
    }

    /**
     * 3.7.主播回复才艺点播邀请
     * @param talentInviteId
     * @param status
     * @param callback
     * @return
     */
    public long DealTalentRequest(final String talentInviteId, final TalentReplyType status, final OnRequestCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniLiveShow.DealTalentRequest(talentInviteId, status, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.DealTalentRequest(talentInviteId, status, new OnRequestCallback() {

            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        });
    }

    /**
     * 3.8.设置主播公开直播间自动邀请状态
     * @param status
     * @param callback
     * @return
     */
    public long SetAutoPush(final SetAutoPushType status, final OnRequestCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniLiveShow.SetAutoPush(status, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.SetAutoPush(status, new OnRequestCallback() {

            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        });
    }

    /**
     * 4.1.获取预约邀请列表
     * @param type
     * @param start
     * @param step
     * @param callback
     * @return
     */
    public long GetScheduleInviteList(final RequstJniSchedule.ScheduleInviteType type, final int start, final int step, final OnGetScheduleInviteListCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequstJniSchedule.GetScheduleInviteList(type, start, step, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetScheduleInviteList(isSuccess, errCode, errMsg, 0, null);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.GetScheduleInviteList(type, start, step, new OnGetScheduleInviteListCallback() {

            @Override
            public void onGetScheduleInviteList(boolean isSuccess, int errCode, String errMsg, int totel, BookInviteItem[] bookInviteList) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetScheduleInviteList(isSuccess, errCode, errMsg, totel, bookInviteList);
                }
            }
        });
    }

    /**
     * 4.2.主播接受预约邀请
     * @param invitationId
     * @param callback
     * @return
     */
    public long AcceptScheduledInvite(final String invitationId, final OnRequestCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequstJniSchedule.AcceptScheduledInvite(invitationId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.AcceptScheduledInvite(invitationId, new OnRequestCallback() {

            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        });
    }

    /**
     * 4.3.主播拒绝预约邀请
     * @param invitationId
     * @param callback
     * @return
     */
    public long RejectScheduledInvite(final String invitationId, final OnRequestCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequstJniSchedule.RejectScheduledInvite(invitationId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.RejectScheduledInvite(invitationId, new OnRequestCallback() {

            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        });
    }

    /**
     * 4.4.获取预约邀请未读或待处理数量
     * @param callback
     * @return
     */
    public long GetCountOfUnreadAndPendingInvite(final OnGetCountOfUnreadAndPendingInviteCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequstJniSchedule.GetCountOfUnreadAndPendingInvite(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetCountOfUnreadAndPendingInvite(isSuccess, errCode, errMsg, 0, 0, 0, 0);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.GetCountOfUnreadAndPendingInvite(new OnGetCountOfUnreadAndPendingInviteCallback() {

            @Override
            public void onGetCountOfUnreadAndPendingInvite(boolean isSuccess, int errCode, String errMsg, int total, int pendingNum, int confirmedUnreadCount, int otherUnreadCount) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetCountOfUnreadAndPendingInvite(isSuccess, errCode, errMsg, total, pendingNum, confirmedUnreadCount, otherUnreadCount);
                }
            }
        });
    }

    /**
     * 4.5.获取已确认的预约数
     * @param callback
     * @return
     */
    public long GetScheduledAcceptNum(final OnGetScheduledAcceptNumCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequstJniSchedule.GetScheduledAcceptNum(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetScheduledAcceptNum(isSuccess, errCode, errMsg, 0);
                }
            }
        };

//        RequestJniProgram.GetProgramList(RequestJniProgram.ProgramSortType.UnVerify, 0, 3, new OnGetProgramListCallback() {
//            @Override
//            public void onGetProgramList(boolean isSuccess, int errCode, String errMsg, ProgramInfoItem[] list) {
//                int i = 0;
//            }
//        });
//
//        RequestJniProgram.GetNoReadNumProgram(new OnGetNoReadNumProgramCallback() {
//            @Override
//            public void onGetNoReadNumProgram(boolean isSuccess, int errCode, String errMsg, int Num) {
//                int i = 0;
//            }
//        });

//        RequestJniProgram.GetShowRoomInfo("11", new OnGetShowRoomInfoCallback() {
//            @Override
//            public void onGetShowRoomInfo(boolean isSuccess, int errCode, String errMsg, ProgramInfoItem item, String roomId) {
//                int i = 0;
//            }
//        });

        RequestJniProgram.CheckPublicRoomType(new OnCheckPublicRoomTypeCallback() {
            @Override
            public void onCheckPublicRoomType(boolean isSuccess, int errCode, String errMsg, int liveShowType, String liveShowId) {
                int i = 0;
            }
        });

        // 调用jni接口
        return RequstJniSchedule.GetScheduledAcceptNum(new OnGetScheduledAcceptNumCallback() {

            @Override
            public void onGetScheduledAcceptNum(boolean isSuccess, int errCode, String errMsg, int scheduledNum) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetScheduledAcceptNum(isSuccess, errCode, errMsg, scheduledNum);
                }
            }
        });
    }

    /**
     * 4.6.主播接受立即私密邀请
     * @param inviteId
     * @param callback
     * @return
     */
    public long AcceptInstanceInvite(final String inviteId, final OnAcceptInstanceInviteCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequstJniSchedule.AcceptInstanceInvite(inviteId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onAcceptInstanceInvite(isSuccess, errCode, errMsg, "", 0);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.AcceptInstanceInvite(inviteId, new OnAcceptInstanceInviteCallback() {

            @Override
            public void onAcceptInstanceInvite(boolean isSuccess, int errCode, String errMsg, String roomId, int roomType) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onAcceptInstanceInvite(isSuccess, errCode, errMsg, roomId, roomType);
                }
            }
        });
    }

    /**
     * 4.7.主播拒绝立即私密邀请
     * @param inviteId
     * @param rejectReason
     * @param callback
     * @return
     */
    public long RejectInstanceInvite(final String inviteId, final String rejectReason, final OnRequestCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequstJniSchedule.RejectInstanceInvite(inviteId, rejectReason, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.RejectInstanceInvite(inviteId, rejectReason, new OnRequestCallback() {

            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        });
    }

    /**
     * 4.8.主播取消已发的立即私密邀请
     * @param inviteId
     * @param callback
     * @return
     */
    public long CancelInstantInvite(final String inviteId, final OnRequestCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequstJniSchedule.CancelInstantInvite(inviteId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.CancelInstantInvite(inviteId, new OnRequestCallback() {

            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        });
    }

    /**
     * 4.9.设置直播间为开始倒数
     * @param roomId
     * @param callback
     * @return
     */
    public long SetRoomCountDown(final String roomId, final OnRequestCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequstJniSchedule.SetRoomCountDown(roomId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.SetRoomCountDown(roomId, new OnRequestCallback() {

            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        });
    }

    /**
     * 5.2.获取收入信息
     * @param callback
     * @return
     */
    public long GetTodayCredit(final OnGetTodayCreditCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniOther.GetTodayCredit(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetTodayCredit(isSuccess, errCode, errMsg, 0, 0, 0, 0);
                }
            }
        };
        // 调用jni接口
        return RequestJniOther.GetTodayCredit(new OnGetTodayCreditCallback() {

            @Override
            public void onGetTodayCredit(boolean isSuccess, int errCode, String errMsg, int monthCredit, int monthCompleted, int monthTarget, int monthProgres) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetTodayCredit(isSuccess, errCode, errMsg, monthCredit, monthCompleted, monthTarget, monthProgres);
                }
            }
        });
    }

    /**
     * 5.3.提交流媒体服务器测速结果
     * @param sid      	流媒体服务器ID
     * @param res     	http请求完成时间（毫秒）
     * @param callback
     * @return
     */
    public long ServerSpeed(final String sid, final int res, final OnRequestCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniOther.ServerSpeed(sid, res, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequestJniOther.ServerSpeed(sid, res, new OnRequestCallback() {

            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        });
    }

    /**
     * 6.1.获取可推荐的好友列表
     * @param start
     * @param step
     * @param callback
     * @return
     */
    public long GetCanRecommendFriendList(final int start, final int step, final OnGetAnchorListCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniHangout.GetCanRecommendFriendList(start, step, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetAnchorList(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniHangout.GetCanRecommendFriendList(start, step, new OnGetAnchorListCallback() {

            @Override
            public void onGetAnchorList(boolean isSuccess, int errCode, String errMsg, AnchorInfoItem[] anchorList) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetAnchorList(isSuccess, errCode, errMsg, anchorList);
                }
            }
        });
    }

    /**
     * 6.2.主播推荐好友给观众
     * @param friendId
     * @param roomId
     * @param callback
     * @return
     */
    public long RecommendFriendJoinHangout(final String friendId, final String roomId, final OnRecommendFriendCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniHangout.RecommendFriendJoinHangout(friendId, roomId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRecommendFriend(isSuccess, errCode, errMsg, "");
                }
            }
        };
        // 调用jni接口
        return RequestJniHangout.RecommendFriendJoinHangout(friendId, roomId, new OnRecommendFriendCallback() {

            @Override
            public void onRecommendFriend(boolean isSuccess, int errCode, String errMsg, String recommendId) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onRecommendFriend(isSuccess, errCode, errMsg, recommendId);
                }
            }
        });
    }


    /**
     * 6.3.主播回复多人互动邀请
     * @param inviteId		多人互动邀请ID
     * @param type			回复结果（AGREE：接受，REJECT：拒绝）
     * @param callback
     * @return
     */
    public long DealInvitationHangout(final String inviteId, final HangoutInviteReplyType type, final OnDealInvitationHangoutCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(final boolean isSuccess, final int errCode, final String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniHangout.DealInvitationHangout(inviteId, type, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onDealInvitationHangout(isSuccess, errCode, errMsg,null);
                }
            }
        };
        // 调用jni接口
        return RequestJniHangout.DealInvitationHangout(inviteId, type, new OnDealInvitationHangoutCallback() {

            @Override
            public void onDealInvitationHangout(boolean isSuccess, int errCode, String errMsg, String roomId) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onDealInvitationHangout(isSuccess, errCode, errMsg,roomId);
                }
            }
        });
    }

    /**
     * 6.4.获取未结束的多人互动直播间列表
     * @param start
     * @param step
     * @param callback
     * @return
     */
    public long GetOngoingHangoutList(final int start, final int step, final OnGetOngoingHangoutCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(final boolean isSuccess, final int errCode, final String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniHangout.GetOngoingHangoutList(start, step, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetOngoingHangout(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniHangout.GetOngoingHangoutList(start, step, new OnGetOngoingHangoutCallback() {

            @Override
            public void onGetOngoingHangout(boolean isSuccess, int errCode, String errMsg, AnchorHangoutItem[] anchorList) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetOngoingHangout(isSuccess, errCode, errMsg, anchorList);
                }
            }
        });
    }

    /**
     * 6.5. 发起敲门请求
     * @param roomId
     * @param callback
     * @return
     */
    public long SendKnockRequest(final String roomId, final OnSendKnockRequestCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(final boolean isSuccess, final int errCode, final String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniHangout.SendKnockRequest(roomId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onSendKnockRequest(isSuccess, errCode, errMsg, "", 0);
                }
            }
        };
        // 调用jni接口
        return RequestJniHangout.SendKnockRequest(roomId, new OnSendKnockRequestCallback() {

            @Override
            public void onSendKnockRequest(boolean isSuccess, int errCode, String errMsg, String knockId, int expire) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onSendKnockRequest(isSuccess, errCode, errMsg, knockId, expire);
                }
            }
        });
    }

    /**
     * 6.6.获取敲门状态
     * @param knockId
     * @param callback
     * @return
     */
    public long GetHangoutKnockStatus(final String knockId, final OnGetHangoutKnockStatusCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(final boolean isSuccess, final int errCode, final String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniHangout.GetHangoutKnockStatus(knockId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetHangoutKnockStatus(isSuccess, errCode, errMsg, "", AnchorKnockType.Unknown.ordinal(), 0);
                }
            }
        };
        // 调用jni接口
        return RequestJniHangout.GetHangoutKnockStatus(knockId, new OnGetHangoutKnockStatusCallback() {

            @Override
            public void onGetHangoutKnockStatus(boolean isSuccess, int errCode, String errMsg, String roomId, int status, int expire) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetHangoutKnockStatus(isSuccess, errCode, errMsg, roomId, status, expire);
                }
            }
        });
    }

    /**
     * 6.7.取消敲门请求
     * @param knockId
     * @param callback
     * @return
     */
    public long CancelHangoutKnock(final String knockId, final OnRequestCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(final boolean isSuccess, final int errCode, final String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniHangout.CancelHangoutKnock(knockId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequestJniHangout.CancelHangoutKnock(knockId, new OnRequestCallback() {

            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        });
    }

    /**
     * 6.8.获取多人互动直播间礼物列表
     * @param roomId		多人互动直播间ID
     * @param callback
     * @return
     */
    public long GetHangoutGiftList(final String roomId, final OnHangoutGiftListCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniHangout.HangoutGiftList(roomId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onHangoutGiftList(isSuccess, errCode, errMsg,null);
                }
            }
        };
        // 调用jni接口
        return RequestJniHangout.HangoutGiftList(roomId, new OnHangoutGiftListCallback() {

            @Override
            public void onHangoutGiftList(boolean isSuccess, int errCode, String errMsg, AnchorHangoutGiftListItem giftItem) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onHangoutGiftList(isSuccess, errCode, errMsg, giftItem);
                }
            }
        });
    }

    /**
     * 6.9.请求添加好友
     * @param userId		主播ID
     * @param callback
     * @return
     */
    public long AddAnchorFriend(final String userId, final OnRequestCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(final boolean isSuccess, final int errCode, final String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniHangout.AddAnchorFriend(userId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequestJniHangout.AddAnchorFriend(userId, new OnRequestCallback() {

            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        });
    }

    /**
     * 6.10.获取好友关系信息
     * @param anchorId		主播ID
     * @param callback
     * @return
     */
    public long GetHangoutFriendRelation(final String anchorId, final OnGetHangoutFriendRelationCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(final boolean isSuccess, final int errCode, final String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniHangout.GetHangoutFriendRelation(anchorId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetHangoutFriendRelation(isSuccess, errCode, errMsg,null);
                }
            }
        };
        // 调用jni接口
        return RequestJniHangout.GetHangoutFriendRelation(anchorId, new OnGetHangoutFriendRelationCallback() {

            @Override
            public void onGetHangoutFriendRelation(boolean isSuccess, int errCode, String errMsg, AnchorInfoItem item) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetHangoutFriendRelation(isSuccess, errCode, errMsg,item);
                }
            }
        });
    }


    /**
     * 7.1.获取节目列表
     * @param type
     * @param start
     * @param step
     * @param callback
     * @return
     */
    public long GetProgramList(final RequestJniProgram.ProgramSortType type, final int start, final int step, final OnGetProgramListCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniProgram.GetProgramList(type, start, step, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetProgramList(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniProgram.GetProgramList(type, start, step, new OnGetProgramListCallback() {

            @Override
            public void onGetProgramList (boolean isSuccess, int errCode, String errMsg, ProgramInfoItem[] list) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetProgramList(isSuccess, errCode, errMsg, list);
                }
            }
        });
    }

    /**
     * 7.2.获取节目未读数(用于观众端向服务器获取节目未读数，已购或已关注的开播中节目数 + 退票未读数)
     * @param callback
     * @return
     */
    public long GetNoReadNumProgram(final OnGetNoReadNumProgramCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniProgram.GetNoReadNumProgram(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetNoReadNumProgram(isSuccess, errCode, errMsg, 0);
                }
            }
        };
        // 调用jni接口
        return RequestJniProgram.GetNoReadNumProgram(new OnGetNoReadNumProgramCallback() {

            @Override
            public void onGetNoReadNumProgram(boolean isSuccess, int errCode, String errMsg, int Num) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetNoReadNumProgram(isSuccess, errCode, errMsg, Num);
                }
            }
        });
    }

    /**
     * 7.3.获取可进入的节目信息(用于主播端向服务器获取节目未读数，包括节目未读数量<审核通过/取消> + 已开播数量)
     * @param liveShowId
     * @param callback
     * @return
     */
    public long GetShowRoomInfo(final String liveShowId, final OnGetShowRoomInfoCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniProgram.GetShowRoomInfo(liveShowId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetShowRoomInfo(isSuccess, errCode, errMsg, null, "");
                }
            }
        };
        // 调用jni接口
        return RequestJniProgram.GetShowRoomInfo(liveShowId, new OnGetShowRoomInfoCallback() {

            @Override
            public void onGetShowRoomInfo(boolean isSuccess, int errCode, String errMsg, ProgramInfoItem item, String roomId) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetShowRoomInfo(isSuccess, errCode, errMsg, item, roomId);
                }
            }
        });
    }

    /**
     * 7.4.检测公开直播开播类型
     * @param callback
     * @return
     */
    public long CheckPublicRoomType(final OnCheckPublicRoomTypeCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {


            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    RequestJniProgram.CheckPublicRoomType(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onCheckPublicRoomType(isSuccess, errCode, errMsg, 0, "");
                }
            }
        };
        // 调用jni接口
        return RequestJniProgram.CheckPublicRoomType(new OnCheckPublicRoomTypeCallback() {

            @Override
            public void onCheckPublicRoomType(boolean isSuccess, int errCode, String errMsg, int liveShowType, String liveShowId) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onCheckPublicRoomType(isSuccess, errCode, errMsg, liveShowType, liveShowId);
                }
            }
        });
    }
}
