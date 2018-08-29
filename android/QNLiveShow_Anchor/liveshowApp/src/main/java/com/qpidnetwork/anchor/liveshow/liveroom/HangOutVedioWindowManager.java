package com.qpidnetwork.anchor.liveshow.liveroom;

import android.text.TextUtils;
import android.widget.FrameLayout;

import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.LoginItem;
import com.qpidnetwork.anchor.im.listener.IMGiftNumItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRecvGiftItem;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.anchor.liveshow.liveroom.vedio.HangOutBarGiftListItem;
import com.qpidnetwork.anchor.liveshow.liveroom.vedio.HangOutVedioWindow;
import com.qpidnetwork.anchor.liveshow.liveroom.vedio.HangoutVedioWindowObj;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.utils.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Description:HangOut直播间四宫格状态管理器
 * <p>
 * Created by Harry on 2018/5/28.
 */
public class HangOutVedioWindowManager{

    private final String TAG = HangOutVedioWindowManager.class.getSimpleName();
    private HangOutLiveRoomActivity mActivity = null;
    private IMHangoutRoomItem mIMHangOutRoomItem;
    private Map<Integer,HangOutVedioWindow> vedioWindowMap = new HashMap<>();
    private Map<String,Integer> userIdIndexMap = new HashMap<>();
    private int vedioWindowWidth;

    public HangOutVedioWindowManager(HangOutLiveRoomActivity activity,IMHangoutRoomItem imHangOutRoomItem){
        this.mActivity = activity;
        this.mIMHangOutRoomItem = imHangOutRoomItem;
        vedioWindowWidth = DisplayUtil.getScreenWidth(activity)/2;
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
        //主播端多人互动原型上并没有要求视频可以放大缩小
        vedioWindow.setViewCanScale(false);
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
    public void initRecvBarGiftData(IMRecvGiftItem[] buyforList){
        if(null != buyforList){
            for(IMRecvGiftItem imRecvGiftItem : buyforList){
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
            HangOutVedioWindow hangOutVedioWindow = null;
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
     */
    public void switchAnchorComingStatus(String userId, String photoUrl, String nickName,
                                          HangOutVedioWindow.AnchorComingType type, int expires){
        if(null == userIdIndexMap){
            return;
        }
        HangOutVedioWindow outVedioWindow;
        if(!userIdIndexMap.containsKey(userId) ) {
            outVedioWindow = getBlankVedioWindow(userId);
        }else{
            outVedioWindow = vedioWindowMap.get(userIdIndexMap.get(userId));
        }
        if(null != outVedioWindow){
            LoginItem loginItem = LoginManager.getInstance().getLoginItem();
            outVedioWindow.showAnchorComingView(mActivity,
                    new HangoutVedioWindowObj(userId, photoUrl, nickName,
                            null != loginItem && userId.equals(loginItem.userId),
                            null !=mIMHangOutRoomItem && mIMHangOutRoomItem.manId.equals(userId)),
                    type,expires);
        }
    }

    /**
     * 开始视频推拉流
     * @param userId
     * @param playUrl
     */
    public void startLive(String userId, String[] playUrl){
        if(null != userIdIndexMap && userIdIndexMap.containsKey(userId) && null != playUrl && playUrl.length>0){
            HangOutVedioWindow outVedioWindow = vedioWindowMap.get(userIdIndexMap.get(userId));
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

    /**
     * 获取空白位置
     * @param userId
     * @return
     */
    private HangOutVedioWindow getBlankVedioWindow(String userId){
        HangOutVedioWindow outVedioWindow = null;
        int index = 1;
        if(null ==mActivity || null== mActivity.loginItem || null == mActivity.mIMHangOutRoomItem){
            return outVedioWindow;
        }
        Log.d(TAG,"getBlankVedioWindow-userId:"+userId+" selfId:"+mActivity.loginItem.userId
                +" manId:"+mActivity.mIMHangOutRoomItem.manId);
        if(userId.equals(mActivity.mIMHangOutRoomItem.manId)){
            //男士默认第一个窗格
            index = 1;
            outVedioWindow = vedioWindowMap.get(index);
            synchronized (userIdIndexMap){
                userIdIndexMap.put(userId,index);
            }
        }else if(userId.equals(mActivity.loginItem.userId)){
            //主播自己默认第四个窗格
            index=4;
            outVedioWindow = vedioWindowMap.get(index);
            synchronized (userIdIndexMap){
                userIdIndexMap.put(userId,index);
            }
        }else{
            for(; index<=vedioWindowMap.size(); index++){
                if(userIdIndexMap.containsValue(index)){
                    continue;
                }
                outVedioWindow = vedioWindowMap.get(index);
                synchronized (userIdIndexMap){
                    userIdIndexMap.put(userId,index);
                }
                break;
            }
        }
        return outVedioWindow;
    }

    /**
     * 初始化hangout直播间状态
     */
    public void switchInvitedStatus(String userId, String photoUrl, String nickName, String[] vedioUrl){
        Log.d(TAG,"switchInvitedStatus-userId:"+userId+" photoUrl:"+photoUrl+" nickName:"+nickName);
        //1.判断男士是否有推流，男士对应第1个cell
        HangOutVedioWindow outVedioWindow = null;
        if(null == userIdIndexMap || null == vedioWindowMap){
            return;
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
                    photoUrl, nickName, null != loginItem && userId.equals(loginItem.userId),
                    mIMHangOutRoomItem.manId.equals(userId));
            //当且仅当主播进入直播间，才算在线
            obj.isOnLine = true;
            outVedioWindow.showVedioStreamView(mActivity,obj);
            if(null != vedioUrl && vedioUrl.length>0){
                outVedioWindow.setVedioDisconnectListener(mActivity);
                outVedioWindow.startPushOrPullVedioStream(mActivity,vedioUrl);
            }
        }
    }

    /**
     * 缩小
     * @param lastScaleVedioWindowIndex
     * @return
     */
    public boolean change2Normal(int lastScaleVedioWindowIndex){
        Log.d(TAG,"change2Normal-lastScaleVedioWindowIndex:"+lastScaleVedioWindowIndex);
        if(null != userIdIndexMap){
            for(int index : userIdIndexMap.values()){
                HangOutVedioWindow vedioWindow = vedioWindowMap.get(index);
                if(lastScaleVedioWindowIndex == index && vedioWindow.change2Normal()){
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * 放大
     * @param lastScaleVedioWindowIndex
     * @return
     */
    public boolean change2Large(int lastScaleVedioWindowIndex){
        Log.d(TAG,"change2Large-lastScaleVedioWindowIndex:"+lastScaleVedioWindowIndex);
        if(null != userIdIndexMap){
            for(int index : userIdIndexMap.values()){
                HangOutVedioWindow vedioWindow = vedioWindowMap.get(index);
                if(lastScaleVedioWindowIndex == index && vedioWindow.change2Large()){
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * 切换摄像头前后置开关的可见与否
     * @param userId
     */
    public void changeCameraSwitchVisibility(String userId){
        Log.d(TAG,"changeCameraSwitchVisibility-userId:"+userId);
        if(null != userIdIndexMap && userIdIndexMap.containsKey(userId)){
            vedioWindowMap.get(userIdIndexMap.get(userId)).changeCameraSwitchVisibility();
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
            isOnLine = null != hangOutVedioWindow && null != hangOutVedioWindow.getObj()
                    && hangOutVedioWindow.getObj().isOnLine;
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
    }
}
