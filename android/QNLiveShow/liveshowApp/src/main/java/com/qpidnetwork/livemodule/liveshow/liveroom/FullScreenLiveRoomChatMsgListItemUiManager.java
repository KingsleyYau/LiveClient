package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.view.View;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.livemsglist.ViewHolder;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvKnockRequestItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.im.listener.IMVoucherMessageContent;
import com.qpidnetwork.livemodule.liveshow.model.LiveRoomMsgListItem;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.utils.StringUtil;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;

/**
 * @author Jagger 2019-9-6
 * 直播间聊天消息列表item样式处理
 */
public class FullScreenLiveRoomChatMsgListItemUiManager {

    private Context mContext;
    private RoomThemeManager roomThemeManager;
    /**
     * 当前主播ID/hangout直播间男士ID
     */
    private String mCurrAnchorId ;
    /**
     * 当前直播间类型
     */
    private IMRoomInItem.IMLiveRoomType currLiveRoomType;

    //新增消息列表item点击事件
    private LiveMessageListItemClickListener mLiveMessageListItemClickListener;

    public interface LiveMessageListItemClickListener{
        void onItemClick(IMMessageItem item);
    }

    public FullScreenLiveRoomChatMsgListItemUiManager(Context context, RoomThemeManager roomThemeManager, IMRoomInItem.IMLiveRoomType imLiveRoomType, String currAnchorId){
        mContext = context;
        this.roomThemeManager = roomThemeManager;
        currLiveRoomType = imLiveRoomType;
        mCurrAnchorId = currAnchorId;
    }

    public void setLiveMessageListItemClickListener(LiveMessageListItemClickListener listItemClickListener){
        mLiveMessageListItemClickListener = listItemClickListener;
    }

    public int getLayoutResId(){
        return R.layout.item_full_screen_live_room_msglist;
    }

