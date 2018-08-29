package com.qpidnetwork.livemodule.liveshow.login;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.Editable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.model.LoginAccount;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;


/**
 * Email登录界面
 * Created by Jagger on 2017/12/19.
 */
public class LiveEmailLoginActivity extends BaseActionBarFragmentActivity implements IAuthorizationListener{

    //控件
    private MaterialTextField mEtMail , mEtPassword;
    private Button mBtnSummit;
    private TextView mTvForgotPassword , mTvSignUp;

    //外部跳转链接字符串
    private String launchModule = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = LiveEmailLoginActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_live_email_login);

        //设置头
        setTitle(getString(R.string.live_login_with_mail_title), Color.WHITE);

        //解析Intent
        Bundle bundle = getIntent().getExtras();
        if(bundle != null && bundle.containsKey(CommonConstant.KEY_PUSH_NOTIFICATION_URL)){
            launchModule = bundle.getString(CommonConstant.KEY_PUSH_NOTIFICATION_URL);
        }
        initUI();
        initData();
    }

    private void initUI(){
        mBtnSummit = (Button)findViewById(R.id.btn_submit);
        mBtnSummit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedLogin();
            }
        });


        //
        TextWatcher textWatcher = new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                Log.logD(TAG,"onTextChanged-s:"+s.toString()+" start:"+start+" before:"+before+" count:"+count);
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                Log.logD(TAG,"beforeTextChanged-s:"+s.toString()+" start:"+start+" count:"+count+" after:"+after);
            }

            @Override
            public void afterTextChanged(Editable s) {
                Log.logD(TAG,"afterTextChanged-s:"+s.toString());
                doCheckData();
            }
        };
        mEtMail = (MaterialTextField)findViewById(R.id.et_email);
        mEtMail.setHint(getString(R.string.live_sign_in_et_tips_email));
        //设置分割线颜色
        mEtMail.setNormalStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtMail.setFocusedStateColor(getResources().getColor(R.color.email_sign_up_devide));
        //获取焦点是et底部分割线是否加粗
        mEtMail.boldDevideOnFocus = false;
        //设置字体大小
        mEtMail.getEditor().setTextSize(15);
        //设置字体颜色
        mEtMail.getEditor().setTextColor(getResources().getColor(R.color.custom_dialog_txt_color_simple));
        mEtMail.getEditor().setHintTextColor(getResources().getColor(R.color.email_sign_up_hint_txt));
        mEtMail.getEditor().addTextChangedListener(textWatcher);

        mEtPassword = (MaterialTextField)findViewById(R.id.et_password);
        mEtPassword.setHint(getString(R.string.live_sign_up_et_tips_enter_password));
        mEtPassword.setNormalStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtPassword.setFocusedStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtPassword.boldDevideOnFocus = false;
        mEtPassword.getEditor().setTextSize(15);
        mEtPassword.getEditor().setTextColor(getResources().getColor(R.color.custom_dialog_txt_color_simple));
        mEtPassword.getEditor().setHintTextColor(getResources().getColor(R.color.email_sign_up_hint_txt));
        mEtPassword.getEditor().addTextChangedListener(passwordWatcher);
        mEtPassword.setPassword();

        mTvForgotPassword = (TextView)findViewById(R.id.tv_forgot_password);
        SpannableString spanText=new SpannableString(getString(R.string.live_forgot_password));
        spanText.setSpan(new ClickableSpan() {
            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                //设置文字颜色
                ds.setColor(getResources().getColor(R.color.email_sign_in_password_tips));
                //设置下划线
                ds.setUnderlineText(true);
            }
            @Override
            public void onClick(View widget) {
                onClickedForgotPassword();
            }
        }, 0 , spanText.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        mTvForgotPassword.setText(spanText);
        //开始响应点击事件
        mTvForgotPassword.setMovementMethod(LinkMovementMethod.getInstance());

        mTvSignUp = (TextView)findViewById(R.id.tv_sing_up);
        SpannableString spanTextSingUp=new SpannableString(getString(R.string.live_sign_up));
        spanTextSingUp.setSpan(new ClickableSpan() {
            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                //设置文字颜色
                ds.setColor(getResources().getColor(R.color.email_sign_in_password_tips));
                //设置下划线
                ds.setUnderlineText(true);
            }
            @Override
            public void onClick(View widget) {
                onClickedSignUp();
            }
        }, 0 , spanTextSingUp.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        mTvSignUp.setText(spanTextSingUp);
        //开始响应点击事件
        mTvSignUp.setMovementMethod(LinkMovementMethod.getInstance());
    }

    private void initData(){
        LoginAccount loginAccount = LoginManager.getInstance().getLoginAccount(LoginManager.LoginType.EMAIL);
        if(loginAccount != null){
            if(!TextUtils.isEmpty(loginAccount.email)){
                mEtMail.setText(loginAccount.email);
            }

            if(!TextUtils.isEmpty(loginAccount.passWord)){
                mEtPassword.setText(loginAccount.passWord);
            }
        }
        doCheckData();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(requestCode == ForgotPasswordActivity.REQUESTCODE_VERIFY_EMAIL){
            if(data != null){
                String s = data.getStringExtra(ForgotPasswordActivity.RESULT_KEY_EMAIL);
                mEtMail.setText(s);
            }
        }
    }

    TextWatcher passwordWatcher = new TextWatcher() {

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
            Log.logD(TAG,"onTextChanged-s:"+s.toString()+" start:"+start+" before:"+before+" count:"+count);
        }

        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            Log.logD(TAG,"beforeTextChanged-s:"+s.toString()+" start:"+start+" count:"+count+" after:"+after);
        }

        @Override
        public void afterTextChanged(Editable s) {
            Log.logD(TAG,"afterTextChanged-s:"+s.toString());
            if(checkPwInputRule(s)){
                doCheckData();
            }

        }
    };

    /**
     * 密码控件输入规则检查
     * @param s
     */
    private boolean checkPwInputRule(Editable s){
        //检测输入字符是否符合原型要求的规则:数字或者字母
        try{
            String pwTxt = s.toString();
            String pwLastStr = pwTxt.substring(pwTxt.length()-1,pwTxt.length());
            char[] pwLastCharArray = pwLastStr.toCharArray();
            int mid = pwLastCharArray[0];
            Log.d(TAG,"doCheckData-mid:"+mid+" pwLastCharArray.length:"+pwLastCharArray.length);
            if(((mid>=48 && mid<=57) || (mid>=65 && mid<=90) || (mid>=97 && mid<=122)) && pwTxt.length()<=32){
                //（数字|大写字母|小写字母）并且密码不得超过32
                return true;
            }else{
                //TODO:zh&en/num<=32 bug.
                s.delete(pwTxt.length()-1,pwTxt.length());
                mEtPassword.getEditor().removeTextChangedListener(passwordWatcher);
                mEtPassword.getEditor().setText(s.toString());
                mEtPassword.getEditor().setSelection(s.length());
                mEtPassword.getEditor().addTextChangedListener(passwordWatcher);
                return false;
            }
        }catch(Exception e){
            e.printStackTrace();
        }
        return true;
    }

    /**
     * 检查数据是否完整
     */
    private void doCheckData(){
        if(mEtMail.getText().length() < 1 || mEtPassword.getText().length() < 1){
            mBtnSummit.setEnabled(false);
            mBtnSummit.setTextColor(getResources().getColor(R.color.submit_unusable));
        }else{
            mBtnSummit.setTextColor(Color.WHITE);
            mBtnSummit.setEnabled(true);
        }
    }

    /**
     * Login
     */
    private void onClickedLogin(){
        Log.d(TAG,"onClickedLogin");
        showLoadingDialog();
        doLogin();
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

    /**
     * 登录
     */
    private void doLogin(){
        LoginManager.getInstance().addListener(this);
        LoginManager.getInstance().login(LoginManager.LoginType.EMAIL , mEtMail.getText().toString() , mEtPassword.getText().toString());
    }

    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        hideLoadingDialog();
        //反注册监听
        LoginManager.getInstance().removeListener(this);
        if(isSuccess){
            //打开HOT列表
            MainFragmentActivity.launchActivityWIthUrl(this, launchModule);
            //通知登录界面关闭
            sendBroadcast(new Intent(LiveLoginActivity.ACTION_CLOSE));
            finish();
        }else {
            showToast(errMsg);
        }
    }

    @Override
    public void onLogout(boolean isMannual) {

    }
}
