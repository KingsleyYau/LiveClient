package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.statusbar.StatusBarUtil;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteUnreadItem;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager.OnUnreadListener;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity;
import com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite.ScheduleInviteActivity;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.view.DotView.DotView;

/**
 * Created by Hunter Mun on 2017/9/14.
 *
 * onResume刷界面数据:头像、nickname等个人数据、未读数据、金币数量
 */

public class PersonalCenterActivity extends BaseActionBarFragmentActivity implements OnUnreadListener{

    private DotView dvInviteUnread;
    private TextView tvPackageUnread;
    private ImageView iv_myLevel;
    private TextView tv_myNickName;
    private TextView tv_myID;
    private ImageView iv_personPhoto;

    //data
    private ScheduleInvitePackageUnreadManager mScheduleInvitePackageUnreadManager;

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        TAG = PersonalCenterActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_personal_center);
        initView();
        //刷新显示，本地数据
        refreshByData();
    }

    private void initView(){
        //状态栏颜色
        StatusBarUtil.setColor(this,Color.WHITE,125);
        setTitleVisible(View.GONE);

        iv_personPhoto = (ImageView) findViewById(R.id.iv_personPhoto);
        tv_myNickName = (TextView) findViewById(R.id.tv_myNickName);
        tv_myID = (TextView) findViewById(R.id.tv_myID);

        dvInviteUnread = (DotView) findViewById(R.id.dv_InviteUnread);
        iv_myLevel = (ImageView) findViewById(R.id.iv_myLevel);
        tvPackageUnread = (TextView)findViewById(R.id.tv_pkgUnread);
        mScheduleInvitePackageUnreadManager = ScheduleInvitePackageUnreadManager.getInstance();
        mScheduleInvitePackageUnreadManager.registerUnreadListener(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
        mScheduleInvitePackageUnreadManager.GetCountOfUnreadAndPendingInvite();
        mScheduleInvitePackageUnreadManager.GetPackageUnreadCount();
        //TODO：刷Http-6.14接口，拿头像数据
    }

    private void refreshByData(){
        //刷新邀请未读数目--本地缓存
        ScheduleInviteUnreadItem inviteItem = mScheduleInvitePackageUnreadManager.getScheduleInviteUnreadItem();
        if(inviteItem != null){
            //edit by Jagger 2017-12-13
            dvInviteUnread.setText(String.valueOf(inviteItem.total));
            dvInviteUnread.setVisibility(inviteItem.total == 0 ? View.INVISIBLE : View.VISIBLE);
        }

        //刷新背包未读数目--本地缓存
        PackageUnreadCountItem packageItem = mScheduleInvitePackageUnreadManager.getPackageUnreadCountItem();
        if(packageItem != null){
            tvPackageUnread.setVisibility(packageItem.total == 0 ? View.INVISIBLE : View.VISIBLE);
        }

        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if(null != loginItem){
            iv_myLevel.setImageDrawable(DisplayUtil.getLevelDrawableByResName(this,loginItem.level));
            tv_myNickName.setText(loginItem.nickName);
            tv_myID.setText(getResources().getString(R.string.live_balance_userId,loginItem.userId));
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        if (i == R.id.ll_myBookings) {
            Intent intent = new Intent(this, ScheduleInviteActivity.class);
            startActivity(intent);
        } else if (i == R.id.ll_backPack) {
            Intent intent = new Intent(this, MyPackageActivity.class);
            startActivity(intent);
        } else if (i == R.id.ll_myLevel) {
            String myLevelTitle = getResources().getString(R.string.my_level_title);
            startActivity(WebViewActivity.getIntent(this,
                    myLevelTitle,
                    WebViewActivity.UrlIntent.View_Audience_Level,
                    null,true));
        } else if(i == R.id.iv_editPersonalInfo){
            startActivity(new Intent(this,UserProfileActivity.class));
        } else if(i == R.id.ll_setting){
            startActivity(new Intent(this,SettingsActivity.class));
        } else if(i == R.id.iv_goBack){
            finish();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mScheduleInvitePackageUnreadManager.unregisterUnreadListener(this);
    }

    /***************************** 未读通知刷新  *********************************/
    @Override
    public void onScheduleInviteUnreadUpdate(ScheduleInviteUnreadItem item) {
        Log.d(TAG,"onScheduleInviteUnreadUpdate-item:"+item);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                refreshByData();
            }
        });
    }

    @Override
    public void onPackageUnreadUpdate(PackageUnreadCountItem item) {
        Log.d(TAG,"onPackageUnreadUpdate-item:"+item);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                refreshByData();
            }
        });
    }
}
