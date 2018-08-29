package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.framework.widget.statusbar.StatusBarUtil;
import com.qpidnetwork.livemodule.httprequest.OnGetAccountBalanceCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.ManBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteUnreadItem;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.MainBaseInfoManager;
import com.qpidnetwork.livemodule.liveshow.credit.BuyCreditActivity;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager.OnUnreadListener;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity;
import com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite.ScheduleInviteActivity;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.livemodule.view.DotView.DotView;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;

/**
 * Created by Hunter Mun on 2017/9/14.
 *
 * onResume刷界面数据:头像、nickname等个人数据、未读数据、金币数量
 */

public class PersonalCenterActivity extends BaseActionBarFragmentActivity implements OnUnreadListener,
        MainBaseInfoManager.OnGetMainBaseInfoListener, OnGetAccountBalanceCallback {

    private DotView dvInviteUnread;
    private TextView tvPackageUnread;
    private ImageView iv_myLevel;
    private TextView tv_myNickName;
    private TextView tv_myID;
    private ImageView iv_personPhoto;

    //data
    private ScheduleInvitePackageUnreadManager mScheduleInvitePackageUnreadManager;

    private ManBaseInfoItem manBaseInfoItem;

    private TextView tv_coinNumb;
    private double lastBalance = 0d;

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        TAG = PersonalCenterActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_personal_center);
        initView();
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

        tv_coinNumb = (TextView) findViewById(R.id.tv_coinNumb);
    }

    @Override
    protected void onResume() {
        super.onResume();
        //刷新显示，本地数据(将各部分的数据刷新逻辑分开，避免重复刷新导致界面头像多次闪烁的情况)
        updateInviteUnreadStyle();
        updatePkgUnreadCount();
        updateUserBaseInfo();
        updateUserBlanceInco();
        //调接口刷最新数据
        getLastInviteUnreadCount();
        getLastPkgUnreadCount();
        getLastUserBaseInfo();
        getLastAccountBalance();
    }

    /**
     * 获取私密预约未读数据
     */
    private void getLastInviteUnreadCount(){
        if(null != mScheduleInvitePackageUnreadManager){
            showLoadingDialog();
            mScheduleInvitePackageUnreadManager.GetCountOfUnreadAndPendingInvite();
        }

    }

    /**
     * 获取背包未读数据
     */
    private void getLastPkgUnreadCount(){
        if(null != mScheduleInvitePackageUnreadManager){
            showLoadingDialog();
            mScheduleInvitePackageUnreadManager.GetPackageUnreadCount();
        }
    }

    /**
     * 获取用户最新的个人资料数据
     */
    private void getLastUserBaseInfo(){
        showLoadingDialog();
        MainBaseInfoManager.getInstance().getMainBaseInfoFromServ(this);
    }

    /**
     * 更新最新的账户余额信息
     */
    private void getLastAccountBalance(){
        showLoadingDialog();
        RequestJniOther.GetAccountBalance(this);
    }

    /**
     * 更新账户余额
     */
    private void updateUserBlanceInco() {
        tv_coinNumb.setText(lastBalance>0 ? ApplicationSettingUtil.formatCoinValue(lastBalance):
                getResources().getString(R.string.profile_coins_add));
    }

    /**
     * 更新个人信息
     */
    private void updateUserBaseInfo() {
        //正常数据加载显示
        manBaseInfoItem = MainBaseInfoManager.getInstance().getLocalMainBaseInfo();
        if(null != manBaseInfoItem){
            //更新头像
            if(!TextUtils.isEmpty(manBaseInfoItem.photoUrl)){
                String localUserPhotoPath = FileCacheManager.getInstance()
                        .getLocalImgPath(manBaseInfoItem.photoUrl);
                boolean isFileExits = SystemUtils.fileExists(localUserPhotoPath);
                Log.d(TAG,"updateUserBaseInfo-localUserPhotoPath:"+localUserPhotoPath
                        +" isFileExits:"+isFileExits);
                Picasso.with(getApplicationContext())
                        .load(manBaseInfoItem.photoUrl)
                        .memoryPolicy(MemoryPolicy.NO_CACHE)
                        .error(R.drawable.ic_personal_photo_default)
                        .noPlaceholder()
                        .into(iv_personPhoto);
//                        .into(new Target() {
//                            @Override
//                            public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom loadedFrom) {
//                                iv_personPhoto.setImageBitmap(bitmap);
//                            }
//
//                            @Override
//                            public void onBitmapFailed(Drawable drawable) {
//                                if(null != drawable){
//                                    iv_personPhoto.setImageDrawable(drawable);
//                                }
//                            }
//
//                            @Override
//                            public void onPrepareLoad(Drawable drawable) {
//
//                            }
//                        });
            }
            //更新昵称
            tv_myNickName.setText(manBaseInfoItem.nickName);
            //更新等级
            iv_myLevel.setImageDrawable(DisplayUtil.getLevelDrawableByResName(this,manBaseInfoItem.userlevel));
            //更新ID
            tv_myID.setText(getResources().getString(R.string.live_balance_userId,manBaseInfoItem.userId));
        }
    }

    /**
     * 更新背包礼物未读
     */
    private void updatePkgUnreadCount() {
        //刷新背包未读数目--本地缓存
        PackageUnreadCountItem packageItem = mScheduleInvitePackageUnreadManager.getPackageUnreadCountItem();
        if(packageItem != null){
            tvPackageUnread.setVisibility(packageItem.total == 0 ? View.INVISIBLE : View.VISIBLE);
        }
    }

    /**
     * 更新预约私密未读
     */
    private void updateInviteUnreadStyle() {
        //刷新邀请未读数目--本地缓存
        ScheduleInviteUnreadItem inviteItem = mScheduleInvitePackageUnreadManager.getScheduleInviteUnreadItem();
        if(inviteItem != null){
            //edit by Harry 依据svn最新原型要求，数目显示超过99，则显示99+
            String totalValue = inviteItem.total >99 ? "99+" : String.valueOf(inviteItem.total);
            Log.d(TAG,"updateInviteUnreadStyle-totalValue:"+totalValue);
            dvInviteUnread.setText(totalValue);
            dvInviteUnread.setVisibility(inviteItem.total == 0 ? View.INVISIBLE : View.VISIBLE);
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
        } else if(i == R.id.ll_myCoins){
            //跳转充值界面
            LiveService.getInstance().onAddCreditClick(mContext);
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
                hideLoadingDialog();
                updateInviteUnreadStyle();
            }
        });
    }

    @Override
    public void onPackageUnreadUpdate(PackageUnreadCountItem item) {
        Log.d(TAG,"onPackageUnreadUpdate-item:"+item);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                hideLoadingDialog();
                updatePkgUnreadCount();
            }
        });
    }

    @Override
    public void onGetMainBaseInfo(final boolean isSuccess, int errCode, String errMsg) {
        Log.d(TAG,"onGetMainBaseInfo-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
        runOnUiThread(new Thread(){
            @Override
            public void run() {
                hideLoadingDialog();
                if(isSuccess){
                    updateUserBaseInfo();
                }
            }
        });
    }

    @Override
    public void onGetAccountBalance(final boolean isSuccess, int errCode, final String errMsg, double balance) {
        Log.d(TAG,"onGetAccountBalance-isSuccess:"+isSuccess+" errCode:"+errCode
                +" errMsg:"+errMsg+" balance:"+balance);
        if(isSuccess){
            LiveRoomCreditRebateManager.getInstance().setCredit(balance);
            lastBalance = balance;
        }
        runOnUiThread(new Thread(){
            @Override
            public void run() {
                hideLoadingDialog();
                if(isSuccess){
                    updateUserBlanceInco();
                }else{
                    showToast(errMsg);
                }
            }
        });
    }
}
