package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.manager.LiveCleanCacheManager;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.livemodule.view.ProfileItemView;

/**
 * Hardy
 * 设置界面——直播
 */
public class SettingsActivity extends BaseActionBarFragmentActivity implements IAuthorizationListener {

    private TextView mTvLogout;

    private ProfileItemView mItemPush;
    private ProfileItemView mItemChangePw;
    private ProfileItemView mItemCleanCache;
    private ProfileItemView mItemVersion;

    private LiveCleanCacheManager mCacheManager;

    public static void startAct(Context context) {
        Intent intent = new Intent(context, SettingsActivity.class);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_settings_live);

        initView();
        initData();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        LoginManager.getInstance().unRegister(this);

        if (mCacheManager != null) {
            mCacheManager.onDestroy();
            mCacheManager = null;
        }

//        PushSettingManager.getInstance().syncPushData(false);
    }

    private void initView() {
        setOnlyTitle("Settings");

        LoginManager.getInstance().register(this);

        mTvLogout = (TextView) findViewById(R.id.act_settings_tv_logout);
        mTvLogout.setOnClickListener(this);

        mItemPush = (ProfileItemView) findViewById(R.id.act_settings_item_push);
        mItemChangePw = (ProfileItemView) findViewById(R.id.act_settings_item_change_pw);
        mItemCleanCache = (ProfileItemView) findViewById(R.id.act_settings_item_clean_cache);
        mItemVersion = (ProfileItemView) findViewById(R.id.act_settings_item_version);

        mItemPush.setOnClickListener(this);
        mItemChangePw.setOnClickListener(this);
        mItemCleanCache.setOnClickListener(this);
        mItemVersion.setOnClickListener(this);

        mItemPush.setTextLeft("Push Notifications");
        mItemChangePw.setTextLeft("Change Password");
        mItemCleanCache.setTextLeft("Clean Cache");
        mItemVersion.setTextLeft("Version");

        mItemPush.setRightIcon2Arrow();
        mItemChangePw.setRightIcon2Arrow();
//        mItemCleanCache.setRightIcon2Arrow();

        int colorGrey = ContextCompat.getColor(mContext, R.color.text_color_grey_light);
        mItemCleanCache.setTextRightColorInt(colorGrey);
        mItemVersion.setTextRightColorInt(colorGrey);

        mItemCleanCache.setTextRightBold(false);
        mItemVersion.setTextRightBold(false);

        mItemPush.setBottomLineLeftMarginDefault();
        mItemCleanCache.setBottomLineLeftMarginDefault();

        initLoginView();
    }

    private void initData() {
        // version
        mItemVersion.setTextRight("v" + SystemUtils.getVersionName(mContext));

        // load cache size
        getCacheManager().loadCacheSize();
    }


    /**
     * 初始化没登录的 View ，不显示
     */
    private void initLoginView() {
        boolean isLogin = LoginManager.getInstance().getLoginItem() != null ? true : false;

        findViewById(R.id.act_settings_item_ll_top).setVisibility(isLogin ? View.VISIBLE : View.GONE);
        mTvLogout.setVisibility(isLogin ? View.VISIBLE : View.GONE);
    }

    private LiveCleanCacheManager getCacheManager() {
        if (mCacheManager == null) {
            mCacheManager = new LiveCleanCacheManager(mContext) {
                @Override
                public void onStartCleaning() {
                    super.onStartCleaning();

                    // xxxM 内存大小为 3 位数时，即 100m 以上才展示清理 dialog，
                    // 如果缓存小，清理速度比较快，该 dialog 就会和清理完成的弹窗交替出现频繁，看起来会一闪而过
                    if (mItemCleanCache.getTextRight().length() >= 4) {     // 4，是包括 "m" 字符的长度
                        // 点击弹窗外部不可消失
                        setProgressDialogCanceled(false);
                        showProgressDialog("Cleaning...");
                    }
                }

                @Override
                public void onCleanCompleted() {
                    super.onCleanCompleted();

                    hideProgressDialog();
                    mItemCleanCache.setTextRight(LiveCleanCacheManager.DEFAULT_CACHE_SIZE);
                }

                @Override
                public void onCacheFileSize(String sizeVal) {
                    super.onCacheFileSize(sizeVal);

                    mItemCleanCache.setTextRight(sizeVal);
                }
            };
        }

        return mCacheManager;
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();
        if (id == R.id.act_settings_tv_logout) {

            LoginManager.getInstance().LogoutAndClean(true);

            //GA统计点击注销按钮
            onAnalyticsEvent(getResources().getString(R.string.Live_Settings_Category),
                    getResources().getString(R.string.Live_Settings_Action_Logout),
                    getResources().getString(R.string.Live_Settings_Label_Logout));

        } else if (id == R.id.act_settings_item_push) {
            // 2018/9/19 跳转到设置 push 开关页面

            PushSettingsActivity.startAct(mContext);

        } else if (id == R.id.act_settings_item_change_pw) {
            // 2018/9/19 跳转到设置密码页面
            MyProfileChangePasswordActivity.startAct(mContext);

        } else if (id == R.id.act_settings_item_clean_cache) {
            // 2018/9/19 清理缓存
            getCacheManager().showCleanCacheDialog();

        } else if (id == R.id.act_settings_item_version) {
            // nothing to do
        }
    }

    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

    }

    @Override
    public void onLogout(boolean isMannual) {
        finish();
    }

}
