package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.text.Html;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;
import android.text.style.URLSpan;
import android.text.style.UnderlineSpan;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.livemsglist.LiveMessageListAdapter;
import com.qpidnetwork.livemodule.framework.livemsglist.LiveMessageListView;
import com.qpidnetwork.livemodule.framework.livemsglist.MessageRecyclerView;
import com.qpidnetwork.livemodule.framework.livemsglist.ViewHolder;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftImageType;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.utils.HtmlImageGetter;
import com.qpidnetwork.livemodule.utils.Log;

import java.lang.ref.WeakReference;

import static com.qpidnetwork.livemodule.utils.DisplayUtil.getResources;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/9/4.
 */

public class LiveRoomChatManager implements IFileDownloadedListener {

    public LiveRoomChatManager(){

    }

    private final String TAG = LiveRoomChatManager.class.getSimpleName();
    private WeakReference<Activity> mActivity;
    private HtmlImageGetter mImageGetter;
    private LiveMessageListView lvlv_roomMsgList;
    private LiveMessageListAdapter lmlAdapter;
    private TextView tv_unReadTip;
    private int imgWidth = 0;
    private int imgHeight = 0;

    public void init(BaseCommonLiveRoomActivity roomActivity, View container){
        mActivity = new WeakReference<Activity>(roomActivity);
        //初始化Html图片解析器
        imgWidth = (int)roomActivity.getResources().getDimension(R.dimen.liveroom_messagelist_gift_width);
        imgHeight = (int)roomActivity.getResources().getDimension(R.dimen.liveroom_messagelist_gift_height);
        mImageGetter = new HtmlImageGetter(roomActivity.getApplicationContext(), imgWidth,imgHeight);
        lvlv_roomMsgList = (LiveMessageListView) container.findViewById(R.id.lvlv_roomMsgList);
        tv_unReadTip = (TextView) container.findViewById(R.id.tv_unReadTip);
        tv_unReadTip.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                lvlv_roomMsgList.loadMore();
            }
        });
        lvlv_roomMsgList.setOnMsgUnreadListener(new MessageRecyclerView.onMsgUnreadListener() {
            @Override
            public void onMsgUnreadSum(int unreadSum) {
                updateUnreadLiveMsgTipVew(unreadSum);
            }

            @Override
            public void onReadAll() {
                updateUnreadLiveMsgTipVew(0);
            }
        });

        lmlAdapter = new LiveMessageListAdapter<IMMessageItem>(roomActivity,
                R.layout.item_live_room_msglist) {
            @Override
            public void convert(ViewHolder holder, IMMessageItem liveMsgItem) {
                refreshViewByMessageItem(holder, liveMsgItem);
            }
        };

        lvlv_roomMsgList.setAdapter(lmlAdapter);
        lvlv_roomMsgList.setMaxMsgSum(getResources().getInteger(R.integer.liveMsgListMaxNum));
        lvlv_roomMsgList.setHoldingTime(getResources().getInteger(R.integer.liveMsgListItemHoldTime));
        lvlv_roomMsgList.setVerticalSpace(Float.valueOf(getResources().getDimension(R.dimen.listmsgview_item_decoration)).intValue());
    }

    /**
     * 更新未读消息提示界面
     * @param unReadNum
     */
    private void updateUnreadLiveMsgTipVew(int unReadNum){
        tv_unReadTip.setVisibility(0 == unReadNum ? View.INVISIBLE : View.VISIBLE);
        String unReadTip = LiveApplication.getContext().getString(R.string.tip_unReadLiveMsg,unReadNum);
        SpannableString styledText = new SpannableString(unReadTip);
        styledText.setSpan(new ForegroundColorSpan(Color.parseColor("#ffd205")),
                0, unReadTip.indexOf(" "), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        tv_unReadTip.setText(styledText);
    }

    /**
     * 更新显示MessageList指定行
     * @param holder
     * @param liveMsgItem
     */
    private void refreshViewByMessageItem(ViewHolder holder,
                                          IMMessageItem liveMsgItem){

        TextView ll_userLevel = holder.getView(R.id.tvMsgDescription);
        Spanned span = null;
        switch (liveMsgItem.msgType){
            case Normal:
            case Barrage:{
                //弹幕或者普通文本消息
                span = ChatEmojiManager.getInstance().parseEmoji(
                        LiveApplication.getContext().getResources().getString(
                                R.string.liveroom_message_template_normal,
                                liveMsgItem.nickName,
                                liveMsgItem.textMsgContent.message),
                        ChatEmojiManager.CHATEMOJI_MODEL_EMOJIDES,imgWidth,imgHeight);
            }break;
            case Gift:{
                //检测礼物小图片存在与否，不存在自动下载，更新列表
                NormalGiftManager.getInstance()
                        .getGiftImage(liveMsgItem.giftMsgContent.giftId, GiftImageType.MsgListIcon, this);

                //礼物消息列表展示
                String giftNum = "";
                if(liveMsgItem.giftMsgContent.giftNum > 1){
                    giftNum = getResources().getString(R.string.liveroom_message_gift_x,
                            liveMsgItem.giftMsgContent.giftNum);
                }
                span = mImageGetter.getExpressMsgHTML(getResources().getString(
                        R.string.liveroom_message_template_gift, liveMsgItem.nickName,
                        liveMsgItem.giftMsgContent.giftName,
                        liveMsgItem.giftMsgContent.giftId, giftNum));
            }break;
            case FollowHost:{
                span = Html.fromHtml(getResources().getString(
                        R.string.liveroom_message_template_follow, liveMsgItem.nickName));
            }break;
            case RoomIn:{
                span = Html.fromHtml(getResources().getString(
                        R.string.liveroom_message_template_roomin, liveMsgItem.nickName));
            }break;

            case SysNotice: {
                IMSysNoticeMessageContent msgContent = liveMsgItem.sysNoticeContent;
                if (msgContent != null) {
                    if (!TextUtils.isEmpty(msgContent.link)) {
//                        span = Html.fromHtml(getResources().getString(
//                                R.string.system_announcement_link, msgContent.link, msgContent.message));

                        SpannableString spanString = new SpannableString(msgContent.message);
                        //下划线
                        UnderlineSpan underlineSpan = new UnderlineSpan();
                        spanString.setSpan(underlineSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                        //超链接
                        URLSpan urlSpan = new URLSpan(msgContent.link);
                        spanString.setSpan(urlSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                        //字体颜色
                        ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(Color.parseColor("#0CD7DE"));
                        spanString.setSpan(foregroundColorSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                        //加粗
                        StyleSpan styleSpan = new StyleSpan(Typeface.BOLD);
                        spanString.setSpan(styleSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                        ll_userLevel.setText(spanString);
                    }else{
                        if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Normal){
                            span = Html.fromHtml(getResources().getString(
                                    R.string.system_announcement_unlink_normal, msgContent.message));
                        }else if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.CarIn){
                            span = Html.fromHtml(getResources().getString(
                                    R.string.system_announcement_unlink_carin, msgContent.message));
                        }else{
                            span = Html.fromHtml(getResources().getString(
                                    R.string.system_announcement_unlink_chat, msgContent.message));
                        }
                    }
                }
            }break;
            default:
                break;
        }
        ll_userLevel.setMovementMethod(liveMsgItem.msgType == IMMessageItem.MessageType.SysNotice
                ? LinkMovementMethod.getInstance() : null);
        if(null != span){
            ll_userLevel.setText(span);
        }
    }

    @Override
    public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl) {
        Log.i(TAG, "LiveRoomChatManager-onCompleted isSuccess：" + isSuccess
                +" localFilePath:"+localFilePath+" fileUrl:"+fileUrl);
        if(isSuccess){
            if(null != mActivity && null != mActivity.get()){
                mActivity.get().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        //图片下载更新列表
                        if(lmlAdapter != null) {
                            lmlAdapter.notifyDataSetChanged();
                        }
                    }
                });
            }
        }
    }

    /**
     * 自动换行(messsage被拆成两段显示，第一段在tv_line1，剩下在tv_line2)
     * @param message
     * @param tv_line1
     * @param tv_line2
     */
    private void calculateTextViewAutoWrap(String message, View rootView, TextView tv_line1, TextView tv_line2){
        tv_line1.setVisibility(View.INVISIBLE);
        tv_line2.setVisibility(View.GONE);
        tv_line1.setText(message);
        rootView.measure(0,0);
        int rootViewMeasuredWidth = rootView.getMeasuredWidth();
        tv_line1.measure(0,0);
        int line1MeasuredWidth = tv_line1.getMeasuredWidth();
        android.util.Log.d(TAG,"initLiveMsgView-line1MeasuredWidth:"+line1MeasuredWidth+" rootViewMeasuredWidth:"+rootViewMeasuredWidth);
        Paint paint = new Paint();
        paint.setTextSize(tv_line1.getTextSize());
        int txtWidth = 0;
        int index = 0;
        for(; index < message.length(); index++){
            char indexChar = message.charAt(index);
            int charWidth = Float.valueOf(paint.measureText(String.valueOf(indexChar))).intValue();
//                        Log.d(TAG,"initLiveMsgView-charWidth:"+charWidth);
            txtWidth+=charWidth;
            if(txtWidth>line1MeasuredWidth){
                tv_line1.setText(message.substring(0, index));
                tv_line2.setText(message.substring(index, message.length()));
                tv_line2.setVisibility(View.VISIBLE);
                break;
            }
        }
        tv_line1.setVisibility(View.VISIBLE);
        //下面可以开个for循环计算line2的宽度，避免每行char个数参差不齐，但是考虑到字数有限制，可以不做
        //String line2Txt = liveMsgItem.liveMsg.substring(index,liveMsgItem.liveMsg.length());
    }

    public void addMessageToList(IMMessageItem msgItem){
        boolean isUpdate = false;

        //最后一条消息是RoomIn时，更新
        if(msgItem.msgType == IMMessageItem.MessageType.RoomIn){
            Object dataItem = lvlv_roomMsgList.getLastData();
            if(dataItem != null && dataItem instanceof IMMessageItem){
                IMMessageItem lastMsgitem = (IMMessageItem)dataItem;
                if(lastMsgitem.msgType == IMMessageItem.MessageType.RoomIn){
                    isUpdate = true;
                    lastMsgitem.copy(msgItem);
                }
            }
        }

        if(lvlv_roomMsgList != null && !isUpdate){
            lvlv_roomMsgList.addNewLiveMsg(msgItem);
        }else{
            lmlAdapter.notifyDataSetChanged();
        }
    }


}
