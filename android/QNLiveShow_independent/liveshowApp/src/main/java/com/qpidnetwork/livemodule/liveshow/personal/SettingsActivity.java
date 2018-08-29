package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.login.LiveLoginActivity;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;

/**
 * Description:设置界面
 * <p>
 * Created by Harry on 2017/12/25.
 */

public class SettingsActivity extends BaseActionBarFragmentActivity{

    private final String TAG = SettingsActivity.class.getSimpleName();

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setCustomContentView(R.layout.activity_settings);
        setTitle(getResources().getString(R.string.settings_title), Color.WHITE);
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int id = v.getId();
        if(id == R.id.ll_aboutUs){
            startActivity(new Intent(this,AboutUsActivity.class));
        }else if(id == R.id.ll_feedback){
            startActivity(new Intent(this,FeedbackActivity.class));
        }else if(id == R.id.btn_Logout){
            showLoadingDialog();
            LoginManager.getInstance().logout();
            //打开登录界面
            LiveLoginActivity.show(mContext , LiveLoginActivity.OPEN_TYPE_LOGOUT, "");
            //关掉其它界面
            mContext.sendBroadcast(new Intent(CommonConstant.ACTION_KICKED_OFF));

            //GA统计，点击注销登录
            onAnalyticsEvent(getResources().getString(R.string.Live_PersonalCenter_Category),
                    getResources().getString(R.string.Live_PersonalCenter_Action_Logout),
                    getResources().getString(R.string.Live_PersonalCenter_Label_Logout));
        }
    }
}
