package com.qpidnetwork.livemodule.httprequest;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;

import com.qpidnetwork.livemodule.httprequest.item.AudienceBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.BookInviteItem;
import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory;
import com.qpidnetwork.livemodule.httprequest.item.FollowingListItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutGiftListItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutOnlineAnchorItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutRoomStatusItem;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpAuthorityItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.ImmediateInviteItem;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.LSOrderType;
import com.qpidnetwork.livemodule.httprequest.item.LSProfileItem;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Children;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Drink;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Education;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Ethnicity;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Height;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Income;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Profession;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Religion;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Weight;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum.Zodiac;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.MainUnreadNumItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.ProgramInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.RegionType;
import com.qpidnetwork.livemodule.httprequest.item.RideItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteConfig;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.TalentInviteItem;
import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.ValidLiveRoomItem;
import com.qpidnetwork.livemodule.httprequest.item.VoucherItem;
import com.qpidnetwork.livemodule.httprequest.item.VouchorAvailableInfoItem;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;

/**
 * Created by Hunter on 17/9/21.
 */

public class LiveRequestOperator {

    private Handler mHandler = null;
    private static LiveRequestOperator gRequestOperate;

    /***
     * 单例初始化
     * @param context
     * @return
     */
    public static LiveRequestOperator newInstance(Context context) {
        if (gRequestOperate == null) {
            gRequestOperate = new LiveRequestOperator(context);
        }
        return gRequestOperate;
    }

    public static LiveRequestOperator getInstance() {
        return gRequestOperate;
    }

