package com.qpidnetwork.livemodule.liveshow.message;

import android.content.Context;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.livemessage.item.LMPrivateMsgContactItem;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.utils.CustomerHtmlTagHandler;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.utils.HtmlSpannedHandler;
import com.qpidnetwork.livemodule.view.BadgeHelper;
import com.squareup.picasso.Picasso;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import q.rorbin.badgeview.Badge;
import q.rorbin.badgeview.QBadgeView;

/**
 * Created by Hunter on 18/7/19.
 */

public class MessageContactAdapter extends BaseAdapter {

    private Context mContext;
    private List<LMPrivateMsgContactItem> mContactList;

    //格式化
    SimpleDateFormat weekFormat=new SimpleDateFormat("EEEE", Locale.ENGLISH);
    SimpleDateFormat weekBeforeDateformat=new SimpleDateFormat("MMM dd,yyyy", Locale.ENGLISH);
    SimpleDateFormat todayDateformat=new SimpleDateFormat("HH:mm", Locale.ENGLISH);

    //表情解析
    private CustomerHtmlTagHandler.Builder mBuilder;
    public OnContactItemClickListener mListener;

    public MessageContactAdapter(Context context, List<LMPrivateMsgContactItem> dataList){
        this.mContext = context;
        this.mContactList = dataList;

        //emoji解析
        int emojiWidth = (int)context.getResources().getDimension(R.dimen.live_size_16dp);
        int emojiHeight = (int)context.getResources().getDimension(R.dimen.live_size_16dp);
        mBuilder = new CustomerHtmlTagHandler.Builder();
        mBuilder.setContext(context)
                .setGiftImgHeight(emojiWidth)
                .setGiftImgWidth(emojiHeight);
    }

    @Override
    public int getCount() {
        int count = 0;
        if(mContactList != null){
            count = mContactList.size();
        }
        return count;
    }

    @Override
    public Object getItem(int position) {
        return mContactList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if(convertView == null){
            convertView = LayoutInflater.from(mContext).inflate(R.layout.adapter_messge_contact, parent, false);    //android:layout_above 无效的解决办法:不能使用 不能使用
            holder = new ViewHolder(mContext, convertView);
        }else{
            holder = (ViewHolder)convertView.getTag();
        }
        final LMPrivateMsgContactItem item = mContactList.get(position);

        //加载主播头像
        holder.civAnchor.setImageResource(R.drawable.ic_default_photo_woman);
        if(!TextUtils.isEmpty(item.avatarImg)) {
            Picasso.with(mContext).load(item.avatarImg)
                    .error(R.drawable.ic_default_photo_woman)
                    .placeholder(R.drawable.ic_default_photo_woman)
                    .into(holder.civAnchor);
        }

        holder.tvName.setText(item.nickName);

        //设置最后一条消息并支持表情显示
        String htmlStr = ChatEmojiManager.getInstance().parseEmojiStr(mContext, item.lastMsg, ChatEmojiManager.PATTERN_MODEL_SIMPLESIGN);
        holder.tvDesc.setText(HtmlSpannedHandler.getLiveRoomMsgHTML(mBuilder , htmlStr,false));

        if(item.onlineStatus == AnchorOnlineStatus.Online){
            holder.ivOnline.setVisibility(View.VISIBLE);
        }else{
            holder.ivOnline.setVisibility(View.GONE);
        }

        if(item.unreadNum > 0){
            holder.badgeUnread.setBadgeNumber(item.unreadNum);
        }else{
            //隐藏
            holder.badgeUnread.setBadgeNumber(0);
        }

        if(TextUtils.isEmpty(item.lastMsg)){
            //最后一条消息为空时，不显示时间
            holder.tvDate.setText("");
        }else{
            holder.tvDate.setText(getDateFormatString((long)item.updateTime * 1000));
        }

        if(position == mContactList.size() - 1){
            //最后一个隐藏分割线
            holder.viewDivider.setVisibility(View.GONE);
        }else{
            //其他显示分割线
            holder.viewDivider.setVisibility(View.VISIBLE);
        }

        holder.rlItemRoot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(mListener != null){
                    mListener.onContactItemClick(item);
                }
            }
        });

        return convertView;
    }

    /**
     * 格式化指定时间，增加当日／昨天／一周内／一周前逻辑判断
     * @param time
     * @return
     */
    private String getDateFormatString(long time){
        String dateFormatString = "";
        DateUtil.DateTimeType timeType = DateUtil.getDateTimeType(time);
        if(timeType == DateUtil.DateTimeType.Today){
            dateFormatString = todayDateformat.format(new Date(time));
        }else if(timeType == DateUtil.DateTimeType.Yestoday){
            dateFormatString = mContext.getResources().getString(R.string.message_contactlist_dateformat_yesterday);
        }else if(timeType == DateUtil.DateTimeType.InWeek){
            dateFormatString = weekFormat.format(new Date(time));
        }else if(timeType == DateUtil.DateTimeType.WeekBefore){
            dateFormatString = weekBeforeDateformat.format(new Date(time));
        }
        return dateFormatString;
    }

    private class ViewHolder{
        public LinearLayout rlItemRoot;
        public CircleImageView civAnchor;
        public ImageView ivOnline;
        public TextView tvName;
        public ImageView ivFavoriate;
        public TextView tvDate;
        public TextView tvDesc;
        public Badge badgeUnread;
        public View viewDivider;

        public ViewHolder(){

        }

        public ViewHolder(Context context, View convertView){
            rlItemRoot = (LinearLayout)convertView.findViewById(R.id.rlItemRoot);
            civAnchor = (CircleImageView)convertView.findViewById(R.id.civAnchor);
            ivOnline = (ImageView) convertView.findViewById(R.id.ivOnline);
            tvName = (TextView)convertView.findViewById(R.id.tvName);
            ivFavoriate = (ImageView)convertView.findViewById(R.id.ivFavoriate);
            tvDate = (TextView)convertView.findViewById(R.id.tvDate);
            tvDesc = (TextView)convertView.findViewById(R.id.tvDesc);
            viewDivider = (View) convertView.findViewById(R.id.viewDivider);

            //初始化未读数目
            LinearLayout llDesc = (LinearLayout)convertView.findViewById(R.id.llDesc);
            badgeUnread = new QBadgeView(context).bindTarget(llDesc);
            badgeUnread.setBadgeNumber(0);
            badgeUnread.setBadgeGravity(Gravity.CENTER | Gravity.END);
            BadgeHelper.setBaseStyle(mContext , badgeUnread, context.getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_badge_txt_size_max));
            convertView.setTag(this);
        }
    }

    public void setOnContactItemClickListener(OnContactItemClickListener listener){
        mListener = listener;
    }

    public interface OnContactItemClickListener{
        public void onContactItemClick(LMPrivateMsgContactItem item);
    }
}
