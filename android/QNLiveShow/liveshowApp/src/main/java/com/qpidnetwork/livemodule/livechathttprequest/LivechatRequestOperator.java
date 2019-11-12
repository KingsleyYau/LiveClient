package com.qpidnetwork.livemodule.livechathttprequest;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;

import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.Coupon;
import com.qpidnetwork.livemodule.livechathttprequest.item.LCSendPhotoItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.LCVideoItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconConfig;
import com.qpidnetwork.livemodule.livechathttprequest.item.Record;
import com.qpidnetwork.livemodule.livechathttprequest.item.RecordMutiple;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.qnbridgemodule.bean.BaseHttpResponseBean;

import java.util.List;

public class LivechatRequestOperator {

    private Handler mHandler = null;
    private static LivechatRequestOperator gRequestOperate;

    /***
     * 单例初始化
     * @param context
     * @return
     */
    public static LivechatRequestOperator newInstance(Context context) {
        if (gRequestOperate == null) {
            gRequestOperate = new LivechatRequestOperator(context);
        }
        return gRequestOperate;
    }

    public static LivechatRequestOperator getInstance() {
        return gRequestOperate;
    }

    @SuppressLint("HandlerLeak")
    private LivechatRequestOperator(Context context) {
        mHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                BaseHttpResponseBean response = (BaseHttpResponseBean) msg.obj;
                //add by Jagger 2018-10-10
                if(response.isSuccess){
                    LoginManager.getInstance().unRegister((IAuthorizationListener)response.data);
                }else{
                    switch (response.errno) {
                        case LivechatRequestErrorCode.MBCE0003:
                        case LivechatRequestErrorCode.ERROR900010:  {
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
     * @param errno
     * @param errmsg
     * @param callback
     * @return
     */
    private boolean HandleRequestCallback(boolean isSuccess, String errno, String errmsg, IAuthorizationListener callback) {
        // 判断错误码是否可以处理
        boolean bFlag = false;
        if (isSuccess) {

        } else {
            switch (errno) {
                case LivechatRequestErrorCode.MBCE0003:
                case LivechatRequestErrorCode.ERROR900010: {
                    // 未登录
                    bFlag = true;
                }
                break;
                default: {
                }
                break;
            }

        }

        //切换线程处理拦截任务
        Message msg = Message.obtain();
        BaseHttpResponseBean response = new BaseHttpResponseBean(isSuccess, errno, errmsg, callback);
        msg.obj = response;
        mHandler.sendMessage(msg);

        return bFlag;
    }

    /***********************************************************************************************

    /**
     * 12.1.查询聊天记录
     *
     * @param inviteId
     * @param callback
     * @return
     */
    public long QueryChatRecord(final String inviteId, final OnQueryChatRecordCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.QueryChatRecord(inviteId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnQueryChatRecord(isSuccess, String.valueOf(errCode), errMsg, 0, null, "");
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.QueryChatRecord(inviteId, new OnQueryChatRecordCallback() {

            @Override
            public void OnQueryChatRecord(boolean isSuccess, String errno, String errmsg, int dbTime, Record[] recordList, String inviteId) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnQueryChatRecord(isSuccess, errno, errmsg, dbTime, recordList, inviteId);
                }
            }
        });
    }


    /**
     * 12.2.批量查询聊天记录
     * @param inviteIds			邀请ID数组
     * @param callback
     * @return					请求唯一标识
     */
    public long QueryChatRecordMutiple(final String[] inviteIds, final OnQueryChatRecordMutipleCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.QueryChatRecordMutiple(inviteIds, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnQueryChatRecordMutiple(isSuccess, String.valueOf(errCode), errMsg, 0, null);
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.QueryChatRecordMutiple(inviteIds, new OnQueryChatRecordMutipleCallback() {

            @Override
            public void OnQueryChatRecordMutiple(boolean isSuccess, String errno, String errmsg, int dbTime, RecordMutiple[] recordMutipleList) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnQueryChatRecordMutiple(isSuccess, errno, errmsg, dbTime, recordMutipleList);
                }
            }
        });
    }

    /**
     * 12.3.上传语音文件
     * @param voiceCode		语音验证码
     * @param inviteId		邀请ID
     * @param mineId		自己的用户ID
     * @param isMan			是否男士
     * @param userId		对方的用户ID
     * @param siteType		站点ID
     * @param fileType		文件类型(mp3, aac...)
     * @param voiceLength	语音时长
     * @param filePath		语音文件路径
     * @param callback
     * @return
     */
    public long UploadVoice(
            final String voiceCode
            , final String inviteId
            , final String mineId
            , final boolean isMan
            , final String userId
            , final int siteType
            , final String fileType
            , final int voiceLength
            , final String filePath
            , final OnLCUploadVoiceCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.UploadVoice(voiceCode, inviteId, mineId, isMan, userId, siteType, fileType, voiceLength, filePath, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnLCUploadVoice(-1, false, String.valueOf(errCode), errMsg, "");
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.UploadVoice(voiceCode, inviteId, mineId, isMan, userId, siteType, fileType, voiceLength, filePath, new OnLCUploadVoiceCallback() {

            @Override
            public void OnLCUploadVoice(long requestId, boolean isSuccess, String errno, String errmsg, String voiceId) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnLCUploadVoice(requestId, isSuccess, errno, errmsg, voiceId);
                }
            }
        });
    }

    /**
     * 12.4.下载语音文件
     * @param voiceId	语音ID
     * @param siteType	站点ID
     * @param filePath	文件路径
     * @param callback
     * @return
     */
    public long PlayVoice(final String voiceId, final int siteType, final String filePath, final OnLCPlayVoiceCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.PlayVoice( voiceId, siteType, filePath, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnLCPlayVoice(-1, false, String.valueOf(errCode), errMsg, "");
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.PlayVoice(voiceId, siteType, filePath, new OnLCPlayVoiceCallback() {

            @Override
            public void OnLCPlayVoice(long requestId, boolean isSuccess, String errno, String errmsg, String voiceId) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnLCPlayVoice(requestId, isSuccess, errno, errmsg, filePath);
                }
            }
        });
    }

