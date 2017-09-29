package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteUnreadItem;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager.OnUnreadListener;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;

/**
 * Created by Hunter Mun on 2017/9/14.
 */

public class PersonalCenterActivity extends BaseActionBarFragmentActivity implements IMOtherEventListener, OnUnreadListener{

    private TextView tvInviteUnread;
    private TextView tvPackageUnread;
    private TextView tvLevelDesc;

    //data
    private ScheduleInvitePackageUnreadManager mScheduleInvitePackageUnreadManager;
    private IMManager mIMManager;

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setCustomContentView(R.layout.activity_personal_center);

        //设置头
        getCustomActionBar().setTitle(getString(R.string.personal_center_title), Color.GRAY);

        tvInviteUnread = (TextView)findViewById(R.id.tvInviteUnread);
        tvPackageUnread = (TextView)findViewById(R.id.tvPackageUnread);
        tvLevelDesc = (TextView)findViewById(R.id.tvLevelDesc);

        mScheduleInvitePackageUnreadManager = ScheduleInvitePackageUnreadManager.getInstance();
        mIMManager = IMManager.getInstance();
        mScheduleInvitePackageUnreadManager.registerUnreadListener(this);
        mIMManager.registerIMOtherEventListener(this);

        //刷新显示，本地数据
        refreshByData();
        mScheduleInvitePackageUnreadManager.GetCountOfUnreadAndPendingInvite();
        mScheduleInvitePackageUnreadManager.GetPackageUnreadCount();
    }

    private void refreshByData(){
        //刷新邀请未读数目
        ScheduleInviteUnreadItem inviteItem = mScheduleInvitePackageUnreadManager.getScheduleInviteUnreadItem();
        if(inviteItem != null){
            tvInviteUnread.setText(String.valueOf(inviteItem.total));
        }

        //刷新背包未读数目
        PackageUnreadCountItem packageItem = mScheduleInvitePackageUnreadManager.getPackageUnreadCountItem();
        if(packageItem != null){
            if(packageItem.total > 0){
                tvPackageUnread.setVisibility(View.VISIBLE);
            }else{
                tvPackageUnread.setVisibility(View.GONE);
            }
        }

        //个人Level
        LoginItem loginItem = LoginManager.getInstance().getmLoginItem();
        if(loginItem != null) {
            tvLevelDesc.setVisibility(View.VISIBLE);
            tvLevelDesc.setText("LV." + String.valueOf(loginItem.level));
        }else{
            tvLevelDesc.setVisibility(View.GONE);
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.llInvite:{
                //点击查看邀请列表
            }break;
            case R.id.llBackPack:{
                //点击查看我的背包
            }break;
            case R.id.llMyLevel:{
                //点击查看我的等级
                startActivity(WebViewActivity.getIntent(this, getResources().getString(R.string.my_level_title), "http://www.baidu.com"));
            }break;
            case R.id.llTest:{
                //才艺点播测试 add by Jagger 2017-9-20
                startActivity(new Intent(mContext , TestTalentActivity.class));
            }break;
            case R.id.llTest2:{
                //预约测试 add by Jagger 2017-9-26
                startActivity(new Intent(mContext , BookPrivateActivity.class));
            }break;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mScheduleInvitePackageUnreadManager.unregisterUnreadListener(this);
        mIMManager.unregisterIMOtherEventListener(this);
    }

    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit) {

    }

    @Override
    public void OnRecvCreditNotice(String roomId, double credit) {

    }

    @Override
    public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

    }

    @Override
    public void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

    }

    @Override
    public void OnRecvSendBookingReplyNotice(String inviteId, IMClientListener.BookInviteReplyType replyType) {

    }

    @Override
    public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {

    }

    @Override
    public void OnRecvLevelUpNotice(int level) {
        //等级改变，刷新等级显示
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                refreshByData();
            }
        });
    }

    @Override
    public void OnRecvLoveLevelUpNotice(int lovelevel) {

    }

    @Override
    public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {

    }

    /***************************** 未读通知刷新  *********************************/
    @Override
    public void onScheduleInviteUnreadUpdate(ScheduleInviteUnreadItem item) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                refreshByData();
            }
        });
    }

    @Override
    public void onPackageUnreadUpdate(PackageUnreadCountItem item) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                refreshByData();
            }
        });
    }
}
