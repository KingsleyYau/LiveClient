package com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite;

import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.BookInviteItem;
import com.squareup.picasso.Picasso;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * Created by Hunter on 17/10/5.
 */

public class InviteHistoryAdapter extends BaseAdapter {

    private Context mContext;
    private List<BookInviteItem> mBookInviteItemList;

    public InviteHistoryAdapter(Context context, List<BookInviteItem> bookInviteItemList){
        this.mContext = context;
        this.mBookInviteItemList = bookInviteItemList;
    }

    @Override
    public int getCount() {
        return mBookInviteItemList.size();
    }

    @Override
    public Object getItem(int position) {
        return mBookInviteItemList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        ViewHolder holder;
        if(convertView == null){
            convertView = LayoutInflater.from(mContext).inflate(R.layout.adapter_invite_history, parent, false);
            holder = new ViewHolder(convertView);
        }else{
            holder = (ViewHolder)convertView.getTag();
        }

        final BookInviteItem item = mBookInviteItemList.get(position);

        //已读／未读
        if(item.isReaded){
            holder.ivUnread.setVisibility(View.INVISIBLE);
        }else{
            holder.ivUnread.setVisibility(View.VISIBLE);
        }

        holder.tvAnchorName.setText(item.oppositeNickname);
        //到期时间
        holder.tvBookTime.setText(String.format(mContext.getResources().getString(R.string.schedule_invite_book_time_desc),
                new SimpleDateFormat("MMM dd  HH:mm", Locale.ENGLISH).format(new Date(((long)item.bookTime) * 1000))));

        //处理答复状态
        switch (item.bookInviteStatus){
            case AnchorOff:{
                //主播失约
                holder.tvInviteStatus.setText(mContext.getResources().getString(R.string.invite_history_state_broadcast));
                holder.tvInviteReply1.setText(mContext.getResources().getString(R.string.invite_history_reply_type_anchor_off1));
                holder.tvInviteReply2.setVisibility(View.VISIBLE);
                holder.tvInviteReply2.setText(mContext.getResources().getString(R.string.invite_history_reply_type_anchor_off2));
                holder.tvInviteStatus.setTextColor(Color.parseColor("#9d9d9d"));
                holder.tvInviteReply1.setTextColor(Color.parseColor("#9d9d9d"));
            }break;
            case AudienceOff:{
                //用户失约
                holder.tvInviteStatus.setText(mContext.getResources().getString(R.string.invite_history_state_broadcast));
                holder.tvInviteReply1.setText(mContext.getResources().getString(R.string.invite_history_reply_type_audience_off1));
                holder.tvInviteReply2.setText(mContext.getResources().getString(R.string.invite_history_reply_type_audience_off2));
                holder.tvInviteReply2.setVisibility(View.VISIBLE);
                holder.tvInviteStatus.setTextColor(Color.parseColor("#9d9d9d"));
                holder.tvInviteReply1.setTextColor(Color.parseColor("#9d9d9d"));
            }break;
            case Finished:{
                //已完成
                holder.tvInviteStatus.setText(mContext.getResources().getString(R.string.invite_history_state_broadcast));
                holder.tvInviteReply1.setText(mContext.getResources().getString(R.string.invite_history_reply_type_finished));
                holder.tvInviteReply2.setVisibility(View.GONE);
                holder.tvInviteStatus.setTextColor(Color.parseColor("#3c3c3c"));
                holder.tvInviteReply1.setTextColor(Color.parseColor("#3c3c3c"));
            }break;
            case Canceled:{
                //已取消
                holder.tvInviteStatus.setText(mContext.getResources().getString(R.string.invite_history_state_booking));
                holder.tvInviteReply1.setText(mContext.getResources().getString(R.string.invite_history_reply_type_cancel));
                holder.tvInviteReply2.setVisibility(View.GONE);
                holder.tvInviteStatus.setTextColor(Color.parseColor("#9d9d9d"));
                holder.tvInviteReply1.setTextColor(Color.parseColor("#9d9d9d"));
            }break;
            case Defined:{
                //用户或主播已拒绝
                holder.tvInviteStatus.setText(mContext.getResources().getString(R.string.invite_history_state_booking));
                holder.tvInviteReply1.setText(mContext.getResources().getString(R.string.invite_history_reply_type_decline));
                holder.tvInviteReply2.setVisibility(View.GONE);
                holder.tvInviteStatus.setTextColor(Color.parseColor("#9d9d9d"));
                holder.tvInviteReply1.setTextColor(Color.parseColor("#9d9d9d"));
            }break;
            case Missed:{
                //主播或用户超时未处理
                holder.tvInviteStatus.setText(mContext.getResources().getString(R.string.invite_history_state_booking));
                holder.tvInviteReply1.setText(mContext.getResources().getString(R.string.invite_history_reply_type_timeout));
                holder.tvInviteReply2.setVisibility(View.GONE);
                holder.tvInviteStatus.setTextColor(Color.parseColor("#9d9d9d"));
                holder.tvInviteReply1.setTextColor(Color.parseColor("#9d9d9d"));
            }break;
            default:{
                holder.tvInviteStatus.setText("");
                holder.tvInviteReply1.setText("");
                holder.tvInviteReply2.setVisibility(View.GONE);
                holder.tvInviteStatus.setTextColor(Color.parseColor("#9d9d9d"));
                holder.tvInviteReply1.setTextColor(Color.parseColor("#9d9d9d"));
            }break;
        }

        //礼物图片
        holder.civAnchorPhoto.setImageResource(R.drawable.ic_default_photo_woman);
        if(!TextUtils.isEmpty(item.oppositePhotoUrl)) {
            Picasso.with(mContext).load(item.oppositePhotoUrl)
                    .error(R.drawable.ic_default_photo_woman)
                    .placeholder(R.drawable.ic_default_photo_woman)
                    .into(holder.civAnchorPhoto);
        }

        return convertView;
    }

    private class ViewHolder{

        public ViewHolder(){

        }

        public ViewHolder(View convertView){
            civAnchorPhoto = (CircleImageView)convertView.findViewById(R.id.civAnchorPhoto);
            tvAnchorName = (TextView)convertView.findViewById(R.id.tvAnchorName);
            tvBookTime = (TextView)convertView.findViewById(R.id.tvBookTime);
            tvInviteStatus = (TextView)convertView.findViewById(R.id.tvInviteStatus);
            tvInviteReply1 = (TextView)convertView.findViewById(R.id.tvInviteReply1);
            tvInviteReply2 = (TextView)convertView.findViewById(R.id.tvInviteReply2);
            ivUnread = (ImageView)convertView.findViewById(R.id.ivUnread);
            convertView.setTag(this);
        }

        public CircleImageView civAnchorPhoto;
        public TextView tvAnchorName;
        public TextView tvBookTime;
        public TextView tvInviteStatus;
        public TextView tvInviteReply1;
        public TextView tvInviteReply2;
        public ImageView ivUnread;
    }
}
