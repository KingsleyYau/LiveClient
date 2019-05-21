package com.qpidnetwork.livemodule.liveshow.liveroom.hangout;

import android.opengl.GLSurfaceView;
import android.text.TextUtils;
import android.widget.FrameLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.im.listener.IMGiftNumItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvBuyforGiftItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.HangOutLiveRoomActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.obj.HangOutBarGiftListItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.obj.HangoutVedioWindowObj;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view.HangOutVedioWindow;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;

/**
 * Description:HangOut直播间四宫格状态管理器
 * <p>
 * Created by Harry on 2018/5/28.
 */
public class HangOutVedioWindowManager {

    private final String TAG = HangOutVedioWindowManager.class.getSimpleName();
    private final int MAN_CELL_INDEX = 4;   //男士位置

    private Map<Integer, HangOutVedioWindow> vedioWindowMap = new HashMap<>();
    private Map<String,Integer> userIdIndexMap = new HashMap<>();
    private int vedioWindowWidth;

    private HangOutLiveRoomActivity mActivity;
    private IMHangoutRoomItem mIMHangOutRoomItem;
    private LoginItem loginItem;

    //RxJava 管理订阅事件disposable
    private CompositeDisposable mCompositeDisposable = new CompositeDisposable();

    //----------------- 接口定义 start -----------------
    /**
     * 敲门事件监听器
     */
    public interface KnockEventListener{
        void onOpenDoor(boolean isSuccess, int httpErrorCode, String errorMsg);
    }

    /**
     * 邀请事件监听器
     */
    public interface InviteEventListener{
        void onClickInvite(boolean isSuccess, int httpErrorCode, String errorMsg);
    }
    //----------------- 接口定义 end -----------------

    /**
     * 构建器(方便参数扩展)
     */
    public static class Builder{

        private HangOutLiveRoomActivity activity = null;
        private IMHangoutRoomItem imHangOutRoomItem;
        private LoginItem loginItem;

        public Builder setmActivity(HangOutLiveRoomActivity hangOutLiveRoomActivity) {
            this.activity = hangOutLiveRoomActivity;
            return this;
        }

        public Builder setImHangOutRoomItem(IMHangoutRoomItem imHangOutRoomItem) {
            this.imHangOutRoomItem = imHangOutRoomItem;
            return this;
        }

        public Builder setLoginItem(LoginItem loginItem) {
            this.loginItem = loginItem;
            return this;
        }

        public HangOutVedioWindowManager build(){
            return new HangOutVedioWindowManager(this);
        }
    }

//    public HangOutVedioWindowManager(HangOutLiveRoomActivity activity, IMHangoutRoomItem imHangOutRoomItem, Builder builder){
//        this.mActivity = activity;
//        this.mIMHangOutRoomItem = imHangOutRoomItem;
//        vedioWindowWidth = DisplayUtil.getScreenWidth(activity)/2;
//        Log.d(TAG,"HangOutVedioWindowManager-mIMHangOutRoomItem:"+mIMHangOutRoomItem+" vedioWindowWidth:"+vedioWindowWidth);
//    }

    private HangOutVedioWindowManager(Builder builder){
        this.mActivity = builder.activity;
        this.mIMHangOutRoomItem = builder.imHangOutRoomItem;
        this.vedioWindowWidth = DisplayUtil.getScreenWidth(this.mActivity)/2;
        this.loginItem = builder.loginItem;
        Log.d(TAG,"HangOutVedioWindowManager-mIMHangOutRoomItem:"+mIMHangOutRoomItem+" vedioWindowWidth:"+vedioWindowWidth);
    }

    /**
     * 添加四宫格并初始化
     */
    public void add(int index,int layoutId){
        Log.d(TAG,"initViedoWindows-index:"+index);
        HangOutVedioWindow vedioWindow = (HangOutVedioWindow)mActivity.findViewById(layoutId);
        FrameLayout.LayoutParams vedioWindowLp1 = (FrameLayout.LayoutParams) vedioWindow.getLayoutParams();
        vedioWindowLp1.width = vedioWindowWidth;
        vedioWindowLp1.height = vedioWindowWidth;
        //视频可以放大缩小
        vedioWindow.setViewCanScale(true);
        vedioWindow.setIndex(index);
        vedioWindow.setOnAddInviteClickListener(mActivity);
        vedioWindow.setVedioClickListener(mActivity);
        vedioWindow.initGiftManager(mActivity);
        vedioWindow.showWaitToInviteView();
        vedioWindowMap.put(index,vedioWindow);
    }

