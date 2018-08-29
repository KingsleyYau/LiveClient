package com.qpidnetwork.anchor.liveshow.hangout;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.httprequest.item.AnchorBaseInfoItem;
import com.qpidnetwork.anchor.httprequest.item.AnchorHangoutItem;
import com.qpidnetwork.anchor.view.ProgressButton;
import com.squareup.picasso.Picasso;

import java.util.List;

/**
 * Created by Hunter Mun on 2018/5/14.
 */

public class OngoingHangoutListAdapter extends BaseAdapter {
    private Context mContext;
    private List<AnchorHangoutItem> mAnchorHangoutItemList;
    private OnOngoingHangoutListClickListener mListener;

    public OngoingHangoutListAdapter(Context context, List<AnchorHangoutItem> anchorHangoutItemList){
        this.mContext = context;
        this.mAnchorHangoutItemList = anchorHangoutItemList;
    }

    /**
     * 设置事件监听器
     * @param listener
     */
    public void setOnOngoingHangoutListClickListener(OnOngoingHangoutListClickListener listener){
        mListener = listener;
    }

    @Override
    public int getCount() {
        return mAnchorHangoutItemList.size();
    }

    @Override
    public Object getItem(int position) {
        return mAnchorHangoutItemList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        ViewHolder holder;
        if(convertView == null){
            convertView = LayoutInflater.from(mContext).inflate(R.layout.adapter_ongoing_hangout_item, parent, false);
            holder = new ViewHolder(convertView);
        }else{
            holder = (ViewHolder)convertView.getTag();
        }

        final AnchorHangoutItem item = mAnchorHangoutItemList.get(position);

        holder.tvHangoutTitle.setText(String.format(mContext.getResources().getString(R.string.hangout_list_desc_tips), item.nickName));
        //设置多人互动直播间观众头像列表
        resetHangoutAudiencePhotos(holder, item.anchorList);

        //礼物图片
        holder.civUserPhoto.setImageResource(R.drawable.ic_default_photo_man);
        if(!TextUtils.isEmpty(item.photoUrl)) {
            Picasso.with(mContext).load(item.photoUrl)
                    .error(R.drawable.ic_default_photo_man)
                    .placeholder(R.drawable.ic_default_photo_man)
                    .into(holder.civUserPhoto);
        }

        holder.civUserPhoto.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
//                //跳转到用户详情
//                mContext.startActivity(MemberProfileActivity.getMemberInfoIntent(mContext, "", userId, true));

            }
        });

        holder.btnKnock.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //按钮出现后，点击就可以进入直播间
                if(mListener != null) {
                    mListener.onKnockClick(item);
                }
            }
        });

        return convertView;
    }

    /**
     * 处理直播间已有观众头像列表
     */
    private void resetHangoutAudiencePhotos(ViewHolder holder, AnchorBaseInfoItem[] audienceArray){
        //重置所有头像
        holder.civAnchor1.setImageResource(R.drawable.ic_default_blank_photo);
        holder.civAnchor2.setImageResource(R.drawable.ic_default_blank_photo);
        holder.civAnchor3.setImageResource(R.drawable.ic_default_blank_photo);
        if(audienceArray != null){
            if(audienceArray.length >= 1){
                if(audienceArray[0] != null && !TextUtils.isEmpty(audienceArray[0].photoUrl)) {
                    Picasso.with(mContext).load(audienceArray[0].photoUrl)
                            .error(R.drawable.ic_default_photo_woman)
                            .placeholder(R.drawable.ic_default_photo_woman)
                            .into(holder.civAnchor1);
                }
            }
            if(audienceArray.length >= 2){
                if(audienceArray[1] != null && !TextUtils.isEmpty(audienceArray[1].photoUrl)) {
                    Picasso.with(mContext).load(audienceArray[1].photoUrl)
                            .error(R.drawable.ic_default_photo_woman)
                            .placeholder(R.drawable.ic_default_photo_woman)
                            .into(holder.civAnchor2);
                }
            }
            if(audienceArray.length >= 3){
                if(audienceArray[2] != null && !TextUtils.isEmpty(audienceArray[2].photoUrl)) {
                    Picasso.with(mContext).load(audienceArray[2].photoUrl)
                            .error(R.drawable.ic_default_photo_woman)
                            .placeholder(R.drawable.ic_default_photo_woman)
                            .into(holder.civAnchor3);
                }
            }
        }
    }

    private class ViewHolder{

        public ViewHolder(){

        }

        public ViewHolder(View convertView){
            civUserPhoto = (CircleImageView)convertView.findViewById(R.id.civUserPhoto);
            tvHangoutTitle = (TextView)convertView.findViewById(R.id.tvHangoutTitle);
            civAnchor1 = (CircleImageView)convertView.findViewById(R.id.civAnchor1);
            civAnchor2 = (CircleImageView) convertView.findViewById(R.id.civAnchor2);
            civAnchor3 = (CircleImageView)convertView.findViewById(R.id.civAnchor3);
            btnKnock = (Button)convertView.findViewById(R.id.btnKnock);
            convertView.setTag(this);
        }

        public CircleImageView civUserPhoto;
        public TextView tvHangoutTitle;
        public CircleImageView civAnchor1;
        public CircleImageView civAnchor2;
        public CircleImageView civAnchor3;
        public Button btnKnock;
    }

    public interface OnOngoingHangoutListClickListener{
        public void onKnockClick(AnchorHangoutItem item);
    }
}
