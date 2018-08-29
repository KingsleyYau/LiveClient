package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.text.Html;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;
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
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftImageType;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.utils.HtmlImageGetter;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;

import java.lang.ref.WeakReference;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/9/4.
 */

public class LiveRoomChatManager implements IFileDownloadedListener {

    private final String TAG = LiveRoomChatManager.class.getSimpleName();
    private WeakReference<BaseCommonLiveRoomActivity> mActivity;
    private HtmlImageGetter mImageGetter;
    private LiveMessageListView lvlv_roomMsgList;
    private LiveMessageListAdapter lmlAdapter;
    private TextView tv_unReadTip;
    private int giftImgWidth = 0;
    private int giftImgHeight = 0;
    private int medalImgWidth = 0;
    private int medalImgHeight = 0;
    private Context mContext;

    public LiveRoomChatManager(Context context){
        mContext = context;
    }

    public void init(BaseCommonLiveRoomActivity roomActivity, View container){
        mActivity = new WeakReference<BaseCommonLiveRoomActivity>(roomActivity);
        //初始化Html图片解析器
        giftImgWidth = (int)roomActivity.getResources().getDimension(R.dimen.liveroom_messagelist_gift_width);
        giftImgHeight = (int)roomActivity.getResources().getDimension(R.dimen.liveroom_messagelist_gift_height);
        medalImgWidth = (int)roomActivity.getResources().getDimension(R.dimen.liveroom_messagelist_medal_width);
        medalImgHeight = (int)roomActivity.getResources().getDimension(R.dimen.liveroom_messagelist_medal_height);
        mImageGetter = new HtmlImageGetter(roomActivity.getApplicationContext(), giftImgWidth, giftImgHeight,medalImgWidth,medalImgHeight);
        lvlv_roomMsgList = (LiveMessageListView) container.findViewById(R.id.lvlv_roomMsgList);
        tv_unReadTip = (TextView) container.findViewById(R.id.tv_unReadTip);
        tv_unReadTip.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                lvlv_roomMsgList.loadNewestUnreadMsg();
            }
        });
        lvlv_roomMsgList.setOnMsgUnreadListener(new MessageRecyclerView.onMsgUnreadListener() {
            @Override
            public void onMsgUnreadSum(int unreadSum) {
                updateUnreadLiveMsgTipVew(unreadSum);
            }

            @Override
            public void onReadAll() {
//                Log.d(TAG,"onReadAll");
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
        lvlv_roomMsgList.setMaxMsgSum(mContext.getResources().getInteger(R.integer.liveMsgListMaxNum));
        lvlv_roomMsgList.setHoldingTime(mContext.getResources().getInteger(R.integer.liveMsgListItemHoldTime));
        lvlv_roomMsgList.setVerticalSpace(Float.valueOf(mContext.getResources().getDimension(R.dimen.listmsgview_item_decoration)).intValue());
    }

    /**
     * 更新未读消息提示界面
     * @param unReadNum
     */
    private void updateUnreadLiveMsgTipVew(int unReadNum){
        Log.d(TAG,"updateUnreadLiveMsgTipVew-unReadNum:"+unReadNum);
        tv_unReadTip.setVisibility(0 == unReadNum ? View.INVISIBLE : View.VISIBLE);
        String unReadTip = mContext.getString(R.string.tip_unReadLiveMsg,unReadNum);
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
        String localHonorImgPath =null;
        boolean honorImgFileExists = false;
        boolean honorImgExists = !TextUtils.isEmpty(liveMsgItem.honorUrl);
        if(honorImgExists){
            localHonorImgPath = FileCacheManager.getInstance().parseHonorImgLocalPath(liveMsgItem.honorUrl);
            honorImgFileExists = SystemUtils.fileExists(localHonorImgPath);
            Log.d(TAG,"refreshViewByMessageItem-localHonorImgPath:"+localHonorImgPath+" honorImgFileExists:"+honorImgFileExists);
            if(!honorImgFileExists){
                FileDownloadManager.getInstance().start(liveMsgItem.honorUrl,localHonorImgPath,null);
            }
        }

        TextView ll_userLevel = holder.getView(R.id.tvMsgDescription);
        Spanned span = null;
        switch (liveMsgItem.msgType){
            case Normal:
            case Barrage:{
                //弹幕或者普通文本消息
                String emoParseStr = null;
                if(honorImgExists){
                    emoParseStr = ChatEmojiManager.getInstance().parseEmojiStr(mActivity.get(),
                            mContext.getResources().getString(mActivity.get().roomThemeManager.getRoomMsgListMedalTxtMsgStrResId(
                                    mActivity.get().mIMRoomInItem.roomType),
                                    liveMsgItem.honorUrl,
                                    liveMsgItem.nickName,
                                    TextUtils.htmlEncode(liveMsgItem.textMsgContent.message)),
                            ChatEmojiManager.PATTERN_MODEL_SIMPLESIGN);
                }else{
                    emoParseStr = ChatEmojiManager.getInstance().parseEmojiStr(mActivity.get(),
                            mContext.getResources().getString(mActivity.get().roomThemeManager.getRoomMsgListNoMedalTxtMsgStrResId(
                                    mActivity.get().mIMRoomInItem.roomType),
                                    liveMsgItem.nickName,
                                    TextUtils.htmlEncode(liveMsgItem.textMsgContent.message)),
                            ChatEmojiManager.PATTERN_MODEL_SIMPLESIGN);
                }
                span = mImageGetter.getExpressMsgHTML(emoParseStr,false,honorImgExists);
            }break;
            case Gift:{
                //检测礼物小图片存在与否，不存在自动下载，更新列表
                NormalGiftManager.getInstance().getGiftImage(liveMsgItem.giftMsgContent.giftId,
                        GiftImageType.MsgListIcon, this);
                //礼物消息列表展示
                String giftNum = "";
                if(liveMsgItem.giftMsgContent.giftNum > 1){
                    giftNum = mContext.getResources().getString(R.string.liveroom_message_gift_x,
                            liveMsgItem.giftMsgContent.giftNum);
                }
                if(honorImgExists){
                    span = mImageGetter.getExpressMsgHTML(mContext.getResources().getString(
                            mActivity.get().roomThemeManager.getRoomMsgListMedalGiftMsgStrResId(mActivity.get().mIMRoomInItem.roomType),
                            liveMsgItem.honorUrl,
                            liveMsgItem.nickName,
                            liveMsgItem.giftMsgContent.giftName,
                            liveMsgItem.giftMsgContent.giftId, giftNum),true,honorImgExists);
                }else{
                    span = mImageGetter.getExpressMsgHTML(mContext.getResources().getString(
                            mActivity.get().roomThemeManager.getRoomMsgListNoMedalGiftMsgStrResId(mActivity.get().mIMRoomInItem.roomType),
                            liveMsgItem.nickName,
                            liveMsgItem.giftMsgContent.giftName,
                            liveMsgItem.giftMsgContent.giftId, giftNum),true,honorImgExists);
                }
            }break;
            //FollowHost系统以公告方式推送给客户端
//            case FollowHost:{
//                span = Html.fromHtml(mContext.getResources().getString(
//                        R.string.liveroom_message_template_follow_freepublic, liveMsgItem.nickName));
//            }break;
            case RoomIn:{
                if(honorImgExists){
                    span = mImageGetter.getExpressMsgHTML(mContext.getResources().getString(
                            mActivity.get().roomThemeManager.getRoomMsgListMedalRoomInMsgStrResId(
                                    mActivity.get().mIMRoomInItem.roomType),
                            liveMsgItem.honorUrl,
                            liveMsgItem.nickName),false,honorImgExists);
                }else{
                    span = mImageGetter.getExpressMsgHTML(mContext.getResources().getString(
                            mActivity.get().roomThemeManager.getRoomMsgListNoMedalRoomInMsgStrResId(
                                    mActivity.get().mIMRoomInItem.roomType),
                            liveMsgItem.nickName),false,honorImgExists);
                }

            }break;
            case SysNotice: {
                final IMSysNoticeMessageContent msgContent = liveMsgItem.sysNoticeContent;
                if (msgContent != null) {
                    if (!TextUtils.isEmpty(msgContent.link)) {
                        SpannableString spanString = new SpannableString(msgContent.message);
                        //下划线
                        UnderlineSpan underlineSpan = new UnderlineSpan();
                        spanString.setSpan(underlineSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                        //超链接
//                        URLSpan urlSpan = new URLSpan(msgContent.link);
//                        spanString.setSpan(urlSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                        ClickableSpan clickableSpan = new ClickableSpan() {
                            @Override
                            public void onClick(View widget) {
                                //加载成功没有导航栏同主播个人页
                                mContext.startActivity(WebViewActivity.getIntent(
                                        mContext, "", msgContent.link, true));
                            }
                        };
                        spanString.setSpan(clickableSpan,0,spanString.length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                        //字体颜色
                        ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(Color.parseColor("#0CD7DE"));
                        spanString.setSpan(foregroundColorSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                        //加粗
                        StyleSpan styleSpan = new StyleSpan(Typeface.BOLD);
                        spanString.setSpan(styleSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                        ll_userLevel.setText(spanString);
                    }else{
                        if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Normal){
                            span = Html.fromHtml(mContext.getResources().getString(
                                    R.string.system_notice_unlink_normal,
                                    msgContent.message));
                        }else if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.CarIn){
                            if(honorImgExists){
                                span = mImageGetter.getExpressMsgHTML(mContext.getResources().getString(
                                        R.string.system_notice_unlink_carin,
                                        liveMsgItem.honorUrl,msgContent.message),false,honorImgExists);
                            }else{
                                span = mImageGetter.getExpressMsgHTML(mContext.getResources().getString(
                                        R.string.system_notice_unlink_carin_nomedal,
                                        msgContent.message),
                                        false,honorImgExists);
                            }
                        }else if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Warning){
                            span = Html.fromHtml(mContext.getResources().getString(
                                    R.string.system_notice_warning,
                                    msgContent.message));
                        }else{
                            span = Html.fromHtml(mContext.getResources().getString(
                                    R.string.system_notice_unlink_chat,
                                    msgContent.message));
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
