package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.UnderlineSpan;
import android.view.View;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.livemsglist.LiveMessageListAdapter;
import com.qpidnetwork.livemodule.framework.livemsglist.LiveMessageListView;
import com.qpidnetwork.livemodule.framework.livemsglist.MessageRecyclerView;
import com.qpidnetwork.livemodule.framework.livemsglist.ViewHolder;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftImageType;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.model.LiveRoomMsgListItem;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.utils.CustomerHtmlTagHandler;
import com.qpidnetwork.livemodule.utils.DynamicDrawableSpanJ;
import com.qpidnetwork.livemodule.utils.HtmlSpannedHandler;
import com.qpidnetwork.livemodule.utils.ImageSpanJ;
import com.qpidnetwork.livemodule.utils.Log;

import java.lang.ref.WeakReference;
import java.util.List;

import io.reactivex.observers.DisposableObserver;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/9/4.
 */

public class LiveRoomChatManager implements IFileDownloadedListener {

    private final String TAG = LiveRoomChatManager.class.getSimpleName();

    private WeakReference<BaseCommonLiveRoomActivity> mActivity;
//    private HtmlImageGetter mImageGetter;
    private CustomerHtmlTagHandler.Builder mBuilder;
    private LiveMessageListView lvlv_roomMsgList;
    private LiveMessageListAdapter lmlAdapter;
    private TextView tv_unReadTip;
    private int giftImgWidth = 0;
    private int giftImgHeight = 0;
    private int anchorFlagImgWidth = 0;
    private int anchorFlagImgHeight = 0;
    private Context mContext;
    private LiveRoomChatMsglistItemManager mLiveRoomChatMsglistItemManager;

    //新增消息列表item点击事件
    private LiveMessageListItemClickListener mLiveMessageListItemClickListener;

    /**
     * 当前直播间类型
     */
    private IMRoomInItem.IMLiveRoomType currLiveRoomType;
    /**
     * 当前主播ID
     */
    private String currAnchorId = null;
    /**
     * 用户自己的ID
     */
    private String mySelfId = null;

    private RoomThemeManager roomThemeManager;

    public LiveRoomChatManager(Context context, IMRoomInItem.IMLiveRoomType currLiveRoomType,
                               String currAnchorId,String mySelfId,RoomThemeManager roomThemeManager){
        Log.d(TAG,"LiveRoomChatManager-currLiveRoomType:"+currLiveRoomType+" currAnchorId:"+currAnchorId+" mySelfId:"+mySelfId);
        mContext = context;
        this.currLiveRoomType = currLiveRoomType;
        this.currAnchorId = currAnchorId;
        this.mySelfId = mySelfId;
        this.roomThemeManager = roomThemeManager;
    }

    public void init(BaseCommonLiveRoomActivity roomActivity, View container){
        mActivity = new WeakReference<BaseCommonLiveRoomActivity>(roomActivity);
        //初始化Html图片解析器
        giftImgWidth = (int)roomActivity.getResources().getDimension(R.dimen.liveroom_messagelist_gift_width);
        giftImgHeight = (int)roomActivity.getResources().getDimension(R.dimen.liveroom_messagelist_gift_height);
        anchorFlagImgWidth = (int)roomActivity.getResources().getDimension(R.dimen.liveroom_messagelist_anchor_flag_width);
        anchorFlagImgHeight = (int)roomActivity.getResources().getDimension(R.dimen.liveroom_messagelist_anchor_flag_height);
//        mImageGetter = new HtmlImageGetter(roomActivity.getApplicationContext(), giftImgWidth, giftImgHeight, anchorFlagImgWidth, anchorFlagImgHeight);
        mBuilder = new CustomerHtmlTagHandler.Builder();
        mBuilder.setContext(mContext)
                .setAnchorFlagImgHeight(this.anchorFlagImgHeight)
                .setAnchorFlagImgWidth(this.anchorFlagImgWidth)
                .setGiftImgHeight(this.giftImgHeight)
                .setGiftImgWidth(this.giftImgWidth);
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

        lmlAdapter = new LiveMessageListAdapter<LiveRoomMsgListItem>(roomActivity,
                R.layout.item_live_room_msglist) {
            @Override
            public void convert(ViewHolder holder, LiveRoomMsgListItem liveMsgItem) {
                doDrawItem(holder, liveMsgItem);
            }
        };

        lvlv_roomMsgList.setAdapter(lmlAdapter);
        lvlv_roomMsgList.setMaxMsgSum(mContext.getResources().getInteger(R.integer.liveMsgListMaxNum));
        lvlv_roomMsgList.setHoldingTime(mContext.getResources().getInteger(R.integer.liveMsgListItemHoldTime));
        lvlv_roomMsgList.setVerticalSpace(Float.valueOf(mContext.getResources().getDimension(R.dimen.listmsgview_item_decoration)).intValue());
        lvlv_roomMsgList.setGradualColor(roomThemeManager.getRoomMsgListTopGradualColor(currLiveRoomType));

        initMsgListCache();
    }

