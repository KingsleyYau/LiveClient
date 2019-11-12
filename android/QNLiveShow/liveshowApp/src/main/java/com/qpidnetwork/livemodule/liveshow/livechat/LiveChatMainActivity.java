package com.qpidnetwork.livemodule.liveshow.livechat;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.Gravity;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.view.BadgeHelper;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.lang.ref.SoftReference;
import java.util.HashMap;

import q.rorbin.badgeview.Badge;
import q.rorbin.badgeview.QBadgeView;

/**
 * 2018/11/16 Hardy
 * <p>
 * 直播 LiveChat 主界面，包括以下
 * 1）chat list
 * 2）invitation list
 */
public class LiveChatMainActivity extends BaseActionBarFragmentActivity implements ViewPager.OnPageChangeListener {

    private static final String DEFAULT_SELECT_PAGE_INDEX = "pageIndex";

    // 左 tab 未读数距离 tab 文本的间距
    private static final int LEFT_TAB_RED_CIRCLE_PADDING_LEFT_NORMAL = 34;
    private static final int LEFT_TAB_RED_CIRCLE_PADDING_LEFT_BIG = 28;     // 值越小，越靠右

    private TabPageIndicator tabPageIndicator;
    private ViewPager mViewPagerContent;
    private MyPackageAdapter mAdapter;

    // 小红点
    private Badge badgeChat, badgeInvite;

    public static void startAct(Context context) {
        startAct(context, 0);
    }

    public static void startAct(Context context, int position) {
        if(checkHasChatPermission(context)){
            Intent intent = new Intent(context, LiveChatMainActivity.class);
            intent.putExtra(DEFAULT_SELECT_PAGE_INDEX, position);
            context.startActivity(intent);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_chat_main);

        //GA统计，设置Activity不需要report
        SetPageActivity(true);

        initView();
        initData();
    }

    private void initView() {
        //设置头
        setOnlyTitle(getString(R.string.Chat));
        hideTitleBarBottomDivider();

        tabPageIndicator = (TabPageIndicator) findViewById(R.id.tabPageIndicator);
        mViewPagerContent = (ViewPager) findViewById(R.id.viewPagerContent);

        //初始化adapter
        mAdapter = new MyPackageAdapter(this);
        mViewPagerContent.setAdapter(mAdapter);
        tabPageIndicator.setViewPager(mViewPagerContent);

        // 设置控件的模式，一定要先设置模式
        tabPageIndicator.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_WEIGHT_NOEXPAND_SAME);
        // 设置两个标题之间的竖直分割线的颜色，如果不需要显示这个，设置颜色为透明即可
        tabPageIndicator.setDividerColor(Color.TRANSPARENT);
        //设置中间竖线上下的padding值
        tabPageIndicator.setDividerPadding(DisplayUtil.dip2px(this, 10));
        //设置页面切换处理
        tabPageIndicator.setOnPageChangeListener(this);

