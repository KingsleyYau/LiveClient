package com.qpidnetwork.anchor.liveshow.manager;

import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.im.IMInviteLaunchEventListener;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMInviteListItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.im.listener.IMSendInviteInfoItem;
import com.qpidnetwork.anchor.utils.Log;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;

/**
 * PC和APP切换视频推流管理器
 * （必需在 IMManager 初始化后初始化)
 * @author Jagger 2019-11-8
 */
public class ChangeVideoPushManager implements IMInviteLaunchEventListener {
    private static ChangeVideoPushManager instance = null;
    private IMManager mIMManager;
    private List<OnVideoChangeEvent> OnVideoChangeEventList ;

    public static ChangeVideoPushManager newInstance() {
        if (instance == null) {
            instance = new ChangeVideoPushManager();
        }
        return instance;
    }

    public static synchronized ChangeVideoPushManager getInstance() {
        return instance;
    }

    private ChangeVideoPushManager(){
        mIMManager = IMManager.getInstance();
        mIMManager.registerIMInviteLaunchEventListener(this);

        OnVideoChangeEventList = new ArrayList<>();
    }

    /**
     * 注册监听
     * @param onVideoChangeEvent
     */
    public void registerOnVideoChangeEvent(OnVideoChangeEvent onVideoChangeEvent){
        if(!OnVideoChangeEventList.contains(onVideoChangeEvent)){
            OnVideoChangeEventList.add(onVideoChangeEvent);
        }
    }

    /**
     * 反注册监听
     * @param onVideoChangeEvent
     */
    public void unregisterOnVideoChangeEvent(OnVideoChangeEvent onVideoChangeEvent){
        if(OnVideoChangeEventList.contains(onVideoChangeEvent)){
            OnVideoChangeEventList.remove(onVideoChangeEvent);
        }
    }

    /**
     * 接收PC转APP推流事件
     * @param data
     */
    private void doOnPcToApp(final PcToAppData data){
        Observable<PcToAppData> observable = Observable.create(new ObservableOnSubscribe<PcToAppData>() {
            @Override
            public void subscribe(ObservableEmitter<PcToAppData> emitter) throws Exception {
                emitter.onNext(data);
                emitter.onComplete();
            }
        });

        Observer<PcToAppData> observer = new Observer<PcToAppData>() {
            Disposable disposable;
            @Override
            public void onSubscribe(Disposable d) {
                disposable = d;
            }

            @Override
            public void onNext(PcToAppData pcToAppData) {
                //通知外部
                for (OnVideoChangeEvent onVideoChangeEvent :OnVideoChangeEventList) {
                    onVideoChangeEvent.onPcToApp(pcToAppData.manId, pcToAppData.manName, pcToAppData.manPhotoUrl);
                }
            }

            @Override
            public void onError(Throwable e) {
            }

            @Override
            public void onComplete() {
                disposable.dispose();
            }
        };

        observable
            .observeOn(AndroidSchedulers.mainThread())	//转由主线程处理结果
            .subscribe(observer);
    }

    //------------------- 应邀监听 start -------------------
    //---------------- 用于接收PC转APP推流事件 ----------------//
    @Override
    public void OnRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo) {

    }

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnAnchorSwitchFlow(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String[] pushUrl, IMClientListener.IMDeviceType deviceType) {

    }

    @Override
    public void OnSendImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMSendInviteInfoItem inviteInfoItem) {
        Log.i("Jagger" , "ChangeVideoPushManager OnSendImmediatePrivateInvite:" + inviteInfoItem.inviteId);
        if(inviteInfoItem != null && inviteInfoItem.deviceType == IMClientListener.IMDeviceType.App){
            PcToAppData data = new PcToAppData(inviteInfoItem.userId,inviteInfoItem.userName,inviteInfoItem.userPhotoUrl);
            doOnPcToApp(data);
        }
    }

//    @Override
//    public void OnSendImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String invitationId, int timeout, String roomId) {
//        Log.i("Jagger" , "ChangeVideoPushManager OnSendImmediatePrivateInvite:" + invitationId);
//        // TODO test
//        PcToAppData data = new PcToAppData("123","Test Man","https://www.baidu.com/s?wd=%E4%BB%8A%E6%97%A5%E6%96%B0%E9%B2%9C%E4%BA%8B&tn=SE_Pclogo_6ysd4c7a&sa=ire_dl_gh_logo&rsv_dl=igh_logo_pc");
//        doOnPcToApp(data);
//    }

    @Override
    public void OnRecvInviteReply(String inviteId, IMClientListener.InviteReplyType replyType, String roomId, LiveRoomType roomType, String anchorId, String nickName, String avatarImg) {

    }

    @Override
    public void OnGetInviteInfo(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMInviteListItem inviteItem) {

    }
    //------------------- 应邀监听 end -------------------


    //------------------- 数据结构定义 start -------------------
    /**
     * 视频切换事件
     */
    public interface OnVideoChangeEvent {

        /**
         * 从PC切换到APP
         */
        void onPcToApp(String manId, String manName, String manPhotoUrl);
    }

    /**
     * PC转APP数据
     */
    private class PcToAppData{
        public String manId,  manName,  manPhotoUrl;

        public PcToAppData(String manId, String manName, String manPhotoUrl){
            this.manId = manId;
            this.manName = manName;
            this.manPhotoUrl = manPhotoUrl;
        }
    }

    //------------------- 数据结构定义 end -------------------
}
