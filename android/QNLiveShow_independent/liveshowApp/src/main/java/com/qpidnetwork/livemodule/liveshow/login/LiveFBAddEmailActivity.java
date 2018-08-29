package com.qpidnetwork.livemodule.liveshow.login;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.httprequest.OnRequestLSCheckMailCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.home.EditProfileActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * Facebook添加邮箱界面
 * Created by Jagger on 2017/12/27.
 */
public class LiveFBAddEmailActivity extends BaseActionBarFragmentActivity {
    //变量
    private String mStrEmail = "";
    //控件
    private MaterialTextField mEtMail;
    private Button mBtnSummit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = LiveFBAddEmailActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_live_fb_add_email);
        setTitle(getString(R.string.live_sing_up_fb_mail_title), Color.WHITE);
        initIntent();
        initUI();
        initData();
    }

    /**
     * 使用这个Activity所需要的参数
     * @param context
     * @return
     */
    public static void show(Context context ){
        Intent i  = new Intent(context , LiveFBAddEmailActivity.class);
        context.startActivity(i);
    }

    /**
     * 取 传入的参数
     */
    private void initIntent(){
        Bundle bundle = getIntent().getExtras();
        if( bundle != null) {

        }

    }

    private void initUI() {
        mBtnSummit = (Button)findViewById(R.id.btn_submit);
        mBtnSummit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedNext();
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
    }

    /**
     *
     */
    private void initData(){
        mStrEmail = LoginManager.getInstance().getAuthorizedEmail(LoginManager.LoginType.FACEBOOK);
        if(!TextUtils.isEmpty(mStrEmail)){
            mEtMail.setText(mStrEmail);
            onClickedNext();
        }
        doCheckData();
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
                    EditProfileActivity.show(mContext , LoginManager.LoginType.FACEBOOK , mEtMail.getText().toString(),"");
                    finish();
                }else{
                    //如果错误
                    HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(response.errCode);
                    switch (errType){
                        case HTTP_LCC_ERR_MAILREGISTER_EXIST_QN_MAILBOX:
                            //如果是QN注册过的,提示错误
                            showToast(response.errMsg);
                            break;
                        case HTTP_LCC_ERR_MAILREGISTER_EXIST_LS_MAILBOX:
                            //如果邮箱是已注册过的,去输入密码登录
                            startActivity(LiveFBEmailLoginActivity.getIntent(mContext , mEtMail.getText().toString()));
//                            finish();
                            break;
                        default:
                            //请求错误
                            showToast(response.errMsg);
                            break;
                    }
                }
            }

        }
    };

    /**
     * 检查数据是否完整
     */
    private void doCheckData(){
        if(mEtMail.getText().length() < 1){
            mBtnSummit.setEnabled(false);
            mBtnSummit.setTextColor(getResources().getColor(R.color.submit_unusable));
        }else{
            mBtnSummit.setTextColor(Color.WHITE);
            mBtnSummit.setEnabled(true);
        }
    }

    private void onClickedNext(){
        Log.d(TAG,"onClickedNext");
        showLoadingDialog();
        //2.8 检测邮箱注册状态
        long requestId = RequestJniAuthorization.LSCheckMail(mEtMail.getText().toString(), new OnRequestLSCheckMailCallback() {
            @Override
            public void onLSCheckMail(boolean isSuccess, int errCode, String errMsg) {
                Log.d(TAG,"onLSCheckMail-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, null);
                Message msg = new Message();
                msg.obj = response;
                mHandler.sendMessage(msg);
            }
        });
        if(requestId == -1){
            //请求无效
            HttpRespObject response = new HttpRespObject(false, HttpLccErrType.HTTP_LCC_ERR_FAIL.ordinal(),
                    getString(R.string.liveroom_transition_audience_invite_network_error),
                    null);

            Message msg = new Message();
            msg.obj = response;
            mHandler.sendMessage(msg);
        }
    }
}
