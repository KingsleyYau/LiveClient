package com.qpidnetwork.livemodule.liveshow.personal;

import android.graphics.Color;
import android.os.Bundle;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/12/25.
 */

public class AboutUsActivity extends BaseActionBarFragmentActivity {


    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setCustomContentView(R.layout.activity_aboutus);
        setTitle(getResources().getString(R.string.settings_about_us), Color.WHITE);
    }
}