    /**
     * 初始化四宫格已经接收到的bar礼物列表
     */
    public void initRecvBarGiftData(List<IMRecvBuyforGiftItem> buyforList){
        if(null != buyforList){
            for(IMRecvBuyforGiftItem imRecvGiftItem : buyforList){
                initRecvBarGiftData(imRecvGiftItem.userId,imRecvGiftItem.buyforList);
            }
        }
    }

    /**
     * 初始化四宫格已经接收到的bar礼物列表
     */
    private void initRecvBarGiftData(String userId, IMGiftNumItem[] bugForList){
        if(null != userIdIndexMap && userIdIndexMap.containsKey(userId)){
            HangOutVedioWindow outVedioWindow = vedioWindowMap.get(userIdIndexMap.get(userId));
            List<HangOutBarGiftListItem> outBarGiftListItems = new ArrayList<>();
            for(IMGiftNumItem imGiftNumItem : bugForList){
                GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(imGiftNumItem.giftId);
                if(null != giftItem){
                    outBarGiftListItems.add(new HangOutBarGiftListItem(giftItem.id,giftItem.middleImgUrl,
                            imGiftNumItem.giftNum));
                }
            }
            if(outBarGiftListItems.size()>0){
                outVedioWindow.setBarGiftList(outBarGiftListItems);
            }
        }
    }

    /**
     * 取男士位置
     * @return
     */
    public int getManIndex(){
        return MAN_CELL_INDEX;
    }

    /**
     * 初始化主播已经接受到的吧台礼物列表
     * @param item
     */
    public void initRecvBarGiftData(IMRecvEnterRoomItem item){
        initRecvBarGiftData(item.userId,item.bugForList);
    }

    /**
     * 切换到待添加主播状态
     * @param userId
     */
    public void switchWait2InviteStatus(String userId){
        if(null != userIdIndexMap && userIdIndexMap.containsKey(userId)){
            HangOutVedioWindow hangOutVedioWindow;
            synchronized (userIdIndexMap){
                int index = userIdIndexMap.remove(userId);;
                hangOutVedioWindow = vedioWindowMap.get(index);
                hangOutVedioWindow.setVedioDisconnectListener(null);
                hangOutVedioWindow.showWaitToInviteView();
            }
        }
    }

    /**
     * 主播直播间进入状态
     * @param userId
     * @param photoUrl
     * @param nickName
     * @param type
     * @param expires
     * @return 相应位置 0则为没有空位置
     */
    public int switchAnchorComingStatus(String userId, String photoUrl, String nickName,
                                          HangOutVedioWindow.AnchorComingType type, int expires){
        return switchAnchorComingStatus(userId, photoUrl, nickName, -1, type, expires);
    }

    /**
     * 主播直播间进入状态
     * @param userId
     * @param photoUrl
     * @param nickName
     * @param windowIndex 格子位置
     * @param type
     * @param expires
     * @return 相应位置 0则为没有空位置
     */
    public int switchAnchorComingStatus(String userId, String photoUrl, String nickName,int windowIndex,
                                         HangOutVedioWindow.AnchorComingType type, int expires){
        int cellIndex = 0;
        if(null == userIdIndexMap){
            return cellIndex;
        }
        HangOutVedioWindow outVedioWindow;
        if(!userIdIndexMap.containsKey(userId) ) {
            if(windowIndex > 0 && windowIndex < 5){
                outVedioWindow = getBlankVedioWindow(userId, windowIndex);
            }else{
                outVedioWindow = getBlankVedioWindow(userId);
            }
        }else{
            outVedioWindow = vedioWindowMap.get(userIdIndexMap.get(userId));
        }

        if(null != outVedioWindow){
            cellIndex = outVedioWindow.index;

            LoginItem loginItem = LoginManager.getInstance().getLoginItem();
            outVedioWindow.showAnchorComingView(mActivity,
                    new HangoutVedioWindowObj(userId, photoUrl, nickName,
                            null != loginItem && userId.equals(loginItem.userId)),
//                            null !=mIMHangOutRoomItem && mIMHangOutRoomItem.manId.equals(userId)),
                    type,expires);
        }

        return cellIndex;
    }

