package com.qpidnetwork.livemodule.liveshow.login;

import android.annotation.SuppressLint;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.httprequest.OnRequestLSCheckMailCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.home.EditProfileActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.regex.Pattern;

/**
 * Email注册界面
 * Created by Jagger on 2017/12/19.
 */
public class LiveEmailSignUpActivity extends BaseActionBarFragmentActivity {

    //控件
    private MaterialTextField mEtMail , mEtPassword;
    private Button mBtnSummit;

    //邮箱地址正则匹配规则,参考http://blog.csdn.net/android_freshman/article/details/53909371
    public static final String REGEX_EMAIL = "^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}$";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = LiveEmailSignUpActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_live_email_sign_up);
        setTitle(getString(R.string.live_sing_up_mail_title), Color.WHITE);
        initUI();
    }

    private void initUI(){
        TextWatcher textWatcher = new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence s, int start, int before,
                                      int count) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count,
                                          int after) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                doCheckData();
            }
        };
        mBtnSummit = (Button)findViewById(R.id.btn_submit);
        mBtnSummit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedSummit();
            }
        });


        mEtMail = (MaterialTextField)findViewById(R.id.et_email);
        //设置提示文案
        mEtMail.setHint(getString(R.string.live_sign_up_et_tips_email));
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
        mEtMail.setEmail();

        mEtPassword = (MaterialTextField)findViewById(R.id.et_password);
        mEtPassword.setHint(getString(R.string.live_sign_up_et_tips_password));
        mEtPassword.setNormalStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtPassword.setFocusedStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtPassword.boldDevideOnFocus = false;
        mEtPassword.getEditor().setTextSize(15);
        mEtPassword.getEditor().setTextColor(getResources().getColor(R.color.custom_dialog_txt_color_simple));
        mEtPassword.getEditor().setHintTextColor(getResources().getColor(R.color.email_sign_up_hint_txt));
        mEtPassword.getEditor().addTextChangedListener(passwordWatcher);
        mEtPassword.setPassword();

        doCheckData();
    }

    /**
     * 检查数据是否完整
     */
    private void doCheckData(){
        if(mEtMail.getText().length() < 4 || mEtPassword.getText().length() < 4){
            mBtnSummit.setEnabled(false);
            mBtnSummit.setTextColor(getResources().getColor(R.color.submit_unusable));
        }else{
            mBtnSummit.setTextColor(Color.WHITE);
            mBtnSummit.setEnabled(true);
        }
    }

    @SuppressLint("HandlerLeak")
    private Handler mHandler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            hideLoadingDialog();
            if(msg.obj != null ){
                HttpRespObject response = (HttpRespObject)msg.obj;
                if(response.isSuccess){
                    //如果成功,去填写资料
                    EditProfileActivity.show(mContext , LoginManager.LoginType.EMAIL ,
                            mEtMail.getText().toString() , mEtPassword.getText().toString());
//                    finish();
                }else{
                    showToast(response.errMsg);
                }
            }

        }
    };

    /**
     * 点击提交
     */
    private void onClickedSummit(){
        Log.d(TAG,"onClickedSummit");
        showLoadingDialog();
        //正则校验邮箱地址输入是否合乎规格
        if(Pattern.matches(REGEX_EMAIL, mEtMail.getText().toString())){
            doCheckEmail();
        }else{
            hideLoadingDialog();
            showToast(getResources().getString(R.string.live_sign_up_email_address_tips));
        }
    }

    /**
     * 检查邮箱
     */
    private void doCheckEmail(){
        Log.d(TAG,"doCheckEmail");
        //2.8 检测邮箱注册状态
        long requestId = RequestJniAuthorization.LSCheckMail(mEtMail.getText().toString(),
                new OnRequestLSCheckMailCallback() {
            @Override
            public void onLSCheckMail(boolean isSuccess, int errCode, String errMsg) {
                Log.d(TAG , "doCheckEmail-onLSCheckMail isSuccess:" + isSuccess + " errCode:"
                        + errCode+" errMsg:"+errMsg);
                Message msg = new Message();
                msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, null);
                mHandler.sendMessage(msg);
            }
        });
        if(requestId == -1){
            //请求无效
            Message msg = new Message();
            msg.obj = new HttpRespObject(false, HttpLccErrType.HTTP_LCC_ERR_CONNECTFAIL.ordinal(), "", null);
            mHandler.sendMessage(msg);
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
            if(((mid>=48 && mid<=57) || (mid>=65 && mid<=90) || (mid>=97 && mid<=122)) && pwTxt.length()<=12){
                //(数字|大写字母|小写字母)&密码长度不得超过12位
                return true;
            }else{
                //TODO:zh&en/num<=12 bug.
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
}