    /**
     * 一定要调用
     */
    public void destroy(){
        if(mLiveRoomChatMsglistItemManager != null){
            mLiveRoomChatMsglistItemManager.destroy();
        }
    }

    /**
     * 设置点击事件监听器
     * @param listener
     */
    public void setLiveMessageListItemClickListener(LiveMessageListItemClickListener listener){
        this.mLiveMessageListItemClickListener = listener;
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
//    private void refreshViewByMessageItem(ViewHolder holder,
//                                          final IMMessageItem liveMsgItem){
//        TextView ll_userLevel = holder.getView(R.id.tvMsgDescription);
//        View ll_msgItemContainer = holder.getView(R.id.ll_msgItemContainer);
//        //避免itemview循环利用时背景色混乱
//        ll_msgItemContainer.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
//        Spanned span = null;
//        //解决才艺推荐被隐藏重用问题
//        View llRecommended = holder.getView(R.id.llRecommended);
//        ll_userLevel.setVisibility(View.VISIBLE);
//        llRecommended.setVisibility(View.GONE);
//
//        switch (liveMsgItem.msgType){
//            case Normal:
//            case Barrage:{
//                boolean isAnchor = !TextUtils.isEmpty(currAnchorId) && liveMsgItem.userId.equals(currAnchorId);
//                boolean isMySelf = !TextUtils.isEmpty(mySelfId) && liveMsgItem.userId.equals(mySelfId);
//                //弹幕或者普通文本消息
//                String emoParseStr = null;
//                int strResId = roomThemeManager.getRoomMsgListNormalStrResId(currLiveRoomType,isAnchor,isMySelf);
//                if(0 != strResId){
//                    //把数据填入HTML模块中
//                    String htmlStr = mContext.getResources().getString(strResId,
//                            liveMsgItem.nickName,
//                            TextUtils.htmlEncode(liveMsgItem.textMsgContent.message));
//
//                    //处理是否有购票标识
//                    //非主播(Ps:与strResId对应，主播的模板是没有<jimg src=\"ticket\"/>的) 且 info不为空
//                    if(!isAnchor && IMManager.getInstance().getUserInfo(liveMsgItem.userId)!= null){
//                        htmlStr = doCheckHasTicketTag(htmlStr , IMManager.getInstance().getUserInfo(liveMsgItem.userId).isHasTicket);
//                    }
//
//                    //生成真正的文本
//                    emoParseStr = ChatEmojiManager.getInstance().parseEmojiStr(mActivity.get(),
//                            htmlStr,
//                            ChatEmojiManager.PATTERN_MODEL_SIMPLESIGN);
////                    span = mImageGetter.getExpressMsgHTML(emoParseStr,false);
//                    span = HtmlSpannedHandler.getLiveRoomMsgHTML(mBuilder , emoParseStr,false);
//                }
//            }break;
//            case Gift:{
//                boolean isAnchor = !TextUtils.isEmpty(currAnchorId) && liveMsgItem.userId.equals(currAnchorId);
//                boolean isMySelf = !TextUtils.isEmpty(mySelfId) && liveMsgItem.userId.equals(mySelfId);
//                //检测礼物小图片存在与否，不存在自动下载，更新列表
//                NormalGiftManager.getInstance().getGiftImage(liveMsgItem.giftMsgContent.giftId,
//                        GiftImageType.MsgListIcon, this);
//                ll_msgItemContainer.setBackgroundDrawable(
//                        roomThemeManager.getRoomMsgListGiftItemBgDrawable(
//                                mContext, currLiveRoomType));
//                //礼物消息列表展示
//                int strResId = roomThemeManager.getRoomMsgListGiftMsgStrResId(currLiveRoomType,isAnchor,isMySelf);
//                String giftNum = "";
//
//                if(liveMsgItem.giftMsgContent.giftNum > 1){
//                    giftNum = mContext.getResources().getString(R.string.liveroom_message_gift_x,
//                            liveMsgItem.giftMsgContent.giftNum);
//                }
//
////                span = mImageGetter.getExpressMsgHTML(mContext.getResources().getString(
////                        strResId,
////                        liveMsgItem.nickName,
////                        liveMsgItem.giftMsgContent.giftName,
////                        liveMsgItem.giftMsgContent.giftId,
////                        giftNum),true);
//
//                //把数据填入HTML模块中
//                String htmlStr = mContext.getResources().getString(
//                        strResId,
//                        liveMsgItem.nickName,
//                        liveMsgItem.giftMsgContent.giftName,
//                        liveMsgItem.giftMsgContent.giftId,
//                        giftNum);
//
//                //处理是否有购票标识
//                //非主播(Ps:与strResId对应，主播的模板是没有<jimg src=\"ticket\"/>的) 且 info不为空
//                if(!isAnchor && IMManager.getInstance().getUserInfo(liveMsgItem.userId)!= null){
//                    htmlStr = doCheckHasTicketTag(htmlStr , IMManager.getInstance().getUserInfo(liveMsgItem.userId).isHasTicket);
//                }
//
//                //生成真正的文本
//                span = HtmlSpannedHandler.getLiveRoomMsgHTML(mBuilder ,
//                        htmlStr,true);
//            }break;
//            case FollowHost:{
//                //FollowHost系统以公告方式推送给客户端
//            }break;
//            case RoomIn:{//入场消息类型
//                boolean isAnchor = !TextUtils.isEmpty(currAnchorId) && liveMsgItem.userId.equals(currAnchorId);
//                boolean isMySelf = !TextUtils.isEmpty(mySelfId) && liveMsgItem.userId.equals(mySelfId);
//                Log.d(TAG,"RoomIn-userId:"+liveMsgItem.userId+" isAnchor:"+isAnchor+" isMySelf:"+isMySelf);
//                if(null != currLiveRoomType){
//                    int strResId = roomThemeManager.getRoomMsgListRoomInMsgStrResId(currLiveRoomType,isMySelf);
//                   if(0 != strResId){
////                       span = mImageGetter.getExpressMsgHTML(mContext.getResources().getString(
////                               strResId, liveMsgItem.nickName,liveMsgItem.textMsgContent.message),
////                               false);
//
//                       //把数据填入HTML模块中
//                       String htmlStr = mContext.getResources().getString(
//                               strResId, liveMsgItem.nickName,liveMsgItem.textMsgContent.message);
//
//                       //处理是否有购票标识
//                       //非主播(Ps:与strResId对应) 且 info不为空
//                       if(!isAnchor && IMManager.getInstance().getUserInfo(liveMsgItem.userId)!= null){
//                           htmlStr = doCheckHasTicketTag(htmlStr , IMManager.getInstance().getUserInfo(liveMsgItem.userId).isHasTicket);
//                       }
//
//                       //生成真正的文本
//                       span = HtmlSpannedHandler.getLiveRoomMsgHTML(mBuilder ,
//                               htmlStr,false);
//                   }
//                }
//            }break;
//            case SysNotice: {
//                final IMSysNoticeMessageContent msgContent = liveMsgItem.sysNoticeContent;
//                if (msgContent != null) {
//                    if (!TextUtils.isEmpty(msgContent.link)) {
//                        SpannableString spanString = new SpannableString(msgContent.message);
//                        //下划线
//                        UnderlineSpan underlineSpan = new UnderlineSpan();
//                        spanString.setSpan(underlineSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
//                        ClickableSpan clickableSpan = new ClickableSpan() {
//                            @Override
//                            public void onClick(View widget) {
//                                //加载成功没有导航栏同主播个人页
//                                mContext.startActivity(WebViewActivity.getIntent(
//                                        mContext, "", msgContent.link, true));
//                            }
//                        };
//                        spanString.setSpan(clickableSpan,0,spanString.length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
//                        //字体颜色
//                        ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(
//                                mActivity.get().roomThemeManager.getRoomMsgListSysNoticeNormalTxtColor(
//                                        mActivity.get().mIMRoomInItem.roomType
//                                ));
//                        spanString.setSpan(foregroundColorSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
//                        ll_userLevel.setText(spanString);
//                    }else{
//                        if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Normal){
//                            SpannableString spanString = new SpannableString(msgContent.message);
//                            //字体颜色
//                            ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(
//                                    mActivity.get().roomThemeManager.getRoomMsgListSysNoticeNormalTxtColor(
//                                            mActivity.get().mIMRoomInItem.roomType
//                                    ));
//                            spanString.setSpan(foregroundColorSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
//
//                            //
//                            ll_userLevel.setText(spanString);
//                        }else if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.CarIn){
//                            //座驾入场从公告类型修改为RoomIn类型
//                        }else if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Warning){
//                            SpannableString spanString = new SpannableString(msgContent.message);
//                            //字体颜色
//                            ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(
//                                    mActivity.get().roomThemeManager.getRoomMsgListSysNoticeWarningTxtColor(
//                                            mActivity.get().mIMRoomInItem.roomType
//                                    ));
//                            spanString.setSpan(foregroundColorSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
//
//                            //
//                            ll_userLevel.setText(spanString);
//                        }
//                    }
//                }
//            }break;
//
//            case TalentRecommand:{
//                ll_userLevel.setVisibility(View.GONE);
//                llRecommended.setVisibility(View.VISIBLE);
//                SimpleDraweeView imgMsgAnchorPhoto = holder.getView(R.id.imgMsgAnchorPhoto);
//                TextView tvDesc = holder.getView(R.id.tvDesc);
//                IMUserBaseInfoItem imUserBaseInfoItem = IMManager.getInstance().getUserInfo(liveMsgItem.userId);
//                if(imUserBaseInfoItem != null){
//                    imgMsgAnchorPhoto.setImageURI(imUserBaseInfoItem.photoUrl);
//                }
//                if(liveMsgItem.textMsgContent != null){
//                    tvDesc.setText(liveMsgItem.textMsgContent.message);
//                }
//                ll_msgItemContainer.setOnClickListener(new View.OnClickListener() {
//                    @Override
//                    public void onClick(View v) {
//                        if(mLiveMessageListItemClickListener != null){
//                            mLiveMessageListItemClickListener.onItemClick(liveMsgItem);
//                        }
//                    }
//                });
//            }break;
//            default:
//                break;
//        }
//        ll_userLevel.setMovementMethod(liveMsgItem.msgType == IMMessageItem.MessageType.SysNotice
//                ? LinkMovementMethod.getInstance() : null);
//        if(null != span){
//            ll_userLevel.setText(span);
//        }
//    }

    /**
     * 初始化列表ITEM缓冲处理Spanned工具
     */
    private void initMsgListCache(){
        mLiveRoomChatMsglistItemManager = new LiveRoomChatMsglistItemManager(mContext , currLiveRoomType , mBuilder , roomThemeManager, currAnchorId , mySelfId);
        mLiveRoomChatMsglistItemManager.setListItemSpannedListener(new LiveRoomChatMsglistItemManager.onMsgItemSpannedListener() {
            @Override
            public void onSpanned(LiveRoomMsgListItem liveRoomMsgListItem) {
                //接收处理从缓冲区回来的数据
                lvlv_roomMsgList.addNewLiveMsg(liveRoomMsgListItem);
            }
        });
    }

    /**
     * 给列表控件赋值
     * @param holder
     * @param msgListItem
     */
    private void doDrawItem(ViewHolder holder,
                            final LiveRoomMsgListItem msgListItem){
        TextView ll_userLevel = holder.getView(R.id.tvMsgDescription);
        View ll_msgItemContainer = holder.getView(R.id.ll_msgItemContainer);
        //避免itemview循环利用时背景色混乱
        ll_msgItemContainer.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        //解决才艺推荐被隐藏重用问题
        View llRecommended = holder.getView(R.id.llRecommended);
        ll_userLevel.setVisibility(View.VISIBLE);
        llRecommended.setVisibility(View.GONE);

        switch (msgListItem.imMessageItem.msgType){
            case Normal:
            case Barrage:{

            }break;
            case Gift:{
                ll_msgItemContainer.setBackgroundDrawable(
                        roomThemeManager.getRoomMsgListGiftItemBgDrawable(
                                mContext, currLiveRoomType));
            }break;
            case FollowHost:{
                //FollowHost系统以公告方式推送给客户端
            }break;
            case RoomIn:{//入场消息类型

            }break;
            case SysNotice: {
                final IMSysNoticeMessageContent msgContent = msgListItem.imMessageItem.sysNoticeContent;
                if (msgContent != null) {
                    if (!TextUtils.isEmpty(msgContent.link)) {

                        ll_userLevel.setText(msgListItem.spanned);
                    }else{
                        if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Normal){
                            ll_userLevel.setText(msgListItem.spanned);
                        }else if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.CarIn){
                            //座驾入场从公告类型修改为RoomIn类型
                        }else if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Warning){
                            ll_userLevel.setText(msgListItem.spanned);
                        }
                    }
                }
            }break;

