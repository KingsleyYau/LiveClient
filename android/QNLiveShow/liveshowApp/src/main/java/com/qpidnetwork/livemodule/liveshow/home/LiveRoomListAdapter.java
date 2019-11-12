package com.qpidnetwork.livemodule.liveshow.home;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.PointF;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.text.TextPaint;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.generic.RoundingParams;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.item.AnchorLevelType;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginNewActivity;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.ButtonUtils;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.utils.HotItemStyleManager;
import com.qpidnetwork.livemodule.utils.StringUtil;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.livemodule.view.ViewSmartHelper;
import com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * 直播间列表通用Adapter
 * @author Jagger 2018-5-28
 */
public class LiveRoomListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    //变量
    protected List<LiveRoomListItem> mList ;
    protected Context mContext;
    private onLiveRoomListEventListener mOnLiveRoomListEventListener;


    public LiveRoomListAdapter(Context context, List<LiveRoomListItem> list){
        mContext = context;
        mList = list;
    }

    public void setOnLiveRoomListEventListener(onLiveRoomListEventListener mOnLiveRoomListEventListener) {
        this.mOnLiveRoomListEventListener = mOnLiveRoomListEventListener;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        if(viewType == LiveRoomListItem.Type.ADVERT.ordinal()) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_live_room_list_advert, parent, false);
            return new ViewHolderAdvert(view);
        }else{
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_live_room_list, parent, false);
            return new ViewHolderLiveRoom(view);
        }
    }

//    @Override
//    public void onViewAttachedToWindow(@NonNull RecyclerView.ViewHolder holder) {
//        super.onViewAttachedToWindow(holder);
//        if(holder instanceof ViewHolderLiveRoom) {
//            ViewHolderLiveRoom viewHolder = (ViewHolderLiveRoom) holder;
//        }
//    }

    @Override
    public int getItemViewType(int position) {
        // TODO Auto-generated method stub
        //判断ITEM类别 加载不同VIEW HOLDER
        if(mList.get(position).itemType == LiveRoomListItem.Type.ADVERT){
            return LiveRoomListItem.Type.ADVERT.ordinal();
        }else {
            return LiveRoomListItem.Type.ANCHOR.ordinal();
        }
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {

        if(holder instanceof ViewHolderAdvert){
            //广告
            ViewHolderAdvert viewHolder = (ViewHolderAdvert) holder;
            final LiveRoomListItem item = mList.get(position);
            // 下载图片
            if(!TextUtils.isEmpty(item.advertItem.image) && mContext!= null){
                int picHeight = mContext.getResources().getDimensionPixelSize(R.dimen.lady_hot_list_bg_max_HW);
                FrescoLoadUtil.loadUrl(viewHolder.ivADPhoto, item.advertItem.image, picHeight);
            }
            viewHolder.ivADPhoto.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if(!TextUtils.isEmpty(item.advertItem.adurl)) {
                        new AppUrlHandler(mContext).urlHandle(item.advertItem.adurl);
                    }
                }
            });

