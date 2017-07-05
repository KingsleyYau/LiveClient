package com.qpidnetwork.liveshow.welcome;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;

import com.qpidnetwork.framework.base.BaseFragmentActivity;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.authorization.LoginByMobileActivity;
import com.qpidnetwork.liveshow.authorization.SignUpByMobileActivity;
import com.qpidnetwork.liveshow.help.UserTermsActivity;
import com.qpidnetwork.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.view.RespDrawClickEventAutoSplitTextView;
import com.qpidnetwork.view.SimpleListPopupWindow;

/**
 * Description:登录方式选择页
 * <p>
 * Created by Harry on 2017/5/22.
 */

public class LoginChooserActivity extends BaseFragmentActivity
        implements RespDrawClickEventAutoSplitTextView.OnDrawableLeftClickListener{

    private RespDrawClickEventAutoSplitTextView rdctv_agreeUserAgreement;
    //手机注册
    public static final int REQ_SINGUP_MOBILE = 3;
    //注册流程，手机号码已经注册，跳转手机验证码登录界面
    public static final int RSP_SINGUP_MOBILE_REGISTED = 4;
    //手机验证码注册，成功跳转到Welcome界面
    public static final int RSP_SINGUP_SUCCESSED = 5;
    public static final int RSP_SINGUP_FAILED = 6;

    public static final int REQ_LOGIN_MOBILE = 7;
    public static final int RSP_LOGIN_MOBILE_SUCCESSED = 8;
    public static final int RSP_LOGIN_MOBILE_FAILED = 9;

    private SimpleListPopupWindow slpw_mobile,slpw_email;

    private String[] mobilePopupItems,emailPopupItems;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = getClass().getSimpleName();
        super.onCreate(savedInstanceState);
        setTitleBarVisibility(View.GONE);
        initView();
    }

    /**
     * 返回当前activity的视图布局ID
     *
     * @return
     */
    @Override
    public int getActivityViewId() {
        return R.layout.activity_select_login_method;
    }

    private void initView(){
        rdctv_agreeUserAgreement = (RespDrawClickEventAutoSplitTextView)findViewById(R.id.rdctv_agreeUserAgreement);
        rdctv_agreeUserAgreement.setOnDrawableLeftClickListener(this);
        final String userAgreement = getResources().getString(R.string.txt_userAgreement);
        SpannableString styledText = new SpannableString(userAgreement);
        styledText.setSpan(new ClickableSpan() {

            @Override
            public void onClick(View widget) {
                startActivity(new Intent(LoginChooserActivity.this, UserTermsActivity.class));
            }
        }, 30, userAgreement.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        styledText.setSpan(new ForegroundColorSpan(Color.parseColor("#1bb2e9")), 30, userAgreement.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        rdctv_agreeUserAgreement.setText(styledText);
        //解决ClickableSpan和OnClicked的事件冲突问题
        rdctv_agreeUserAgreement.setMovementMethod(LinkMovementMethod.getInstance());
    }

    @Override
    public void onDrawableLeftClicked(View view) {
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.iv_emailLogin:
                showEmailMethodPopupWindow();
                break;
            case R.id.iv_facebookLogin:
                showToast("iv_facebookLogin clicked");
                break;
            case R.id.iv_mobileLogin:
                //底部弹出框来选择
                showMobileMethodPopupWindow();
                break;
        }
    }

    private AdapterView.OnItemClickListener onMobileItemClickListener=new AdapterView.OnItemClickListener() {
        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

            switch (position){
                case 0://Login mobile
                    showToast("Login mobile");
                    startActivityForResult(new Intent(LoginChooserActivity.this,LoginByMobileActivity.class), REQ_LOGIN_MOBILE);
                    break;
                case 1://Singup mobile
                    showToast("Singup mobile");
                    startActivityForResult(new Intent(LoginChooserActivity.this,SignUpByMobileActivity.class), REQ_SINGUP_MOBILE);
                    break;
                default:
                    break;
            }
            if(null != slpw_mobile){
                slpw_mobile.dismiss();
            }

        }
    };

    private AdapterView.OnItemClickListener onEmailItemClickListener=new AdapterView.OnItemClickListener() {
        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

            switch (position){
                case 0://Singup E-mail
                    showToast("Singup E-mail");
                    break;
                case 1://Login E-mail
                    showToast("Login E-mail");
                    break;
                default:
                    break;
            }
            if(null != slpw_email){
                slpw_email.dismiss();
            }

        }
    };

    private void showEmailMethodPopupWindow(){

        if(null == emailPopupItems){
            emailPopupItems = getResources().getStringArray(R.array.emailPopupItems);
        }
        if(null == slpw_email){
            slpw_email = new SimpleListPopupWindow(LoginChooserActivity.this.getApplicationContext(),0, ViewGroup.LayoutParams.FILL_PARENT,ViewGroup.LayoutParams.WRAP_CONTENT,ViewGroup.LayoutParams.FILL_PARENT);
            slpw_email.setViewData(emailPopupItems,0);
            slpw_email.setItemClickListener(onEmailItemClickListener);
            slpw_email.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#909090")));
        }
        slpw_email.showAtLocation(LoginChooserActivity.this.findViewById(R.id.rl_loginMethodContainer), Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL,0,0);
    }

    private void showMobileMethodPopupWindow(){

        if(null == mobilePopupItems){
            mobilePopupItems = getResources().getStringArray(R.array.mobilePopupItems);
        }
        if(null == slpw_mobile){
            slpw_mobile = new SimpleListPopupWindow(LoginChooserActivity.this.getApplicationContext(),0, ViewGroup.LayoutParams.FILL_PARENT,ViewGroup.LayoutParams.WRAP_CONTENT,ViewGroup.LayoutParams.FILL_PARENT);
            slpw_mobile.setViewData(mobilePopupItems,0);
            slpw_mobile.setItemClickListener(onMobileItemClickListener);
            slpw_mobile.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#232323")));
        }
        slpw_mobile.showAtLocation(LoginChooserActivity.this.findViewById(R.id.rl_loginMethodContainer), Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL,0,0);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(REQ_SINGUP_MOBILE == requestCode){
            if(RSP_SINGUP_SUCCESSED == resultCode){
                startActivity(new Intent(LoginChooserActivity.this,WelcomeActivity.class));
                this.finish();
            }else if(RSP_SINGUP_MOBILE_REGISTED == resultCode){
                Intent loginMobileIntent = new Intent(LoginChooserActivity.this,LoginByMobileActivity.class);
                if(null != data){
                    loginMobileIntent.putExtra("phoneNumber",data.getStringExtra("phoneNumber"));
                }
                startActivityForResult(loginMobileIntent,REQ_LOGIN_MOBILE);
            }
        }else if(REQ_LOGIN_MOBILE == requestCode){
            if(RSP_LOGIN_MOBILE_SUCCESSED == resultCode){
                Intent mainFragmentIntent = new Intent(LoginChooserActivity.this,MainFragmentActivity.class);
                startActivity(mainFragmentIntent);
                this.finish();
            }
        }

    }
}
