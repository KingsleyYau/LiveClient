package com.qpidnetwork.anchor.liveshow.liveroom.gift;

import android.app.Activity;
import android.support.v4.content.ContextCompat;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.anchor.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.advance.BigGiftAnimItem;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.advance.BigGiftAnimManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.normal.LiveGift;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.normal.LiveGiftItemView;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.normal.LiveGiftView;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.lang.ref.WeakReference;

/**
 * 礼物动画模块
 * Created by Hunter Mun on 2017/6/23.
 *
 */

public class ModuleGiftManager {

    private WeakReference<Activity> mActivity;
    private final String TAG = ModuleGiftManager.class.getSimpleName();
    /**
     * IMManager
     */
    //连击动画
    private LiveGiftView mLiveGiftView;

    //大礼物播放管理器
    private BigGiftAnimManager mBigGiftAnimManager;

    public ModuleGiftManager(Activity activity){
        this.mActivity = new WeakReference<Activity>(activity);
    }

    private boolean isGiftAnimShowedInHangOutRoom = false;

    public void setGiftAnimShowedInHangOutRoom(boolean isGiftAnimShowedInHangOutRoom){
        this.isGiftAnimShowedInHangOutRoom = isGiftAnimShowedInHangOutRoom;
    }

    /************************************** 消息分发器  ********************************************/
    /**
     * 分发礼物消息
     * @param msgItem
     */
    public void dispatchIMMessage(IMMessageItem msgItem){
//        Log.d(TAG,"dispatchIMMessage-msgItem:"+msgItem);
        if(msgItem != null && msgItem.msgType == IMMessageItem.MessageType.Gift){
            String giftId = msgItem.giftMsgContent.giftId;
            GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(giftId);
//            Log.d(TAG,"dispatchIMMessage-giftId:"+giftId+" giftItem:"+giftItem);
            if(giftItem != null){
                //本地已存在
                switch (giftItem.giftType){
                    case Normal: {
                        //分发给连击动画模块
                        Log.d(TAG,"dispatchIMMessage-本地详情存在，分发给连击动画模块");
                        addToNoramlGiftManager(msgItem);
                    }break;
                    case Bar:
                    case Celebrate:
                    case Advanced:{
                        //分发给大礼物动画
                        Log.d(TAG,"dispatchIMMessage-本地详情存在，分发给大礼物动画");
                        addToBigGiftManager(msgItem);
                    }break;
                    default: {
                        //其他类型丢掉
                    }break;
                }
            }else{
                //本地详情不存在，仅更新礼物详情，不显示动画
                Log.d(TAG,"dispatchIMMessage-本地详情不存在，仅更新礼物详情，不显示动画");
                NormalGiftManager.getInstance().getGiftDetail(giftId, null);
            }
        }
    }

    /**
     * 发送或收到连击动画添加到连接动画模块
     * @param msgItem
     */
    private void addToNoramlGiftManager(IMMessageItem msgItem){
        LiveGift liveGift = new LiveGift();
        liveGift.setGiftId(createUniqueMultiGiftIdentify(msgItem.userId,
                msgItem.giftMsgContent.giftId, String.valueOf(msgItem.giftMsgContent.multi_click_id)));
        liveGift.setNewRange(new LiveGift.ClickRange(msgItem.giftMsgContent.multi_click_start, msgItem.giftMsgContent.multi_click_end));
        liveGift.setObj(msgItem);
        mLiveGiftView.addGift(liveGift);
    }

    /**
     * 生成唯一multiclick gift id
     * @param userId
     * @param giftId
     * @param multiClickId
     * @return
     */
    private String createUniqueMultiGiftIdentify(String userId, String giftId, String multiClickId){
        String multiGiftId = userId + "_" + giftId + "_" + multiClickId;
        Log.d(TAG,"createUniqueMultiGiftIdentify");
        return multiClickId;
    }

    /**********************************  大礼物  **************************************/
    /**
     * 初始化大礼物view
     * @param simpleDraweeView
     */
    public void initAdvanceGift(SimpleDraweeView simpleDraweeView){
        mBigGiftAnimManager = new BigGiftAnimManager(simpleDraweeView);
    }

