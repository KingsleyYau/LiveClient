package com.qpidnetwork.livemodule.liveshow.home;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteUnreadItem;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity;
import com.qpidnetwork.livemodule.liveshow.personal.tickets.MyTicketsActivity;
import com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite.ScheduleInviteActivity;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.view.DotView.DotView;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * 个人中心
 * Created by Jagger on 2018/1/25.
 */

public class PersonalCenterFragment extends BaseFragment implements ScheduleInvitePackageUnreadManager.OnUnreadListener {
    private DotView dvInviteUnread;
    private TextView tvPackageUnread;
    private ImageView iv_myLevel;
    private LinearLayout mLlInvite , mLlBackPack , mLlMyLevel , mLlMyTickets;

    //data
    private ScheduleInvitePackageUnreadManager mScheduleInvitePackageUnreadManager;

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        refreshByData();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = View.inflate(getContext(), R.layout.activity_personal_center, null);
        dvInviteUnread = (DotView) view.findViewById(R.id.dv_InviteUnread);
        iv_myLevel = (ImageView) view.findViewById(R.id.iv_myLevel);
        tvPackageUnread = (TextView)view.findViewById(R.id.tvPackageUnread);
        //
        mScheduleInvitePackageUnreadManager = ScheduleInvitePackageUnreadManager.getInstance();
        mScheduleInvitePackageUnreadManager.registerUnreadListener(this);

        mLlInvite = (LinearLayout)view.findViewById(R.id.llInvite);
        mLlInvite.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), ScheduleInviteActivity.class);
                startActivity(intent);
            }
        });
        mLlBackPack = (LinearLayout)view.findViewById(R.id.llBackPack);
        mLlBackPack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), MyPackageActivity.class);
                startActivity(intent);
            }
        });
        mLlMyLevel = (LinearLayout)view.findViewById(R.id.llMyLevel);
        mLlMyLevel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String myLevelTitle = getResources().getString(R.string.my_level_title);
                startActivity(WebViewActivity.getIntent(getActivity(),
                        myLevelTitle,
                        WebViewActivity.UrlIntent.View_Audience_Level,
                        null,true));
            }
        });
        mLlMyTickets= (LinearLayout)view.findViewById(R.id.llTickets);
        mLlMyTickets.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), MyTicketsActivity.class);
                startActivity(intent);
            }
        });

        return view;
    }


    @Override
    public void onDestroy() {
        mScheduleInvitePackageUnreadManager.unregisterUnreadListener(this);
        super.onDestroy();
    }

    @Override
    public void onResume() {
        super.onResume();
        mScheduleInvitePackageUnreadManager.GetCountOfUnreadAndPendingInvite();
        mScheduleInvitePackageUnreadManager.GetPackageUnreadCount();
    }

    /**
     * setUserVisibleHint() 在 上图所示fragment所有生命周期之前
     * 而 一般这个方法作为当fragment变为可视时刷新数据, 这时会出现问题,因为fragment没初始化
     * @param isVisibleToUser
     */
    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        //以mContext作为是否已初始化的标志
        if(mContext != null && isVisibleToUser){
            mScheduleInvitePackageUnreadManager.GetCountOfUnreadAndPendingInvite();
            mScheduleInvitePackageUnreadManager.GetPackageUnreadCount();
        }
    }

    private void refreshByData(){
        //刷新邀请未读数目
        ScheduleInviteUnreadItem inviteItem = mScheduleInvitePackageUnreadManager.getScheduleInviteUnreadItem();
        if(inviteItem != null){
//            tvInviteUnread.setText(inviteItem.total>99 ? "99+" : String.valueOf(inviteItem.total));
//            //可动态修改属性值的shape
//            //DisplayUtil.setTxtUnReadBgDrawable(tvInviteUnread,Color.parseColor("#ec6941"));
//            tvInviteUnread.setVisibility(inviteItem.total == 0 ? View.INVISIBLE : View.VISIBLE);

            //edit by Jagger 2017-12-13
            dvInviteUnread.setVisibility(View.VISIBLE);
            dvInviteUnread.setText(String.valueOf(inviteItem.total));
            dvInviteUnread.setVisibility(inviteItem.total == 0 ? View.INVISIBLE : View.VISIBLE);
        }

        //刷新背包未读数目
        PackageUnreadCountItem packageItem = mScheduleInvitePackageUnreadManager.getPackageUnreadCountItem();
        if(packageItem != null){
            tvPackageUnread.setVisibility(packageItem.total == 0 ? View.INVISIBLE : View.VISIBLE);
        }

        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if(null != loginItem){
            iv_myLevel.setImageDrawable(DisplayUtil.getLevelDrawableByResName(getActivity(),loginItem.level));
        }
    }

    /***************************** 未读通知刷新  *********************************/
    @Override
    public void onScheduleInviteUnreadUpdate(ScheduleInviteUnreadItem item) {
        Log.d(TAG,"onScheduleInviteUnreadUpdate-item:"+item);
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                refreshByData();
            }
        });
    }

    @Override
    public void onPackageUnreadUpdate(PackageUnreadCountItem item) {
        Log.d(TAG,"onPackageUnreadUpdate-item:"+item);
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                refreshByData();
            }
        });
    }
}