    /**
     * 12.5 查询小高级表情配置
     * @param callback
     * @return
     */
    public long GetMagicIconConfig(final OnLCGetMagicIconConfigCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.GetMagicIconConfig(callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnLCGetMagicIconConfig(false, String.valueOf(errCode), errMsg, null);
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.GetMagicIconConfig(new OnLCGetMagicIconConfigCallback() {

            @Override
            public void OnLCGetMagicIconConfig(boolean isSuccess, String errno, String errmsg, MagicIconConfig config) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnLCGetMagicIconConfig(isSuccess, errno, errmsg, config);
                }
            }
        });
    }

    /**
     * 12.6.检测功能是否开通
     * @param functionList 待检测功能列表
     * @param type 设备类型
     * @param versionCode 待检测版本号
     * @param user_sid session id
     * @param user_id 用户ID
     * @return
     */
    public long CheckFunctions(final List<LCRequestJniLiveChat.FunctionType> functionList,
                               final LiveChatTalkUserListItem.DeviceType type, final String versionCode, final String user_sid, final String user_id, final OnLCCheckFunctionsCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.CheckFunctions(functionList, type,   versionCode,   user_sid,   user_id, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnLCCheckFunctions(false, String.valueOf(errCode), errMsg, null);
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.CheckFunctions(functionList, type,   versionCode,   user_sid,   user_id, new OnLCCheckFunctionsCallback() {

            @Override
            public void OnLCCheckFunctions(boolean isSuccess, String errno, String errmsg, int[] flags) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnLCCheckFunctions(isSuccess, errno, errmsg, flags);
                }
            }
        });
    }

    /**
     * 12.7.查询是否符合试聊条件
     * @param womanId			女士ID
     * @param serviceType       查询指定服务类型
     * @param callback
     * @return					请求唯一标识
     */
    public long CheckCoupon(final String womanId, final LCRequestJniLiveChat.ServiceType serviceType, final OnCheckCouponCallCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.CheckCoupon(womanId, serviceType, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnCheckCoupon(-1,false, String.valueOf(errCode), errMsg, null);
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.CheckCoupon(womanId, serviceType, new OnCheckCouponCallCallback() {

            @Override
            public void OnCheckCoupon(long requestId, boolean isSuccess, String errno, String errmsg, Coupon item) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnCheckCoupon(requestId, isSuccess, errno, errmsg, item);
                }
            }
        });
    }

    /**
     * 12.8.使用试聊券
     * @param womanId			女士ID
     * @param serviceType       查询指定服务类型
     * @param callback
     * @return					请求唯一标识
     */
    public long UseCoupon(final String womanId, final LCRequestJniLiveChat.ServiceType serviceType, final OnLCUseCouponCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.UseCoupon(womanId, serviceType, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnLCUseCoupon(-1,false, String.valueOf(errCode), errMsg, "", null);
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.UseCoupon(womanId, serviceType, new OnLCUseCouponCallback() {

            @Override
            public void OnLCUseCoupon(long requestId, boolean isSuccess, String errno, String errmsg, String userId, String couponid) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnLCUseCoupon(requestId, isSuccess, errno, errmsg, userId, couponid);
                }
            }
        });
    }

    /**
     * 12.9.发送私密照片
     * @param targetId	接收方ID
     * @param inviteId	邀请ID
     * @param userId	用户ID
     * @param sid		sid
     * @param filePath	待发送的文件路径
     * @return
     */
    public long SendPhoto(final String targetId, final String inviteId, final String userId, final String sid, final String filePath, final OnLCSendPhotoCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.SendPhoto(targetId, inviteId,   userId,   sid,   filePath, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnLCSendPhoto(-1,false, String.valueOf(errCode), errMsg, null);
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.SendPhoto(targetId, inviteId,   userId,   sid,   filePath, new OnLCSendPhotoCallback() {

            @Override
            public void OnLCSendPhoto(long requestId, boolean isSuccess, String errno, String errmsg, LCSendPhotoItem item) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnLCSendPhoto(requestId, isSuccess, errno, errmsg, item);
                }
            }
        });
    }

    /**
     * 12.10.付费获取私密照片
     * @param targetId	接收方ID
     * @param inviteId	邀请ID
     * @param userId	用户ID
     * @param sid		sid
     * @param photoId	照片ID
     * @return
     */
    public long PhotoFee(final String targetId, final String inviteId, final String userId, final String sid, final String photoId, final OnLCPhotoFeeCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.PhotoFee(targetId,  inviteId,  userId,  sid,  photoId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnLCPhotoFee(-1,false, String.valueOf(errCode), errMsg);
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.PhotoFee(targetId,  inviteId,  userId,  sid,  photoId, new OnLCPhotoFeeCallback() {

            @Override
            public void OnLCPhotoFee(long requestId, boolean isSuccess, String errno, String errmsg) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnLCPhotoFee(requestId, isSuccess, errno, errmsg);
                }
            }
        });
    }

    /**
     * 12.11.检查私密照片是否已付费
     * @param targetId	接收方ID
     * @param inviteId	邀请ID
     * @param userId	用户ID
     * @param sid		sid
     * @param photoId	照片ID
     * @return
     */
    public long CheckPhoto(final String targetId, final String inviteId, final String userId, final String sid, final String photoId, final OnLCCheckPhotoCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.CheckPhoto(targetId,   inviteId,   userId,   sid,   photoId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnCheckPhoto(-1,false, String.valueOf(errCode), errMsg,"", false);
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.CheckPhoto(targetId,   inviteId,   userId,   sid,   photoId, new OnLCCheckPhotoCallback() {

            @Override
            public void OnCheckPhoto(long requestId, boolean isSuccess, String errno, String errmsg, String sendId, boolean isChange) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnCheckPhoto(requestId, isSuccess, errno, errmsg, sendId, isChange);
                }
            }
        });
    }

    /**
     * 12.12.获取照片
     * @param toFlag	获取类型
     * @param targetId	照片所有者ID
     * @param userId	用户ID
     * @param sid		sid
     * @param photoId	照片ID
     * @param sizeType	照片尺寸
     * @param modeType	照片类型
     * @param filePath	照片文件路径
     * @return
     */
    public long GetPhoto(final LCRequestJniLiveChat.ToFlagType toFlag, final String targetId, final String userId, final String sid, final String photoId, final LCRequestJniLiveChat.PhotoSizeType sizeType, final LCRequestJniLiveChat.PhotoModeType modeType, final String filePath, final OnLCGetPhotoCallback callback) {
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.GetPhoto(toFlag,  targetId,   userId,   sid,   photoId, sizeType,  modeType,  filePath, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnLCGetPhoto(-1,false, String.valueOf(errCode), errMsg,"");
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.GetPhoto(toFlag,  targetId,   userId,   sid,   photoId, sizeType,  modeType,  filePath, new OnLCGetPhotoCallback() {

            @Override
            public void OnLCGetPhoto(long requestId, boolean isSuccess, String errno, String errmsg, String filePath) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnLCGetPhoto(requestId, isSuccess, errno, errmsg, filePath);
                }
            }
        });
    }

    /**
     * 12.13.获取最近已看微视频列表（http post）（New）
     * @param womanId		女士ID
     * @param callback
     * @return				请求唯一Id
     */
    public long QueryRecentVideo(
            final String user_sid,
            final String user_id,
            final String womanId,
            final OnQueryRecentVideoListCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.QueryRecentVideo( user_sid,user_id,womanId, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnQueryRecentVideoList(false, String.valueOf(errCode), errMsg,null);
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.QueryRecentVideo( user_sid,user_id,womanId, new OnQueryRecentVideoListCallback() {

            @Override
            public void OnQueryRecentVideoList(boolean isSuccess, String errno, String errmsg, LCVideoItem[] itemList) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnQueryRecentVideoList( isSuccess, errno, errmsg, itemList);
                }
            }
        });
    }

    /**
     * 12.14.获取微视频图片（http get）（New）
     * @param womanId		女士ID
     * @param videoid		视频ID
     * @param type			图片尺寸<VideoPhotoType>
     * @param filePath		文件路径
     * @param callback
     * @return				请求唯一Id
     */
    public long GetVideoPhoto(
            final String user_sid,
            final String user_id,
            final String womanId,
            final String videoid,
            final LCRequestJniLiveChat.VideoPhotoType type,
            final String filePath,
            final OnLCRequestFileCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.GetVideoPhoto( user_sid, user_id, womanId, videoid, type, filePath, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnLCRequestFile(-1, false, String.valueOf(errCode), errMsg,"");
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.GetVideoPhoto( user_sid, user_id, womanId, videoid, type, filePath, new OnLCRequestFileCallback() {

            @Override
            public void OnLCRequestFile(long requestId, boolean isSuccess, String errno, String errmsg, String filePath) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnLCRequestFile( requestId, isSuccess, errno, errmsg, filePath);
                }
            }
        });
    }

    /**
     * 12.15.获取微视频文件URL（http post）
     * @param womanId		女士ID
     * @param videoid		视频ID
     * @param inviteid		邀请ID
     * @param toflag		客户端类型<VideoToFlagType>
     * @param sendid		发送ID，在LiveChat收到女士端发出的消息中
     * @param callback
     * @return				请求唯一Id
     */
    public long GetVideo(
            final String user_sid,
            final String user_id,
            final String womanId,
            final String videoid,
            final String inviteid,
            final LCRequestJniLiveChat.VideoToFlagType toflag,
            final String sendid,
            final OnLCGetVideoCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.GetVideo( user_sid,
                      user_id,
                      womanId,
                      videoid,
                      inviteid,
                      toflag,
                      sendid, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnLCGetVideo(-1, false, String.valueOf(errCode), errMsg,"");
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.GetVideo( user_sid,
                user_id,
                womanId,
                videoid,
                inviteid,
                toflag,
                sendid, new OnLCGetVideoCallback() {

            @Override
            public void OnLCGetVideo(long requestId, boolean isSuccess, String errno, String errmsg, String url) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnLCGetVideo( requestId, isSuccess, errno, errmsg, url);
                }
            }
        });
    }

    /**
     * 12.16.上传LiveChat相关附件, file:照片二进制流， fileName：文件名便于查找哪个文件上传的(用于发送私密照前使用)
     * @param file			file:照片二进制流
     * @param callback
     * @return				请求唯一Id
     */
    public long UploadManPhoto(
            final String file,
            final OnLCUploadManPhotoCallback callback){
        // 登录状态改变重新调用接口
        final IAuthorizationListener callbackLogin = new IAuthorizationListener() {

            @Override
            public void onLogout(boolean isMannual) {

            }

            @Override
            public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
                HandleRequestCallback(isSuccess, String.valueOf(errCode), errMsg, this);
                if (isSuccess) {
                    // 登录成功
                    // 再次调用jni接口
                    LCRequestJniLiveChat.UploadManPhoto( file, callback);
                } else {
                    // 登录不成功, 回调失败
                    callback.OnUploadManPhoto(-1, false, errCode, errMsg,"", "");
                }
            }
        };
        // 调用jni接口
        return LCRequestJniLiveChat.UploadManPhoto( file, new OnLCUploadManPhotoCallback() {

            @Override
            public void OnUploadManPhoto(long requestId, boolean isSuccess, int errCode, String errmsg, String photoUrl, String photomd5) {
                // 公共处理VerifySms
                boolean bFlag = HandleRequestCallback(isSuccess, String.valueOf(errCode), errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    callback.OnUploadManPhoto( requestId, isSuccess, errCode, errmsg, photoUrl, photomd5);
                }
            }
        });
    }
}
