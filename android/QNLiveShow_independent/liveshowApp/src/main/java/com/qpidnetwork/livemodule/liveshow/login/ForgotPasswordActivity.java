package com.qpidnetwork.livemodule.liveshow.login;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.httprequest.OnRequestGetVerificationCodeCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestLSFindPasswordCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.VerifyCodeType;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.model.LoginAccount;
import com.qpidnetwork.livemodule.view.Dialogs.DialogNormal;

/**
 * 找回密码
 * Created by Jagger on 2017/12/19.
 */
public class ForgotPasswordActivity extends BaseActionBarFragmentActivity {
    public static int REQUESTCODE_VERIFY_EMAIL = 10;
    public static String RESULT_KEY_EMAIL = "RESULT_KEY_EMAIL";

    private final int REQUEST_SUCCESS = 0;
    private final int REQUEST_Fail = -1;
    private final int REQUEST_GET_VER_CODE_SUCCESS = 1;
    private final int REQUEST_GET_VER_CODE_FAIL = -2;

    //控件
    private MaterialTextField mEtMail , mEtVerCode;
    private ImageView mImgVerCode;
    private Button mBtnSummit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = ForgotPasswordActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_forgot_password);
        setTitle(getString(R.string.live_forgot_password_title), Color.WHITE);
        initUI();
        initData();
    }

    private void initUI() {
        mBtnSummit = (Button)findViewById(R.id.btn_submit);
        mBtnSummit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onCliceNext();
            }
        });
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
        mEtMail = (MaterialTextField) findViewById(R.id.et_email);
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

        mEtVerCode = (MaterialTextField) findViewById(R.id.et_ver_code);
        mEtVerCode.setHint(getString(R.string.live_sign_up_et_tips_ver_code));
        mEtVerCode.setNormalStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtVerCode.setFocusedStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtVerCode.boldDevideOnFocus = false;
        mEtVerCode.getEditor().setTextSize(15);
        mEtVerCode.getEditor().setTextColor(getResources().getColor(R.color.custom_dialog_txt_color_simple));
        mEtVerCode.getEditor().setHintTextColor(getResources().getColor(R.color.email_sign_up_hint_txt));
        mEtVerCode.getEditor().addTextChangedListener(textWatcher);

        mImgVerCode = (ImageView)  findViewById(R.id.img_ver_code);
        mImgVerCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                doGetVerCode();
            }
        });
    }

    private void initData(){
        doGetVerCode();

        LoginAccount loginAccount = LoginManager.getInstance().getLoginAccount(LoginManager.LoginType.EMAIL);
        if(loginAccount != null) {
            if (!TextUtils.isEmpty(loginAccount.email)) {
                mEtMail.setText(loginAccount.email);
            }
        }

        doCheckData();
    }

    @SuppressLint("HandlerLeak")
    private Handler mHandler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what){
                case REQUEST_SUCCESS:
                    hideLoadingDialog();
                    showDialog();
                    break;
                case REQUEST_Fail:
                    HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(msg.arg1);
                    if(errType == HttpLccErrType.HTTP_LCC_ERR_FINDPASSWORD_VERIFICATION_WRONG){
                        //自动刷新验证码
                        doGetVerCode();
                    }
                    hideLoadingDialog();
                    showToast(String.valueOf(msg.obj) );
                    break;
                case REQUEST_GET_VER_CODE_SUCCESS:
                    if(msg.obj != null){
                        Bitmap bitmap = (Bitmap)msg.obj;
                        mImgVerCode.setImageBitmap(bitmap);
                    }
                    break;
                case REQUEST_GET_VER_CODE_FAIL:
                    mImgVerCode.setImageResource(R.drawable.verify_code_error_reload);
                    break;
                default:
                    break;
            }
        }
    };

    /**
     * 点击Next
     */
    private void onCliceNext(){
        Log.d(TAG,"onCliceNext");
        showLoadingDialog();
        doSummit();
    }

    /**
     * 检查数据是否完整
     */
    private void doCheckData(){
        if(mEtMail.getText().length() < 1 || mEtVerCode.getText().length() < 1){
            mBtnSummit.setEnabled(false);
            mBtnSummit.setTextColor(getResources().getColor(R.color.submit_unusable));
        }else{
            mBtnSummit.setTextColor(Color.WHITE);
            mBtnSummit.setEnabled(true);
        }
    }

    /**
     * 提交
     */
    private void doSummit(){
        RequestJniAuthorization.LSFindPassword(mEtMail.getText().toString().trim(), mEtVerCode.getText().toString(), new OnRequestLSFindPasswordCallback() {
            @Override
            public void onLSFindPassword(boolean isSuccess, int errCode, String errMsg) {
                Log.i("Jagger" , "ForgotPasswordActivity doSummit:" + isSuccess + ",errCode:" + errCode);
                if(isSuccess){
                    Message msg = new Message();
                    msg.what = REQUEST_SUCCESS;
                    mHandler.sendMessage(msg);
                }else{
                    Message msg = new Message();
                    msg.what = REQUEST_Fail;
                    msg.arg1 = errCode;
                    msg.obj = errMsg;
                    mHandler.sendMessage(msg);
                }
            }
        });
    }

    /**
     * 取验证码
     */
    private void doGetVerCode(){
        Log.d(TAG,"doGetVerCode");
        RequestJniAuthorization.LSGetVerificationCode(VerifyCodeType.findpassword, false, new OnRequestGetVerificationCodeCallback(){
            @Override
            public void onGetVerificationCode(boolean isSuccess, int errCode, String errMsg, byte[] date) {
                Log.d(TAG,"onGetVerificationCode-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" date:"+date);
                if(isSuccess){
                    Message msg = new Message();
                    msg.what = REQUEST_GET_VER_CODE_SUCCESS;
                    if( date.length != 0 ) {
                        msg.obj = BitmapFactory.decodeByteArray(date, 0, date.length);
                    }
                    mHandler.sendMessage(msg);
                }else{
                    Message msg = new Message();
                    msg.what = REQUEST_GET_VER_CODE_FAIL;
                    msg.obj = errMsg;
                    mHandler.sendMessage(msg);
                }
            }
        });
    }

    /**
     * 提示 邮件已发送
     */
    private void showDialog(){
        //TODO:对标注图样式
        DialogNormal.Builder builder = new DialogNormal.Builder()
                .setContext(mContext)
                .setContent(getString(R.string.live_forgot_pw_tips2))
                .btnRight(new DialogNormal.Button(
                        getString(R.string.common_btn_ok),
                        false,
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                //返回结果
                                Intent i=new Intent();
                                i.putExtra(RESULT_KEY_EMAIL, mEtMail.getText().toString());
                                setResult(RESULT_OK,i);
                                finish();
                            }
                        }
                ));

        DialogNormal.setBuilder(builder).show();
    }
}