//            //被显示统计
//            mAdWomanListRangeAdvertEventManager.showed(item.adRangAdvert);

        }else {
            //主播
            ViewHolderLiveRoom viewHolder = (ViewHolderLiveRoom) holder;
            final LiveRoomListItem bean = mList.get(position);

//            Log.i("Jagger" , bean.nickName + ",OneOnOne权限:" + bean.priv.isHasOneOnOneAuth + ",book权限:" + bean.priv.isHasBookingAuth + ",chat在线:" + bean.chatOnlineStatus);

            //房间状态
            final ImageView ivLiveType = viewHolder.ivLiveType;
            //edit by Jagger 2018-1-8 控件看不到时, 停止动画
            ViewSmartHelper viewSmartHelperLiveType = new ViewSmartHelper(ivLiveType);
            viewSmartHelperLiveType.setOnVisibilityChangedListener(new ViewSmartHelper.onVisibilityChangedListener() {
                @Override
                public void onVisibilityChanged(boolean isVisible) {
                    Drawable liveTypeDrawable = ivLiveType.getDrawable();
                    if(!isVisible){
                        if ((liveTypeDrawable != null)
                                && (liveTypeDrawable instanceof AnimationDrawable)) {
                            if(((AnimationDrawable) liveTypeDrawable).isRunning()) {
                                ((AnimationDrawable) liveTypeDrawable).stop();
                            }
                        }
                    }else{
                        if ((liveTypeDrawable != null)
                                && (liveTypeDrawable instanceof AnimationDrawable)) {
                            if(!((AnimationDrawable) liveTypeDrawable).isRunning()) {
                                ((AnimationDrawable) liveTypeDrawable).start();
                            }
                        }
                    }
                }
            });

            //统一先隐藏，只有公开直播间时才显示
            viewHolder.ivLiveType.setVisibility(View.GONE);
            viewHolder.ivPremium.setVisibility(View.GONE);
            viewHolder.ivCam.setVisibility(View.GONE);
            viewHolder.iv_chat.setVisibility(View.GONE);
            viewHolder.iv_mail.setVisibility(View.GONE);
            viewHolder.iv_book.setVisibility(View.GONE);

            //统一先隐藏操作按钮，根据需要打开
            viewHolder.flPubilc.setVisibility(View.GONE);
            viewHolder.flPrivate.setVisibility(View.GONE);
            viewHolder.flChat.setVisibility(View.GONE);
            viewHolder.flMail.setVisibility(View.GONE);

            //背景图
            if(!TextUtils.isEmpty(bean.roomPhotoUrl) && mContext!= null){
                int picHeight = mContext.getResources().getDimensionPixelSize(R.dimen.lady_hot_list_bg_max_HW);
                FrescoLoadUtil.loadUrl(viewHolder.ivRoomBg, bean.roomPhotoUrl, picHeight);

            }

            //区别处理节目和普通直播间
            boolean isProgram = false;
            viewHolder.tvName.setText(bean.nickName);
            if(bean.showInfo != null && !TextUtils.isEmpty(bean.showInfo.showLiveId)){
                isProgram = true;
            }

            //收藏
            if(bean.isFollow){
                viewHolder.iv_follow.setImageResource(R.drawable.ic_follow);
            }else{
                viewHolder.iv_follow.setImageResource(R.drawable.ic_unfollow);
            }
            viewHolder.iv_follow.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        if (isGotoLogin()) {
                            return;
                        }
                        if (mOnLiveRoomListEventListener != null) {
                            mOnLiveRoomListEventListener.onFavClicked(bean);
                        }
                    }
                }
            });

            //SayHi
            if(LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logined){
                //观众是否有SayHi权限
                LoginItem loginItem = LoginManager.getInstance().getLoginItem();
                if (null != loginItem && loginItem.userPriv != null) {
                    if(loginItem.userPriv.isSayHiPriv){
                        viewHolder.flSayHi.setVisibility(View.VISIBLE);
                    }else {
                        viewHolder.flSayHi.setVisibility(View.GONE);
                    }
                }

            }else{
                viewHolder.flSayHi.setVisibility(View.GONE);
            }
            viewHolder.iv_sayhi.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {

                        //GA统计SayHi点击事件
                        Activity activity = (Activity)mContext;
                        if(activity != null && activity instanceof AnalyticsFragmentActivity){
                            ((AnalyticsFragmentActivity)activity).onAnalyticsEvent(mContext.getResources().getString(R.string.Live_SayHi_Category),
                                    mContext.getResources().getString(R.string.Live_SayHi_Action_Edit_Click),
                                    mContext.getResources().getString(R.string.Live_SayHi_Label_Edit_Click));
                        }

                        if (isGotoLogin()) {
                            return;
                        }
                        if (mOnLiveRoomListEventListener != null) {
                            mOnLiveRoomListEventListener.onSayHiClicked(bean);
                        }
                    }
                }
            });

            //按钮区域
            if(bean.onlineStatus == AnchorOnlineStatus.Online){
                //++++ 在线 ++++
                //统一处理右上角图标（节目和付费公开直播间时显示）
                if(isProgram){
                    viewHolder.ivPremium.setVisibility(View.GONE);
                    viewHolder.ivPremium.setImageResource(R.drawable.list_program_indicator);
                }else if(bean.roomType == LiveRoomType.PaidPublicRoom){
                    viewHolder.ivPremium.setVisibility(View.GONE);
                    viewHolder.ivPremium.setImageResource(R.drawable.list_premium_public);
                }

                //左上角
                if (bean.roomType == LiveRoomType.FreePublicRoom
                        || bean.roomType == LiveRoomType.PaidPublicRoom) {
                    //Live动画
                    viewHolder.ivLiveType.setVisibility(View.VISIBLE);
                    setAndStartRoomTypeAnimation(bean.roomType, ivLiveType);
                }

                //在线状态(名字旁边)
                viewHolder.ivOnline.setVisibility(View.VISIBLE);

                switch (bean.roomType) {
                    case FreePublicRoom:
                        //公开
                        viewHolder.flPubilc.setVisibility(View.VISIBLE);
                        viewHolder.ivPubilcFree.setVisibility(View.GONE);
                        //私密
                        if(bean.priv.isHasOneOnOneAuth) {
                            //在线 有私密权限:显示One on One
                            viewHolder.flPrivate.setVisibility(View.VISIBLE);
                            if(bean.isHasPrivateVoucherFree){
                                viewHolder.ivPivateFree.setVisibility(View.VISIBLE);
                            }else{
                                viewHolder.ivPivateFree.setVisibility(View.GONE);
                            }
                        }

                        //Chat (底部)
                        viewHolder.iv_chat.setVisibility(View.VISIBLE);
                        break;
                    case PaidPublicRoom:
                        //公开
                        viewHolder.flPubilc.setVisibility(View.VISIBLE);
                        if(bean.isHasPublicVoucherFree){
                            viewHolder.ivPubilcFree.setVisibility(View.VISIBLE);
                        }else {
                            viewHolder.ivPubilcFree.setVisibility(View.GONE);
                        }
                        //私密
                        if(bean.priv.isHasOneOnOneAuth) {
                            //在线 有私密权限:显示One on One
                            viewHolder.flPrivate.setVisibility(View.VISIBLE);
                            if(bean.isHasPrivateVoucherFree){
                                viewHolder.ivPivateFree.setVisibility(View.VISIBLE);
                            }else{
                                viewHolder.ivPivateFree.setVisibility(View.GONE);
                            }
                        }

                        //Chat (底部)
                        viewHolder.iv_chat.setVisibility(View.VISIBLE);
                        break;
                    default:
                        //无开播
                        //私密
                        if(bean.priv.isHasOneOnOneAuth){
                            //在线 有私密权限:显示左上角Cam图标
                            viewHolder.ivCam.setVisibility(View.VISIBLE);
                            //在线 有私密权限:显示One on One
                            viewHolder.flPrivate.setVisibility(View.VISIBLE);
                            if(bean.isHasPrivateVoucherFree){
                                viewHolder.ivPivateFree.setVisibility(View.VISIBLE);
                            }else{
                                viewHolder.ivPivateFree.setVisibility(View.GONE);
                            }

                            //显示Chat
                            viewHolder.flChat.setVisibility(View.VISIBLE);

                            //在线 有私密权限:显示Mail (底部)
                            viewHolder.iv_mail.setVisibility(View.VISIBLE);
                        }else {
                            if(bean.chatOnlineStatus == IMClientListener.IMChatOnlineStatus.online){
                                //在线 无私密权限, IM在线:显示Chat
                                viewHolder.flChat.setVisibility(View.VISIBLE);
                            }else {
                                //在线 无私密权限, IM不在线:显示SendMail
                                viewHolder.flMail.setVisibility( View.VISIBLE);
                            }

                            //在线 无私密权限:显示Mail (底部)
                            viewHolder.iv_mail.setVisibility(View.VISIBLE);
                        }
                        break;
                }
            }else{
                //---- 不在线 ----
                //离线 :显示Send Mail
                viewHolder.flMail.setVisibility( View.VISIBLE);
                //在线状态(名字旁边)
                viewHolder.ivOnline.setVisibility(View.GONE);

                //Book (底部)
                viewHolder.iv_book.setVisibility(View.VISIBLE);
            }

            //点击事件
            viewHolder.ivRoomBg.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        AnchorProfileActivity.launchAnchorInfoActivty(mContext,
                                mContext.getResources().getString(R.string.live_webview_anchor_profile_title),
                                bean.userId, false, AnchorProfileActivity.TagType.Album);
                    }
                }
            });

            viewHolder.btnPrivate.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    String action = "";
                    String label = "";
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        if(isGotoLogin()){
                            return;
                        }

                        mContext.startActivity(LiveRoomTransitionActivity.getIntent(mContext,
                                LiveRoomTransitionActivity.CategoryType.Audience_Invite_Enter_Room,
                                bean.userId, bean.nickName, bean.photoUrl, "", bean.roomPhotoUrl));
                        //GA统计
                        if (bean.anchorType == AnchorLevelType.gold) {
                            action = mContext.getResources().getString(R.string.Live_EnterBroadcast_Action_VIPPrivateBroadcast);
                            label = mContext.getResources().getString(R.string.Live_EnterBroadcast_Label_VIPPrivateBroadcast);
                        } else {
                            action = mContext.getResources().getString(R.string.Live_EnterBroadcast_Action_PrivateBroadcast);
                            label = mContext.getResources().getString(R.string.Live_EnterBroadcast_Label_PrivateBroadcast);
                        }
                        //GA统计
                        Activity activity = (Activity)mContext;
                        if(!TextUtils.isEmpty(action) && activity != null
                                && activity instanceof AnalyticsFragmentActivity){
                            ((AnalyticsFragmentActivity)activity).onAnalyticsEvent(mContext.getResources().getString(R.string.Live_EnterBroadcast_Category), action, label);
                        }
                    }
                }
            });

            viewHolder.btnPubilc.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    String action = "";
                    String label = "";
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        if(isGotoLogin()){
                            return;
                        }

                        mContext.startActivity(LiveRoomTransitionActivity.getIntent(mContext,
                                LiveRoomTransitionActivity.CategoryType.Enter_Public_Room,
                                bean.userId, bean.nickName, bean.photoUrl, "", bean.roomPhotoUrl));
                        //GA统计
                        if (bean.showInfo != null && !TextUtils.isEmpty(bean.showInfo.showLiveId)) {
                            //节目
                            action = mContext.getResources().getString(R.string.Live_EnterBroadcast_Action_ShowBroadcast);
                            label = mContext.getResources().getString(R.string.Live_EnterBroadcast_Label_ShowBroadcast);
                        } else if (bean.anchorType == AnchorLevelType.gold) {
                            action = mContext.getResources().getString(R.string.Live_EnterBroadcast_Action_VIPPublicBroadcast);
                            label = mContext.getResources().getString(R.string.Live_EnterBroadcast_Label_VIPPublicBroadcast);
                        } else {
                            action = mContext.getResources().getString(R.string.Live_EnterBroadcast_Action_PublicBroadcast);
                            label = mContext.getResources().getString(R.string.Live_EnterBroadcast_Label_PublicBroadcast);
                        }
                        //GA统计
                        Activity activity = (Activity)mContext;
                        if(!TextUtils.isEmpty(action) && activity != null
                                && activity instanceof AnalyticsFragmentActivity){
                            ((AnalyticsFragmentActivity)activity).onAnalyticsEvent(mContext.getResources().getString(R.string.Live_EnterBroadcast_Category), action, label);
                        }
                    }
                }
            });

            View.OnClickListener chatClickedListener = new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        String chatUrl = LiveUrlBuilder.createLiveChatActivityUrl(bean.userId, bean.nickName, bean.photoUrl);