    @SuppressLint("HandlerLeak")
    private LiveRequestOperator(Context context) {
        mHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                HttpRespObject response = (HttpRespObject) msg.obj;
                //add by Jagger 2018-10-10
                if(response.isSuccess){
                    LoginManager.getInstance().unRegister((IAuthorizationListener)response.data);
                }else{
                    HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(response.errCode);
                    switch (errType) {
                        case HTTP_LCC_ERR_TOKEN_EXPIRE:
                        case HTTP_LCC_ERR_NO_LOGIN: {
                            //sesssion 过期 //add by Jagger 2018-10-10
                            LoginManager.getInstance().register((IAuthorizationListener)response.data);
                            //modify by hunter 2018.8.7 修改为session过期执行踢出逻辑
                            LoginManager.getInstance().onModuleSessionOverTime();
                        }
                        break;
                        default: {
                            LoginManager.getInstance().unRegister((IAuthorizationListener)response.data);
                        }
                        break;
                    }
                }
            }
//            }
        };
    }


    /**
     * 错误公共处理
     *
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param callback
     * @return
     */
    private boolean HandleRequestCallback(boolean isSuccess, int errCode, String errMsg, IAuthorizationListener callback) {
        //判断错误码是否需要拦截
        boolean bFlag = false;
        HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(errCode);
        if (!isSuccess) {
            switch (errType) {
                case HTTP_LCC_ERR_TOKEN_EXPIRE:
                case HTTP_LCC_ERR_NO_LOGIN: {
                    bFlag = true;
                }
                break;
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
                    callback.onAcceptInstanceInvite(isSuccess, errCode, errMsg, "", 0, null);
                }
            }
        };
        // 调用jni接口
        return RequstJniSchedule.AcceptInstanceInvite(inviteId, isConfirmed, new OnAcceptInstanceInviteCallback() {

            @Override
            public void onAcceptInstanceInvite(boolean isSuccess, int errCode, String errMsg, String roomId, int roomType, HttpAuthorityItem priv) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onAcceptInstanceInvite(isSuccess, errCode, errMsg, roomId, roomType, priv);
                }
            }
        });
    }

    /**
     * 5.1.获取背包礼物列表
     *
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
     *
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
     *
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
     *
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
     *
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
     * 5.6.获取试用券可用信息
     *
     * @param callback
     * @return
     */
    public long GetVoucherAvailableInfo(final OnGetVoucherAvailableInfoCallback callback) {
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
                    RequestJniPackage.GetVoucherAvailableInfo(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetVoucherAvailableInfo(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniPackage.GetVoucherAvailableInfo(new OnGetVoucherAvailableInfoCallback() {

            @Override
            public void onGetVoucherAvailableInfo(boolean isSuccess, int errCode, String errMsg, VouchorAvailableInfoItem infoItem) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetVoucherAvailableInfo(isSuccess, errCode, errMsg, infoItem);
                }
            }
        });
    }

    /**
     * 6.2.获取账号余额
     *
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
                    callback.onGetAccountBalance(isSuccess, errCode, errMsg, 0, 0);
                }
            }
        };
        // 调用jni接口
        return RequestJniOther.GetAccountBalance(new OnGetAccountBalanceCallback() {

            @Override
            public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, double balance, int coupon) {

                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetAccountBalance(isSuccess, errCode, errMsg, balance, coupon);
                }
            }
        });
    }

    /**
     * 6.3.添加/取消收藏
     *
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
     *
     * @param number
     * @param callback
     * @return
     */
    public long GetAdAnchorList(final int number, final RegionType regionType, final OnGetAdAnchorListCallback callback) {
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
     *
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
     *
     * @param country  国家
     * @param areaCode 手机区号
     * @param phoneNo  手机号码
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
     *
     * @param country    国家
     * @param areaCode   手机区号
     * @param phoneNo    手机号码
     * @param verifyCode 验证码
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
     *
     * @param sid      流媒体服务器ID
     * @param res      http请求完成时间（毫秒）
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
     *
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
     *
     * @param userId   观众ID或者主播ID
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

    /**
     * 9.1.获取节目未读数(用于观众端向服务器获取节目未读数，已购或已关注的开播中节目数 + 退票未读数)
     *
     * @param callback
     * @return
     * @deprecated http接口已经废弃
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
            public void onGetNoReadNumProgram(boolean isSuccess, int errCode, String errMsg, int num) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetNoReadNumProgram(isSuccess, errCode, errMsg, num);
                }
            }
        });
    }

    /**
     * 9.2.获取节目列表
     *
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
            public void onGetProgramList(boolean isSuccess, int errCode, String errMsg, ProgramInfoItem[] array) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetProgramList(isSuccess, errCode, errMsg, array);
                }
            }
        });
    }

    /**
     * 9.3.购买
     *
     * @param liveShowId
     * @param callback
     * @return
     */
    public long BuyProgram(final String liveShowId, final OnBuyProgramCallback callback) {
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
                    RequestJniProgram.BuyProgram(liveShowId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onBuyProgram(isSuccess, errCode, errMsg, 0);
                }
            }
        };
        // 调用jni接口
        return RequestJniProgram.BuyProgram(liveShowId, new OnBuyProgramCallback() {

            @Override
            public void onBuyProgram(boolean isSuccess, int errCode, String errMsg, double leftCredit) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onBuyProgram(isSuccess, errCode, errMsg, leftCredit);
                }
            }
        });
    }

    /**
     * 9.4.关注/取消关注
     *
     * @param liveShowId
     * @param isCancel
     * @param callback
     * @return
     */
    public long FollowShow(final String liveShowId, final boolean isCancel, final OnFollowShowCallback callback) {
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
                    RequestJniProgram.FollowShow(liveShowId, isCancel, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onFollowShow(isSuccess, errCode, errMsg);
                }
            }
        };
        // 调用jni接口
        return RequestJniProgram.FollowShow(liveShowId, isCancel, new OnFollowShowCallback() {

            @Override
            public void onFollowShow(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onFollowShow(isSuccess, errCode, errMsg);
                }
            }
        });
    }

    /**
     * 9.5.获取可进入的节目信息接口
     *
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
                    callback.onGetShowRoomInfo(isSuccess, errCode, errMsg, null, "", null);
                }
            }
        };
        // 调用jni接口
        return RequestJniProgram.GetShowRoomInfo(liveShowId, new OnGetShowRoomInfoCallback() {

            @Override
            public void onGetShowRoomInfo(boolean isSuccess, int errCode, String errMsg, ProgramInfoItem item, String roomId, HttpAuthorityItem privItem) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetShowRoomInfo(isSuccess, errCode, errMsg, item, roomId, privItem);
                }
            }
        });
    }

    /**
     * 9.6.获取节目推荐列表
     *
     * @param type
     * @param start
     * @param step
     * @param anchorId
     * @param callback
     * @return
     */
    public long ShowListWithAnchorId(final RequestJniProgram.ShowRecommendListType type, final int start, final int step, final String anchorId, final OnShowListWithAnchorIdCallback callback) {
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
                    RequestJniProgram.ShowListWithAnchorId(type, start, step, anchorId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onShowListWithAnchorId(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniProgram.ShowListWithAnchorId(type, start, step, anchorId, new OnShowListWithAnchorIdCallback() {

            @Override
            public void onShowListWithAnchorId(boolean isSuccess, int errCode, String errMsg, ProgramInfoItem[] array) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onShowListWithAnchorId(isSuccess, errCode, errMsg, array);
                }
            }
        });
    }

    /**
     * /**
     * 6.17.获取主界面未读数量
     *
     * @param callback
     * @return
     */
    public long GetMainUnreadNum(final OnGetMainUnreadNumCallback callback) {
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
                    RequestJniOther.GetMainUnreadNum(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetMainUnreadNum(isSuccess, errCode, errMsg, null);
                }
            }
        };
        // 调用jni接口
        return RequestJniOther.GetMainUnreadNum(new OnGetMainUnreadNumCallback() {

            @Override
            public void onGetMainUnreadNum(boolean isSuccess, int errCode, String errMsg, MainUnreadNumItem unreadItem) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetMainUnreadNum(isSuccess, errCode, errMsg, unreadItem);
                }
            }
        });
    }


