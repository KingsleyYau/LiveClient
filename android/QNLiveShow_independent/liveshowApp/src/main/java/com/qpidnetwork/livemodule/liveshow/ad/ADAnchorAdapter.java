package com.qpidnetwork.livemodule.liveshow.ad;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;

import java.util.List;

/**
 * 广告列表Adapter
 * Created by Jagger on 2017/9/22.
 */

public class ADAnchorAdapter extends RecyclerView.Adapter<ADAnchorAdapter.ViewHolder> {
    private Context mContext;
    private List<HotListItem> mDatas;

    public ADAnchorAdapter(List<HotListItem> datas) {
        this.mDatas = datas;
    }


    //创建新View，被LayoutManager所调用
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        mContext = viewGroup.getContext();
        View view = LayoutInflater.from(mContext).inflate(R.layout.item_live_ad_anchor_list,viewGroup,false);
        ViewHolder vh = new ViewHolder(view);
        return vh;
    }

    //将数据与界面进行绑定的操作
    @Override
    public void onBindViewHolder(ViewHolder viewHolder, int position) {
        final HotListItem item = mDatas.get(position);

//        //添加动画看不见回收
//        final ImageView roomTypeImageView = viewHolder.mImgRoomType;
//        ViewSmartHelper viewSmartHelperLiveType = new ViewSmartHelper(roomTypeImageView);
//        viewSmartHelperLiveType.setOnVisibilityChangedListener(new ViewSmartHelper.onVisibilityChangedListener() {
//            @Override
//            public void onVisibilityChanged(boolean isVisible) {
//                if(!isVisible){
//                    Drawable liveTypeDrawable = roomTypeImageView.getDrawable();
//                    if ((liveTypeDrawable != null)
//                            && (liveTypeDrawable instanceof AnimationDrawable)) {
//                        if(((AnimationDrawable) liveTypeDrawable).isRunning()) {
//                            ((AnimationDrawable) liveTypeDrawable).stop();
//                        }
//                    }
//                }
//            }
//        });

//        //房间类型
//        if(item.onlineStatus != AnchorOnlineStatus.Online
//                || item.roomType == LiveRoomType.Unknown){
//            viewHolder.mImgRoomType.setVisibility(View.GONE);
//        }else{
//            viewHolder.mImgRoomType.setVisibility(View.VISIBLE);
//            if(item.roomType == LiveRoomType.FreePublicRoom
//                    || item.roomType == LiveRoomType.PaidPublicRoom){
//                viewHolder.mImgRoomType.setImageResource(R.drawable.room_type_public);
//            }else {
//                viewHolder.mImgRoomType.setImageResource(R.drawable.room_type_private);
//            }
//        }

        //人名
        viewHolder.mTextViewName.setText(item.nickName);
        //绿点
//        Drawable drawable = null;
//        if(item.onlineStatus == AnchorOnlineStatus.Online){
//            drawable = mContext.getResources().getDrawable(R.drawable.circle_solid_green);
//        }else{
//            drawable= mContext.getResources().getDrawable(R.drawable.circle_solid_grey);
//        }
//        drawable.setBounds(0, 0,
//                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_8dp),
//                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_8dp));
//        viewHolder.mTextViewName.setCompoundDrawables(drawable,null,null,null);
//        viewHolder.mTextViewName.setCompoundDrawablePadding(8);

        //照片
        if(!TextUtils.isEmpty(item.photoUrl)){
//            Log.i("Jagger" , "ad url:" + item.photoUrl);

            viewHolder.mImgPhoto.setImageURI(Uri.parse(item.roomPhotoUrl));
            viewHolder.mImgPhoto.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    //打开主播资料界面
                    String pushActionUrl = URL2ActivityManager.createOutOpenAnchorProfile(item.userId);
                    //建立Intent
                    Intent intent = new Intent();
                    intent.putExtra(CommonConstant.KEY_PUSH_NOTIFICATION_URL, pushActionUrl);
                    intent.setAction(CommonConstant.ACTION_PUSH_NOTIFICATION);
                    mContext.sendBroadcast(intent);

                    //GA统计
                    AnalyticsManager manager = AnalyticsManager.getsInstance();
                    if(manager != null){
                        manager.ReportEvent(mContext.getResources().getString(R.string.LiveQN_Category),
                                mContext.getResources().getString(R.string.LiveQN_Action_BroadcasterCover),
                                mContext.getResources().getString(R.string.LiveQN_Label_BroadcasterCover));
                    }
                }
            });
        }

        //兴趣
        viewHolder.mImgInterest1.setVisibility(View.GONE);
        viewHolder.mImgInterest2.setVisibility(View.GONE);
        viewHolder.mImgInterest3.setVisibility(View.GONE);
        if(item.interests != null && item.interests.size() > 0){
            if(item.interests.size() >= 2){
                viewHolder.mImgInterest1.setVisibility(View.VISIBLE);
                viewHolder.mImgInterest2.setVisibility(View.VISIBLE);
                viewHolder.mImgInterest1.setImageResource(ImageUtil.getImageResoursceByName(item.interests.get(0).name()));
                viewHolder.mImgInterest2.setImageResource(ImageUtil.getImageResoursceByName(item.interests.get(1).name()));
            }else{
                viewHolder.mImgInterest1.setVisibility(View.VISIBLE);
                viewHolder.mImgInterest1.setImageResource(ImageUtil.getImageResoursceByName(item.interests.get(0).name()));
            }
        }
    }

    //获取数据的数量
    @Override
    public int getItemCount() {
        if(mDatas == null){
            return 0;
        }else{
            return mDatas.size();
        }

    }

    //自定义的ViewHolder，持有每个Item的的所有界面元素
    public static class ViewHolder extends RecyclerView.ViewHolder {
        public SimpleDraweeView mImgPhoto;
        public ImageView mImgRoomType;
        public TextView mTextViewName;
        public ImageView mImgInterest1 , mImgInterest2 , mImgInterest3;

        public ViewHolder(View view){
            super(view);
            mImgPhoto = (SimpleDraweeView) view.findViewById(R.id.img_ad);
            mImgRoomType = (ImageView) view.findViewById(R.id.img_ad_online_status);
            mTextViewName = (TextView) view.findViewById(R.id.tv_ad_name);
            mImgInterest1 = (ImageView) view.findViewById(R.id.ivInterest1);
            mImgInterest2 = (ImageView) view.findViewById(R.id.ivInterest2);
            mImgInterest3 = (ImageView) view.findViewById(R.id.ivInterest3);
        }
    }
}
