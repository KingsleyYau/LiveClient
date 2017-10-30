package com.qpidnetwork.livemodule.liveshow.ad;

import android.content.Context;
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
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;

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

        //房间类型
        if(item.roomType == LiveRoomType.FreePublicRoom){
            viewHolder.mImgRoomType.setImageResource(R.drawable.room_type_public);
        }else {
            viewHolder.mImgRoomType.setImageResource(R.drawable.room_type_private);
        }

        //人名
        viewHolder.mTextViewName.setText(item.nickName);
        //绿点
        Drawable drawable= mContext.getResources().getDrawable(R.drawable.circle_solid_green);
        drawable.setBounds(0, 0,
                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_8dp),
                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_8dp));
        viewHolder.mTextViewName.setCompoundDrawables(drawable,null,null,null);
        viewHolder.mTextViewName.setCompoundDrawablePadding(8);

        //照片
        if(!TextUtils.isEmpty(item.photoUrl)){
//            Log.i("Jagger" , "ad url:" + item.photoUrl);

            viewHolder.mImgPhoto.setImageURI(Uri.parse(item.photoUrl));
            viewHolder.mImgPhoto.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    //test
                    //打开主播资料界面
                    URL2ActivityManager.getInstance().URL2Activity(mContext , item.userId
                    );
                }
            });
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

        public ViewHolder(View view){
            super(view);
            mImgPhoto = (SimpleDraweeView) view.findViewById(R.id.img_ad);
            mImgRoomType = (ImageView) view.findViewById(R.id.img_ad_online_status);
            mTextViewName = (TextView) view.findViewById(R.id.tv_ad_name);
        }
    }
}
