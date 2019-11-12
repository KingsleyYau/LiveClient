package com.qpidnetwork.anchor.liveshow.home;

import android.app.Activity;
import android.content.Intent;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.bean.AnchorInCoinInfo;
import com.qpidnetwork.anchor.bean.ScheduleInviteUnreadItem;
import com.qpidnetwork.anchor.framework.base.BaseFragment;
import com.qpidnetwork.anchor.httprequest.OnGetTodayCreditCallback;
import com.qpidnetwork.anchor.liveshow.hangout.OngoingHangoutListActivity;
import com.qpidnetwork.anchor.liveshow.manager.AnchorInfoManager;
import com.qpidnetwork.anchor.liveshow.manager.CheckPCBroadCastRoomStatusManager;
import com.qpidnetwork.anchor.liveshow.manager.ProgramUnreadManager;
import com.qpidnetwork.anchor.liveshow.manager.ScheduleInviteManager;
import com.qpidnetwork.anchor.liveshow.personal.scheduleinvite.ScheduleInviteActivity;
import com.qpidnetwork.anchor.liveshow.personal.shows.MyShowsActivity;

import q.rorbin.badgeview.QBadgeView;

/**
 * Message中心
 * Created by Jagger on 2018/1/25.
 */

public class HomeFragment extends BaseFragment implements ScheduleInviteManager.OnScheduleInviteChangeListener,
        ProgramUnreadManager.OnProgramUnreadListener {

    private final static int EVNET_ANCHOR_COINS_UPDATE = 1;
    private final static int EVNET_SHCEDULED_INVITE_NOTIFY = 2;
    private final static int EVNET_PROGRAM_UNREAD_NOTIFY = 3;

    private RelativeLayout rlMonthProgress;
    private TextView tvMonthlyProgress;
    private ProgressBar mProgressBar;
    private TextView tvCoins;
    private TextView tvScheduled;
    private QBadgeView qbvUnread, qbvCalendarUnread;
    private LinearLayout mLinearLayoutTodoItem, mLinearLayoutCalendarItem;

    // 2019/11/8 Hardy  多端，在 PC 端开启直播间
    private View mLLBroadcastRoomItem;
    private ImageView mIvBroadcastRoomLiving;
    private TextView mTvBroadcastRoomDesc;

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        initData();
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        //绑定预约未读事件监听器
        ScheduleInviteManager.getInstance().registerScheduleInviteChangeListener(this);
        //绑定节目未读事件监听器
        ProgramUnreadManager.getInstance().registerUnreadListener(this);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        //解绑预约未读事件监听器
        ScheduleInviteManager.getInstance().unregisterScheduleInviteChangeListener(this);
        //解绑节目未读事件监听器
        ProgramUnreadManager.getInstance().unregisterUnreadListener(this);
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        if (isVisibleToUser) {
            //刷新未读数目
            if (mContext != null) {
                ProgramUnreadManager.getInstance().GetNoReadNumProgram();
            }
            ScheduleInviteManager.getInstance().GetCountOfUnreadAndPendingInvite();
            ScheduleInviteManager.getInstance().GetAllScheduledInviteCount();
            //更新主播信用点信息
            updateAnchorCoinInfo();
        }
    }


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = View.inflate(getContext(), R.layout.fragment_main_home, null);

        mProgressBar = (ProgressBar) view.findViewById(R.id.progressBar);
        mProgressBar.setProgress(0);

        rlMonthProgress = (RelativeLayout) view.findViewById(R.id.rlMonthProgress);
        tvMonthlyProgress = (TextView) view.findViewById(R.id.tvMonthlyProgress);
        tvCoins = (TextView) view.findViewById(R.id.tvCoins);

        LinearLayout llScheduledBooking = (LinearLayout) view.findViewById(R.id.llScheduledBooking);
        llScheduledBooking.setOnClickListener(this);
        tvScheduled = (TextView) view.findViewById(R.id.tvScheduled);
        mLinearLayoutTodoItem = (LinearLayout) view.findViewById(R.id.ll_todo_item);
        mLinearLayoutTodoItem.setOnClickListener(this);

        mLinearLayoutCalendarItem = (LinearLayout) view.findViewById(R.id.ll_calendar_item);
        mLinearLayoutCalendarItem.setOnClickListener(this);

        //增加hang-out点击效果
        view.findViewById(R.id.ll_hangout_item).setOnClickListener(this);

        qbvUnread = new QBadgeView(mContext);
        qbvUnread.setBadgeNumber(0)  //先隐藏, 因为初始化时取不到准确的坐标,会在右上角先显示一个图标,不好看
                .setBadgeGravity(Gravity.END | Gravity.CENTER)
                .setShowShadow(false)//不要阴影
                .bindTarget(mLinearLayoutTodoItem);

        qbvCalendarUnread = new QBadgeView(mContext);
        qbvCalendarUnread.setBadgeNumber(0)  //先隐藏, 因为初始化时取不到准确的坐标,会在右上角先显示一个图标,不好看
                .setBadgeGravity(Gravity.END | Gravity.CENTER)
                .setShowShadow(false)//不要阴影
                .bindTarget(mLinearLayoutCalendarItem);

        // 2019/11/8 Hardy
        mLLBroadcastRoomItem = view.findViewById(R.id.fg_main_home_item_ll_broadcast_room);
        mIvBroadcastRoomLiving = view.findViewById(R.id.adapter_home_broadcast_room_item_iv_icon);
        mTvBroadcastRoomDesc = view.findViewById(R.id.adapter_home_broadcast_room_item_tv_desc);
        mLLBroadcastRoomItem.setOnClickListener(this);
        // 隐藏直播间冒泡 view
        hideBroadCastRoomView();

        // 注册
        CheckPCBroadCastRoomStatusManager.getInstance().register(new CheckPCBroadCastRoomStatusManager.OnCheckRoomStatusChangeListener() {
            @Override
            public void onOpen(String desc) {
                openBroadCastRoomView(desc);
            }

            @Override
            public void onHide() {
                hideBroadCastRoomView();
            }

            @Override
            public void onPublicRoomPreview() {
                if (mContext instanceof MainFragmentActivity) {
                    ((MainFragmentActivity) mContext).publicRoomOpenClick();
                }
            }
        });
        // 主动查询直播间信息
        CheckPCBroadCastRoomStatusManager.getInstance().getCurRoomInfo();

        return view;
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()) {
            case R.id.ll_todo_item: {
                Intent intent = new Intent(getActivity(), ScheduleInviteActivity.class);
                startActivity(intent);
            }
            break;
            case R.id.llScheduledBooking: {
                Intent intent = new Intent(getActivity(), ScheduleInviteActivity.class);
                startActivity(intent);
            }
            break;
            case R.id.ll_calendar_item: {
                Intent intent = new Intent(getActivity(), MyShowsActivity.class);
                startActivity(intent);
            }
            break;
            case R.id.ll_hangout_item: {
                Intent intent = new Intent(getActivity(), OngoingHangoutListActivity.class);
                startActivity(intent);
            }
            break;

            case R.id.fg_main_home_item_ll_broadcast_room: {
                CheckPCBroadCastRoomStatusManager.getInstance().handlerClickEvent(mContext);
            }
            break;

            default:
                break;
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        CheckPCBroadCastRoomStatusManager.getInstance().unRegister();
    }

    @Override
    public void onResume() {
        super.onResume();
        //刷新未读数目
        ProgramUnreadManager.getInstance().GetNoReadNumProgram();
    }

    private void initData() {
        //本地更新预约邀请信息
        ScheduleInviteUnreadItem unreadItem = ScheduleInviteManager.getInstance().getScheduleInviteUnreadItem();
        int scheduleCount = ScheduleInviteManager.getInstance().getAllScheduledInviteCount();
        refreshScheduleInvite(unreadItem, scheduleCount);
        //本地更新主播信息
        AnchorInCoinInfo anchorCoinsInfo = AnchorInfoManager.getInstance().getLocalAnchorInCoinInfo();
        refreshAnchorCoinsInfo(anchorCoinsInfo);
        //初始化节目未读数目显示
        refreshProgramUnread(ProgramUnreadManager.getInstance().GetLocalShowNoRead());
    }

    /**
     * 刷新预约邀请信息
     *
     * @param unreadItem
     * @param scheduleInviteCount
     */
    public void refreshScheduleInvite(ScheduleInviteUnreadItem unreadItem, int scheduleInviteCount) {
        tvScheduled.setText(String.valueOf(scheduleInviteCount));
        if (unreadItem != null) {
            if (unreadItem.confirmedUnreadCount > 0) {
//                tvUnread.setVisibility(View.VISIBLE);
//                tvUnread.setText(String.valueOf(unreadItem.confirmedUnreadCount));
                qbvUnread.setBadgeText(String.valueOf(unreadItem.confirmedUnreadCount));
            } else {
//                tvUnread.setVisibility(View.GONE);
                qbvUnread.setBadgeNumber(0);
            }
        }
    }

    /**
     * 刷新主播信用点信息
     *
     * @param anchorInfo
     */
    private void refreshAnchorCoinsInfo(AnchorInCoinInfo anchorInfo) {
        if (anchorInfo != null) {
//            rlMonthProgress.setVisibility(View.VISIBLE);
            rlMonthProgress.setVisibility(View.GONE);
            tvMonthlyProgress.setText(String.format(getResources().getString(R.string.live_home_month_task_progress_desc),
                    String.valueOf(anchorInfo.monthCompleted), String.valueOf(anchorInfo.monthTarget)));
            tvCoins.setText(String.valueOf(anchorInfo.monthCredit));
            mProgressBar.setProgress(anchorInfo.monthProgress);
        } else {
//            rlMonthProgress.setVisibility(View.INVISIBLE);
            rlMonthProgress.setVisibility(View.GONE);
            tvCoins.setText(getResources().getString(R.string.common_default_middle_dash));
            mProgressBar.setProgress(0);
        }
    }

    /**
     * 刷新节目未读数目
     *
     * @param unreadNum
     */
    private void refreshProgramUnread(int unreadNum) {
        if (unreadNum > 0) {
            qbvCalendarUnread.setBadgeText(String.valueOf(unreadNum));
        } else {
            qbvCalendarUnread.setBadgeNumber(0);
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what) {
            case EVNET_ANCHOR_COINS_UPDATE: {
                AnchorInCoinInfo anchorInfo = (AnchorInCoinInfo) msg.obj;
                refreshAnchorCoinsInfo(anchorInfo);
            }
            break;

            case EVNET_SHCEDULED_INVITE_NOTIFY: {
                int scheduledInviteCount = msg.arg1;
                ScheduleInviteUnreadItem item = (ScheduleInviteUnreadItem) msg.obj;
                refreshScheduleInvite(item, scheduledInviteCount);
            }
            break;

            case EVNET_PROGRAM_UNREAD_NOTIFY: {
                int unreadNum = msg.arg1;
                refreshProgramUnread(unreadNum);
            }
            break;
        }
    }

    /**
     * 更新主播coins信息
     */
    private void updateAnchorCoinInfo() {
        AnchorInfoManager.getInstance().GetInCoinsInfo(new OnGetTodayCreditCallback() {
            @Override
            public void onGetTodayCredit(boolean isSuccess, int errCode, String errMsg, int monthCredit, int monthCompleted, int monthTarget, int monthProgress) {
                if (isSuccess) {
                    Message msg = Message.obtain();
                    msg.what = EVNET_ANCHOR_COINS_UPDATE;
                    msg.obj = new AnchorInCoinInfo(monthCredit, monthCompleted, monthTarget, monthProgress);
                    sendUiMessage(msg);
                }
            }
        });
    }

    /****************************** 预约邀请未读数目更新通知  ************************************/
    @Override
    public void onScheduleInviteUpdate(ScheduleInviteUnreadItem item, int scheduledInvite) {
        Message msg = Message.obtain();
        msg.what = EVNET_SHCEDULED_INVITE_NOTIFY;
        msg.arg1 = scheduledInvite;
        msg.obj = item;
        sendUiMessage(msg);
    }

    /****************************** 获取节目未读数目更新通知  ************************************/
    @Override
    public void onProgramUnreadUpdate(int unreadNum) {
        Message msg = Message.obtain();
        msg.what = EVNET_PROGRAM_UNREAD_NOTIFY;
        msg.arg1 = unreadNum;
        sendUiMessage(msg);
    }

    //****************************** 多端直播 **********************************************

    private void openBroadCastRoomView(String roomTypeDesc) {
        setBroadCastRoomDesc(roomTypeDesc);
        showBroadCastRoomLiving(true);
        showBroadCastRoomView(true);
    }

    private void hideBroadCastRoomView() {
        showBroadCastRoomLiving(false);
        showBroadCastRoomView(false);
    }

    private void setBroadCastRoomDesc(String val) {
        mTvBroadcastRoomDesc.setText(val);
    }

    private void showBroadCastRoomLiving(boolean isShow) {
        if (isShow) {
            mIvBroadcastRoomLiving.postDelayed(new Runnable() {
                @Override
                public void run() {
                    Drawable tempDrawable = mIvBroadcastRoomLiving.getDrawable();
                    if (tempDrawable instanceof AnimationDrawable) {
                        ((AnimationDrawable) tempDrawable).start();
                    }
                }
            }, 200);
        } else {
            Drawable tempDrawable = mIvBroadcastRoomLiving.getDrawable();
            if (tempDrawable instanceof AnimationDrawable) {
                ((AnimationDrawable) tempDrawable).stop();
            }
        }
    }

    private void showBroadCastRoomView(boolean isShow) {
        mLLBroadcastRoomItem.setVisibility(isShow ? View.VISIBLE : View.GONE);
    }

    //****************************** 多端直播 **********************************************
}