        // 由于 tabPageIndicator 自带的小红点不支持需求样式
        // 左边小红点
        badgeChat = new QBadgeView(this).bindTarget(tabPageIndicator.getCurTabView(0));
        badgeChat.setBadgeNumber(0);
        badgeChat.setBadgeGravity(Gravity.CENTER | Gravity.END);
        BadgeHelper.setBaseStyle(this, badgeChat);
        badgeChat.setGravityOffset(LEFT_TAB_RED_CIRCLE_PADDING_LEFT_NORMAL, 0, true);
        // 右边小红点
        badgeInvite = new QBadgeView(this).bindTarget(tabPageIndicator.getCurTabView(1));
        badgeInvite.setBadgeNumber(0);
        badgeInvite.setBadgeGravity(Gravity.CENTER | Gravity.END);
        BadgeHelper.setBaseStyle(this, badgeInvite);
        badgeInvite.setGravityOffset(44, 0, true);
        badgeInvite.setBadgePadding(BadgeHelper.HOT_BADGE_PADDING, true);
    }

    private void initData() {
        if (getIntent() != null) {
            int position = getIntent().getIntExtra(DEFAULT_SELECT_PAGE_INDEX, 0);
            if (position > 0) {
                mViewPagerContent.setCurrentItem(position);
            }
        }

        // test
//        showRightTabRedCircle(true);
//        showLeftTabUnReadNum(true, 100);
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.i("info", "--------- LiveChatMainActivity ------------ onResume");
    }

    /**
     * 检查liveChat权限
     */
    private static boolean checkHasChatPermission(Context context){
        boolean isHasPermission = true;
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if (loginItem != null && loginItem.premit && !loginItem.livechat) {
            /* 账号未被冻结且livechat未被风控，可直接进入聊天界面 */
            isHasPermission = true;
        }else {
            MaterialDialogAlert dialog = new MaterialDialogAlert(context);
            dialog.setMessageCenter(context
                    .getString(R.string.live_chat_common_risk_control_notify));
            dialog.addButton(dialog.createButton(
                    context.getString(R.string.common_btn_ok), null));
            dialog.show();

            isHasPermission = false;
        }
        return isHasPermission;
    }

    /**
     * 左 tab 是否显示未读数字
     *
     * @param isShow
     * @param num
     */
    private void showLeftTabUnReadNum(boolean isShow, int num) {
        badgeChat.setBadgeNumber(isShow ? num : 0);
        if (isShow && num > 99) {
            badgeChat.setGravityOffset(LEFT_TAB_RED_CIRCLE_PADDING_LEFT_BIG, 0, true);
        }else {
            badgeChat.setGravityOffset(LEFT_TAB_RED_CIRCLE_PADDING_LEFT_NORMAL, 0, true);
        }
    }

    /**
     * 右 tab 是否显示小红点
     *
     * @param isShow
     */
    private void showRightTabRedCircle(boolean isShow) {
        badgeInvite.setBadgeNumber(isShow ? -1 : 0);
    }


    /**
     * 邀请列表的 tab 小红点监听
     */
    ChatOrInvitationListFragment.OnUnreadMsgListener onInviteUnreadMsgListener = new ChatOrInvitationListFragment.OnUnreadMsgListener() {
        @Override
        public void onUnreadInviteMsg(boolean showRedCircle) {
            showRightTabRedCircle(showRedCircle);
        }

        @Override
        public void onUnreadChatMsg(int unreadCount) {
            showLeftTabUnReadNum(unreadCount > 0, unreadCount);
        }
    };

    //====================      ViewPager   ==================================================
    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {
        //GA统计
        onAnalyticsPageSelected(position);
    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }
    //====================      ViewPager   ==================================================


    //====================      Adapter   ==================================================

    /**
     * Tab类型
     */
    private enum LiveChatTab {
        ChatList,
        Invitation,
    }

    public class MyPackageAdapter extends FragmentPagerAdapter {

        private String[] mTitles = null;
        private HashMap<Integer, SoftReference<ChatOrInvitationListFragment>> mLocalCache = null;

        public MyPackageAdapter(FragmentActivity activity) {
            super(activity.getSupportFragmentManager());
            mTitles = activity.getResources().getStringArray(R.array.LiveChatTab);
            mLocalCache = new HashMap<>();
        }

        @Override
        public Fragment getItem(int position) {
            SoftReference<ChatOrInvitationListFragment> fragmentRefer = mLocalCache.get(position);

            if (fragmentRefer != null && fragmentRefer.get() != null) {
                return fragmentRefer.get();
            }

            ChatOrInvitationListFragment fragment = null;
            switch (position) {
                case 0:
                    fragment = new ChatListFragment();
                    break;

                default:
                    fragment = new InvitationListFragment();
                    break;
            }
            fragment.setOnUnreadMsgListener(onInviteUnreadMsgListener);

            mLocalCache.put(position, new SoftReference<>(fragment));

            return fragment;
        }

        @Override
        public int getCount() {
            return LiveChatTab.values().length;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            String title = "";
            if (position < LiveChatTab.values().length) {
                title = getTabTitleByType(LiveChatTab.values()[position]);
            }
            return title;
        }

        /**
         * 根据tab类型获取title
         *
         * @return
         */
        private String getTabTitleByType(LiveChatTab tabtype) {
            String tabTitle = "";
            if (tabtype.ordinal() < mTitles.length) {
                tabTitle = mTitles[tabtype.ordinal()];
            }
            return tabTitle;
        }
    }
    //====================      Adapter   ==================================================
}