//    /**
//     * 6.18 查询个人信息
//     *
//     * @param callback
//     * @return
//     */
//    public long GetMyProfile(final OnGetMyProfileCallback callback) {
//        // 登录状态改变重新调用接口
//        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {
//
//            @Override
//            public void onLogout(boolean isMannual) {
//
//
//            }
//
//            @Override
//            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
//                // 公共处理
//                HandleRequestCallback(isSuccess, errCode, errMsg, this);
//                if (isSuccess) {
//                    // 登录成功
//                    // 再次调用jni接口
//                    RequestJniOther.GetMyProfile(callback);
//                } else {
//                    // 登录不成功, 回调失败
//                    callback.onGetMyProfile(isSuccess, errCode, errMsg, null);
//                }
//            }
//        };
//
//        // 调用jni接口
//        return RequestJniOther.GetMyProfile(new OnGetMyProfileCallback() {
//
//            @Override
//            public void onGetMyProfile(boolean isSuccess, int errCode, String errMsg, LSProfileItem item) {
//                // 公共处理VerifySms
//                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
//                if (bFlag) {
//                    // 已经匹配处理, 等待回调
//                } else {
//                    // 没有匹配处理, 直接回调
//                    callback.onGetMyProfile(isSuccess, errCode, errMsg, item);
//                }
//            }
//        });
//    }
//
//
//    /**
//     * 6.19 修改个人信息
//     *
//     * @param callback
//     * @return
//     */
//    public long UpdateProfile(
//            final Weight weight,
//            final Height height,
//            final LSRequestEnum.Language language,
//            final Ethnicity ethnicity,
//            final Religion religion,
//            final Education education,
//            final Profession profession,
//            final Income income,
//            final Children children,
//            final LSRequestEnum.Smoke smoke,
//            final Drink drink,
//            final String resume,
//            final String[] interest,
//            final Zodiac zodiac,
//            final OnUpdateMyProfileCallback callback) {
//
//        // 登录状态改变重新调用接口
//        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {
//
//            @Override
//            public void onLogout(boolean isMannual) {
//
//
//            }
//
//            @Override
//            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
//                // 公共处理
//                HandleRequestCallback(isSuccess, errCode, errMsg, this);
//                if (isSuccess) {
//                    // 登录成功
//                    // 再次调用jni接口
//                    RequestJniOther.UpdateProfile(weight, height, language, ethnicity, religion, education, profession,
//                            income, children, smoke, drink, resume, interest, zodiac, callback);
//                } else {
//                    // 登录不成功, 回调失败
//                    callback.onUpdateMyProfile(isSuccess, errCode, errMsg, false);
//                }
//            }
//        };
//
//        // 调用jni接口
//        return RequestJniOther.UpdateProfile(weight, height, language, ethnicity,
//                religion, education, profession, income, children, smoke, drink,
//                resume, interest, zodiac, new OnUpdateMyProfileCallback() {
//
//                    @Override
//                    public void onUpdateMyProfile(boolean isSuccess, int errCode, String errMsg, boolean rsModified) {
//                        // 公共处理VerifySms
//                        boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
//                        if (bFlag) {
//                            // 已经匹配处理, 等待回调
//                        } else {
//                            // 没有匹配处理, 直接回调
//                            callback.onUpdateMyProfile(isSuccess, errCode, errMsg, false);
//                        }
//                    }
//                });
//    }
//
//
//    /**
//     * 2.17.修改密码
//     *
//     * @param passwordNew
//     * @param passwordOld
//     * @param callback
//     * @return
//     */
//    public long ChangePassword(final String passwordNew, final String passwordOld, final OnRequestCallback callback) {
//        // 登录状态改变重新调用接口
//        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {
//
//            @Override
//            public void onLogout(boolean isMannual) {
//
//
//            }
//
//            @Override
//            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
//                // 公共处理
//                HandleRequestCallback(isSuccess, errCode, errMsg, this);
//                if (isSuccess) {
//                    // 登录成功
//                    // 再次调用jni接口
//                    RequestJniAuthorization.ChangePassword(passwordNew, passwordOld, callback);
//                } else {
//                    // 登录不成功, 回调失败
//                    callback.onRequest(isSuccess, errCode, errMsg);
//                }
//            }
//        };
//
//        // 调用jni接口
//        return RequestJniAuthorization.ChangePassword(passwordNew, passwordOld, new OnRequestCallback() {
//
//            @Override
//            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
//                // 公共处理VerifySms
//                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
//                if (bFlag) {
//                    // 已经匹配处理, 等待回调
//                } else {
//                    // 没有匹配处理, 直接回调
//                    callback.onRequest(isSuccess, errCode, errMsg);
//                }
//            }
//        });
//    }

    /**
     * 2.19.获取认证token
     *
     * @param siteId
     * @param callback
     * @return
     */
    public long GetAuthToken(final int siteId, final OnRequestSidCallback callback) {
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
                    RequestJniAuthorization.GetAuthToken(siteId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequestSid(isSuccess, errCode, errMsg, "", "");
                }
            }
        };

        // 调用jni接口
        return RequestJniAuthorization.GetAuthToken(siteId, new OnRequestSidCallback() {

            @Override
            public void onRequestSid(boolean isSuccess, int errCode, String errMsg, String memberId, String sid){
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onRequestSid(isSuccess, errCode, errMsg, memberId, sid);
                }
            }
        });
    }


    /**
     * 11.1. 获取推送设置
     *
     * @param callback
     * @return
     */
    public long GetPushConfig(final OnGetPushConfigCallback callback) {
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
                    RequestJniSetting.GetPushConfig(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetPushConfig(isSuccess, errCode, errMsg, true, true);
                }
            }
        };

        // 调用jni接口
        return RequestJniSetting.GetPushConfig(new OnGetPushConfigCallback() {

            @Override
            public void onGetPushConfig(boolean isSuccess, int errCode, String errMsg, boolean isPriMsgAppPush, boolean isMailAppPush) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetPushConfig(isSuccess, errCode, errMsg, isPriMsgAppPush, isMailAppPush);
                }
            }
        });
    }


    public long SetPushConfig(final boolean isPriMsgAppPush, final boolean isMailAppPush, final OnRequestCallback callback) {
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
                    RequestJniSetting.SetPushConfig(isPriMsgAppPush, isMailAppPush, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };

        // 调用jni接口
        return RequestJniSetting.SetPushConfig(isPriMsgAppPush, isMailAppPush, new OnRequestCallback() {

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
     * 7.7. 获取h5买点页面URL（仅Android）
     * @param orderType
     * @param clickFrom  购买产品类型（credit：信用点，monthFree：月费服务，stamp：邮票）
     * @param numberId   点击来源（Axx表示不可切换，Bxx表示可切换）（可""，""则表示不指定）
     * @param callback   已选中的充值包ID（可""，""表示不指定充值包）
     * @return
     */
    public long MobilePayGoto(final LSOrderType orderType, final String clickFrom, final String numberId, final OnMobilePayGotoCallback callback) {
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
                    RequestJniPayment.MobilePayGoto(orderType, clickFrom, numberId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onMobilePayGoto(isSuccess, errCode, errMsg, "");
                }
            }
        };

        return RequestJniPayment.MobilePayGoto(orderType, clickFrom, numberId, new OnMobilePayGotoCallback() {
            @Override
            public void onMobilePayGoto(boolean isSuccess, int errCode, String errMsg, String redirtctUrl) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onMobilePayGoto(isSuccess, errCode, errMsg, redirtctUrl);
                }
            }
        });

    }

    /**
     * 8.2.发起多人互动邀请
     * @param roomId            当前发起的直播间ID
     * @param anchorId          主播ID
     * @param recommendId       推荐ID（可无，无则表示不是因推荐导致观众发起邀请）
     * @param callback
     * @return
     */
    public long SendInvitationHangout(final String roomId, final String anchorId, final String recommendId, final boolean isCreateOnly, final OnSendInvitationHangoutCallback callback) {
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
                    RequestJniHangout.SendInvitationHangout(roomId, anchorId, recommendId, isCreateOnly, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onSendInvitationHangout(isSuccess, errCode, errMsg, "", "", 0);
                }
            }
        };

        return RequestJniHangout.SendInvitationHangout(roomId, anchorId, recommendId, isCreateOnly, new OnSendInvitationHangoutCallback() {
            @Override
            public void onSendInvitationHangout(boolean isSuccess, int errCode, String errMsg, String roomId, String inviteId, int expire) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onSendInvitationHangout(isSuccess, errCode, errMsg, roomId, inviteId, expire);
                }
            }
        });

    }

    /**
     * 8.3.取消多人互动邀请
     * @param inviteId      邀请ID
     * @param callback
     * @return
     */
    public long CancelHangoutInvit(final String inviteId, final OnRequestCallback callback) {
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
                    RequestJniHangout.CancelHangoutInvit(inviteId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };

        return RequestJniHangout.CancelHangoutInvit(inviteId, new OnRequestCallback() {
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
     * 8.4.获取多人互动邀请状态
     * @param inviteId     邀请ID
     * @param callback
     * @return
     */
    public long GetHangoutInvitStatus(final String inviteId, final OnGetHangoutInvitStatusCallback callback) {
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
                    RequestJniHangout.GetHangoutInvitStatus(inviteId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetHangoutInvitStatus(isSuccess, errCode, errMsg, 0, "", 0);
                }
            }
        };

        return RequestJniHangout.GetHangoutInvitStatus(inviteId, new OnGetHangoutInvitStatusCallback() {
            @Override
            public void onGetHangoutInvitStatus(boolean isSuccess, int errCode, String errMsg, int status, String roomId, int expire) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetHangoutInvitStatus(isSuccess, errCode, errMsg, status, roomId, expire);
                }
            }
        });

    }

    /**
     * 8.5.同意主播敲门请求
     * @param knockId       敲门ID
     * @param callback
     * @return
     */
    public long DealKnockRequest(final String knockId, final OnRequestCallback callback) {
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
                    RequestJniHangout.DealKnockRequest(knockId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };

        return RequestJniHangout.DealKnockRequest(knockId, new OnRequestCallback() {
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
     * 8.6.获取多人互动直播间可发送的礼物列表
     * @param roomId       直播间ID
     * @param callback
     * @return
     */
    public long GetHangoutGiftList(final String roomId, final OnGetHangoutGiftListCallback callback) {
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
                    RequestJniHangout.GetHangoutGiftList(roomId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetHangoutGiftList(isSuccess, errCode, errMsg, null);
                }
            }
        };

        return RequestJniHangout.GetHangoutGiftList(roomId, new OnGetHangoutGiftListCallback() {
            @Override
            public void onGetHangoutGiftList(boolean isSuccess, int errCode, String errMsg, HangoutGiftListItem item) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetHangoutGiftList(isSuccess, errCode, errMsg, item);
                }
            }
        });

    }


    /**
     * 8.7.获取Hang-out在线主播列表接口
     * @param callback
     * @return
     */
    public long GetHangoutOnlineAnchor(final OnGetHangoutOnlineAnchorCallback callback) {
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
                    RequestJniHangout.GetHangoutOnlineAnchor(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetHangoutOnlineAnchor(isSuccess, errCode, errMsg, null);
                }
            }
        };

        return RequestJniHangout.GetHangoutOnlineAnchor(new OnGetHangoutOnlineAnchorCallback() {
            @Override
            public void onGetHangoutOnlineAnchor(boolean isSuccess, int errCode, String errMsg, HangoutOnlineAnchorItem[] list) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetHangoutOnlineAnchor(isSuccess, errCode, errMsg, list);
                }
            }
        });

    }

    /**
     * 8.8.获取指定主播的Hang-out好友列表
     * @param anchorId   主播ID
     * @param callback
     * @return
     */
    public long GetHangoutFriends(final String anchorId, final OnGetHangoutFriendsCallback callback) {
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
                    RequestJniHangout.GetHangoutFriends(anchorId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetHangoutFriends(isSuccess, errCode, errMsg, null);
                }
            }
        };

        return RequestJniHangout.GetHangoutFriends(anchorId, new OnGetHangoutFriendsCallback() {
            @Override
            public void onGetHangoutFriends(boolean isSuccess, int errCode, String errMsg, HangoutAnchorInfoItem[] audienceList) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetHangoutFriends(isSuccess, errCode, errMsg, audienceList);
                }
            }
        });

    }


    /**
     * 8.9.自动邀请Hangout直播邀請展示條件
     * @param anchorId   主播ID
     * @param callback
     * @return
     */
    public long AutoInvitationHangoutLiveDisplay(final String anchorId, final boolean isAuto, final OnRequestCallback callback) {
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
                    RequestJniHangout.AutoInvitationHangoutLiveDisplay(anchorId, isAuto, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };

        return RequestJniHangout.AutoInvitationHangoutLiveDisplay(anchorId, isAuto, new OnRequestCallback() {
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
     * 8.10.自动邀请hangout点击记录
     * @param anchorId   主播ID
     * @param callback
     * @return
     */
    public long AutoInvitationClickLog(final String anchorId, final boolean isAuto, final OnRequestCallback callback) {
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
                    RequestJniHangout.AutoInvitationClickLog(anchorId, isAuto, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onRequest(isSuccess, errCode, errMsg);
                }
            }
        };

        return RequestJniHangout.AutoInvitationClickLog(anchorId, isAuto, new OnRequestCallback() {
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
     * 8.11.获取当前会员Hangout直播状态
     * @param callback
     * @return
     */
    public long GetHangoutStatus(final OnGetHangoutStatusCallback callback) {
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
                    RequestJniHangout.GetHangoutStatus(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.onGetHangoutStatus(isSuccess, errCode, errMsg, null);
                }
            }
        };

        return RequestJniHangout.GetHangoutStatus(new OnGetHangoutStatusCallback() {
            @Override
            public void onGetHangoutStatus(boolean isSuccess, int errCode, String errMsg, HangoutRoomStatusItem[] list) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.onGetHangoutStatus(isSuccess, errCode, errMsg, list);
                }
            }
        });

    }

}
