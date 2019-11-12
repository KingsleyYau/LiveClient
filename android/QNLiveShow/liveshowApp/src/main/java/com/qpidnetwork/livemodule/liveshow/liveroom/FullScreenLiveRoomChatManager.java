package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.livemsglist.LiveMessageListAdapter;
import com.qpidnetwork.livemodule.framework.livemsglist.LiveMessageListView;
import com.qpidnetwork.livemodule.framework.livemsglist.MessageRecyclerView;
import com.qpidnetwork.livemodule.framework.livemsglist.ViewHolder;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvKnockRequestItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.model.LiveRoomMsgListItem;
import com.qpidnetwork.livemodule.utils.CustomerHtmlTagHandler;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.utils.StringUtil;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.bubble.BubbleLayout;

import java.lang.ref.WeakReference;

/**
 * Description:全屏样式聊天消息列表
 * <p>
 * Copt by Jagger on 2019/9/5. {@link LiveRoomChatManager}
 * 对应 view_full_screen_liveroom_msglist.xml 布局文件
 */

public class FullScreenLiveRoomChatManager implements IFileDownloadedListener {

    private final String TAG = FullScreenLiveRoomChatManager.class.getSimpleName();

    /**
     * 消息列表展开状态
     */
    public enum MsgListToggleStatus {
        OPEN,
        CLOSE
    }

//    private WeakReference<BaseCommonLiveRoomActivity> mActivity;
// 2019/3/19 Hardy
    private WeakReference<BaseFragmentActivity> mActivity;
//    private HtmlImageGetter mImageGetter;
    private CustomerHtmlTagHandler.Builder mBuilder;
    private ImageView iv_list_arrow;
    private LiveMessageListView lvlv_roomMsgList;
    private LiveMessageListAdapter lmlAdapter;
    private BubbleLayout bl_unReadTip;
    private TextView tv_unReadTip;
    private int giftImgWidth = 0;
    private int giftImgHeight = 0;
    private int anchorFlagImgWidth = 0;
    private int anchorFlagImgHeight = 0;
    private Context mContext;
    private LiveRoomChatMsgListItemTextManager mLiveRoomChatMsglistItemManager;

    private MsgListToggleStatus mMsgListToggleStatus = MsgListToggleStatus.OPEN;

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
    private FullScreenLiveRoomChatMsgListItemUiManager mFullScreenLiveRoomChatMsgListItemUiManager;

    public FullScreenLiveRoomChatManager(Context context, IMRoomInItem.IMLiveRoomType currLiveRoomType,
                                         String currAnchorId, String mySelfId, RoomThemeManager roomThemeManager){
        Log.d(TAG,"LiveRoomChatManager-currLiveRoomType:"+currLiveRoomType+" currAnchorId:"+currAnchorId+" mySelfId:"+mySelfId);
        mContext = context;
        this.currLiveRoomType = currLiveRoomType;
        this.currAnchorId = currAnchorId;
        this.mySelfId = mySelfId;
        this.roomThemeManager = roomThemeManager;
        this.mFullScreenLiveRoomChatMsgListItemUiManager = new FullScreenLiveRoomChatMsgListItemUiManager(mContext, roomThemeManager, currLiveRoomType, currAnchorId);
    }

