package com.qpidnetwork.anchor.liveshow.liveroom;

import android.content.Context;
import android.graphics.Color;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.UnderlineSpan;
import android.view.View;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.anchor.liveshow.BaseWebViewActivity;
import com.qpidnetwork.anchor.liveshow.WebViewActivity;
import com.qpidnetwork.anchor.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.GiftImageType;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.anchor.liveshow.model.LiveRoomMsgListItem;
import com.qpidnetwork.anchor.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.anchor.utils.CustomerHtmlTagHandler;
import com.qpidnetwork.anchor.utils.HtmlSpannedHandler;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.functions.Function;
import io.reactivex.observers.DisposableObserver;
import io.reactivex.subjects.PublishSubject;

/**
 * @author Jagger 2018-6-20
 * 直播间聊天消息列表item处理
 */
public class LiveRoomChatMsglistItemManager {
    /**
     * html模板中, 已购票标识
     */
    private final String HTML_TAG_TICKET = "<jimg src=\"ticket\"/>";

    /**
     * 当前直播间类型
     */
    private IMRoomInItem.IMLiveRoomType currLiveRoomType;
    /**
     * 当前主播ID/hangout直播间男士ID
     */
    private String mCurrAnchorId = null;
    private Context mContext;
    private CustomerHtmlTagHandler.Builder mBuilder;
    private RoomThemeManager mRoomThemeManager;

    private PublishSubject<IMMessageItem> mPublishSubject;  //缓存着未将内容转化为HTML文本的聊天信息列表
    private CompositeDisposable mCompositeDisposable;
    private DisposableObserver<List<LiveRoomMsgListItem>> mDisposableObserver;
    private onMsgItemSpannedListener mOnMsgItemSpannedListener;

    /**
     * 为了下载礼物图片后，能重生生成spanned
     */
    private class Obj4DownloadRefresh{
        private LiveRoomMsgListItem mLiveRoomMsgListItem;
        private String mHtmlStr;

        public Obj4DownloadRefresh(LiveRoomMsgListItem liveRoomMsgListItem , String htmlStr){
            mLiveRoomMsgListItem = liveRoomMsgListItem;
            mHtmlStr = htmlStr;
        }
    }

    /**
     * 事件回调
     */
    public interface onMsgItemSpannedListener{
        void onSpanned(LiveRoomMsgListItem liveRoomMsgListItem);
    }

    public LiveRoomChatMsglistItemManager(Context context ,
                                          IMRoomInItem.IMLiveRoomType liveRoomType ,
                                          CustomerHtmlTagHandler.Builder builder,
                                          RoomThemeManager roomThemeManager,
                                          String currAnchorId){
        mContext = context;
        currLiveRoomType = liveRoomType;
        mBuilder = builder;
        mRoomThemeManager = roomThemeManager;
        mCurrAnchorId = currAnchorId;
        init();
    }

    /**
     * 异步处理，子线程生成HTML文本，再转到主线程画item，以免卡界面
     *
     * Ps:RxJava处理缓冲区用法 https://www.jianshu.com/p/5dd01b14c02a
     */
    private void init(){
        //监听者
        mDisposableObserver = new DisposableObserver<List<LiveRoomMsgListItem>>() {
            @Override
            public void onNext(List<LiveRoomMsgListItem> msgItems) {
                //回调出去
                if(mOnMsgItemSpannedListener != null){
                    for (LiveRoomMsgListItem msgItem:msgItems) {
                        mOnMsgItemSpannedListener.onSpanned(msgItem);
                    }
                }

            }

            @Override
            public void onError(Throwable throwable) {

            }

            @Override
            public void onComplete() {

            }
        };

        //创建缓冲区
        mPublishSubject = PublishSubject.create();

        //每秒轮询一次缓冲区中的数据
        mPublishSubject.buffer(1000, TimeUnit.MILLISECONDS)
                .map(new Function<List<IMMessageItem>, List<LiveRoomMsgListItem>>() {
                    /**
                     * 把 IMMessageItem 转化为 LiveRoomMsgListItem 回调出去
                     * @param imMessageItems
                     * @return
                     * @throws Exception
                     */
                    @Override
                    public List<LiveRoomMsgListItem> apply(List<IMMessageItem> imMessageItems) throws Exception {
                        //转化文本为HTML文本，再发送出去
                        List<LiveRoomMsgListItem> msgListItems = new ArrayList<>();

                        for (IMMessageItem imMessageItem:imMessageItems) {
                            //转为另一种类型
                            LiveRoomMsgListItem msgListItem = new LiveRoomMsgListItem();
                            msgListItem.imMessageItem = imMessageItem;
                            doMakeSpanner(msgListItem);
                            msgListItems.add(msgListItem);
                        }
                        return msgListItems;
                    }
                })
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(mDisposableObserver);

        //用作停止监听
        mCompositeDisposable = new CompositeDisposable();
        mCompositeDisposable.add(mDisposableObserver);
    }

