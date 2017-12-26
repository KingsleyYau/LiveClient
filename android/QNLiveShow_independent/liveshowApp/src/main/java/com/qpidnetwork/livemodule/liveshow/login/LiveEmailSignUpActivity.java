package com.qpidnetwork.livemodule.liveshow.login;

import android.graphics.Color;
import android.os.Bundle;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.view.ButtonRaised;

/**
 * Email注册界面
 * Created by Jagger on 2017/12/19.
 */
public class LiveEmailSignUpActivity extends BaseActionBarFragmentActivity {

    //控件
    private MaterialTextField mEtMail , mEtPassword;
    private ButtonRaised mBtnSummit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_live_email_sign_up);

        //设置头
        setTitle(getString(R.string.live_sing_up_mail_title), Color.WHITE);

        //
        initUI();
    }

    private void initUI(){
        mEtMail = (MaterialTextField)findViewById(R.id.et_email);
        mEtMail.setHint(getString(R.string.live_sign_up_et_tips_email));

        mEtPassword = (MaterialTextField)findViewById(R.id.et_password);
        mEtPassword.setHint(getString(R.string.live_sign_up_et_tips_password));

        mBtnSummit = (ButtonRaised)findViewById(R.id.btn_Summit);
        mBtnSummit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
    }
}
