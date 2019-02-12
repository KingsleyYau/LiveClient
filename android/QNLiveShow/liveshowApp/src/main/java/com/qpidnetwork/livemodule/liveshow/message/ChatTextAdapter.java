package com.qpidnetwork.livemodule.liveshow.message;

import android.content.Context;
import android.graphics.Color;
import android.support.v7.widget.RecyclerView;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livemessage.item.LMSystemNoticeItem;
import com.qpidnetwork.livemodule.livemessage.item.LiveMessageItem;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.utils.CustomerHtmlTagHandler;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.utils.HtmlSpannedHandler;
import com.qpidnetwork.livemodule.view.MaterialProgressBar;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class ChatTextAdapter extends RecyclerView.Adapter<ChatTextAdapter.DrawerViewHolder> {

    private static final int TYPE_TEXT_MSG_RECV = 0;
    private static final int TYPE_TEXT_MSG_SEND = 1;
    private static final int TYPE_SORT_TIME = 2;
    private static final int TYPE_WARNING = 3;
    private static final int TYPE_SYSTEM = 4;

    //格式化
    SimpleDateFormat weekFormat=new SimpleDateFormat("EEEE HH:mm", Locale.ENGLISH);
    SimpleDateFormat weekBeforeDateformat=new SimpleDateFormat("yyyy/MM/dd HH:mm", Locale.ENGLISH);
    SimpleDateFormat todayDateformat=new SimpleDateFormat("HH:mm", Locale.ENGLISH);

    private Context mContext;

    //列表数据
    private List<LiveMessageItem> mMsgList = new ArrayList<LiveMessageItem>();

    //表情解析
    private CustomerHtmlTagHandler.Builder mBuilder;


    public ChatTextAdapter(Context context , List<LiveMessageItem> list){
        mContext = context;
        mMsgList = list;
        //emoji解析
        int emojiWidth = (int)context.getResources().getDimension(R.dimen.live_size_16dp);
        int emojiHeight = (int)context.getResources().getDimension(R.dimen.live_size_16dp);
        mBuilder = new CustomerHtmlTagHandler.Builder();
        mBuilder.setContext(context)
                .setGiftImgHeight(emojiWidth)
                .setGiftImgWidth(emojiHeight);
    }

    @Override
    public int getItemViewType(int position) {
        int viewType = -1;
        LiveMessageItem item = mMsgList.get(position);
        if (item.msgType == LiveMessageItem.LMMessageType.Text) {
            if(item.sendType == LiveMessageItem.LMSendType.Send){
                viewType =  TYPE_TEXT_MSG_SEND;
            }else{
                viewType = TYPE_TEXT_MSG_RECV;
            }

        }else if(item.msgType == LiveMessageItem.LMMessageType.Time){
            viewType = TYPE_SORT_TIME;
        }else if(item.msgType == LiveMessageItem.LMMessageType.Warning){
            viewType = TYPE_WARNING;
        }else if(item.msgType == LiveMessageItem.LMMessageType.System){
            viewType = TYPE_SYSTEM;
        }
        if(viewType < 0){
            viewType = super.getItemViewType(position);
        }
        return viewType;
    }

    @Override
    public int getItemCount() {
        return (mMsgList == null || mMsgList.size() == 0) ? 0 : mMsgList.size();
    }

    @Override
    public DrawerViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        DrawerViewHolder viewHolder = null;
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        switch (viewType) {
            case TYPE_TEXT_MSG_RECV:{
                viewHolder = new RecvTextTypeViewHolder(inflater.inflate(R.layout.message_item_recv_text, parent, false));
            }break;
            case TYPE_TEXT_MSG_SEND:{
                viewHolder = new SendTextTypeViewHolder(inflater.inflate(R.layout.message_item_send_text, parent, false));
            }break;
            case TYPE_SORT_TIME:{
                viewHolder = new SortedTimeTypeViewHolder(inflater.inflate(R.layout.message_item_sorted_time, parent, false));
            }break;
            case TYPE_WARNING: {
                viewHolder = new WarningTypeViewHolder(inflater.inflate(R.layout.message_item_warning, parent, false));
            }break;
            case TYPE_SYSTEM: {
                viewHolder = new SystemTypeViewHolder(inflater.inflate(R.layout.message_item_system_nomore, parent, false));
            }break;
        }
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(DrawerViewHolder holder, int position) {
        //选项
        final LiveMessageItem item = mMsgList.get(position);

        if (holder instanceof RecvTextTypeViewHolder) {

            RecvTextTypeViewHolder recvTextViewHolder = (RecvTextTypeViewHolder) holder;
            if(item.privateItem != null) {
                String htmlStr = ChatEmojiManager.getInstance().parseEmojiStr(mContext, item.privateItem.message, ChatEmojiManager.PATTERN_MODEL_SIMPLESIGN);

                recvTextViewHolder.tvMessage.setText(HtmlSpannedHandler.getLiveRoomMsgHTML(mBuilder , htmlStr,false));
            }
        } else if(holder instanceof SendTextTypeViewHolder){
            SendTextTypeViewHolder sendTextViewHolder = (SendTextTypeViewHolder) holder;
            //处理发送状态
            if(item.statusType == LiveMessageItem.LMMessageStatus.Processing){
                sendTextViewHolder.llSendStatus.setVisibility(View.VISIBLE);
                sendTextViewHolder.pbProcessing.setVisibility(View.VISIBLE);
                sendTextViewHolder.btnError.setVisibility(View.GONE);
            }else if(item.statusType == LiveMessageItem.LMMessageStatus.Fail){
                sendTextViewHolder.llSendStatus.setVisibility(View.VISIBLE);
                sendTextViewHolder.pbProcessing.setVisibility(View.GONE);
                sendTextViewHolder.btnError.setVisibility(View.VISIBLE);
                sendTextViewHolder.btnError.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if(listener != null){
                            listener.onResendClick(item);
                        }
                    }
                });
            }else{
                sendTextViewHolder.llSendStatus.setVisibility(View.GONE);
            }
            if(item.privateItem != null) {
                String htmlStr = ChatEmojiManager.getInstance().parseEmojiStr(mContext, item.privateItem.message, ChatEmojiManager.PATTERN_MODEL_SIMPLESIGN);
                sendTextViewHolder.tvMessage.setText(HtmlSpannedHandler.getLiveRoomMsgHTML(mBuilder , htmlStr,false));
            }
        }else if(holder instanceof SortedTimeTypeViewHolder){
            SortedTimeTypeViewHolder sortedTimeTypeViewHolder = (SortedTimeTypeViewHolder) holder;
            if(item.timeMsgItem != null) {
                sortedTimeTypeViewHolder.tvMessage.setText(getDateFormatString((long) item.timeMsgItem.msgTime * 1000));
            }
        }else if(holder instanceof WarningTypeViewHolder){
            WarningTypeViewHolder warningTypeViewHolder = (WarningTypeViewHolder) holder;
            if(item.msgType == LiveMessageItem.LMMessageType.Warning){
                String noMoneyTips = mContext.getResources().getString(R.string.message_contactlist_no_enoughmoney_tips);
                String noMoneySpanKey = mContext.getResources().getString(R.string.message_contactlist_no_enoughmoney_span_key);
                SpannableString sp = new SpannableString(noMoneyTips);
                ClickableSpan clickableSpan = new ClickableSpan() {

                    @Override
                    public void onClick(View widget) {
                        if(listener != null){
                            listener.onAddCreditClick();
                        }
                    }
                };
                sp.setSpan(new ForegroundColorSpan(Color.parseColor("#FF7100")), noMoneyTips.indexOf(noMoneySpanKey), noMoneyTips.indexOf(noMoneySpanKey) + noMoneySpanKey.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                sp.setSpan(clickableSpan, noMoneyTips.indexOf(noMoneySpanKey), noMoneyTips.indexOf(noMoneySpanKey) + noMoneySpanKey.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                warningTypeViewHolder.tvMessage.setText(sp);

                warningTypeViewHolder.tvMessage.setMovementMethod(LinkMovementMethod.getInstance());
                warningTypeViewHolder.tvMessage.setFocusable(false);
                warningTypeViewHolder.tvMessage.setClickable(false);
                warningTypeViewHolder.tvMessage.setLongClickable(false);
            }
        }else if(holder instanceof SystemTypeViewHolder){
            SystemTypeViewHolder systemTypeViewHolder = (SystemTypeViewHolder) holder;
            if(item.systemItem != null) {
                systemTypeViewHolder.tvMessage.setText(item.systemItem.message);
                LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) systemTypeViewHolder.tvMessage.getLayoutParams();
                if(item.systemItem.systemType == LMSystemNoticeItem.LMSystemType.NoMuchMore){
                    params.topMargin = (int)mContext.getResources().getDimension(R.dimen.live_size_20dp);
                }else{
                    params.topMargin = 0;
                }
            }
        }
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
            dateFormatString = mContext.getResources().getString(R.string.message_contactlist_dateformat_yesterday) + " " + todayDateformat.format(new Date(time));
        }else if(timeType == DateUtil.DateTimeType.InWeek){
            dateFormatString = weekFormat.format(new Date(time));
        }else if(timeType == DateUtil.DateTimeType.WeekBefore){
            dateFormatString = weekBeforeDateformat.format(new Date(time));
        }
        return dateFormatString;
    }

    public OnItemClickListener listener;

    public void setOnItemClickListener(OnItemClickListener listener){
        this.listener = listener;
    }

    /**
     * 菜单点击事件c
     */
    public interface OnItemClickListener{
        //点击重发按钮
        public void onResendClick(LiveMessageItem messageItem);
        //点击充值
        public void onAddCreditClick();
    }

    //-------------------------item数据模型------------------------------


    //----------------------------------ViewHolder数据模型---------------------------
    //抽屉ViewHolder模型
    public class DrawerViewHolder extends RecyclerView.ViewHolder {

        public DrawerViewHolder(View itemView) {
            super(itemView);
        }
    }

    //警告类型布局
    public class WarningTypeViewHolder extends DrawerViewHolder {
        public TextView tvMessage;
        public WarningTypeViewHolder(View itemView) {
            super(itemView);
            tvMessage = (TextView) itemView.findViewById(R.id.tvMessage);
        }
    }

    //系统消息类型布局
    public class SystemTypeViewHolder extends DrawerViewHolder {
        public TextView tvMessage;
        public SystemTypeViewHolder(View itemView) {
            super(itemView);
            tvMessage = (TextView) itemView.findViewById(R.id.tvMessage);
        }
    }

    //文本接收样式
    public class RecvTextTypeViewHolder extends DrawerViewHolder {
        public TextView tvMessage;

        public RecvTextTypeViewHolder(View itemView) {
            super(itemView);
            tvMessage = (TextView) itemView.findViewById(R.id.tvMessage);
        }
    }

    //文本发送样式
    public class SendTextTypeViewHolder extends DrawerViewHolder {
        public TextView tvMessage;
        public LinearLayout llSendStatus;
        public ImageButton btnError;
        public MaterialProgressBar pbProcessing;

        public SendTextTypeViewHolder(View itemView) {
            super(itemView);
            tvMessage = (TextView) itemView.findViewById(R.id.tvMessage);
            llSendStatus = (LinearLayout) itemView.findViewById(R.id.llSendStatus);
            btnError = (ImageButton) itemView.findViewById(R.id.btnError);
            pbProcessing = (MaterialProgressBar) itemView.findViewById(R.id.pbProcessing);
        }
    }

    //分组时间描述
    public class SortedTimeTypeViewHolder extends DrawerViewHolder {
        public TextView tvMessage;

        public SortedTimeTypeViewHolder(View itemView) {
            super(itemView);
            tvMessage = (TextView) itemView.findViewById(R.id.tvMessage);
        }
    }
}
