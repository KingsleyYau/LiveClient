package com.qpidnetwork.liveshow.authorization;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.qpidnetwork.framework.base.BaseFragmentActivity;
import com.qpidnetwork.httprequest.OnRequestCallback;
import com.qpidnetwork.httprequest.RequestJniAuthorization;
import com.qpidnetwork.liveshow.R;

/**
 * Description:发送短信验证码
 * <p>
 * Created by Harry on 2017/5/22.
 */

public abstract class BaseVerificationCodeActivity extends BaseFragmentActivity {

    public static final String BUNDLE_SELECTED_COUNTRY_CODE = "countryCode";
    public static final String BUNDLE_SELECTED_COUNTRY_NAME = "countryName";
    public static final String BUNDLE_REGISTER_PHONENUMBER = "phoneNumber";

    public String selectedCountry = null, phoneNumber = null, countryCode=null;

    public TextView tv_tipTimeCount,tv_nextOperate,tv_tipSentNumber;
    public EditText et_editPassWord, et_verifCode;
    public int maxTimeCount = 60;
    public final int MSG_WHAT_TIMECOUNT = 0;//更改倒计时textview的显示
    public int passwordMaxLength = 20;
    public int minPasswordLength = 6;

    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what){
                case MSG_WHAT_TIMECOUNT:
                    int timeCount = msg.arg1;
                    Log.d(TAG,"MSG_WHAT_TIMECOUNT-timeCount:"+timeCount);
                    if(timeCount>=1 && timeCount<=maxTimeCount){
                        tv_tipTimeCount.setClickable(false);
                        tv_tipTimeCount.setTextColor(Color.WHITE);
                        tv_tipTimeCount.setBackgroundDrawable(getResources().getDrawable(R.drawable.bg_btn_send_verif_unusable));
                        tv_tipTimeCount.setText(getString(R.string.tip_timecount,timeCount));
                        startTimeCountAnima(--timeCount,1000l);
                    }else{
                        tv_tipTimeCount.setText(getString(R.string.txt_resend));
                        tv_tipTimeCount.setClickable(true);
                        tv_tipTimeCount.setTextColor(getResources().getColor(R.color.txt_color_next_usable));
                        tv_tipTimeCount.setBackgroundDrawable(getResources().getDrawable(R.drawable.bg_btn_send_verif_usable));
                    }
                    break;
                default:
                    super.handleMessage(msg);
                    break;
            }

        }
    };

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initBaseData();
        initBaseView();
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
            int selectedStartIndex = et_editPassWord.getSelectionStart();
            int selectedEndIndex = et_editPassWord.getSelectionEnd();
            Log.d(TAG,"et_editPassWord-afterTextChanged-s:"+s.toString()+" selectedStartIndex:"+selectedStartIndex+" selectedEndIndex:"+selectedEndIndex);
            if(s.toString().length()>0 && null != et_verifCode && et_verifCode.getText().toString().length()>0){
                tv_nextOperate.setEnabled(true);
            }else{
                tv_nextOperate.setEnabled(false);
            }
            if(s.toString().length()>passwordMaxLength){
                s.delete(selectedStartIndex-1,selectedEndIndex);
                if(null != et_editPassWord){
                    et_editPassWord.removeTextChangedListener(tw_password);
                    et_editPassWord.setText(s.toString());
                    et_editPassWord.setSelection(s.toString().length());
                    et_editPassWord.addTextChangedListener(tw_password);
                }

            }
        }
    };

    private void initBaseView(){
        tv_nextOperate = (TextView)findViewById(R.id.tv_nextOperate);
        tv_nextOperate.setEnabled(false);
        tv_tipTimeCount = (TextView)findViewById(R.id.tv_tipTimeCount);
        tv_tipSentNumber = (TextView)findViewById(R.id.tv_tipSentNumber);
        StringBuffer sb = new StringBuffer(countryCode).append(" ").append(phoneNumber);
        tv_tipSentNumber.setText(sb.toString());
        sb.delete(0,sb.length());
        sb = null;
        et_editPassWord = (EditText)findViewById(R.id.et_editPassWord);
        et_verifCode = (EditText)findViewById(R.id.et_verifCode);
        et_verifCode.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                et_verifCode.setTextColor(getResources().getColor(hasFocus ? R.color.txt_color_oninput : R.color.txt_color_uninput));
            }
        });
        et_editPassWord.addTextChangedListener(tw_password);

        et_verifCode.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                Log.d(TAG,"et_verifCode-afterTextChanged-s:"+s.toString());
                if(s.toString().length()>0 && null != et_editPassWord && et_editPassWord.getText().toString().length()>0){
                    tv_nextOperate.setEnabled(true);
                }else{
                    tv_nextOperate.setEnabled(false);
                }

            }
        });
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        return super.onKeyDown(keyCode, event);
    }

    private void initBaseData(){
        Intent comeIntent = getIntent();
        if(null != comeIntent){
            selectedCountry = comeIntent.getStringExtra(BUNDLE_SELECTED_COUNTRY_NAME);
            phoneNumber = comeIntent.getStringExtra(BUNDLE_REGISTER_PHONENUMBER);
            countryCode = comeIntent.getStringExtra(BUNDLE_SELECTED_COUNTRY_CODE);
        }
        passwordMaxLength = getResources().getInteger(R.integer.passwordMaxLength);
        maxTimeCount = getResources().getInteger(R.integer.maxTimeCount);
        minPasswordLength = getResources().getInteger(R.integer.minPasswordLength);
    }

    /**
     * 播放倒计时动画
     */
    public void startTimeCountAnima(int timeCount, long delayMillis){
        Log.d(TAG,"startTimeCountAnima-timeCount:"+timeCount+" delayMillis:"+delayMillis);
        Message msg = handler.obtainMessage(MSG_WHAT_TIMECOUNT);
        msg.arg1 = timeCount;
        handler.sendMessageDelayed(msg,delayMillis);
    }

    public void sendVerifCode(){
        startTimeCountAnima(maxTimeCount,0l);
        if(null!=selectedCountry && null != phoneNumber && null != countryCode){
            //接口调用
            RequestJniAuthorization.GetRegisterVerifyCode(phoneNumber, countryCode, new OnRequestCallback() {
                @Override
                public void onRequest(boolean isSuccess, int errCode, String errMsg) {

                }
            });
        }
    }

    /**
     * 输入校验
     * @return
     */
    public boolean checkInput(){
        if(null == et_verifCode || et_verifCode.getText().length()==0){
            //提示：请输入验证码
            showToast("请输入验证码");
            return false;
        }

        if(null == et_editPassWord || et_editPassWord.getText().length() < minPasswordLength){
            //密码长度不得低于6位
            showToast(getString(R.string.tip_passwordMinLenReq));
            return false;
        }

        return true;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        handler.removeCallbacksAndMessages(null);
    }



    /**
     * 返回当前activity的视图布局ID
     *
     * @return
     */
    @Override
    public int getActivityViewId() {
        return R.layout.activity_send_verfication_code;
    }

}
