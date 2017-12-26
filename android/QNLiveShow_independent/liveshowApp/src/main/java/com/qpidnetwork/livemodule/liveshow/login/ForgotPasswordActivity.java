package com.qpidnetwork.livemodule.liveshow.login;

import android.app.Dialog;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;

import com.dou361.dialogui.DialogUIUtils;
import com.dou361.dialogui.listener.DialogUIListener;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.view.ButtonRaised;

/**
 * 找回密码
 * Created by Jagger on 2017/12/19.
 */
public class ForgotPasswordActivity extends BaseActionBarFragmentActivity {
    public static int REQUESTCODE_VERIFY_EMAIL = 10;
    public static String RESULT_KEY_EMAIL = "RESULT_KEY_EMAIL";

    //控件
    private MaterialTextField mEtMail;
    private ButtonRaised mBtnSummit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_forgot_password);

        //设置头
        setTitle(getString(R.string.live_forgot_password), Color.WHITE);

        //
        initUI();
    }

    private void initUI() {
        mEtMail = (MaterialTextField) findViewById(R.id.et_email);
        mEtMail.setHint(getString(R.string.live_sign_up_et_tips_email));

        mBtnSummit = (ButtonRaised)findViewById(R.id.btn_Summit);
        mBtnSummit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onCliceNext();
            }
        });
    }

    /**
     * 点击Next
     */
    private void onCliceNext(){
        showDialog();
    }

    /**
     *
     */
    private void showDialog(){
        View rootView = View.inflate(this, R.layout.dialog_forgot_pw, null);
        final Dialog dialog = DialogUIUtils.showCustomAlert(this, rootView, "", "", Gravity.CENTER, true, false ,
                null).show();
        rootView.findViewById(R.id.btn_ok).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DialogUIUtils.dismiss(dialog);

                //返回结果
                Intent i=new Intent();
                i.putExtra(RESULT_KEY_EMAIL, mEtMail.getText().toString());
                setResult(RESULT_OK,i);
                finish();
            }
        });
    }
}