    /**
     * 设置 消息文本转换为HTML文本成功监听器
     * (已转为UI线程，可直接处理界面)
     * @param onMsgItemSpannedListener
     */
    public void setListItemSpannedListener(onMsgItemSpannedListener onMsgItemSpannedListener){
        mOnMsgItemSpannedListener = onMsgItemSpannedListener;
    }

    /**
     * 插入消息
     * @param imMessageItem
     */
    public void addMsgListItem(IMMessageItem imMessageItem){
        if(mPublishSubject != null){
            mPublishSubject.onNext(imMessageItem);
        }
    }

    /**
     * 销毁,一定要调用
     */
    public void destroy(){
        if(mCompositeDisposable != null){
            mCompositeDisposable.clear();
        }
    }

    /**
     * 生成Html文本
     * @param msgListItem
     */
    private void doMakeSpanner(LiveRoomMsgListItem msgListItem){

        switch (msgListItem.imMessageItem.msgType){
            case Normal:
            case Barrage:{
                //弹幕或者普通文本消息
                String emoParseStr = null;
                boolean isAnchor = false;
                if(currLiveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom){
                    //currAnchorId在hangout直播间指定为男士ID
                    isAnchor = !msgListItem.imMessageItem.userId.equals(mCurrAnchorId);
                }else{
                    isAnchor = msgListItem.imMessageItem.userId.equals(mCurrAnchorId);
                }
                int strResId = mRoomThemeManager.getRoomMsgListNormalStrResId(currLiveRoomType,isAnchor);
                if(0 != strResId){
                    //把数据填入HTML模块中
                    String htmlStr = mContext.getResources().getString(strResId,
                            msgListItem.imMessageItem.nickName,
                            TextUtils.htmlEncode(msgListItem.imMessageItem.textMsgContent.message));

                    //处理是否有购票标识
                    if(!isAnchor && IMManager.getInstance().getUserInfo(msgListItem.imMessageItem.userId)!= null){
                        htmlStr = doCheckHasTicketTag(htmlStr , IMManager.getInstance().getUserInfo(msgListItem.imMessageItem.userId).isHasTicket);
                    }

                    //生成真正的文本
                    emoParseStr = ChatEmojiManager.getInstance().parseEmojiStr(mContext,
                            htmlStr,ChatEmojiManager.PATTERN_MODEL_SIMPLESIGN);
                    msgListItem.spanned = HtmlSpannedHandler.getLiveRoomMsgHTML(mBuilder,emoParseStr,false,false);
                }
            }break;
            case Gift:{
                boolean isAnchor = false;
                if(currLiveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom){
                    //currAnchorId在hangout直播间指定为男士ID
                    isAnchor = !msgListItem.imMessageItem.userId.equals(mCurrAnchorId);
                }else{
                    isAnchor = msgListItem.imMessageItem.userId.equals(mCurrAnchorId);
                }
                //检测礼物小图片存在与否，不存在自动下载，更新列表
//                NormalGiftManager.getInstance().getGiftImage(msgListItem.imMessageItem.giftMsgContent.giftId,
//                        GiftImageType.MsgListIcon, this);
                //礼物消息列表展示
                GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(msgListItem.imMessageItem.giftMsgContent.giftId);
                //toUid
                boolean hasRecvNickname = null != msgListItem.imMessageItem.textMsgContent && !TextUtils.isEmpty(msgListItem.imMessageItem.textMsgContent.message);
                boolean isCelebGift = false;
                if(null != giftItem){
                    isCelebGift = giftItem.giftType == GiftItem.GiftType.Celebrate;
                }else{
                    isCelebGift = !hasRecvNickname;
                }
                int strResId = mRoomThemeManager.getRoomMsgListGiftMsgStrResId(currLiveRoomType,isAnchor, giftItem,
                        msgListItem.imMessageItem.giftMsgContent.isSecretly,hasRecvNickname);
                String giftNum = "";
                if(msgListItem.imMessageItem.giftMsgContent.giftNum > 1){
                    giftNum = mContext.getResources().getString(R.string.liveroom_message_gift_x,
                            msgListItem.imMessageItem.giftMsgContent.giftNum);
                }
                String htmlStr = null;
                if(currLiveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom){
                    if(isCelebGift){
                        htmlStr = mContext.getResources().getString(
                                strResId,
                                msgListItem.imMessageItem.nickName,
                                msgListItem.imMessageItem.giftMsgContent.giftName);
                    }else if(hasRecvNickname){
                        htmlStr = mContext.getResources().getString(
                                strResId,
                                msgListItem.imMessageItem.nickName,
                                msgListItem.imMessageItem.giftMsgContent.giftName,
                                msgListItem.imMessageItem.giftMsgContent.giftId,
                                msgListItem.imMessageItem.textMsgContent.message);
                    }
                }else{
                    htmlStr = mContext.getResources().getString(
                            strResId,
                            msgListItem.imMessageItem.nickName,
                            msgListItem.imMessageItem.giftMsgContent.giftName,
                            msgListItem.imMessageItem.giftMsgContent.giftId,
                            giftNum);
                }
                //处理是否有购票标识
                if(!isAnchor && IMManager.getInstance().getUserInfo(msgListItem.imMessageItem.userId)!= null){
                    htmlStr = doCheckHasTicketTag(htmlStr , IMManager.getInstance().getUserInfo(msgListItem.imMessageItem.userId).isHasTicket);
                }
                final Obj4DownloadRefresh obj4DownloadRefresh = new Obj4DownloadRefresh(msgListItem , htmlStr);
                //检测礼物小图片存在与否，不存在自动下载，重新生成Spanned
                NormalGiftManager.getInstance().getGiftImageEx(msgListItem.imMessageItem.giftMsgContent.giftId,
                        GiftImageType.MsgListIcon, new IFileDownloadedListener() {

                            @Override
                            public void onCompleted(boolean isDownloadSuccess, String localFilePath, String fileUrl) {
                                if(isDownloadSuccess && obj4DownloadRefresh.mLiveRoomMsgListItem != null){
                                    obj4DownloadRefresh.mLiveRoomMsgListItem.spanned = HtmlSpannedHandler.getLiveRoomMsgHTML(mBuilder ,
                                            obj4DownloadRefresh.mHtmlStr,true,false);
                                }
                            }
                        });
                //生成真正的文本
                msgListItem.spanned = HtmlSpannedHandler.getLiveRoomMsgHTML(mBuilder ,
                        htmlStr,true,false);
            }break;
            case FollowHost:{
                //FollowHost系统以公告方式推送给客户端
            }break;
            case RoomIn:{//入场消息类型
                if(null != currLiveRoomType && null != msgListItem.imMessageItem.roomInMessageContent){
                    boolean hasCar = !TextUtils.isEmpty(msgListItem.imMessageItem.roomInMessageContent.riderId);
                    int strResId = mRoomThemeManager.getRoomMsgListRoomInMsgStrResId(
                            currLiveRoomType, hasCar,!TextUtils.isEmpty(msgListItem.imMessageItem.userId) && msgListItem.imMessageItem.userId.equals(mCurrAnchorId));
                    if(0 != strResId){
                        //把数据填入HTML模块中
                        String roomInStr = null;
                        if(hasCar){
                            roomInStr= mContext.getResources().getString(strResId,
                                    msgListItem.imMessageItem.roomInMessageContent.nickname,
                                    msgListItem.imMessageItem.roomInMessageContent.riderName,
                                    msgListItem.imMessageItem.roomInMessageContent.riderImgLocalPath);
                        }else{
                            roomInStr= mContext.getResources().getString(strResId, msgListItem.imMessageItem.roomInMessageContent.nickname);
                        }

                        //处理是否有购票标识
                        if(IMManager.getInstance().getUserInfo(msgListItem.imMessageItem.userId)!= null){
                            roomInStr = doCheckHasTicketTag(roomInStr , IMManager.getInstance().getUserInfo(msgListItem.imMessageItem.userId).isHasTicket);
                        }

                        //生成真正的文本
                        msgListItem.spanned = HtmlSpannedHandler.getLiveRoomMsgHTML(mBuilder,roomInStr, false,true);
                    }
                }
            }break;
            case SysNotice: {
                final IMSysNoticeMessageContent msgContent = msgListItem.imMessageItem.sysNoticeContent;
                if (msgContent != null) {
                    if (!TextUtils.isEmpty(msgContent.link)) {
                        SpannableString spanString = new SpannableString(msgContent.message);
                        //下划线
                        UnderlineSpan underlineSpan = new UnderlineSpan();
                        spanString.setSpan(underlineSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                        ClickableSpan clickableSpan = new ClickableSpan() {
                            @Override
                            public void onClick(View widget) {
                                //加载成功没有导航栏同主播个人页
                                mContext.startActivity(WebViewActivity.getIntent(
                                        mContext, "", msgContent.link, BaseWebViewActivity.WebTitleType.Normal));
                            }
                        };
                        spanString.setSpan(clickableSpan,0,spanString.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                        //字体颜色
                        ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(
                                mRoomThemeManager.getRoomMsgListSysNoticeNormalTxtColor( currLiveRoomType ));
                        spanString.setSpan(foregroundColorSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
//                        tvMsgDescription.setText(spanString);
                        msgListItem.spanned = spanString;
                    }else{
                        if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Normal){
                            SpannableString spanString = new SpannableString(msgContent.message);
                            //字体颜色
                            ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(
                                    mRoomThemeManager.getRoomMsgListSysNoticeNormalTxtColor( currLiveRoomType ));
                            spanString.setSpan(foregroundColorSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
//                            tvMsgDescription.setText(spanString);
                            msgListItem.spanned = spanString;
                        }else if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.CarIn){
                            //座驾入场从公告类型修改为RoomIn类型
                        }else if(msgContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Warning){
                            SpannableString spanString = new SpannableString(msgContent.message);
                            //字体颜色-警告-所有直播间保持一致
                            ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(Color.parseColor("#FF4D4D"));
                            spanString.setSpan(foregroundColorSpan, 0, spanString.length(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
//                            tvMsgDescription.setText(spanString);
                            msgListItem.spanned = spanString;
                        }
                    }
                }
            }break;
            case HangOut:{
                if(null != currLiveRoomType && null != msgListItem.imMessageItem.hangoutRecommendItem){
                    int strResId = mRoomThemeManager.getRoomMsgListRecommendedStrResId(
                            currLiveRoomType);
                    if(0 != strResId){
                        //把数据填入HTML模块中
                        String strRecommend = null;

                        if(currLiveRoomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom
                                || currLiveRoomType == IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom){
                            strRecommend= mContext.getResources().getString(strResId,
                                    msgListItem.imMessageItem.hangoutRecommendItem.friendNickName,
                                    msgListItem.imMessageItem.hangoutRecommendItem.manNickeName
                            );
                        }else if(currLiveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom){
                            strRecommend= mContext.getResources().getString(strResId,
                                    msgListItem.imMessageItem.hangoutRecommendItem.nickName,
                                    msgListItem.imMessageItem.hangoutRecommendItem.friendNickName);
                        }

                        //生成真正的文本
                        msgListItem.spanned = HtmlSpannedHandler.getLiveRoomMsgHTML(mBuilder,strRecommend, false,false);
                    }
                }
            }break;

            default:
                break;
        }
    }

    /**
     * 处理已购票标签
     */
    private String doCheckHasTicketTag(String htmlStr , boolean hasTicket){
        //没买票的,把标识转为空, 就不会显示买票图标了
        if(!hasTicket){
            htmlStr = htmlStr.replace(HTML_TAG_TICKET , "");
        }
        return htmlStr;
    }
}
