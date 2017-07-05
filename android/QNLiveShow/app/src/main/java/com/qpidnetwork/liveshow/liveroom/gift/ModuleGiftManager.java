package com.qpidnetwork.liveshow.liveroom.gift;

import android.app.Activity;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.httprequest.item.GiftItem;
import com.qpidnetwork.im.IMManager;
import com.qpidnetwork.im.listener.IMMessageItem;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.liveshow.liveroom.UserPhotoImageDownloader;
import com.qpidnetwork.liveshow.liveroom.gift.advance.AdvanceGiftManager;
import com.qpidnetwork.liveshow.liveroom.gift.downloader.FileDownloadManager;
import com.qpidnetwork.liveshow.liveroom.gift.downloader.IFileDownloadedListener;
import com.qpidnetwork.liveshow.liveroom.gift.normal.LiveGift;
import com.qpidnetwork.liveshow.liveroom.gift.normal.LiveGiftItemView;
import com.qpidnetwork.liveshow.liveroom.gift.normal.LiveGiftView;
import com.squareup.picasso.Picasso;

/**
 * 礼物动画模块
 * Created by Hunter Mun on 2017/6/23.
 */

public class ModuleGiftManager {

    private Activity mActivity;
    /**
     * IMManager
     */
    private IMManager mIManager;
    //连击动画
    private LiveGiftView mLiveGiftView;

    //大礼物播放管理器
    private AdvanceGiftManager mAdvanceGiftManager;

    public ModuleGiftManager(Activity activity){
        this.mActivity = activity;
        mIManager =IMManager.getInstance();
    }



    /************************************** 消息分发器  ********************************************/
    /**
     * 分发礼物消息
     * @param msgItem
     */
    public void dispatchIMMessage(IMMessageItem msgItem){
        if(msgItem != null && msgItem.msgType == IMMessageItem.MessageType.Gift){
            String giftId = msgItem.giftMsgContent.giftId;
            GiftItem giftItem = mIManager.getLocalGiftDetailById(giftId);
            if(giftItem != null){
                //本地已存在
                switch (giftItem.giftType){
                    case Normal: {
                        //分发给连击动画模块
                        addToNoramlGifatManager(msgItem);
                    }break;
                    case AdvancedAnimation:{
                        //分发给大礼物动画
                        addToAdvanceGiftManager(msgItem);
                    }break;
                    default: {
                        //其他类型丢掉
                    }break;
                }
            }else{
                //本地详情不存在，仅更新礼物详情，不显示动画
                mIManager.synGiftDetail(giftId, null);
            }
        }
    }

    /**
     * 发送或收到连击动画添加到连接动画模块
     * @param msgItem
     */
    private void addToNoramlGifatManager(IMMessageItem msgItem){
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
        return userId + "_" + giftId + "_" + multiClickId;
    }

    /**********************************  大礼物  **************************************/
    /**
     * 初始化大礼物view
     * @param simpleDraweeView
     */
    public void initAdvanceGift(SimpleDraweeView simpleDraweeView){
        mAdvanceGiftManager = new AdvanceGiftManager(mActivity, simpleDraweeView);
    }

    /**
     * 添加到大礼物模块
     * @param msgItem
     */
    private void addToAdvanceGiftManager(IMMessageItem msgItem){
        if(msgItem != null && msgItem.msgType == IMMessageItem.MessageType.Gift){
            GiftItem giftItem = mIManager.getLocalGiftDetailById(msgItem.giftMsgContent.giftId);
            if(giftItem != null && giftItem.giftType == GiftItem.GiftType.AdvancedAnimation){
                if(FileDownloadManager.getInstance().fileExists(giftItem.id, giftItem.srcUrl)){
                    String localPath = FileDownloadManager.getInstance().getLocalFilePath(giftItem.id, giftItem.srcUrl);
                    if(mAdvanceGiftManager != null){
                        mAdvanceGiftManager.addAdvanceGiftItem(localPath);
                    }
                }else if(!TextUtils.isEmpty(giftItem.srcUrl)){
                    //本地文件不存在，仅下载
                    FileDownloadManager.getInstance().start(giftItem.id, giftItem.srcUrl, new IFileDownloadedListener() {
                        @Override
                        public void onCompleted(String localFilePath, String fileId, String fileUrl) {

                        }
                    });
                }
            }
        }
    }

    /***********************************  连击动画  ***********************************/
    public void initMultiGift(){
        //初始化连击礼物控件
        mLiveGiftView = new LiveGiftView(mActivity){
            @Override
            public void onSetChileView(LiveGift liveGift , LiveGiftItemView v) {
                v.setChildView(getGitfView(liveGift));
            }
        };
        //连击动画速度
        mLiveGiftView.setDuration4NumShow(mActivity.getResources().getInteger(R.integer.multiAnimationDuration));
    }

    public void showMultiGiftAs(View anchorView){
        //绑定锚控件
        mLiveGiftView.bind(anchorView);
    }

    /**
     * 单个礼物Item初始化
     * @param liveGift
     * @return
     */
    private View getGitfView(LiveGift liveGift){
        LayoutInflater inflater = LayoutInflater.from(mActivity);
        View view = inflater.inflate(R.layout.item_multiclick_gift_anim , null);
        CircleImageView civ_photo = (CircleImageView)view.findViewById(R.id.civ_photo);
        TextView tvNickName = (TextView)view.findViewById(R.id.tvNickName);
        TextView tvGiftName = (TextView)view.findViewById(R.id.tvGiftName);
        ImageView ivGift = (ImageView)view.findViewById(R.id.ivGift);
        if(liveGift.getObj() instanceof IMMessageItem){
            IMMessageItem msgItem = (IMMessageItem)liveGift.getObj();
            if(msgItem != null){

                tvNickName.setText(msgItem.nickName);
                new UserPhotoImageDownloader(mActivity)
                        .setDefaultResource(R.drawable.circleimageview_hugh)
                        .loadUserPhoto(msgItem.userId).into(civ_photo);

                GiftItem giftItem = IMManager.getInstance().getLocalGiftDetailById(msgItem.giftMsgContent.giftId);
                if(giftItem != null && !TextUtils.isEmpty(giftItem.name)){
                    tvGiftName.setText(giftItem.name);
                }else{
                    tvGiftName.setText(msgItem.giftMsgContent.giftId);
                }

                if(!TextUtils.isEmpty(giftItem.smallimgurl)){
                    Picasso.with(mActivity).load(giftItem.smallimgurl).into(ivGift);
                }
            }
        }
        return view;
    }

    /**
     * 连击动画控件回收
     */
    public void onMultiGiftDetroy(){
        if(mLiveGiftView != null) {
            mLiveGiftView.dismiss();
        }
    }

}