    public void init(BaseFragmentActivity roomActivity, View container){
        mActivity = new WeakReference<>(roomActivity);
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
        lvlv_roomMsgList.setDisplayDirection(MessageRecyclerView.DisplayDirection.BottomToTop); //数据从底向上排
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

        //聊天消息ITEM样式
        lmlAdapter = new LiveMessageListAdapter<LiveRoomMsgListItem>(roomActivity,
                mFullScreenLiveRoomChatMsgListItemUiManager.getLayoutResId()) {
            @Override
            public void convert(ViewHolder holder, LiveRoomMsgListItem liveMsgItem) {
                mFullScreenLiveRoomChatMsgListItemUiManager.doDrawItem(holder, liveMsgItem);
            }
        };

        lvlv_roomMsgList.setAdapter(lmlAdapter);
        lvlv_roomMsgList.setMaxMsgSum(mContext.getResources().getInteger(R.integer.liveMsgListMaxNum));
        lvlv_roomMsgList.setHoldingTime(mContext.getResources().getInteger(R.integer.liveMsgListItemHoldTime));
        lvlv_roomMsgList.setVerticalSpace(Float.valueOf(mContext.getResources().getDimension(R.dimen.listmsgview_item_decoration)).intValue());
        lvlv_roomMsgList.setGradualColor(roomThemeManager.getRoomMsgListTopGradualColor(currLiveRoomType));

        //未读
        tv_unReadTip = (TextView) container.findViewById(R.id.tv_unReadTip);
        bl_unReadTip = container.findViewById(R.id.bl_unReadTip);
        bl_unReadTip.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mMsgListToggleStatus == MsgListToggleStatus.CLOSE){
                    openMsgList();
                }
                lvlv_roomMsgList.loadNewestUnreadMsg();
            }
        });

        //列表开关
        iv_list_arrow = container.findViewById(R.id.iv_list_arrow);
        iv_list_arrow.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mMsgListToggleStatus == MsgListToggleStatus.OPEN){
                    closeMsgList();
                }else{
                    openMsgList();
                }
            }
        });

        initMsgListCache();
    }

    //----------------------- 对外公开方法 start -----------------------

    /**
     * 设置点击事件监听器
     * @param listener
     */
    public void setLiveMessageListItemClickListener(FullScreenLiveRoomChatMsgListItemUiManager.LiveMessageListItemClickListener listener){
        mFullScreenLiveRoomChatMsgListItemUiManager.setLiveMessageListItemClickListener(listener);
    }

    /**
     * 插入消息
     * @param msgItem
     */
    public void addMessageToList(IMMessageItem msgItem){
        if(IMMessageItem.MessageType.RoomIn == msgItem.msgType){
            Log.d(TAG,"addMessageToList-msgItem.txtMsg:"+msgItem.textMsgContent);
        }

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

    /**
     * 取得列表展开/关闭状态
     * @return
     */
    public MsgListToggleStatus getToggleStatus(){
        return mMsgListToggleStatus;
    }

    /**
     * 滚到最底
     */
    public void scrollToBottom(){
        lvlv_roomMsgList.loadNewestUnreadMsg();
    }

    /**
     * 一定要调用
     */
    public void destroy(){
        if(mLiveRoomChatMsglistItemManager != null){
            mLiveRoomChatMsglistItemManager.destroy();
        }
        if (lvlv_roomMsgList != null) {
            lvlv_roomMsgList.onDestroy();
        }
    }

    //----------------------- 对外公开方法 end -----------------------

    /**
     * 更新未读消息提示界面
     * @param unReadNum
     */
    private void updateUnreadLiveMsgTipVew(int unReadNum){
        Log.d(TAG,"updateUnreadLiveMsgTipVew-unReadNum:"+unReadNum);

        bl_unReadTip.setVisibility(0 == unReadNum ? View.INVISIBLE : View.VISIBLE);
        String unReadTip = mContext.getString(R.string.tip_unReadLiveMsg,unReadNum);
        tv_unReadTip.setText(unReadTip);
    }

    /**
     * 展开消息列表
     */
    private void openMsgList(){
        mMsgListToggleStatus = MsgListToggleStatus.OPEN;

        lvlv_roomMsgList.setVisibility(View.VISIBLE);
        //更改箭头图标
        iv_list_arrow.setImageResource(R.drawable.ic_full_screen_live_room_arrow_down_white);

        //如果列表在底部，把未读气泡隐藏
        if(lvlv_roomMsgList.getReadingStatus() == MessageRecyclerView.ReadingStatus.Playing){
            lvlv_roomMsgList.loadNewestUnreadMsg();
            bl_unReadTip.setVisibility(View.INVISIBLE);
        }
    }

    /**
     * 收起消息列表
     */
    private void closeMsgList(){
        mMsgListToggleStatus = MsgListToggleStatus.CLOSE;

        lvlv_roomMsgList.setVisibility(View.GONE);
        //更改箭头图标
        iv_list_arrow.setImageResource(R.drawable.ic_full_screen_live_room_arrow_up_white);
    }
    
    /**
     * 初始化列表ITEM缓冲处理Spanned工具
     */
    private void initMsgListCache(){
        mLiveRoomChatMsglistItemManager = new LiveRoomChatMsgListItemTextManager(mContext , currLiveRoomType , mBuilder , roomThemeManager, currAnchorId , mySelfId);
        mLiveRoomChatMsglistItemManager.setListItemSpannedListener(new LiveRoomChatMsgListItemTextManager.onMsgItemSpannedListener() {
            @Override
            public void onSpanned(LiveRoomMsgListItem liveRoomMsgListItem) {
                //接收处理从缓冲区回来的数据
                lvlv_roomMsgList.addNewLiveMsg(liveRoomMsgListItem);
            }

            @Override
            public void onRefreshList() {
                //刷新列表（用于礼物图片下载成功回调）
                lmlAdapter.notifyDataSetChanged();
            }
        });
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

    @Override
    public void onProgress(String fileUrl, int progress) {

    }
}
