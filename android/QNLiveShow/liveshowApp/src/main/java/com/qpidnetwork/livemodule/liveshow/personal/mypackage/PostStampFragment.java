package com.qpidnetwork.livemodule.liveshow.personal.mypackage;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.framework.base.BaseWebViewFragment;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * Description:
 * <p>
 * Created by harry52 on 2018/8/16.
 */
public class PostStampFragment extends BaseWebViewFragment {

    @Override
    protected void initViewData() {
        super.initViewData();
        Log.d(TAG,"initViewData");
        ConfigItem configItem = LoginManager.getInstance().getLocalConfigItem();
        if(null != configItem && !TextUtils.isEmpty(configItem.postStampUrl)){
            mUrl = configItem.postStampUrl;
        }
        loadUrl(false,false);
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

    }

    @Override
    protected void onReVisible() {
        super.onReVisible();
        //切换到当前fragment
        loadUrl(false,false);
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        TAG = PostStampFragment.class.getSimpleName();
        super.setUserVisibleHint(isVisibleToUser);
    }
}
