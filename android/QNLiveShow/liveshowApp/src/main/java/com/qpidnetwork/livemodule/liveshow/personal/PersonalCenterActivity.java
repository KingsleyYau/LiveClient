package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.TextUtils;
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
 * @deprecated
 */

public class PersonalCenterActivity extends BaseActionBarFragmentActivity implements OnUnreadListener{

//    private TextView tvInviteUnread;
    private DotView dvInviteUnread;
    private TextView tvPackageUnread;
    private ImageView iv_myLevel;

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
//        StatusBarUtil.setColor(this,Color.parseColor("#5d0e86"),0);

        //设置头
        String title = "";
        LoginItem item = LoginManager.getInstance().getLoginItem();
        if(item != null && !TextUtils.isEmpty(item.nickName)){
            title = item.nickName;
        }
        setTitle(title, R.color.theme_default_black);


//        tvInviteUnread = (TextView)findViewById(R.id.tvInviteUnread);
        dvInviteUnread = (DotView) findViewById(R.id.dv_InviteUnread);
        iv_myLevel = (ImageView) findViewById(R.id.iv_myLevel);
        tvPackageUnread = (TextView)findViewById(R.id.tvPackageUnread);
        mScheduleInvitePackageUnreadManager = ScheduleInvitePackageUnreadManager.getInstance();
        mScheduleInvitePackageUnreadManager.registerUnreadListener(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
        mScheduleInvitePackageUnreadManager.GetCountOfUnreadAndPendingInvite();
        mScheduleInvitePackageUnreadManager.GetPackageUnreadCount();
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
            iv_myLevel.setImageDrawable(DisplayUtil.getLevelDrawableByResName(this,loginItem.level));
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        if (i == R.id.llInvite) {
            Intent intent = new Intent(this, ScheduleInviteActivity.class);
            startActivity(intent);
        } else if (i == R.id.llBackPack) {
            Intent intent = new Intent(this, MyPackageActivity.class);
            startActivity(intent);
        } else if (i == R.id.llMyLevel) {
            String myLevelTitle = getResources().getString(R.string.my_level_title);
            startActivity(WebViewActivity.getIntent(this,
                    myLevelTitle,
                    WebViewActivity.UrlIntent.View_Audience_Level,
                    null,true));
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
