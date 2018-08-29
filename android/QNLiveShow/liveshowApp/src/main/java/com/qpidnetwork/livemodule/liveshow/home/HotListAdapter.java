package com.qpidnetwork.livemodule.liveshow.home;

import android.app.Activity;
import android.content.Context;
import android.graphics.PointF;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.support.v7.widget.RecyclerView;
import android.text.TextPaint;
import android.text.TextUtils;
import android.util.Log;
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
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.common.ResizeOptions;
import com.facebook.imagepipeline.image.ImageInfo;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AnchorLevelType;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.utils.ButtonUtils;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.HotItemStyleManager;
import com.qpidnetwork.livemodule.utils.StringUtil;
import com.qpidnetwork.livemodule.view.ViewSmartHelper;

import java.util.ArrayList;
import java.util.List;

/**
 * @author Jagger 2018-6-28
 */
public class HotListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    //变量
    protected List<HotListItem> mList ;
    protected Context mContext;

    public HotListAdapter(Context context, List<HotListItem> list){
        mContext = context;
        mList = list;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_hot_list, parent, false);
        return new ViewHolderLiveRoom(view);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        if(holder instanceof ViewHolderLiveRoom) {
            ViewHolderLiveRoom viewHolder = (ViewHolderLiveRoom) holder;
            final HotListItem bean = mList.get(position);

            //处理item大小（宽高相同）
            int itemHeight = DisplayUtil.getScreenWidth(mContext);
            ViewGroup.LayoutParams params = viewHolder.flBody.getLayoutParams();
            params.height = itemHeight;

            viewHolder.ivInterest1.setVisibility(View.GONE);
            viewHolder.ivInterest2.setVisibility(View.GONE);
            viewHolder.ivInterest3.setVisibility(View.GONE);

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

            //统一先隐藏操作按钮，根据需要打开
            viewHolder.btnPrivate.setVisibility(View.GONE);
            viewHolder.btnPublic.setVisibility(View.GONE);
            viewHolder.btnSchedule.setVisibility(View.GONE);

            //背景图
//            viewHolder.ivRoomBg.setImageResource( R.drawable.rectangle_transparent_drawable);
            if(!TextUtils.isEmpty(bean.roomPhotoUrl) && mContext!= null){
                //edit by Jagger 2018-6-29:picasso不会从本地取缓存，每次下载，初始化时图片显示得太慢，所以改用fresco
                //对齐方式(左上角对齐)
                PointF focusPoint = new PointF();
                focusPoint.x = 0f;
                focusPoint.y = 0f;

                //占位图，拉伸方式
                GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(mContext.getResources());
                GenericDraweeHierarchy hierarchy = builder
                        .setFadeDuration(300)
                        .setPlaceholderImage(R.drawable.bg_hotlist_item)    //占位图
                        .setPlaceholderImageScaleType(ScalingUtils.ScaleType.FIT_XY)    //占位图拉伸
                        .setActualImageFocusPoint(focusPoint)
                        .setActualImageScaleType(ScalingUtils.ScaleType.FOCUS_CROP)     //图片拉伸（配合上面的focusPoint）
                        .build();
                viewHolder.ivRoomBg.setHierarchy(hierarchy);

                //压缩、裁剪图片
                int picHeight = itemHeight;
                int maxHeight = mContext.getResources().getInteger(R.integer.lady_hot_list_bg_max_HW);
                if(itemHeight > maxHeight){
                    picHeight = maxHeight;
                }
                Uri imageUri = Uri.parse(bean.roomPhotoUrl);
                ImageRequest request = ImageRequestBuilder.newBuilderWithSource(imageUri)
                        .setResizeOptions(new ResizeOptions(picHeight, picHeight))
                        .build();
                DraweeController controller = Fresco.newDraweeControllerBuilder()
                        .setImageRequest(request)
                        .setOldController(viewHolder.ivRoomBg.getController())
                        .setControllerListener(new BaseControllerListener<ImageInfo>())
                        .build();
                viewHolder.ivRoomBg.setController(controller);
            }

            //区别处理节目和普通直播间
            boolean isProgram = false;
            viewHolder.tvName.setText(bean.nickName);
            if(bean.showInfo != null && !TextUtils.isEmpty(bean.showInfo.showLiveId)){
                isProgram = true;
            }

            //节目描述
            if(isProgram) {
                List<Integer> returnDrawableWidths = new ArrayList<>();
                viewHolder.tvProgramDesc.setVisibility(View.VISIBLE);
                viewHolder.tvProgramDesc.setText(StringUtil.parseHotFollowProgramDesc(mContext, bean.showInfo.showTitle , returnDrawableWidths));

                //计算文字宽
                TextPaint paint = viewHolder.tvProgramDesc.getPaint();
                String showTitleText = viewHolder.tvProgramDesc.getText().toString();
                int textLength = (int)paint.measureText(showTitleText);
                for (Integer drawableWidth:returnDrawableWidths ) {
                    textLength += drawableWidth;
                }
                //重设TextView宽度
                viewHolder.tvProgramDesc.setLayoutParams(new LinearLayout.LayoutParams(textLength , ViewGroup.LayoutParams.WRAP_CONTENT));

                //Speed 根据字长计算滚动速度 (每秒显示3个字符)
                float speed = 8;
                if(!TextUtils.isEmpty(showTitleText)){
                    speed = showTitleText.length()/3;
                }

                //设置动画（Ps:花这么多功夫做个滚动， 是因为需求要求文字短也能滚， 所以用不了跑马灯）
                Animation animation = AnimationUtils.loadAnimation(mContext, R.anim.anim_hotlist_grogramme_des);
                animation.setDuration((int)(speed * 1000));
                viewHolder.tvProgramDesc.startAnimation(animation);
            }else{
                viewHolder.tvProgramDesc.setVisibility( View.GONE);
            }

            //按钮区域
            if(bean.onlineStatus == AnchorOnlineStatus.Online){

                //统一处理右上角图标（节目和付费公开直播间时显示）
                if(isProgram){
                    viewHolder.ivPremium.setVisibility(View.VISIBLE);
                    viewHolder.ivPremium.setImageResource(R.drawable.list_program_indicator);
                }else if(bean.roomType == LiveRoomType.PaidPublicRoom){
                    viewHolder.ivPremium.setVisibility(View.VISIBLE);
                    viewHolder.ivPremium.setImageResource(R.drawable.list_premium_public);
                }

                if(bean.roomType != LiveRoomType.Unknown) {
                    //房间类型
//                        helper.setVisibility(R.id.btnSchedule, View.GONE);
//                        helper.setVisibility(R.id.llStartContent, View.VISIBLE);
//                        helper.setVisibility(R.id.ivLiveType, View.VISIBLE);
                    if (bean.roomType == LiveRoomType.FreePublicRoom
                            || bean.roomType == LiveRoomType.PaidPublicRoom) {
//                            helper.setImageResource(R.id.ivLiveType, R.drawable.room_type_public);
                        viewHolder.ivLiveType.setVisibility(View.VISIBLE);
                        setAndStartRoomTypeAnimation(bean.roomType, ivLiveType);
//                            helper.setVisibility(R.id.btnPrivate, View.VISIBLE);
//                            helper.setVisibility(R.id.btnPublic, View.VISIBLE);
                    }
//                        else {
//                            helper.setImageResource(R.id.ivLiveType, R.drawable.anchor_status_online);
//                            helper.setVisibility(R.id.btnPrivate, View.VISIBLE);
//                            helper.setVisibility(R.id.btnPublic, View.GONE);
//                        }

                    switch (bean.roomType) {
                        case FreePublicRoom: {
//                                helper.setImageResource(R.id.btnPrivate, R.drawable.list_button_start_normal_private_broadcast);
//                                setAndStartAdvancePrivateAnimation(btnPrivate);
                            viewHolder.btnPublic.setVisibility(View.VISIBLE);
                            //根据是否free更换图标，调整间距
                            HotItemStyleManager.resetHotItemButtomStyle(mContext,
                                    viewHolder.btnPublic,
                                    bean.isHasPublicVoucherFree,true);

//                                helper.setImageResource(R.id.btnPublic, R.drawable.list_button_view_free_public_broadcast);
                        }
                        break;
                        case PaidPublicRoom: {
//                                setAndStartAdvancePrivateAnimation(btnPrivate);
                            viewHolder.btnPublic.setVisibility(View.VISIBLE);
                            //根据是否free更换图标，调整间距
                            HotItemStyleManager.resetHotItemButtomStyle(mContext,
                                    viewHolder.btnPublic,
                                    bean.isHasPublicVoucherFree,true);
                        }
                        break;
                        case AdvancedPrivateRoom: {
//                                setAndStartAdvancePrivateAnimation(btnPrivate);
                            viewHolder.btnPrivate.setVisibility(View.VISIBLE);
                            //根据是否free更换图标，调整间距
                            HotItemStyleManager.resetHotItemButtomStyle(mContext,
                                    viewHolder.btnPrivate,
                                    bean.isHasPrivateVoucherFree,false);
                        }
                        break;
                        case NormalPrivateRoom: {
//                                helper.setImageResource(R.id.btnPrivate, R.drawable.list_button_start_normal_private_broadcast);
//                                setAndStartAdvancePrivateAnimation(btnPrivate);
                            viewHolder.btnPrivate.setVisibility(View.VISIBLE);
                            //根据是否free更换图标，调整间距
                            HotItemStyleManager.resetHotItemButtomStyle(mContext,
                                    viewHolder.btnPrivate,
                                    bean.isHasPrivateVoucherFree,false);
                        }
                        break;
                    }
                }else{
                    //在线未直播
//                        helper.setVisibility(R.id.btnSchedule, View.GONE);
//                        helper.setVisibility(R.id.llStartContent, View.VISIBLE);
                    viewHolder.btnPrivate.setVisibility(View.VISIBLE);
                    //根据是否free更换图标，调整间距
                    HotItemStyleManager.resetHotItemButtomStyle(mContext,
                            viewHolder.btnPrivate,
                            bean.isHasPrivateVoucherFree,false);
//                        helper.setVisibility(R.id.btnPrivate, View.VISIBLE);
//                        helper.setVisibility(R.id.btnPublic, View.GONE);
//                        if(bean.anchorType == AnchorLevelType.gold){
//                            setAndStartAdvancePrivateAnimation(btnPrivate);
//                        }else{
////                            helper.setImageResource(R.id.btnPrivate, R.drawable.list_button_start_normal_private_broadcast);
//                            setAndStartAdvancePrivateAnimation(btnPrivate);
//                        }

                    //add by Jagger 2018-3-8
                    viewHolder.ivLiveType.setVisibility( View.VISIBLE);
                    viewHolder.ivLiveType.setImageResource(R.drawable.ic_livetype_room_online);
                }
            }else{
//                    helper.setImageResource(R.id.ivLiveType, R.drawable.anchor_status_offline);
//                    helper.setVisibility(R.id.llStartContent, View.GONE);
//                    helper.setVisibility(R.id.btnSchedule, View.VISIBLE);
                viewHolder.btnSchedule.setVisibility( View.VISIBLE);
                viewHolder.btnSchedule.setImageResource(R.drawable.list_button_send_schedule);
            }

            //点击事件
            viewHolder.btnPrivate.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    String action = "";
                    String label = "";
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
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

            viewHolder.btnPublic.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    String action = "";
                    String label = "";
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
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

            viewHolder.btnSchedule.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    String action = "";
                    String label = "";
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
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
        }
    }

    /**
     * 当图片不显示的时候自动释放，防止oom
     * @param holder
     */
    @Override
    public void onViewRecycled(RecyclerView.ViewHolder holder) {
        super.onViewRecycled(holder);
        if(holder instanceof ViewHolderLiveRoom) {
            ViewHolderLiveRoom viewHolder = (ViewHolderLiveRoom) holder;
            if (viewHolder.ivRoomBg.getController() != null) {
                viewHolder.ivRoomBg.getController().onDetach();
            }
            if (viewHolder.ivRoomBg.getTopLevelDrawable() != null) {
                viewHolder.ivRoomBg.getTopLevelDrawable().setCallback(null);
            }
        }
    }

    @Override
    public int getItemCount() {
        return mList.size();
    }

    /**
     * 介绍View
     */
    protected static class ViewHolderLiveRoom extends RecyclerView.ViewHolder {
        public FrameLayout flBody;
        public SimpleDraweeView ivRoomBg;
        public ImageView ivLiveType, ivPremium, ivInterest1, ivInterest2, ivInterest3, btnPrivate, btnPublic, btnSchedule;//ivRoomBg
        public TextView tvName, tvProgramDesc;
        public LinearLayout llProgramDesc;

        public ViewHolderLiveRoom(View itemView){
            super(itemView);
            flBody = (FrameLayout)itemView.findViewById(R.id.flBody);
//            ivRoomBg = (ImageView)itemView.findViewById(R.id.iv_roomBg);
            ivRoomBg = (SimpleDraweeView)itemView.findViewById(R.id.iv_roomBg);
            ivLiveType = (ImageView)itemView.findViewById(R.id.ivLiveType);
            ivPremium = (ImageView)itemView.findViewById(R.id.ivPremium);
            ivInterest1 = (ImageView)itemView.findViewById(R.id.ivInterest1);
            ivInterest2 = (ImageView)itemView.findViewById(R.id.ivInterest2);
            ivInterest3 = (ImageView)itemView.findViewById(R.id.ivInterest3);
            tvName = (TextView)itemView.findViewById(R.id.tvName);
            llProgramDesc = (LinearLayout)itemView.findViewById(R.id.llProgramDesc);
            tvProgramDesc = (TextView)itemView.findViewById(R.id.tvProgramDesc);
            btnPrivate = (ImageView)itemView.findViewById(R.id.btnPrivate);
            btnPublic = (ImageView)itemView.findViewById(R.id.btnPublic);
            btnSchedule  = (ImageView)itemView.findViewById(R.id.btnSchedule);
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
}
