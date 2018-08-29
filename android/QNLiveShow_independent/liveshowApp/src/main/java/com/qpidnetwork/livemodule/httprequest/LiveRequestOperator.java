package com.qpidnetwork.livemodule.httprequest;

import android.content.Context;
import android.os.Handler;
import android.os.Message;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AudienceBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.BookInviteItem;
import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory;
import com.qpidnetwork.livemodule.httprequest.item.FollowingListItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.ImmediateInviteItem;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.RideItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteConfig;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.TalentInviteItem;
import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.ValidLiveRoomItem;
import com.qpidnetwork.livemodule.httprequest.item.VoucherItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;

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
     * 3.1.分页获取热播列表
     * @param start
     * @param step
     * @param hasWatch
     * @param callback
     * @return
     */
    public long GetHotLiveList(final int start, final int step, final boolean hasWatch, final boolean isForTest, final OnGetHotListCallback callback) {
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
                    RequestJniLiveShow.GetHotLiveList(start, step, hasWatch, isForTest, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetHotList(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetHotLiveList(start, step, hasWatch, isForTest, new OnGetHotListCallback() {

            @Override
            public void onGetHotList(boolean isSuccess, int errCode, String errMsg, HotListItem[] hotList) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetHotList(isSuccess, errCode, errMsg, hotList);
                }
            }
        });
    }


    /**
     * 3.2.分页获取收藏主播当前开播列表
     * @param start
     * @param step
     * @param callback
     * @return
     */
    public long GetFollowingLiveList(final int start, final int step, final OnGetFollowingListCallback callback) {
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
                    RequestJniLiveShow.GetFollowingLiveList(start, step, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetFollowingList(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetFollowingLiveList(start, step, new OnGetFollowingListCallback() {

            @Override
            public void onGetFollowingList(boolean isSuccess, int errCode, String errMsg, FollowingListItem[] followingList) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetFollowingList(isSuccess, errCode, errMsg, followingList);
                }
            }
        });
    }

    /**
     * 3.3.获取本人有效直播间或邀请信息
     * @param callback
     * @return
     */
    public long GetLivingRoomAndInvites(final OnGetLivingRoomAndInvitesCallback callback) {
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
                    RequestJniLiveShow.GetLivingRoomAndInvites(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetLivingRoomAndInvites(isSuccess, errCode, errMsg, null, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetLivingRoomAndInvites(new OnGetLivingRoomAndInvitesCallback() {

            @Override
            public void onGetLivingRoomAndInvites(boolean isSuccess, int errCode, String errMsg, ValidLiveRoomItem[] roomList, ImmediateInviteItem[] inviteList) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetLivingRoomAndInvites(isSuccess, errCode, errMsg, roomList, inviteList);
                }
            }
        });
    }

    /**
     * 3.4.获取直播间观众头像列表
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
     * 3.5. 获取礼物列表
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
     * 3.6. 获取直播间可发送的礼物列表
     * @param roomId
     * @param callback
     * @return
     */
    public long GetSendableGiftList(final String roomId, final OnGetSendableGiftListCallback callback) {
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
                    RequestJniLiveShow.GetSendableGiftList(roomId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetSendableGiftList(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetSendableGiftList(roomId, new OnGetSendableGiftListCallback() {

            @Override
            public void onGetSendableGiftList(boolean isSuccess, int errCode, String errMsg, SendableGiftItem[] giftIds) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetSendableGiftList(isSuccess, errCode, errMsg, giftIds);
                }
            }
        });
    }

    /**
     * 3.7. 获取指定礼物详情
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
     * 3.8.获取文本表情列表
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
     * 3.9.获取指定立即私密邀请信息
     * @param invitationId
     * @param callback
     * @return
     */
    public long GetImediateInviteInfo(final String invitationId, final OnGetImediateInviteInfoCallback callback) {
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
                    RequestJniLiveShow.GetImediateInviteInfo(invitationId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetImediateInviteInfo(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetImediateInviteInfo(invitationId, new OnGetImediateInviteInfoCallback() {

            @Override
            public void onGetImediateInviteInfo(boolean isSuccess, int errCode, String errMsg, ImmediateInviteItem inviteInfo) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetImediateInviteInfo(isSuccess, errCode, errMsg, inviteInfo);
                }
            }
        });
    }

    /**
     * 3.10.获取才艺点播列表
     * @param roomId
     * @param callback
     * @return
     */
    public long GetTalentList(final String roomId, final OnGetTalentListCallback callback) {
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
                    RequestJniLiveShow.GetTalentList(roomId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetTalentList(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetTalentList(roomId, new OnGetTalentListCallback() {

            @Override
            public void onGetTalentList(boolean isSuccess, int errCode, String errMsg, TalentInfoItem[] talentList) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetTalentList(isSuccess, errCode, errMsg, talentList);
                }
            }
        });
    }

    /**
     * 3.11.获取才艺点播邀请状态
     * @param roomId
     * @param talentInviteId
     * @param callback
     * @return
     */
    public long GetTalentInviteStatus(final String roomId, final String talentInviteId, final OnGetTalentInviteStatusCallback callback) {
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
                    RequestJniLiveShow.GetTalentInviteStatus(roomId, talentInviteId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetTalentInviteStatus(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetTalentInviteStatus(roomId, talentInviteId, new OnGetTalentInviteStatusCallback() {

            @Override
            public void onGetTalentInviteStatus(boolean isSuccess, int errCode, String errMsg, TalentInviteItem inviteItem) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetTalentInviteStatus(isSuccess, errCode, errMsg, inviteItem);
                }
            }
        });
    }

    /**
     * 3.12.获取指定观众信息
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
     * 3.13.观众开始/结束视频互动
     * @param roomId
     * @param operateType
     * @param callback
     * @return
     */
    public long StartOrStopVideoInteractive(final String roomId, final RequestJniLiveShow.VideoInteractiveOperateType operateType, final OnStartOrStopVideoInteractiveCallback callback) {
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
                    RequestJniLiveShow.StartOrStopVideoInteractive(roomId, operateType, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onStartOrStopVideoInteractive(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.StartOrStopVideoInteractive(roomId, operateType, new OnStartOrStopVideoInteractiveCallback() {

            @Override
            public void onStartOrStopVideoInteractive(boolean isSuccess, int errCode, String errMsg, String[] uploadUrls) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onStartOrStopVideoInteractive(isSuccess, errCode, errMsg, uploadUrls);
                }
            }
        });
    }

    /**
     * 3.14.获取推荐主播列表
     * @param number
     * @param userId
     * @param callback
     * @return
     */
    public long GetPromoAnchorList(final int number, final RequestJniLiveShow.PromotionCategoryType type, final String userId, final OnGetPromoAnchorListCallback callback) {
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
                    RequestJniLiveShow.GetPromoAnchorList(number, type, userId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetPromoAnchorList(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniLiveShow.GetPromoAnchorList(number, type, userId, new OnGetPromoAnchorListCallback() {

            @Override
            public void onGetPromoAnchorList(boolean isSuccess, int errCode, String errMsg, HotListItem[] anchorList) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetPromoAnchorList(isSuccess, errCode, errMsg, anchorList);
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
     * 4.2.观众处理预约邀请
     * @param invitationId
     * @param isConfirmed
     * @param callback
     * @return
     */
    public long HandleScheduledInvite(final String invitationId, final boolean isConfirmed, final OnRequestCallback callback) {
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
                    RequstJniSchedule.HandleScheduledInvite(invitationId, isConfirmed, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.HandleScheduledInvite(invitationId, isConfirmed, new OnRequestCallback() {

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
     * 4.3.取消预约邀请
     * @param invitationId
     * @param callback
     * @return
     */
    public long CancelScheduledInvite(final String invitationId, final OnRequestCallback callback) {
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
                    RequstJniSchedule.CancelScheduledInvite(invitationId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.CancelScheduledInvite(invitationId, new OnRequestCallback() {

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
     * 4.5.获取新建预约邀请信息
     * @param anchorId
     * @param callback
     * @return
     */
    public long GetScheduleInviteCreateConfig(final String anchorId, final OnGetScheduleInviteCreateConfigCallback callback) {
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
                    RequstJniSchedule.GetScheduleInviteCreateConfig(anchorId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetScheduleInviteCreateConfig(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.GetScheduleInviteCreateConfig(anchorId, new OnGetScheduleInviteCreateConfigCallback() {

            @Override
            public void onGetScheduleInviteCreateConfig(boolean isSuccess, int errCode, String errMsg, ScheduleInviteConfig scheduleInviteConfig) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetScheduleInviteCreateConfig(isSuccess, errCode, errMsg, scheduleInviteConfig);
                }
            }
        });
    }

    /**
     * 4.6.新建预约邀请
     * @param userId
     * @param timeId
     * @param bookTime
     * @param giftId
     * @param giftNum
     * @param callback
     * @return
     */
    public long CreateScheduleInvite(final String userId, final String timeId, final int bookTime, final String giftId, final int giftNum, final boolean needSms, final OnRequestCallback callback) {
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
                    RequstJniSchedule.CreateScheduleInvite(userId, timeId, bookTime, giftId, giftNum, needSms, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.CreateScheduleInvite(userId, timeId, bookTime, giftId, giftNum, needSms, new OnRequestCallback() {

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
     * 4.7.观众处理立即私密邀请
     * @param inviteId
     * @param isConfirmed
     * @param callback
     * @return
     */
    public long AcceptInstanceInvite(final String inviteId, final boolean isConfirmed, final OnAcceptInstanceInviteCallback callback) {
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
                    RequstJniSchedule.AcceptInstanceInvite(inviteId, isConfirmed, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onAcceptInstanceInvite(isSuccess, errCode, errMsg, "", 0);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.AcceptInstanceInvite(inviteId, isConfirmed, new OnAcceptInstanceInviteCallback() {

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
     * 5.1.获取背包礼物列表
     * @param callback
     * @return
     */
    public long GetPackageGiftList(final OnGetPackageGiftListCallback callback) {
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
                    RequestJniPackage.GetPackageGiftList(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetPackageGiftList(isSuccess, errCode, errMsg, null, 0);
                }
            }
        };
        // 调用jni接口
        return RequestJniPackage.GetPackageGiftList(new OnGetPackageGiftListCallback() {

            @Override
            public void onGetPackageGiftList(boolean isSuccess, int errCode, String errMsg, PackageGiftItem[] packageGiftList, int totalCount) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetPackageGiftList(isSuccess, errCode, errMsg, packageGiftList, totalCount);
                }
            }
        });
    }

    /**
     * 5.2.获取试用券列表
     * @param callback
     * @return
     */
    public long GetVouchersList(final OnGetVouchersListCallback callback) {
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
                    RequestJniPackage.GetVouchersList(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetVouchersList(isSuccess, errCode, errMsg, null, 0);
                }
            }
        };
        // 调用jni接口
        return RequestJniPackage.GetVouchersList(new OnGetVouchersListCallback() {

            @Override
            public void onGetVouchersList(boolean isSuccess, int errCode, String errMsg, VoucherItem[] voucherList, int totalCount) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetVouchersList(isSuccess, errCode, errMsg, voucherList, totalCount);
                }
            }
        });
    }

    /**
     * 5.3.获取座驾列表
     * @param callback
     * @return
     */
    public long GetRidesList(final OnGetRidesListCallback callback) {
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
                    RequestJniPackage.GetRidesList(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetRidesList(isSuccess, errCode, errMsg, null, 0);
                }
            }
        };
        // 调用jni接口
        return RequestJniPackage.GetRidesList(new OnGetRidesListCallback() {

            @Override
            public void onGetRidesList(boolean isSuccess, int errCode, String errMsg, RideItem[] rideList, int totalCount) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetRidesList(isSuccess, errCode, errMsg, rideList, totalCount);
                }
            }
        });
    }

    /**
     * 5.4.使用/取消座驾
     * @param rideId
     * @param callback
     * @return
     */
    public long UseOrCancelRide(final String rideId, final OnRequestCallback callback) {
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
                    RequestJniPackage.UseOrCancelRide(rideId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequestJniPackage.UseOrCancelRide(rideId, new OnRequestCallback() {

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
     * 5.5.获取背包未读数量
     * @param callback
     * @return
     */
    public long GetPackageUnreadCount(final OnGetPackageUnreadCountCallback callback) {
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
                    RequestJniPackage.GetPackageUnreadCount(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetPackageUnreadCount(isSuccess, errCode, errMsg, 0, 0, 0, 0);
                }
            }
        };
        // 调用jni接口
        return RequestJniPackage.GetPackageUnreadCount(new OnGetPackageUnreadCountCallback() {

            @Override
            public void onGetPackageUnreadCount(boolean isSuccess, int errCode, String errMsg, int total, int voucherNum, int giftNum, int rideNum) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetPackageUnreadCount(isSuccess, errCode, errMsg, total, voucherNum, giftNum, rideNum);
                }
            }
        });
    }

    /**
     * 6.2.获取账号余额
     * @param callback
     * @return
     */
    public long GetAccountBalance(final OnGetAccountBalanceCallback callback) {
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
                    RequestJniOther.GetAccountBalance(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetAccountBalance(isSuccess, errCode, errMsg, 0);
                }
            }
        };
        // 调用jni接口
        return RequestJniOther.GetAccountBalance(new OnGetAccountBalanceCallback() {

            @Override
            public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, double balance) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetAccountBalance(isSuccess, errCode, errMsg, balance);
                }
            }
        });
    }

    /**
     * 6.3.添加/取消收藏
     * @param anchorId
     * @param roomId
     * @param isFav
     * @param callback
     * @return
     */
    public long AddOrCancelFavorite(final String anchorId, final String roomId, final boolean isFav, final OnRequestCallback callback) {
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
                    RequestJniOther.AddOrCancelFavorite(anchorId, roomId, isFav, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequestJniOther.AddOrCancelFavorite(anchorId, roomId, isFav, new OnRequestCallback() {

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
     * 6.4.获取QN广告列表
     * @param number
     * @param callback
     * @return
     */
    public long GetAdAnchorList(final int number, final OnGetAdAnchorListCallback callback) {
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
                    RequestJniOther.GetAdAnchorList(number, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetAdAnchorList(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniOther.GetAdAnchorList(number, new OnGetAdAnchorListCallback() {

            @Override
            public void onGetAdAnchorList(boolean isSuccess, int errCode, String errMsg, HotListItem[] hotList) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetAdAnchorList(isSuccess, errCode, errMsg, hotList);
                }
            }
        });
    }

    /**
     * 6.5.关闭QN广告列表
     * @param callback
     * @return
     */
    public long CloseAdAnchorList(final OnRequestCallback callback) {
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
                    RequestJniOther.CloseAdAnchorList(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequestJniOther.CloseAdAnchorList(new OnRequestCallback() {

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
     * 6.6.获取手机验证码
     * @param country      国家
     * @param areaCode     手机区号
     * @param phoneNo      手机号码
     * @param callback
     * @return
     */
    public long GetPhoneVerifyCode(final String country, final String areaCode, final String phoneNo, final OnRequestCallback callback) {
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
                    RequestJniOther.GetPhoneVerifyCode(country, areaCode, phoneNo, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequestJniOther.GetPhoneVerifyCode(country, areaCode, phoneNo, new OnRequestCallback() {

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
     * 6.7.提交手机验证码
     * @param country      国家
     * @param areaCode     手机区号
     * @param phoneNo      手机号码
     * @param verifyCode   验证码
     * @param callback
     * @return
     */
    public long SubmitPhoneVerifyCode(final String country, final String areaCode, final String phoneNo, final String verifyCode, final OnRequestCallback callback) {
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
                    RequestJniOther.SubmitPhoneVerifyCode(country, areaCode, phoneNo, verifyCode, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequestJniOther.SubmitPhoneVerifyCode(country, areaCode, phoneNo, verifyCode, new OnRequestCallback() {

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
     * 6.8.提交流媒体服务器测速结果
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
     * 6.9.获取Hot/Following列表头部广告
     * @param callback
     * @return
     */
    public long Banner(final OnBannerCallback callback) {
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
                    RequestJniOther.Banner(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onBanner(isSuccess, errCode, errMsg, "", "", "");
                }
            }
        };
        // 调用jni接口
        return RequestJniOther.Banner(new OnBannerCallback() {

            @Override
            public void onBanner(boolean isSuccess, int errCode, String errMsg, String bannerImg, String bannerLink, String bannerName) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onBanner(isSuccess, errCode, errMsg, bannerImg, bannerLink, bannerName);
                }
            }
        });
    }

    /**
     * 6.10.获取主播/观众信息
     * @param userId   		观众ID或者主播ID
     * @param callback
     * @return
     */
    public long GetUserInfo(final String userId, final OnGetUserInfoCallback callback) {
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
                    RequestJniOther.GetUserInfo(userId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetUserInfo(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniOther.GetUserInfo(userId, new OnGetUserInfoCallback() {

            @Override
            public void onGetUserInfo(boolean isSuccess, int errCode, String errMsg, UserInfoItem userItem) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetUserInfo(isSuccess, errCode, errMsg, userItem);
                }
            }
        });
    }
}