    /**
     * 设置吧台礼物播放控件
     * @param simpleDraweeView
     */
    public void setBarGiftAnimView(SimpleDraweeView simpleDraweeView){
        if(null != mBigGiftAnimManager){
            mBigGiftAnimManager.setBarGiftAnimView(simpleDraweeView);
        }
    }

    /**
     * 添加到大礼物模块
     * @param msgItem
     */
    private void addToBigGiftManager(IMMessageItem msgItem){
//        Log.d(TAG,"addToBigGiftManager-msgItem:"+msgItem);
        if(msgItem != null && msgItem.msgType == IMMessageItem.MessageType.Gift){
            //IMGiftMessageContent包含了gift的id、name、num等信息，且是大礼物，因此重点关注的是img
            GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(msgItem.giftMsgContent.giftId);
//            Log.d(TAG,"addToBigGiftManager-giftId:"+msgItem.giftMsgContent.giftId+" giftItem:"+giftItem);
            if(giftItem != null){
                String localPath = null;
                if(giftItem.giftType == GiftItem.GiftType.Advanced || giftItem.giftType == GiftItem.GiftType.Celebrate){
                    localPath = FileCacheManager.getInstance().getGiftLocalPath(giftItem.id, giftItem.srcWebpUrl);
                }else if(giftItem.giftType == GiftItem.GiftType.Bar){
                    localPath = FileCacheManager.getInstance().getGiftLocalPath(giftItem.id, giftItem.bigImageUrl);
                }
//                Log.d(TAG,"addToBigGiftManager-localPath:"+localPath);
                if(SystemUtils.fileExists(localPath)){
                    if(mBigGiftAnimManager != null){
                        BigGiftAnimItem.BigGiftAnimType type = null;
                        if(giftItem.giftType == GiftItem.GiftType.Advanced){
                            type = BigGiftAnimItem.BigGiftAnimType.AdvanceGift;
                        }else if(giftItem.giftType == GiftItem.GiftType.Celebrate){
                            type = BigGiftAnimItem.BigGiftAnimType.CelebGift;
                        }else{
                            type = BigGiftAnimItem.BigGiftAnimType.BarGift;
                        }
                        mBigGiftAnimManager.addBigGiftAnimItem(new BigGiftAnimItem(localPath,msgItem.giftMsgContent.giftNum,type,giftItem.playTime));
                    }
                }else{
                    //本地文件不存在，仅下载
                    Log.d(TAG,"giftId:"+giftItem.id+" 对应的大礼物，本地动画文件不存在，这里仅下载，不播放动画");
                    NormalGiftManager.getInstance().getGiftImage(giftItem.id, GiftImageType.BigAnimSrc, null);
                }
            }
        }
    }

    /***********************************  连击动画  ***********************************/
    public void initMultiGift(FrameLayout viewContent, int giftShowMaxSum){
        //初始化连击礼物控件
        mLiveGiftView = new LiveGiftView(mActivity.get(), viewContent){
            @Override
            public void onSetChileView(LiveGift liveGift , LiveGiftItemView v) {
                if(liveGift.getViewType() == IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom.ordinal()
                    || liveGift.getViewType() == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom.ordinal() ) {
                    // 私密直播间礼物样式
                    v.setBg(ContextCompat.getDrawable(mActivity.get(), R.drawable.mult_gift_bg_4_private_room));
                }

                if(liveGift.getViewType() != IMRoomInItem.IMLiveRoomType.HangoutRoom.ordinal()) {
                    // 自定义连击数字图片资源ID
                    v.setImgXResId(R.drawable.ic_x);
                    v.setImg0ResId(R.drawable.ic_0);
                    v.setImg1ResId(R.drawable.ic_1);
                    v.setImg2ResId(R.drawable.ic_2);
                    v.setImg3ResId(R.drawable.ic_3);
                    v.setImg4ResId(R.drawable.ic_4);
                    v.setImg5ResId(R.drawable.ic_5);
                    v.setImg6ResId(R.drawable.ic_6);
                    v.setImg7ResId(R.drawable.ic_7);
                    v.setImg8ResId(R.drawable.ic_8);
                    v.setImg9ResId(R.drawable.ic_9);
                }
                v.setChildView(getGiftView(liveGift));
            }
        };
        //连击动画速度
        mLiveGiftView.setDuration4NumShow(mActivity.get().getResources().getInteger(R.integer.multiAnimationDuration));
        //动画最大显示条数
        mLiveGiftView.setMaxSumShowed(giftShowMaxSum);
    }

