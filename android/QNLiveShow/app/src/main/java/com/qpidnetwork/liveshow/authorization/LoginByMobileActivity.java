package com.qpidnetwork.liveshow.authorization;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.qpidnetwork.framework.base.BaseFragmentActivity;
import com.qpidnetwork.httprequest.item.LoginItem;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.liveshow.model.LoginParam;
import com.qpidnetwork.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.liveshow.welcome.LoginChooserActivity;
import com.qpidnetwork.utils.ApplicationSettingUtil;


/**
 * Description:手机号+密码登录界面
 * <p>
 * Created by Harry on 2017/5/22.
 */

public class LoginByMobileActivity extends BaseFragmentActivity implements IAuthorizationListener{
    private TextView tv_forgotPassword,tv_countryCode,tv_selectedCountry,tv_loginByMobile;
    private EditText et_loginPassword,et_phoneNumber;
    private String phoneNumber = "";

    //登录返回
    private final int MSG_WHAT_LOGINRESULT = 0;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = getClass().getSimpleName();
        super.onCreate(savedInstanceState);
        setTitleBarVisibility(View.VISIBLE);
        setBackTitleVisibility(View.VISIBLE);
        setTitle(R.string.txt_login_title);
        initView();
        initData();
        LoginManager.getInstance().register(this);
    }

    private TextWatcher tw_password = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {

        }

        @Override
        public void afterTextChanged(Editable s) {
            int selectedStartIndex = et_loginPassword.getSelectionStart();
            int selectedEndIndex = et_loginPassword.getSelectionEnd();
            Log.d(TAG,"et_editPassWord-afterTextChanged-s:"+s.toString()+" selectedStartIndex:"+selectedStartIndex+" selectedEndIndex:"+selectedEndIndex);
            if(s.toString().length()>0 && null != et_phoneNumber && et_phoneNumber.getText().toString().length()>0){
                tv_loginByMobile.setEnabled(true);
                tv_loginByMobile.setTextColor(Color.WHITE);
            }else{
                tv_loginByMobile.setEnabled(false);
                tv_loginByMobile.setTextColor(getResources().getColor(R.color.txt_color_next_usable));
            }
            if(s.toString().length() > getResources().getInteger(R.integer.passwordMaxLength)){
                s.delete(selectedStartIndex-1,selectedEndIndex);
                et_loginPassword.removeTextChangedListener(tw_password);
                et_loginPassword.setText(s.toString());
                et_loginPassword.setSelection(s.toString().length());
                et_loginPassword.addTextChangedListener(tw_password);
            }
        }
    };

    private TextWatcher tw_phoneNumber = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {

        }

        @Override
        public void afterTextChanged(Editable s) {
            Log.d(TAG,"et_verifCode-afterTextChanged-s:"+s.toString());
            if(s.toString().length()>0 && null != et_loginPassword && et_loginPassword.getText().toString().length()>0){
                tv_loginByMobile.setEnabled(true);
                tv_loginByMobile.setTextColor(Color.WHITE);
            }else{
                tv_loginByMobile.setEnabled(false);
                tv_loginByMobile.setTextColor(getResources().getColor(R.color.txt_color_next_usable));
            }
        }
    };

    private void initView(){
        tv_loginByMobile = (TextView)findViewById(R.id.tv_loginByMobile);
        tv_loginByMobile.setEnabled(false);
        tv_loginByMobile.setTextColor(getResources().getColor(R.color.txt_color_next_usable));
        tv_countryCode = (TextView)findViewById(R.id.tv_countryCode);
        tv_selectedCountry = (TextView)findViewById(R.id.tv_selectedCountry);
        tv_forgotPassword = (TextView)findViewById(R.id.tv_forgotPassword);
        tv_forgotPassword.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);

        et_loginPassword = (EditText)findViewById(R.id.et_loginPassword);
        et_phoneNumber = (EditText)findViewById(R.id.et_phoneNumber);

        et_loginPassword.addTextChangedListener(tw_password);
        et_phoneNumber.addTextChangedListener(tw_phoneNumber);
    }

    private void initData(){
        //初始化国家码,
        // 1.由于从PeacocActivity跳转过来的时候，带的就是本地存储的国家码，因此无需intent传递
        // 2.如果是从SignUpMobileActivity跳转过来的话，因为每次选择国家码之后就及时本地存储了，因此也无需intent传递
        String defaultCountryCode = ApplicationSettingUtil.getDefaultCountryCode(mContext);
        LoginParam param = null;
        if(!TextUtils.isEmpty(defaultCountryCode)){
            tv_selectedCountry.setText(defaultCountryCode.substring(0, defaultCountryCode.indexOf("(")-1));
            tv_countryCode.setText(defaultCountryCode.substring(defaultCountryCode.indexOf("+"), defaultCountryCode.indexOf(")")));
            param = LoginManager.getInstance().getAccountInfo();
            if(param != null && !TextUtils.isEmpty(param.password)){
                et_loginPassword.setText(param.password);
            }
        }
        //初始化手机号码
        phoneNumber = getIntent().getStringExtra("phoneNumber");
        if(!TextUtils.isEmpty(phoneNumber)){
            //如果有传递过来的手机号码，那么就直接填充，并让密码输入框获取焦点
            et_phoneNumber.setText(phoneNumber);
            et_loginPassword.requestFocus();
        }else if(param != null && !TextUtils.isEmpty(param.phoneNumber)){
            et_phoneNumber.setText(param.phoneNumber);
            et_loginPassword.requestFocus();
        }
    }

    @Override
    public void onClick(View view){
        super.onClick(view);
        switch (view.getId()){
            case R.id.tv_selectedCountry:
            case R.id.tv_countryCode:
                startActivityForResult(new Intent(LoginByMobileActivity.this,SelecteCountryCodeActivity.class), SelecteCountryCodeActivity.REQ_SELECTCOUNTRY);
                break;
            case R.id.tv_forgotPassword:
                showToast("忘记密码");
                startActivity(new Intent(LoginByMobileActivity.this,ModifyPasswordByMobileActivity.class));
                break;
            case R.id.tv_loginByMobile:
                if(null == et_phoneNumber || et_phoneNumber.getText().length()==0 || tv_countryCode.getText().length()<=1){
                    showToast("请输入手机号码");
                    return;
                }
                if(null == et_loginPassword || et_loginPassword.getText().length()< getResources().getInteger(R.integer.minPasswordLength)){
                    showToast(getString(R.string.tip_passwordMinLenReq));
                    return;
                }
                showCustomDialog(0,0,R.string.tip_waitlogin,false,false,null);
                String phoneNumber = et_phoneNumber.getText().toString();
                String password = et_loginPassword.getText().toString();
                LoginManager.getInstance().loginByPhone(tv_countryCode.getText().toString(), phoneNumber, et_loginPassword.getText().toString(),false);
                break;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if(SelecteCountryCodeActivity.REQ_SELECTCOUNTRY == requestCode && resultCode == SelecteCountryCodeActivity.RES_SELECTCOUNTRY){
            if(null != data){
                String countryCode = data.getStringExtra("countryCode");
                new LocalPreferenceManager(mContext).saveDefaultCountryCode(countryCode);
                if(null != countryCode && null  != tv_selectedCountry && null != tv_countryCode){
                    tv_countryCode.setText(countryCode.substring(countryCode.indexOf("+"),countryCode.length()-1));
                    tv_selectedCountry.setText(countryCode.substring(0,countryCode.indexOf("(")));
                }
            }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        LoginManager.getInstance().unRegister(this);
    }

    /**
     * 返回当前activity的视图布局ID
     *
     * @return
     */
    @Override
    public int getActivityViewId() {
        return R.layout.activity_login_mobile;
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case MSG_WHAT_LOGINRESULT: {
                HttpRespObject object = (HttpRespObject) msg.obj;
                dismissCustomDialog();
                if (object.isSuccess) {
                    //登录成功，则跳转
                    setResult(LoginChooserActivity.RSP_LOGIN_MOBILE_SUCCESSED);
                    finish();
                } else {
                    showToast(object.errMsg);
                }
            }break;
            default:
                break;
        }
    }

    /********************************  登录注销监听  ****************************/
    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        Message msg = Message.obtain();
        msg.obj = MSG_WHAT_LOGINRESULT;
        msg.obj = new HttpRespObject(isSuccess,errCode,errMsg,item);
        sendUiMessage(msg);
    }

    @Override
    public void onLogout() {

    }
}
