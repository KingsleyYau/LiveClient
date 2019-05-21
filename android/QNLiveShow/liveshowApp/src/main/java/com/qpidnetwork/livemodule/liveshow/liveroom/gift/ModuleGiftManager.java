package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import android.app.Activity;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.RoomThemeManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.advance.AdvanceGiftItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.advance.AdvanceGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.advance.AdvancePngGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.normal.LiveGift;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.normal.LiveGiftItemView;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.normal.LiveGiftView;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.util.Log;

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
    private AdvanceGiftManager mAdvanceGiftManager;
    //静态礼物放管理器
    private AdvancePngGiftManager mAdvancePngGiftManager;

    public ModuleGiftManager(Activity activity){
        this.mActivity = new WeakReference<>(activity);
    }

    /************************************** 消息分发器  ********************************************/
    /**
     * 分发礼物消息
     * @param msgItem
     */
    public void dispatchIMMessage(IMMessageItem msgItem, IMRoomInItem.IMLiveRoomType liveRoomType){
        if(msgItem != null && msgItem.msgType == IMMessageItem.MessageType.Gift){
            String giftId = msgItem.giftMsgContent.giftId;
            GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(giftId);
            if(giftItem != null){
                //本地已存在
                switch (giftItem.giftType){
                    case Normal: {
                        Log.d(TAG,"dispatchIMMessage-本地详情存在，分发给连击动画模块");
                        //设置连击礼物背景
                        RoomThemeManager roomThemeManager = new RoomThemeManager();
                        Drawable drawable = roomThemeManager.getRoomRepeatGiftAnimBgDrawable(
                                mActivity.get(),
                                liveRoomType);
                        //分发给连击动画模块
                        addToNormalGiftManager(msgItem, liveRoomType.ordinal(), drawable);
                    }break;
                    case Advanced:
                    case Celebrate:
                    case Bar:
                        //分发给大礼物动画
                        Log.d(TAG,"dispatchIMMessage-本地详情存在，分发给大礼物动画");
                        addToAdvanceGiftManager(msgItem);
                        break;
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
     * @param giftType 礼物类型
     */
    private void addToNormalGiftManager(IMMessageItem msgItem, int giftType, Drawable background){
        LiveGift liveGift = new LiveGift();
        liveGift.setGiftId(createUniqueMultiGiftIdentify(msgItem.userId,
                msgItem.giftMsgContent.giftId, String.valueOf(msgItem.giftMsgContent.multi_click_id)));
        liveGift.setNewRange(new LiveGift.ClickRange(msgItem.giftMsgContent.multi_click_start, msgItem.giftMsgContent.multi_click_end));
        liveGift.setObj(msgItem);
        liveGift.setViewType(giftType);
        if(background != null){
            liveGift.setBackground(background);
        }
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
        return userId + "_" + giftId + "_" + multiClickId;
    }

    /**********************************  大礼物  **************************************/
    /**
     * 初始化大礼物view
     * @param simpleDraweeView
     */
    public void initAdvanceGift(SimpleDraweeView simpleDraweeView){
        mAdvanceGiftManager = new AdvanceGiftManager(simpleDraweeView);
    }

//    /**
//     * 设置吧台礼物播放控件
//     * @param simpleDraweeView
//     */
//    public void setBarGiftAnimView(SimpleDraweeView simpleDraweeView){
//        if(null == mAdvancePngGiftManager){
//            mAdvanceGiftManage.(simpleDraweeView);
//        }
//    }

    /**
     * 设置吧台礼物播放控件
     * @param simpleDraweeView
     */
    public void initAdvancePngGift(SimpleDraweeView simpleDraweeView){
        mAdvancePngGiftManager = new AdvancePngGiftManager(simpleDraweeView);
    }

    /**
     * 添加到大礼物模块
     * @param msgItem
     */
    private void addToAdvanceGiftManager(IMMessageItem msgItem){
        if(msgItem != null && msgItem.msgType == IMMessageItem.MessageType.Gift){
            //IMGiftMessageContent包含了gift的id、name、num等信息，且是大礼物，因此重点关注的是img
            GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(msgItem.giftMsgContent.giftId);
            if(giftItem != null ){
                //本地路径
                String localPath = null;
                if(giftItem.giftType == GiftItem.GiftType.Advanced || giftItem.giftType == GiftItem.GiftType.Celebrate){
                    localPath = FileCacheManager.getInstance().getGiftLocalPath(giftItem.id, giftItem.srcWebpUrl);
                }else if(giftItem.giftType == GiftItem.GiftType.Bar){
                    localPath = FileCacheManager.getInstance().getGiftLocalPath(giftItem.id, giftItem.middleImgUrl);
                }

                //礼物图片
                AdvanceGiftItem.AdvanceGiftType type = null;
                if(SystemUtils.fileExists(localPath)){
                    //生成礼物
                    if(giftItem.giftType == GiftItem.GiftType.Advanced){
                        type = AdvanceGiftItem.AdvanceGiftType.AdvanceGift;

                        if(mAdvanceGiftManager != null){
                            mAdvanceGiftManager.addAdvanceGiftItem(new AdvanceGiftItem(localPath, msgItem.giftMsgContent.giftNum, type));
                        }

                    }else if(giftItem.giftType == GiftItem.GiftType.Celebrate){
                        type = AdvanceGiftItem.AdvanceGiftType.CelebGift;

                        if(mAdvanceGiftManager != null){
                            mAdvanceGiftManager.addAdvanceGiftItem(new AdvanceGiftItem(localPath, msgItem.giftMsgContent.giftNum, type));
                        }
                    }else if(giftItem.giftType == GiftItem.GiftType.Bar){
                        type = AdvanceGiftItem.AdvanceGiftType.BarGift;

                        if(mAdvancePngGiftManager != null){
                            mAdvancePngGiftManager.addPngGiftAnimItem(new AdvanceGiftItem(localPath, msgItem.giftMsgContent.giftNum, type, 1));
                        }
                    }
                }else{
                    //本地文件不存在，仅下载
                    Log.d(TAG,"giftId:"+giftItem.id+" 对应的大礼物，本地动画文件不存在，这里仅下载，不播放动画");
                    if(giftItem.giftType == GiftItem.GiftType.Advanced ||
                            giftItem.giftType == GiftItem.GiftType.Celebrate){
                        NormalGiftManager.getInstance().getGiftImage(giftItem.id, GiftImageType.BigAnimSrc, null);
                    }else if(giftItem.giftType == GiftItem.GiftType.Bar){
                        NormalGiftManager.getInstance().getGiftImage(giftItem.id, GiftImageType.BigPngSrc, null);
                    }

                }
            }
        }
    }

    /***********************************  连击动画  ***********************************/
    /**
     *
     * @param viewContent    动画控件容器
     * @param giftShowMaxSum 动画最大显示条数
     */
    public void initMultiGift(FrameLayout viewContent, int giftShowMaxSum){
        //初始化连击礼物控件
        mLiveGiftView = new LiveGiftView(mActivity.get(), viewContent){
            @Override
            public void onSetChileView(LiveGift liveGift , LiveGiftItemView v) {
                Log.i("Jagger" , "initMultiGift onSetChileView:" + ((IMMessageItem)liveGift.getObj()).msgType.name());
                v.setChildView(getGiftView(liveGift));
            }
        };
        //连击动画速度
        mLiveGiftView.setDuration4NumShow(mActivity.get().getResources().getInteger(R.integer.multiAnimationDuration));
        //动画最大显示条数
        mLiveGiftView.setMaxSumShowed(giftShowMaxSum);
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
            CircleImageView civ_photo = (CircleImageView)view.findViewById(R.id.civ_photo);
            LinearLayout ll_gift_info = view.findViewById(R.id.ll_gift_info);
            TextView tvNickName = (TextView)view.findViewById(R.id.tvNickName);
            TextView tvGiftName = (TextView)view.findViewById(R.id.tvGiftName);
            ImageView ivGift = (ImageView)view.findViewById(R.id.ivGift);
            if(liveGift.getObj() instanceof IMMessageItem){
                IMMessageItem msgItem = (IMMessageItem)liveGift.getObj();
                if(msgItem != null){

                    if(liveGift.getViewType() == IMRoomInItem.IMLiveRoomType.HangoutRoom.ordinal()){
                        //如果是HangOut连击礼物，则隐藏部分控件
                        ll_gift_info.setVisibility(View.GONE);
                        civ_photo.setVisibility(View.GONE);
                    }else{
                        //如果是普通直播间
                        tvNickName.setText(msgItem.nickName);
                        IMUserBaseInfoItem imUserBaseInfoItem = IMManager.getInstance().getUserInfo(msgItem.userId);
                        if(null != imUserBaseInfoItem && !TextUtils.isEmpty(imUserBaseInfoItem.photoUrl)){
                            Log.d(TAG,"getGiftView-userId:"+msgItem.userId+" photoUrl:"+imUserBaseInfoItem.photoUrl);
//                        Picasso.with(mActivity.get())
//                                .load(imUserBaseInfoItem.photoUrl)
//                                .placeholder(R.drawable.ic_default_photo_man)
//                                .error(R.drawable.ic_default_photo_man)
//                                .memoryPolicy(MemoryPolicy.NO_CACHE)
//                                .into(civ_photo);
                            PicassoLoadUtil.loadUrlNoMCache(civ_photo,imUserBaseInfoItem.photoUrl,R.drawable.ic_default_photo_man);
                        }
                    }

                    GiftItem giftItem = NormalGiftManager.getInstance().
                            getLocalGiftDetail(msgItem.giftMsgContent.giftId);
                    if(giftItem != null && !TextUtils.isEmpty(giftItem.name)){
                        tvGiftName.setText(giftItem.name);
                    }else{
                        tvGiftName.setText(msgItem.giftMsgContent.giftId);
                    }
                    if(!TextUtils.isEmpty(giftItem.bigImageUrl)){
//                        Picasso.with(mActivity.get())
//                                .load(giftItem.bigImageUrl)
//                                .placeholder(R.drawable.ic_default_gift)
//                                .error(R.drawable.ic_default_gift)
//                                .into(ivGift);
                        PicassoLoadUtil.loadUrl(ivGift,giftItem.bigImageUrl,R.drawable.ic_default_gift);
                    }
                }
            }
            return view;
        }
        return null;
    }

    public void onMultiGiftOnStop(){
        //清空大礼物动画队列
        if(mAdvanceGiftManager != null){
            mAdvanceGiftManager.onDestroy();
        }
    }

    /**
     * 连击动画控件回收
     */
    public void onMultiGiftDestroy(){
        onMultiGiftOnStop();
        //回收资源
        if(mLiveGiftView != null) {
            mLiveGiftView.dismiss();
        }
    }

    /**
     * 销毁
     */
    public void destroy(){
        //销毁
        if(mLiveGiftView != null) {
            mLiveGiftView.destroy();
        }
    }

}