//                        URL2ActivityManager.getInstance().URL2Activity(mContext, chatUrl);
                        new AppUrlHandler(mContext).urlHandle(chatUrl);
                    }
                }
            };
            viewHolder.btnChat.setOnClickListener(chatClickedListener);
            viewHolder.iv_chat.setOnClickListener(chatClickedListener);

            View.OnClickListener mailClickedListener = new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        String sendMailUrl = LiveUrlBuilder.createSendMailActivityUrl(bean.userId);
//                        URL2ActivityManager.getInstance().URL2Activity(mContext, sendMailUrl);
                        new AppUrlHandler(mContext).urlHandle(sendMailUrl);
                    }
                }
            };
            viewHolder.btnMail.setOnClickListener(mailClickedListener);
            viewHolder.iv_mail.setOnClickListener(mailClickedListener);

            viewHolder.iv_book.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    String action = "";
                    String label = "";
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        if(isGotoLogin()){
                            return;
                        }

                        mContext.startActivity(BookPrivateActivity.getIntent(mContext, bean.userId, bean.nickName));
                        //GA统计
                        action = mContext.getResources().getString(R.string.Live_EnterBroadcast_Action_RequestBooking);
                        label = mContext.getResources().getString(R.string.Live_EnterBroadcast_Label_RequestBooking);
                        //GA统计
                        Activity activity = (Activity)mContext;
                        if(!TextUtils.isEmpty(action) && activity != null
                                && activity instanceof AnalyticsFragmentActivity){
                            ((AnalyticsFragmentActivity)activity).onAnalyticsEvent(mContext.getResources().getString(R.string.Live_EnterBroadcast_Category), action, label);
                        }
                    }
                }
            });
        }
    }

    /**
     * 当图片不显示的时候自动释放，防止oom
     * @param holder
     */
    @Override
    public void onViewRecycled(RecyclerView.ViewHolder holder) {
        super.onViewRecycled(holder);
//        Log.i("info","----------------- onViewRecycled ----------------------pos: "+holder.getLayoutPosition());
        if(holder instanceof ViewHolderLiveRoom) {
            ViewHolderLiveRoom viewHolder = (ViewHolderLiveRoom) holder;
            if (viewHolder.ivRoomBg.getController() != null) {
                viewHolder.ivRoomBg.getController().onDetach();
            }

            // 2018/12/29 Hardy
            // 该 callback 是 Drawable 内部接口，其 invalidateDrawable() 方法用于在需要重画的时候回调更新 view
            // Fresco 中有一些继承 Drawable 的子类，做该更新处理，若设置空，会导致不能更新，当前 ImageView 的图片会显示回
            // 该 item 的 position 的上一次的图片，即看起来图片错乱.
//            if (viewHolder.ivRoomBg.getTopLevelDrawable() != null) {
//                viewHolder.ivRoomBg.getTopLevelDrawable().setCallback(null);
//            }
        }
    }

    @Override
    public int getItemCount() {
        return mList.size();
    }

    /**
     * 列表事件监听器
     */
    public interface onLiveRoomListEventListener{
        void onFavClicked(LiveRoomListItem liveRoomListItem);
        void onSayHiClicked(LiveRoomListItem liveRoomListItem);
    }

    /**
     * ViewHolder
     */
    protected static class ViewHolderLiveRoom extends RecyclerView.ViewHolder {
        public FrameLayout flBody;
        public SimpleDraweeView ivRoomBg;
        public ImageView ivLiveType, ivPremium, ivOnline, ivCam;
        public ImageView iv_sayhi, iv_chat, iv_mail, iv_book, iv_follow;
        public FrameLayout flPubilc, flPrivate, flChat, flMail, flSayHi;
        public ButtonRaised btnPubilc, btnPrivate, btnChat, btnMail;
        public ImageView ivPubilcFree, ivPivateFree;//, ivChatFree, ivMailFree, ivBookFree;
        public TextView tvName;// tvProgramDesc;
//        public LinearLayout llProgramDesc;

        public ViewHolderLiveRoom(View itemView){
            super(itemView);
            flBody = (FrameLayout)itemView.findViewById(R.id.flBody);
            ivRoomBg = (SimpleDraweeView)itemView.findViewById(R.id.iv_roomBg);
            ivLiveType = (ImageView)itemView.findViewById(R.id.ivLiveType);
            ivCam = (ImageView)itemView.findViewById(R.id.ivCam);
            ivPremium = (ImageView)itemView.findViewById(R.id.ivPremium);
            tvName = (TextView)itemView.findViewById(R.id.tvName);
//            llProgramDesc = (LinearLayout)itemView.findViewById(R.id.llProgramDesc);
//            tvProgramDesc = (TextView)itemView.findViewById(R.id.tvProgramDesc);

            flPubilc = itemView.findViewById(R.id.fl_public);
            flPrivate = itemView.findViewById(R.id.fl_private);
            flChat = itemView.findViewById(R.id.fl_chat);
            flMail = itemView.findViewById(R.id.fl_mail);

            btnPubilc = itemView.findViewById(R.id.btn_public);
            btnPrivate = itemView.findViewById(R.id.btn_private);
            btnChat = itemView.findViewById(R.id.btn_chat);
            btnMail = itemView.findViewById(R.id.btn_mail);

            ivPubilcFree = itemView.findViewById(R.id.img_free_public);
            ivPivateFree = itemView.findViewById(R.id.img_free_private);

            ivOnline = (ImageView)itemView.findViewById(R.id.ivOnline);

            flSayHi = itemView.findViewById(R.id.fl_sayhi);
            iv_sayhi = (ImageView)itemView.findViewById(R.id.iv_sayhi);
            iv_chat = itemView.findViewById(R.id.iv_chat);
            iv_mail = itemView.findViewById(R.id.iv_mail);
            iv_book = itemView.findViewById(R.id.iv_book);
            iv_follow = (ImageView)itemView.findViewById(R.id.iv_follow);

            //edit by Jagger 2018-6-29:picasso不会从本地取缓存，每次下载，初始化时图片显示得太慢，所以改用fresco
            //对齐方式(中上对齐)
            FrescoLoadUtil.setHierarchy(itemView.getContext(), ivRoomBg, R.drawable.bg_hotlist_item, false);
        }
    }

    /**
     * 广告
     * @author Jagger
     * 2019-9-30
     */
    class ViewHolderAdvert extends RecyclerView.ViewHolder{

        public SimpleDraweeView ivADPhoto;

        public ViewHolderAdvert(View v) {
            super(v);
            // TODO Auto-generated constructor stub
            ivADPhoto = (SimpleDraweeView)v.findViewById(R.id.ivLadyPhoto);

            //对齐方式(中上对齐)
            FrescoLoadUtil.setHierarchy(itemView.getContext(), ivADPhoto, R.color.black4, false);
        }

    }

    /**
     * 设置启动房间直播间状态
     * @param roomType
     * @param view
     */
    private void setAndStartRoomTypeAnimation(LiveRoomType roomType, final ImageView view){
        if(roomType == LiveRoomType.FreePublicRoom){
            view.setImageResource(R.drawable.anim_room_broadcasting);
        }else if(roomType == LiveRoomType.PaidPublicRoom){
            view.setImageResource(R.drawable.anim_room_broadcasting);
        }
        view.postDelayed(new Runnable() {
            @Override
            public void run() {
                Drawable tempDrawable = view.getDrawable();
                if((tempDrawable != null)
                        && (tempDrawable instanceof AnimationDrawable)){
                    ((AnimationDrawable)tempDrawable).start();
                }
            }
        }, 200);
    }

    /**
     * 是否跳转到登录界面
     * @return
     */
    private boolean isGotoLogin(){
        if(LoginManager.getInstance().getLoginStatus() != LoginManager.LoginStatus.Logined){
            LoginNewActivity.launchRegisterActivity(mContext);
            return true;
        }
        return false;
    }
}
