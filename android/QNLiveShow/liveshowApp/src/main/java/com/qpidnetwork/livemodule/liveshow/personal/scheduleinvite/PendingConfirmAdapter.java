package com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.BookInviteItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.squareup.picasso.Picasso;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * Created by Hunter on 17/9/30.
 */

public class PendingConfirmAdapter extends BaseAdapter {

    private Context mContext;
    private List<BookInviteItem> mBookInviteItemList;
    private OnPendingConfirmClickListener mListener;

    public PendingConfirmAdapter(Context context, List<BookInviteItem> bookInviteItemList){
        this.mContext = context;
        this.mBookInviteItemList = bookInviteItemList;
    }

    /**
     * 设置事件监听器
     * @param listener
     */
    public void setOnPendingConfirmClickListener(OnPendingConfirmClickListener listener){
        mListener = listener;
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
            convertView = LayoutInflater.from(mContext).inflate(R.layout.adapter_pending_confirm_invite, parent, false);
            holder = new ViewHolder(convertView);
        }else{
            holder = (ViewHolder)convertView.getTag();
        }

        final BookInviteItem item = mBookInviteItemList.get(position);

//        //已读／未读
//        if(item.isReaded){
//            holder.ivUnread.setVisibility(View.GONE);
//        }else{
//            holder.ivUnread.setVisibility(View.VISIBLE);
//        }

        holder.tvAnchorName.setText(item.oppositeNickname);
        //到期时间
        holder.tvBookTime.setText(String.format(mContext.getResources().getString(R.string.schedule_invite_book_time_desc),
                new SimpleDateFormat("MMM dd  HH:mm", Locale.ENGLISH).format(new Date(((long)item.bookTime) * 1000))));

        //礼物图片
        holder.civAnchorPhoto.setImageResource(R.drawable.ic_default_photo_woman);
        if(!TextUtils.isEmpty(item.oppositePhotoUrl)) {
            Picasso.with(mContext).load(item.oppositePhotoUrl)
                    .error(R.drawable.ic_default_photo_woman)
                    .placeholder(R.drawable.ic_default_photo_woman)
                    .into(holder.civAnchorPhoto);
        }

        holder.civAnchorPhoto.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String userId = "";
                LoginItem loginItem = LoginManager.getInstance().getLoginItem();
                if(loginItem != null){
                    if(!item.fromId.equals(loginItem.userId)){
                        userId = item.fromId;
                    }else if(!item.toId.equals(loginItem.userId)){
                        userId = item.toId;
                    }
                }
                //跳转到主播详情页
                if(!TextUtils.isEmpty(userId)){
                    AnchorProfileActivity.launchAnchorInfoActivty(mContext, mContext.getResources().getString(R.string.live_webview_anchor_profile_title),
                            userId, false, AnchorProfileActivity.TagType.Album);
                }
            }
        });

        //设置点击事件
        holder.btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mListener != null){
                    mListener.onInviteCancel(item);
                }
            }
        });

        return convertView;
    }

    private class ViewHolder{

        public ViewHolder(){

        }

        public ViewHolder(View convertView){
            civAnchorPhoto = (CircleImageView)convertView.findViewById(R.id.civAnchorPhoto);
            tvAnchorName = (TextView)convertView.findViewById(R.id.tvAnchorName);
            tvBookTime = (TextView)convertView.findViewById(R.id.tvBookTime);
            btnCancel = (Button)convertView.findViewById(R.id.btnCancel);
            ivUnread = (ImageView)convertView.findViewById(R.id.ivUnread);
            convertView.setTag(this);
        }

        public CircleImageView civAnchorPhoto;
        public TextView tvAnchorName;
        public TextView tvBookTime;
        public Button btnCancel;
        public ImageView ivUnread;
    }

    public interface OnPendingConfirmClickListener{
        public void onInviteCancel(BookInviteItem item);
    }
}
