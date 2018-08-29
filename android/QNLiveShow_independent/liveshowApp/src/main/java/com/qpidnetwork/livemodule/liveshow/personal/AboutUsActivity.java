package com.qpidnetwork.livemodule.liveshow.personal;

import android.graphics.Color;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.utils.IPConfigUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;

/**
 * Description:About Us
 * <p>
 * Created by Harry on 2017/12/25.
 */

public class AboutUsActivity extends BaseActionBarFragmentActivity {

    private TextView tv_currVersionName;


    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setCustomContentView(R.layout.activity_aboutus);
        setTitle(getResources().getString(R.string.settings_about_us), Color.WHITE);
        initView();
        initData();
    }

    private void initView(){
        tv_currVersionName = (TextView)findViewById(R.id.tv_currVersionName);
    }

    private void initData(){
        tv_currVersionName.setText(getResources().getString(R.string.about_us_version_name, SystemUtils.getVersionName(this)));
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.tv_termsOfUse:{
                ConfigItem configItem = LoginManager.getInstance().getSynConfig();
                if(null != configItem && !TextUtils.isEmpty(configItem.termsOfUse)){
                    Log.d(TAG,"onClick termsOfUse:");
                    startActivity(WebViewActivity.getIntent(this,
                            getString(R.string.about_us_terms),
                            IPConfigUtil.addCommonParamsToH5Url(configItem.termsOfUse),
                            true));
                }
            }break;
            case R.id.tv_privacyPolicy:{
                ConfigItem configItem = LoginManager.getInstance().getSynConfig();
                if(null != configItem && !TextUtils.isEmpty(configItem.privacyPolicy)){
                    startActivity(WebViewActivity.getIntent(this,
                            getString(R.string.about_us_privacy_policy),
                            IPConfigUtil.addCommonParamsToH5Url(configItem.privacyPolicy),
                            true));
                }
            }break;
            default:
                break;
        }
    }
}
