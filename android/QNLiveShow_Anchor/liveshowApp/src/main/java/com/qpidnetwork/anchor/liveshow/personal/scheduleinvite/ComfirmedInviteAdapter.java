package com.qpidnetwork.anchor.liveshow.personal.scheduleinvite;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.httprequest.item.BookInviteItem;
import com.qpidnetwork.anchor.httprequest.item.LoginItem;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.member.MemberProfileActivity;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.view.ProgressButton;
import com.squareup.picasso.Picasso;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * Created by Hunter on 17/9/30.
 */

public class ComfirmedInviteAdapter extends BaseAdapter {

    private Context mContext;
    private List<BookInviteItem> mBookInviteItemList;
    private OnComfirmedInviteEventListener mListener;
    private final String TAG = ComfirmedInviteAdapter.class.getSimpleName();

    public ComfirmedInviteAdapter(Context context, List<BookInviteItem> bookInviteItemList){
        this.mContext = context;
        this.mBookInviteItemList = bookInviteItemList;
    }

    /**
     * 设置事件监听器
     * @param listener
     */
    public void setOnComfirmedInviteClickListener(OnComfirmedInviteEventListener listener){
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
            convertView = LayoutInflater.from(mContext).inflate(R.layout.adapter_comfirmed_schedule_invite, parent, false);
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

        //礼物图片
        holder.civAnchorPhoto.setImageResource(R.drawable.ic_default_photo_man);
        if(!TextUtils.isEmpty(item.oppositePhotoUrl)) {
            Picasso.with(mContext).load(item.oppositePhotoUrl)
                    .error(R.drawable.ic_default_photo_man)
                    .placeholder(R.drawable.ic_default_photo_man)
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
                //跳转到用户详情
                mContext.startActivity(MemberProfileActivity.getMemberInfoIntent(mContext, "", userId, true));

            }
        });



        //设置点击事件
        if(holder.btnStartProcess.isFinish()){
            holder.btnStartProcess.initState();
        }
        //根据预约事件计算处理界面倒计时显示
        calculateAndUpdateLeftTime(item, holder);

        holder.btnStartProcess.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(v instanceof ProgressButton){
                    //按钮出现后，点击就可以进入直播间
                    if(mListener != null) {
                        mListener.onStartEnterRoomClick(item);
                    }
                }
            }
        });

        return convertView;
    }

    /**
     * 处理不同状态预约处理（剩余时间1分钟1内时，开始进入直播间倒计时（倒计时时长为180秒））
     * @param item 预约时间，单位秒
     */
    private void calculateAndUpdateLeftTime(BookInviteItem item, ViewHolder holder){
        int currTime = (int)(System.currentTimeMillis()/1000);
        int bookTime = item.bookTime;
        //初始化状态
        holder.llCountDown.setVisibility(View.GONE);
        holder.rlStart.setVisibility(View.GONE);
        if(bookTime - currTime <= 0){
            //剩余时间少于等于1分钟，显示进度button
            int tmpTime = bookTime - currTime;
            int leftTime = 180 - Math.abs(tmpTime);
            if(leftTime <= 0){
                //显示进度条按钮
                holder.rlStart.setVisibility(View.VISIBLE);
                holder.btnStartProcess.setProgress(0);

                //到期，刷新界面
                if(mListener != null){
                    mListener.onScheduleInvalidNotify(item);
                }
            }else{
                //显示进度条按钮
                holder.rlStart.setVisibility(View.VISIBLE);
//                int progress = (int)((180 - leftTime)/180f*100);
                int progress = (int)(leftTime/180f*100);
                if(holder.btnStartProcess.isStop()){
                    holder.btnStartProcess.setStop(false);
                }
                holder.btnStartProcess.setProgress(progress);
                Log.d(TAG,"calculateAndUpdateLeftTime-progress:"+progress);
            }
        }else{
            //剩余时间大于1分钟，显示倒数
            int leftDay = 0;
            int leftHour = 0;
            int leftMinute = 0;
            int leftSecond = 0;
            if(currTime < bookTime){
                //未开始
                leftDay = (bookTime - currTime)/(24 * 60 * 60);
                leftHour = ((bookTime - currTime)/(60 * 60))%24;
                leftMinute = ((((bookTime - currTime)/60)%(60*24))%60);
                leftSecond = (bookTime - currTime) % 60;
            }
            Log.d(TAG,"calculateAndUpdateLeftTime-bookTime:"+bookTime+" leftDay:"+leftDay
                    +" leftHour:"+leftHour);
            Log.d(TAG,"calculateAndUpdateLeftTime-leftMinute:"+leftMinute+" leftSecond:"+leftSecond);
            if(leftDay > 0 || leftHour > 0 || leftMinute > 0 || leftSecond > 0){
                if(leftDay > 0){
                    //超过一天
                    holder.llCountDown.setVisibility(View.VISIBLE);
                    holder.tvLeftTime.setText(String.format(mContext.getResources().getString(R.string.schedule_invite_confirmed_format_day_hour), String.valueOf(leftDay), String.valueOf(leftHour)));
                }else if(leftHour > 0){
                    //超过1小时小于1天
                    holder.llCountDown.setVisibility(View.VISIBLE);
                    holder.tvLeftTime.setText(String.format(mContext.getResources().getString(R.string.schedule_invite_confirmed_format_hour_minute), String.valueOf(leftHour), String.valueOf(leftMinute)));
                }else{
                    //1小时以内，1分钟以上
                    holder.llCountDown.setVisibility(View.VISIBLE);
                    holder.tvLeftTime.setText(String.format(mContext.getResources().getString(R.string.schedule_invite_confirmed_format_minute_second), String.valueOf(leftMinute), String.valueOf(leftSecond)));
                }
            }
        }
    }

    private class ViewHolder{

        public ViewHolder(){

        }

        public ViewHolder(View convertView){
            civAnchorPhoto = (CircleImageView)convertView.findViewById(R.id.civAnchorPhoto);
            tvAnchorName = (TextView)convertView.findViewById(R.id.tvAnchorName);
            tvBookTime = (TextView)convertView.findViewById(R.id.tvBookTime);
            llCountDown = (LinearLayout) convertView.findViewById(R.id.llCountDown);
            tvLeftTime = (TextView)convertView.findViewById(R.id.tvLeftTime);
            rlStart = (RelativeLayout)convertView.findViewById(R.id.rlStart);
            btnStartProcess = (ProgressButton)convertView.findViewById(R.id.btnStartProcess);
            ivUnread = (ImageView)convertView.findViewById(R.id.ivUnread);
            convertView.setTag(this);
        }

        public CircleImageView civAnchorPhoto;
        public TextView tvAnchorName;
        public TextView tvBookTime;
        public LinearLayout llCountDown;
        public TextView tvLeftTime;
        public RelativeLayout rlStart;
        public ProgressButton btnStartProcess;
        public ImageView ivUnread;
    }

    public interface OnComfirmedInviteEventListener{
        void onStartEnterRoomClick(BookInviteItem item);
        void onScheduleInvalidNotify(BookInviteItem item);
    }
}
