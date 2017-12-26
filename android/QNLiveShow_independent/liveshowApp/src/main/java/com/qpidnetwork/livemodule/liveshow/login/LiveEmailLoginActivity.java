package com.qpidnetwork.livemodule.liveshow.login;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.view.ButtonRaised;


/**
 * Email登录界面
 * Created by Jagger on 2017/12/19.
 */
public class LiveEmailLoginActivity extends BaseActionBarFragmentActivity {

    //控件
    private MaterialTextField mEtMail , mEtPassword;
    private ButtonRaised mBtnSummit;
    private TextView mTvForgotPassword , mTvSignUp;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_live_email_login);

        //设置头
        setTitle(getString(R.string.live_sing_up_mail_title), Color.WHITE);

        //
        initUI();
    }

    private void initUI(){
        mEtMail = (MaterialTextField)findViewById(R.id.et_email);
        mEtMail.setHint(getString(R.string.live_sign_up_et_tips_email));

        mEtPassword = (MaterialTextField)findViewById(R.id.et_password);
        mEtPassword.setHint(getString(R.string.live_sign_up_et_tips_enter_password));

        mBtnSummit = (ButtonRaised)findViewById(R.id.btn_Summit);
        mBtnSummit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedLogin();
            }
        });


        mTvForgotPassword = (TextView)findViewById(R.id.tv_forgot_password);
        SpannableString spanText=new SpannableString(getString(R.string.live_forgot_password));
        spanText.setSpan(new ClickableSpan() {
            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(Color.BLACK);       //设置文件颜色
                ds.setUnderlineText(true);      //设置下划线
            }
            @Override
            public void onClick(View widget) {
                onClickedForgotPassword();
            }
        }, 0 , spanText.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        mTvForgotPassword.setHighlightColor(Color.TRANSPARENT); //设置点击后的颜色为透明，否则会一直出现高亮
        mTvForgotPassword.setText(spanText);
        mTvForgotPassword.setMovementMethod(LinkMovementMethod.getInstance());//开始响应点击事件

        mTvSignUp = (TextView)findViewById(R.id.tv_sing_up);
        SpannableString spanTextSingUp=new SpannableString(getString(R.string.live_sign_up));
        spanTextSingUp.setSpan(new ClickableSpan() {
            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(Color.BLACK);       //设置文件颜色
                ds.setUnderlineText(true);      //设置下划线
            }
            @Override
            public void onClick(View widget) {
                onClickedSignUp();
            }
        }, 0 , spanTextSingUp.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        mTvSignUp.setHighlightColor(Color.TRANSPARENT); //设置点击后的颜色为透明，否则会一直出现高亮
        mTvSignUp.setText(spanTextSingUp);
        mTvSignUp.setMovementMethod(LinkMovementMethod.getInstance());//开始响应点击事件
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(requestCode == ForgotPasswordActivity.REQUESTCODE_VERIFY_EMAIL){
            String s=data.getStringExtra(ForgotPasswordActivity.RESULT_KEY_EMAIL);
            mEtMail.setText(s);
        }
    }

    /**
     * Login
     */
    private void onClickedLogin(){

    }

    /**
     * ForgotPassword
     */
    private void onClickedForgotPassword(){
        Intent i = new Intent(mContext , ForgotPasswordActivity.class);
        startActivityForResult(i , ForgotPasswordActivity.REQUESTCODE_VERIFY_EMAIL);
    }

    /**
     * SignUp
     */
    private void onClickedSignUp(){
        Intent i = new Intent(mContext , LiveEmailSignUpActivity.class);
        startActivity(i);
    }
}