    /**
     * 开始视频推拉流
     * @param userId
     * @param playUrl
     */
    public void startLive(String userId, String[] playUrl){
        if(null != userIdIndexMap && userIdIndexMap.containsKey(userId) && null != playUrl && playUrl.length>0){
            Log.i(TAG, "开始视频推拉流 userId:" + userId + "\n,地址1：" +  playUrl[0] + "\n,地址2:" + playUrl[1]);

            HangOutVedioWindow outVedioWindow = vedioWindowMap.get(userIdIndexMap.get(userId));
            //add by Jagger 2019-3-26 先停再开
//            outVedioWindow.stopPushOrPullVedioStream();
            outVedioWindow.startPushOrPullVedioStream(mActivity,playUrl);
            outVedioWindow.setVedioDisconnectListener(mActivity);
        }
    }

    /**
     * 停止视频推拉流
     * @param userId
     */
    public void stopLive(String userId){
        if(null != userIdIndexMap && userIdIndexMap.containsKey(userId)){
            HangOutVedioWindow outVedioWindow = vedioWindowMap.get(userIdIndexMap.get(userId));
            outVedioWindow.setVedioDisconnectListener(null);
            outVedioWindow.stopPushOrPullVedioStream();
            outVedioWindow.showVedioStreamView(mActivity,outVedioWindow.getObj());
        }
    }

//    public enum SendInvitationResult{
//        Success,
//        Error4Inviting,
//        Error4Entered,
//        Fail
//    }

    /**
     * 发送邀请
     * @param userId
     * @param photoUrl
     * @param nickName
     * @param windowIndex 指定位置（0代表不指定）
     * @return 是否发送邀结果
     */
    public void sendInvitation(String roomId, String userId, String photoUrl, String nickName, int windowIndex, InviteEventListener listener){
        if(null == userIdIndexMap){
            return ;
        }
        HangOutVedioWindow outVedioWindow;
        if(!userIdIndexMap.containsKey(userId) ) {
            if(windowIndex > 0 && windowIndex < 5){
                outVedioWindow = getBlankVedioWindow(userId, windowIndex);
            }else{
                outVedioWindow = getBlankVedioWindow(userId);
            }
        }else{
            outVedioWindow = vedioWindowMap.get(userIdIndexMap.get(userId));
        }


        if(outVedioWindow == null){
            //满员
            if(listener != null){
                listener.onClickInvite(false, 1, mActivity.getString(R.string.hangout_open_door_error_full));
            }
        }else{
            //非满员
            switch (getVedioWindowStatus(outVedioWindow.index)){
                case Inviting:
                    //邀请中
                    if(listener != null){
                        listener.onClickInvite(false, 1, mActivity.getString(R.string.hangout_sent_invitation_fail_tip1));
                    }
                    break;
                case VideoStreaming:
                    //已在直播中
                    if(listener != null){
                        listener.onClickInvite(false, 1, mActivity.getString(R.string.hangout_sent_invitation_fail_tip2));
                    }
                    break;
                case OpeningDoor:
                    //已开门
                case WaitToInvite:
                    //当座位上没人时
                    //更新界面状态
                    //发送确认请求
                    outVedioWindow.sendInvitation(
                            new HangoutVedioWindowObj(userId, photoUrl, nickName,
                                    null != loginItem && userId.equals(loginItem.userId)),
                            roomId);
                    break;
            }
        }

//        if(null != outVedioWindow){
//            LoginItem loginItem = LoginManager.getInstance().getLoginItem();
//            if(!outVedioWindow.sendInvitation(
//                    new HangoutVedioWindowObj(userId, photoUrl, nickName,
//                            null != loginItem && userId.equals(loginItem.userId)),
//                    roomId)){
//                //邀请失败原因
//                if(outVedioWindow.getWindowStatus() == HangOutVedioWindow.VedioWindowStatus.Inviting){
//                    result = SendInvitationResult.Error4Inviting;
//                }else if(outVedioWindow.getWindowStatus() == HangOutVedioWindow.VedioWindowStatus.VideoStreaming){
//                    result = SendInvitationResult.Error4Entered;
//                }
//            }else {
//                result = SendInvitationResult.Success;
//            }
//        }
    }