            case TalentRecommand:{
                ll_userLevel.setVisibility(View.GONE);
                llRecommended.setVisibility(View.VISIBLE);
                SimpleDraweeView imgMsgAnchorPhoto = holder.getView(R.id.imgMsgAnchorPhoto);
                TextView tvDesc = holder.getView(R.id.tvDesc);
                IMUserBaseInfoItem imUserBaseInfoItem = IMManager.getInstance().getUserInfo(msgListItem.imMessageItem.userId);
                if(imUserBaseInfoItem != null){
                    imgMsgAnchorPhoto.setImageURI(imUserBaseInfoItem.photoUrl);
                }
                if(msgListItem.imMessageItem.textMsgContent != null){
                    tvDesc.setText(msgListItem.imMessageItem.textMsgContent.message);
                }
                ll_msgItemContainer.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if(mLiveMessageListItemClickListener != null){
                            mLiveMessageListItemClickListener.onItemClick(msgListItem.imMessageItem);
                        }
                    }
                });
            }break;
            default:
                break;
        }
        ll_userLevel.setMovementMethod(msgListItem.imMessageItem.msgType == IMMessageItem.MessageType.SysNotice
                ? LinkMovementMethod.getInstance() : null);
        if(null != msgListItem.spanned){
            ll_userLevel.setText(msgListItem.spanned);
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
        if(IMMessageItem.MessageType.RoomIn == msgItem.msgType){
            Log.d(TAG,"addMessageToList-msgItem.txtMsg:"+msgItem.textMsgContent);
        }
        boolean isUpdate = false;
        //最后一条消息是RoomIn时，更新
//        if(msgItem.msgType == IMMessageItem.MessageType.RoomIn){
//            Object dataItem = lvlv_roomMsgList.getLastData();
//            if(dataItem != null && dataItem instanceof IMMessageItem){
//                IMMessageItem lastMsgitem = (IMMessageItem)dataItem;
//                if(lastMsgitem.msgType == IMMessageItem.MessageType.RoomIn){
//                    isUpdate = true;
//                    lastMsgitem.copy(msgItem);
//                }
//            }
//        }

        //del by Jagger 2018-6-21
//        if(lvlv_roomMsgList != null && !isUpdate){
//            Log.d(TAG,"addMessageToList-插入RoomIn消息");
//            lvlv_roomMsgList.addNewLiveMsg(msgItem);
//        }else{
//            Log.d(TAG,"addMessageToList-更新RoomIn消息");
//            lmlAdapter.notifyDataSetChanged();
//        }

        //edit by Jagger 2018-6-21 交由管理器异步转化HTML文本
        if(lvlv_roomMsgList != null){
            Log.d(TAG,"addMessageToList-插入RoomIn消息");
            //放放缓冲区
            if(mLiveRoomChatMsglistItemManager != null){
                mLiveRoomChatMsglistItemManager.addMsgListItem(msgItem);
            }
        }else{
            Log.d(TAG,"addMessageToList-更新RoomIn消息");
            lmlAdapter.notifyDataSetChanged();
        }
        //end
    }


    public interface LiveMessageListItemClickListener{
        public void onItemClick(IMMessageItem item);
    }
}
