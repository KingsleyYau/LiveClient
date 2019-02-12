package com.qpidnetwork.livemodule.liveshow.authorization;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;

public class LiveRegisterResetPasswordSuccessfulActivity extends BaseActionBarFragmentActivity {

    public static String INPUT_EMAIL_KEY;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_live_register_reset_password_successful_acitiviy);

        // 2018/10/26 Hardy
        setTitleBackResId(R.drawable.ic_close_grey600_24dp);
        setTitle(getString(R.string.live_forgot_password), R.color.theme_default_black);
        // 2018/10/26 Hardy

        //设置头
//        setTitle(getString(R.string.my_package_title), R.color.theme_default_black);
        hideTitleBarBottomDivider();

        initViews();

        if (this.getCallingPackage() != null) {
            finish();
            return;
        }


        Bundle extras = this.getIntent().getExtras();
        if (extras == null) {
            finish();
            return;
        }

        if (!extras.containsKey(INPUT_EMAIL_KEY)) {
            finish();
            return;
        }
    }

    private void initViews() {
        TextView textView = (TextView) findViewById(R.id.email_address);
        textView.setText(this.getIntent().getExtras().getString(INPUT_EMAIL_KEY));
    }

    /**
     * 点击取消
     *
     * @param v
     */
    public void onClickCancel(View v) {
        finish();
    }
}