    /**
     * 发送开门
     * @param knockId
     * @param anchorId
     * @param anchorNickName
     * @param anchorPhotoUrl
     * @param listener
     */
    public void sendOpenDoor(final String knockId, final String anchorId, String anchorNickName, String anchorPhotoUrl, final KnockEventListener listener){
        if(null == userIdIndexMap){
            return ;
        }

        HangOutVedioWindow outVedioWindow;
        if(!userIdIndexMap.containsKey(anchorId) ) {
            outVedioWindow = getBlankVedioWindow(anchorId);
        }else{
            outVedioWindow = vedioWindowMap.get(userIdIndexMap.get(anchorId));
        }

        if(outVedioWindow == null){
            //满员
            if(listener != null){
                listener.onOpenDoor(false, 1, mActivity.getString(R.string.hangout_open_door_error_full));
            }
        }else{
            //非满员
            switch (getVedioWindowStatus(outVedioWindow.index)){
                case Inviting:
                    //邀请中
                    if(listener != null){
                        listener.onOpenDoor(false, 1, mActivity.getString(R.string.hangout_sent_invitation_fail_tip1));
                    }
                    break;
                case OpeningDoor:
                    //已开门
                    if(listener != null){
                        listener.onOpenDoor(false, 1, mActivity.getString(R.string.hangout_open_door_error_already_open));
                    }
                    break;
                case VideoStreaming:
                    //已在直播中
                    if(listener != null){
                        listener.onOpenDoor(false, 1, mActivity.getString(R.string.hangout_sent_invitation_fail_tip2));
                    }
                    break;
                case WaitToInvite:
                    //当座位上没人时
                    //更新界面状态
                    switchAnchorComingStatus(anchorId, anchorPhotoUrl, anchorNickName,
                            HangOutVedioWindow.AnchorComingType.Man_Accepted_Anchor_Knock,0);

                    //发送确认请求
                    sendDealKnock(knockId, anchorId, new Consumer<HttpRespObject>() {
                        @Override
                        public void accept(HttpRespObject httpRespObject) throws Exception {
                            Log.i(TAG, "liveRoomChatManager AnchorKnock sendDealKnock:" + httpRespObject.isSuccess + ",errCode:" + httpRespObject.errCode);
                            if(!httpRespObject.isSuccess){
                                //处理失败
                                if(listener != null){
                                    listener.onOpenDoor(false, httpRespObject.errCode, httpRespObject.errMsg);
                                }

                                //进入失败，还原界面
                                if(httpRespObject.data != null){
                                    String anchorId = String.valueOf(httpRespObject.data);
                                    switchWait2InviteStatus(anchorId);
                                }

                            }

                            //成功则由 IM接收主播进入直播间通知处理
                        }
                    });
                    break;
            }
        }

    }

    /**
     * 同意某个主播敲门
     * @param knockId
     * @param observerResult
     */
    private void sendDealKnock(final String knockId, final String anchorId, Consumer<HttpRespObject> observerResult){
        //rxjava
        Observable<HttpRespObject> observerable = Observable.create(new ObservableOnSubscribe<HttpRespObject>() {

            @Override
            public void subscribe(final ObservableEmitter<HttpRespObject> emitter) {
                LiveRequestOperator.getInstance().DealKnockRequest(knockId, new OnRequestCallback(){
                    @Override
                    public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                        HttpRespObject respose = new HttpRespObject(isSuccess, errCode, errMsg, anchorId);

                        //发射
                        emitter.onNext(respose);
                    }
                });
            }
        });