    public void showMultiGiftAs(View anchorView){
        //绑定锚控件
//        mLiveGiftView.bind(anchorView);
    }

    /**
     * 单个礼物Item初始化
     * @param liveGift
     * @return
     */
    private View getGiftView(LiveGift liveGift){
        if(null != mActivity && null != mActivity.get()){
            LayoutInflater inflater = LayoutInflater.from(mActivity.get());
            View view = inflater.inflate(R.layout.item_multiclick_gift_anim , null);
            View ll_giftAnimContainer = view.findViewById(R.id.ll_giftAnimContainer);
            View ll_giftInfo = view.findViewById(R.id.ll_giftInfo);
            CircleImageView civ_photo = (CircleImageView)view.findViewById(R.id.civ_photo);
            TextView tvNickName = (TextView)view.findViewById(R.id.tvNickName);
            TextView tvGiftName = (TextView)view.findViewById(R.id.tvGiftName);
            ImageView ivGift = (ImageView)view.findViewById(R.id.ivGift);
            if(liveGift.getObj() instanceof IMMessageItem){
                IMMessageItem msgItem = (IMMessageItem)liveGift.getObj();
                if(msgItem != null && null != msgItem.giftMsgContent){
                    GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(msgItem.giftMsgContent.giftId);
                    if(isGiftAnimShowedInHangOutRoom){
                        ll_giftInfo.setVisibility(View.GONE);
                        civ_photo.setVisibility(View.GONE);
                    }else{
                        tvNickName.setText(msgItem.nickName);
                        IMUserBaseInfoItem imUserBaseInfoItem = IMManager.getInstance().getUserInfo(msgItem.userId);
                        if(null != imUserBaseInfoItem && !TextUtils.isEmpty(imUserBaseInfoItem.photoUrl)){
                            Log.d(TAG,"getGiftView-userId:"+msgItem.userId+" photoUrl:"+imUserBaseInfoItem.photoUrl);
                            Picasso.with(mActivity.get())
                                    .load(imUserBaseInfoItem.photoUrl)
                                    .placeholder(R.drawable.ic_default_photo_man)
                                    .error(R.drawable.ic_default_photo_man)
                                    .memoryPolicy(MemoryPolicy.NO_CACHE)
                                    .into(civ_photo);
                        }

                        if(giftItem != null && !TextUtils.isEmpty(giftItem.name)){
                            tvGiftName.setText(giftItem.name);
                        }else{
                            tvGiftName.setText(msgItem.giftMsgContent.giftId);
                        }
                    }
                    if(!TextUtils.isEmpty(giftItem.bigImageUrl)){
                        Picasso.with(mActivity.get())
                                .load(giftItem.bigImageUrl)
                                .placeholder(R.drawable.ic_default_gift)
                                .error(R.drawable.ic_default_gift)
                                .into(ivGift);
                    }
                }
            }
            return view;
        }
        return null;
    }

    public void stopAdvanceGiftAnim(){
        //清空大礼物动画队列
        if(mBigGiftAnimManager != null){
            mBigGiftAnimManager.onDestroy();
        }
    }

    public void stopMultiGiftAnim(){
        //回收资源
        if(mLiveGiftView != null) {
            mLiveGiftView.dismiss();
        }
    }

    /**
     * 连击动画控件回收
     */
    public void onMultiGiftDestroy(){
        stopAdvanceGiftAnim();
        stopMultiGiftAnim();
    }

}