    /**
     * 给列表控件赋值
     * @param holder
     * @param msgListItem
     */
    public void doDrawItem(ViewHolder holder,
                            final LiveRoomMsgListItem msgListItem){
        View ll_msgItemContainer = holder.getView(R.id.ll_msgItemContainer);
        //文字
        TextView tvMsg = holder.getView(R.id.tvMsgDescription);
        TextView tvName = holder.getView(R.id.tvName);
        //避免itemview循环利用时背景色混乱
        ll_msgItemContainer.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        ll_msgItemContainer.setOnClickListener(null);
        //解决才艺推荐被隐藏重用问题
        View llRecommended = holder.getView(R.id.llRecommended);
        tvMsg.setVisibility(View.VISIBLE);
        llRecommended.setVisibility(View.GONE);
        //增加hangout敲门及推荐逻辑
        View llAnchorRecommended = holder.getView(R.id.llAnchorRecommended);
        llAnchorRecommended.setVisibility(View.GONE);
        SimpleDraweeView ivAnchorPhoto = holder.getView(R.id.ivAnchorPhoto);
        TextView tvAnchorName = holder.getView(R.id.tvAnchorName);
        TextView tvAnchorDesc = holder.getView(R.id.tvAnchorDesc);

        TextView tvEventButton = holder.getView(R.id.tvEventButton);
        View llEventButton = holder.getView(R.id.llEventButton);
        llEventButton.setOnClickListener(null);

        // 2019/3/22 Hardy
        //设置默认 padding
        tvMsg.setMinHeight(0);
        tvMsg.setPadding(0,0,0,0);

        switch (msgListItem.imMessageItem.msgType){
            case Normal:
//            case Barrage:{
                //名字和背景色
                boolean isAnchorMsg = msgListItem.imMessageItem.userId.equals(mCurrAnchorId);
                tvName.setVisibility(View.VISIBLE);
                tvName.setText(msgListItem.imMessageItem.nickName);
                tvName.setBackground(
                        roomThemeManager.getFullScreenRoomNickNameBgDrawable(mContext, currLiveRoomType,isAnchorMsg));
                //设置消息背景
                ll_msgItemContainer.setBackgroundDrawable(
                        roomThemeManager.getFullScreenRoomNorMsgItemBgDrawable(
                                mContext, currLiveRoomType));
                break;
            case Gift:{
                if(currLiveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom){
                    tvName.setVisibility(View.GONE);
                    int margin = DisplayUtil.dip2px(mContext,9f);
                    int space = DisplayUtil.dip2px(mContext,3f);
                    tvMsg.setPadding(margin,space,margin,space);
                    tvMsg.setMinHeight(DisplayUtil.dip2px(mContext,26f));

                    //设置消息背景
                    ll_msgItemContainer.setBackgroundDrawable(
                            roomThemeManager.getRoomMsgListGiftItemBgDrawableByHangout(
                                    mContext, currLiveRoomType, msgListItem.imMessageItem.giftMsgContent.isSecretly));
                }else {
                    //名字和背景色
                    boolean isAnchorGift = msgListItem.imMessageItem.userId.equals(mCurrAnchorId);
                    tvName.setVisibility(View.VISIBLE);
                    tvName.setText(msgListItem.imMessageItem.nickName);
                    tvName.setBackground(
                            roomThemeManager.getFullScreenRoomNickNameBgDrawable(mContext, currLiveRoomType,isAnchorGift));

                    //设置消息背景
                    ll_msgItemContainer.setBackgroundDrawable(
                            roomThemeManager.getFullScreenRoomNorMsgItemBgDrawable(
                                    mContext, currLiveRoomType));
                }
            }break;
            case FollowHost:{
                //FollowHost系统以公告方式推送给客户端
            }break;
            case RoomIn:{//入场消息类型
                tvName.setVisibility(View.GONE);
                //设置消息背景
                ll_msgItemContainer.setBackgroundDrawable(
                        roomThemeManager.getFullScreenRoomNorMsgItemBgDrawable(
                                mContext, currLiveRoomType));
            }break;
            case SysNotice: {
                final IMSysNoticeMessageContent msgContent = msgListItem.imMessageItem.sysNoticeContent;
                if (msgContent != null) {
                    tvName.setVisibility(View.GONE);

                    if (!TextUtils.isEmpty(msgContent.link)) {
                        //连接
                        tvMsg.setText(msgListItem.spanned);
                        //设置消息背景
                        ll_msgItemContainer.setBackgroundDrawable(
                                roomThemeManager.getFullScreenRoomMineSysMsgItemBgDrawable(
                                        mContext, currLiveRoomType));
                    }else{
                        //其它类型的系统提示
                        if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Normal){
                            tvMsg.setText(msgListItem.spanned);
                            //设置消息背景
                            ll_msgItemContainer.setBackgroundDrawable(
                                    roomThemeManager.getFullScreenRoomMineSysMsgItemBgDrawable(
                                            mContext, currLiveRoomType));
                        }else if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.CarIn){
                            //座驾入场从公告类型修改为RoomIn类型

                        }else if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Warning){
                            tvMsg.setText(msgListItem.spanned);
                            //设置消息背景
                            ll_msgItemContainer.setBackgroundDrawable(
                                    roomThemeManager.getFullScreenRoomWarningMsgItemBgDrawable(
                                            mContext, currLiveRoomType));
                        }else{
                            //设置消息背景
                            ll_msgItemContainer.setBackgroundDrawable(
                                    roomThemeManager.getFullScreenRoomMineSysMsgItemBgDrawable(
                                            mContext, currLiveRoomType));
                        }
                    }
                }
            }break;
            case TalentRecommand:{
                tvName.setVisibility(View.GONE);
                tvMsg.setVisibility(View.GONE);

                llRecommended.setVisibility(View.VISIBLE);
                SimpleDraweeView imgMsgAnchorPhoto = holder.getView(R.id.imgMsgAnchorPhoto);
                TextView tvDesc = holder.getView(R.id.tvDesc);
                IMUserBaseInfoItem imUserBaseInfoItem = IMManager.getInstance().getUserInfo(msgListItem.imMessageItem.userId);
                if(imUserBaseInfoItem != null){
                    imgMsgAnchorPhoto.setImageURI(imUserBaseInfoItem.photoUrl);
                }
                if(msgListItem.imMessageItem.textMsgContent != null){
                    tvDesc.setText(msgListItem.imMessageItem.textMsgContent.message);
                }
                ll_msgItemContainer.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if(mLiveMessageListItemClickListener != null){
                            mLiveMessageListItemClickListener.onItemClick(msgListItem.imMessageItem);
                        }
                    }
                });
            }break;
            case AnchorKnock:{
                //主播敲门处理
                tvName.setVisibility(View.GONE);
                tvMsg.setVisibility(View.GONE);

                llAnchorRecommended.setVisibility(View.VISIBLE);
                IMRecvKnockRequestItem knockItem = msgListItem.imMessageItem.hangoutKnockRequestItem;
                if(knockItem != null){
                    FrescoLoadUtil.loadUrl(mContext, ivAnchorPhoto, knockItem.photoUrl,
                            mContext.getResources().getDimensionPixelSize(R.dimen.live_size_50dp),
                            R.drawable.ic_default_photo_woman_rect,
                            false,
                            mContext.getResources().getDimensionPixelSize(R.dimen.live_size_6dp),0,mContext.getResources().getDimensionPixelSize(R.dimen.live_size_6dp),0);

                    tvAnchorName.setText(StringUtil.truncateName(knockItem.nickName));
                    tvAnchorDesc.setText(mContext.getResources().getString(R.string.hangout_dialog_des, knockItem.age, knockItem.country));
                    tvEventButton.setText(mContext.getResources().getString(R.string.live_common_open_door));
                    llEventButton.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            if(mLiveMessageListItemClickListener != null){
                                mLiveMessageListItemClickListener.onItemClick(msgListItem.imMessageItem);
                            }
                        }
                    });
                }
            }break;
            case AnchorRecommand:{
                //主播推荐hangout
                tvName.setVisibility(View.GONE);
//                tvMsg.setVisibility(View.GONE);

                llAnchorRecommended.setVisibility(View.VISIBLE);
                IMHangoutRecommendItem hangoutRecommendItem = msgListItem.imMessageItem.hangoutRecommendItem;
                if(hangoutRecommendItem != null){
                    //文字
                    tvMsg.setText(mContext.getString(R.string.hangout_anchor_recommand_private_tips , hangoutRecommendItem.nickName , hangoutRecommendItem.friendNickName));

                    FrescoLoadUtil.loadUrl(mContext, ivAnchorPhoto, hangoutRecommendItem.friendPhotoUrl,
                            mContext.getResources().getDimensionPixelSize(R.dimen.live_size_50dp),
                            R.drawable.ic_default_photo_woman_rect,
                            false,
                            mContext.getResources().getDimensionPixelSize(R.dimen.live_size_6dp),0,mContext.getResources().getDimensionPixelSize(R.dimen.live_size_6dp),0);

                    tvAnchorName.setText(StringUtil.truncateName(hangoutRecommendItem.friendNickName));
                    tvAnchorDesc.setText(mContext.getResources().getString(R.string.hangout_dialog_des, hangoutRecommendItem.friendAge, hangoutRecommendItem.friendCountry));
                    IMRoomInItem.IMLiveRoomType roomType = IMManager.getInstance().getRoomType(hangoutRecommendItem.roomId);
                    if(roomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom
                            || roomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom){
                        tvEventButton.setText(mContext.getResources().getString(R.string.live_common_start_hangout));
                    }else{
                        tvEventButton.setText(mContext.getResources().getString(R.string.live_common_invite_now));
                    }
                    llEventButton.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            if(mLiveMessageListItemClickListener != null){
                                mLiveMessageListItemClickListener.onItemClick(msgListItem.imMessageItem);
                            }
                        }
                    });
                }
            }break;
            case Voucher:
                final IMVoucherMessageContent voucherMessageContent = msgListItem.imMessageItem.voucherMessageContent;
                if (voucherMessageContent != null) {
                    tvName.setVisibility(View.GONE);
                    tvMsg.setText(msgListItem.spanned);
                    //设置消息背景
                    ll_msgItemContainer.setBackgroundDrawable(
                            roomThemeManager.getFullScreenRoomVoucherMsgItemBgDrawable(
                                    mContext, currLiveRoomType));
                }
                break;
            default:
                break;
        }
        tvMsg.setMovementMethod(msgListItem.imMessageItem.msgType == IMMessageItem.MessageType.SysNotice
                ? LinkMovementMethod.getInstance() : null);
        if(null != msgListItem.spanned){
            tvMsg.setText(msgListItem.spanned);
        }
    }
}