        Disposable disposable = observerable
                .observeOn(AndroidSchedulers.mainThread())    //转由主线程处理结果
                .subscribe(observerResult);
        mCompositeDisposable.add(disposable);
    }

    /**
     * 取某个位置的窗口状态
     * @param windowIndex
     * @return
     */
    public HangOutVedioWindow.VedioWindowStatus getVedioWindowStatus(int windowIndex){
        HangOutVedioWindow.VedioWindowStatus windowStatus = HangOutVedioWindow.VedioWindowStatus.WaitToInvite;
        if(windowIndex > 0 && windowIndex < 5){
            windowStatus = vedioWindowMap.get(windowIndex).getWindowStatus();
        }
        return windowStatus;
    }

    /**
     * 获取空白位置
     * @param userId
     * @return
     */
    private HangOutVedioWindow getBlankVedioWindow(String userId){
        HangOutVedioWindow outVedioWindow = null;
        int index = 1;
        if(null ==mActivity || null== this.loginItem || null == this.mIMHangOutRoomItem){
            return outVedioWindow;
        }
        Log.d(TAG,"getBlankVedioWindow-userId:"+userId+" selfId:"+this.loginItem.userId);
//                +" manId:"+this.mIMHangOutRoomItem.manId);
//        if(userId.equals(this.mIMHangOutRoomItem.manId)){
//            //男士默认第一个窗格
//            index = 1;
//            outVedioWindow = vedioWindowMap.get(index);
//            synchronized (userIdIndexMap){
//                userIdIndexMap.put(userId,index);
//            }
//        }else
        if(userId.equals(this.loginItem.userId)){
            //自己默认第四个窗格
            index=MAN_CELL_INDEX;
            outVedioWindow = vedioWindowMap.get(index);
            synchronized (userIdIndexMap){
                userIdIndexMap.put(userId,index);
            }
        }else{
            for(; index<=vedioWindowMap.size(); index++){
//                if(userIdIndexMap.containsValue(index)){
//                    continue;
//                }
//                outVedioWindow = vedioWindowMap.get(index);
//                synchronized (userIdIndexMap){
//                    userIdIndexMap.put(userId,index);
//                }
//                break;
                outVedioWindow = getBlankVedioWindow(userId, index);
                if(outVedioWindow == null){
                    //没有返回可用格子，继续循环
                    continue;
                }else{
                    //否则退出循环
                    break;
                }
            }
        }
        return outVedioWindow;
    }

    /**
     * 获取指定空白位置
     * @param userId
     * @param index
     * @return
     */
    private HangOutVedioWindow getBlankVedioWindow(String userId, int index){
//        HangOutVedioWindow outVedioWindow = null;
//        if(null ==mActivity || null== this.loginItem || null == this.mIMHangOutRoomItem){
//            return null;
//        }
//
//        if(userId.equals(this.loginItem.userId)){
//            //自己默认第四个窗格
//            index=4;
//            outVedioWindow = vedioWindowMap.get(index);
//            synchronized (userIdIndexMap){
//                userIdIndexMap.put(userId,index);
//            }
//        }else{
//            outVedioWindow = vedioWindowMap.get(index);
//            synchronized (userIdIndexMap){
//                userIdIndexMap.put(userId,index);
//            }
//
//        }
//        return outVedioWindow;

        HangOutVedioWindow outVedioWindow = null;
        //如果这个位置没人坐 且 在范围内
        if(!userIdIndexMap.containsValue(index) && index > 0 && index < MAN_CELL_INDEX){
            outVedioWindow = vedioWindowMap.get(index);
            synchronized (userIdIndexMap){
                userIdIndexMap.put(userId,index);
            }
        }

        return outVedioWindow;
    }

    /**
     * 初始化hangout直播间状态
     * @return 对应格子位置
     */
    public int switchInvitedStatus(String userId, String photoUrl, String nickName, String[] vedioUrl){
        Log.d(TAG,"switchInvitedStatus-userId:"+userId+" photoUrl:"+photoUrl+" nickName:"+nickName);
        int cellIndex = 0;
        //1.判断男士是否有推流，男士对应第1个cell
        HangOutVedioWindow outVedioWindow = null;
        if(null == userIdIndexMap || null == vedioWindowMap){
            return cellIndex;
        }
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        //如果该userId对应的宫格还未初始化，那么按顺序去第一个未初始化的宫格
        if(!userIdIndexMap.containsKey(userId) && vedioWindowMap.size()>0){
            outVedioWindow = getBlankVedioWindow(userId);
        }else{
            outVedioWindow = vedioWindowMap.get(userIdIndexMap.get(userId));
        }
        if(null != outVedioWindow){
            HangoutVedioWindowObj obj = new HangoutVedioWindowObj(userId,
                    photoUrl, nickName, null != loginItem && userId.equals(loginItem.userId));
//                    mIMHangOutRoomItem.manId.equals(userId));
            //当且仅当主播进入直播间，才算在线
            obj.isOnLine = true;
            outVedioWindow.showVedioStreamView(mActivity,obj);
//            if(null != vedioUrl && vedioUrl.length>0){
//                outVedioWindow.setVedioDisconnectListener(mActivity);
//                outVedioWindow.startPushOrPullVedioStream(mActivity,vedioUrl);
//            }

            cellIndex = outVedioWindow.index;
            startLive(userId, vedioUrl);
        }
        return cellIndex;
    }

    /**
     * 缩小
     * @return
     */
    public boolean change2Normal(int index){
//        Log.d(TAG,"change2Normal-lastScaleVedioWindowIndex:"+lastScaleVedioWindowIndex);
//        if(null != userIdIndexMap){
//            for(int index : userIdIndexMap.values()){
//                HangOutVedioWindow vedioWindow = vedioWindowMap.get(index);
//                //当只把一个变大时，就把变大的变回原状
////                if(lastScaleVedioWindowIndex == index && vedioWindow.change2Normal()){
////                    return true;
////                }
//
//
//                //把一个变大，其它变小时，把所有窗口变回原状
//                vedioWindow.change2Normal();
//            }
//        }
////        return false;
        if(null != userIdIndexMap){
            HangOutVedioWindow vedioWindow = vedioWindowMap.get(index);
            vedioWindow.change2Normal();
        }
        return true;
    }

    /**
     * 放大
     * @param index
     * @return
     */
    public boolean change2Large(int index){
        Log.d(TAG,"change2Large-lastScaleVedioWindowIndex:"+index);
        boolean result = false;
//        if(null != userIdIndexMap){
//            for(int index : userIdIndexMap.values()){
//                HangOutVedioWindow vedioWindow = vedioWindowMap.get(index);
//                //把长按的变大
//                if(lastScaleVedioWindowIndex == index && vedioWindow.change2Large()){
//                    vedioWindow.bringToFront();
////                    vedioWindow.requestLayout();
//                    result = true;
//                }else{
//                    //把其它的变小
//                    vedioWindow.change2Normal();
//                }
//            }
//        }
        if(null != userIdIndexMap){
            HangOutVedioWindow vedioWindow = vedioWindowMap.get(index);
            vedioWindow.change2Large();
            result = true;
        }
        return result;
    }

    /**
     * 利用切换渲染器的方式放大
     * @param lastScaleVedioWindowIndex
     * @return
     */
    public boolean changeRender2Large(int lastScaleVedioWindowIndex, GLSurfaceView newSurfaceView, FrameLayout frameLayout){
        Log.d(TAG,"changeRender2Large-lastScaleVedioWindowIndex:"+lastScaleVedioWindowIndex);
        boolean result = false;
        if(null != userIdIndexMap){
            HangOutVedioWindow vedioWindow = vedioWindowMap.get(lastScaleVedioWindowIndex);
            //把长按的变大
            vedioWindow.changeRenderBinder(newSurfaceView, frameLayout);
            result = true;
        }
        return result;
    }

    /**
     * 切换到原来试用的渲染器的方式缩小
     * @param lastScaleVedioWindowIndex
     * @return
     */
    public boolean changeRender2Small(int lastScaleVedioWindowIndex){
        Log.d(TAG,"changeRender2Large-lastScaleVedioWindowIndex:"+lastScaleVedioWindowIndex);
        boolean result = false;
        if(null != userIdIndexMap){
            HangOutVedioWindow vedioWindow = vedioWindowMap.get(lastScaleVedioWindowIndex);
            //把长按的缩小
            vedioWindow.resetRenderBinder();
            result = true;
        }
        return result;
    }

    /**
     * 摄像头能否转换
     * @param cameraCanSwitch
     */
    public void setCameraCanSwitch(String userId, boolean cameraCanSwitch){
        Log.d(TAG,"setCameraCanSwitch-userId:"+userId);
        if(null != userIdIndexMap && userIdIndexMap.containsKey(userId)){
            vedioWindowMap.get(userIdIndexMap.get(userId)).setCameraCanSwitch(cameraCanSwitch);
        }
    }

    /**
     * 静音
     * @param onOrOff
     */
    public void mute(boolean onOrOff){
        Log.d(TAG,"mute-onOrOff:"+onOrOff);
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if(null != userIdIndexMap && null != loginItem && userIdIndexMap.containsKey(loginItem.userId)){
            HangOutVedioWindow hangOutVedioWindow = vedioWindowMap.get(userIdIndexMap.get(loginItem.userId));
            hangOutVedioWindow.setPushStreamMute(onOrOff);
        }
    }

    /**
     * 静音
     * @param onOrOff
     */
    public void slient(boolean onOrOff){
        Log.d(TAG,"slient-onOrOff:"+onOrOff);
        if(null != userIdIndexMap){
            for(int index : userIdIndexMap.values()){
                HangOutVedioWindow hangOutVedioWindow = vedioWindowMap.get(index);
                //!hangOutVedioWindow.getObj().isUserSelf 等同于 !hangOutVedioWindow.getObj().targetUserId.equals(loginItem.userId)
                if(null != hangOutVedioWindow.getObj() && !hangOutVedioWindow.getObj().isUserSelf){
                    hangOutVedioWindow.setPullStreamSilent(onOrOff);
                }
            }
        }
    }

    public void stopLSPubilsher() {
        for(HangOutVedioWindow hangOutVedioWindow : vedioWindowMap.values()){
            hangOutVedioWindow.stopPushOrPullVedioStream();
        }
    }

    /**
     * 更新礼物动画
     * @param toUid
     * @param msgItem
     * @param giftItem
     */
    public void updateVedioWindowGiftAnimData(String toUid, IMMessageItem msgItem, GiftItem giftItem) {
        if(!TextUtils.isEmpty(toUid) && null != userIdIndexMap && userIdIndexMap.containsKey(toUid)){
            //toUid不为空 针对指定用户窗口
            HangOutVedioWindow hangOutVedioWindow = vedioWindowMap.get(userIdIndexMap.get(toUid));
            //1.更新展示礼物动画;
            hangOutVedioWindow.addIMMessageItem(msgItem);
            //2.更新指定用户的吧台礼物列表
            if(giftItem.giftType == GiftItem.GiftType.Bar) {
                hangOutVedioWindow.updateBarGiftList(
                        new HangOutBarGiftListItem(giftItem.id,giftItem.middleImgUrl,msgItem.giftMsgContent.giftNum));
            }
        }
    }

    /**
     * 2019/3/20 Hardy
     * 更新礼物动画，全部主播播放
     * @param msgItem
     * @param giftItem
     */
    public void updateVedioWindowGiftAnimDataForAll(IMMessageItem msgItem, GiftItem giftItem) {
        if (userIdIndexMap != null) {
            // 男士 id
            String manId = this.loginItem != null ? this.loginItem.userId : "";
            for (String userId : userIdIndexMap.keySet()) {
                // 主播才播放动画
                if (!TextUtils.isEmpty(userId) && !userId.equals(manId)) {
                    updateVedioWindowGiftAnimData(userId, msgItem, giftItem);
                }
            }
        }
    }

    public Map<String ,Integer> getUserIdIndexMap(){
        return userIdIndexMap;
    }

    /**
     * 判断userId对应的主播是否已在线该HangOut直播间
     * @param userId
     * @return
     */
    public boolean checkIsOnLine(String userId){
        boolean isOnLine = false;

        if(userIdIndexMap.containsKey(userId)){
            HangOutVedioWindow hangOutVedioWindow = vedioWindowMap.get(userIdIndexMap.get(userId));
            isOnLine = (null != hangOutVedioWindow && null != hangOutVedioWindow.getObj() );//&& hangOutVedioWindow.getObj().isOnLine;
        }
        Log.d(TAG,"checkIsOnLine-userId:"+userId+" isOnLine:"+isOnLine);
        return isOnLine;
    }

    public void onActivityStop(){
        //四个窗格的大礼物动画也顺便结束一下
        if(null != userIdIndexMap){
            for (int index : userIdIndexMap.values()){
                vedioWindowMap.get(index).onActivityStop();
            }
        }
    }

    public void onPause() {
        Log.d(TAG,"onPause");
        if(null != userIdIndexMap){
            for (int index : userIdIndexMap.values()){
                vedioWindowMap.get(index).onPause();
            }
        }
    }

    /**
     * 资源释放
     */
    public void release(){
        if(null != vedioWindowMap){
            for(HangOutVedioWindow hangOutVedioWindow : vedioWindowMap.values()){
                hangOutVedioWindow.release();
            }
            vedioWindowMap.clear();
        }
        if(null != userIdIndexMap){
            userIdIndexMap.clear();
        }

        //解除所有订阅者
        mCompositeDisposable.clear();
    }
}
