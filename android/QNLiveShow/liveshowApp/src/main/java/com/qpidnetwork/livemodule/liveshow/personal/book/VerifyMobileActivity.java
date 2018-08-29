package com.qpidnetwork.livemodule.liveshow.personal.book;

import android.graphics.Color;
import android.os.Bundle;
import android.os.Message;
import android.support.constraint.ConstraintLayout;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.view.ButtonRaised;

/**
 * 验证号码
 * Created by Jagger on 2017/9/29.
 */
public class VerifyMobileActivity extends BaseActionBarFragmentActivity {

    public static String KEY_COUNTRY = "KEY_COUNTRY";
    public static String KEY_AREA_CODE = "KEY_AREA_CODE";
    public static String KEY_PHONE_NUMBER = "KEY_PHONE_NUMBER";
    public static String KEY_IS_SUCCESS = "KEY_IS_SUCCESS";
    private final int REQUEST_SUCCESS = 0;
    private final int REQUEST_FAILED = 1;
    private final int COUNT_DOWN = 2;
    private final int REQUEST_RESNED_SUCCESS = 3;
    private final int REQUEST_RESNED_FAILED = 4;
    private final int MAX_RESEND_TIME = 30; //秒

    //变量
    private boolean mIsSuccess ;
    private String mCountry , mAreaCode , mPhone , mFullNumber;
    private int mResendTime = MAX_RESEND_TIME;
    private boolean mIsCanResend = false;

    //控件
    private TextView mTvPhone , mTvChange;
    private ButtonRaised mBtnResend , mBtnSummit ;
    private ButtonRaised mBtnErrorBack;
    private MaterialTextField mEtVerifyCode;
    private ConstraintLayout mConstraintLayoutError;
    private ConstraintLayout mConstraintLayoutContent;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_verify_mobile);

        //设置头
        setTitle(getString(R.string.live_book_verify_num_title), R.color.theme_default_black);

        //
        initIntent();
        //
        initUI();
    }

    private void initIntent(){
        Bundle bundle = getIntent().getExtras();
        if( bundle != null) {
            if(bundle.containsKey(KEY_IS_SUCCESS)){
                mIsSuccess =  bundle.getBoolean(KEY_IS_SUCCESS);
            }

            if(bundle.containsKey(KEY_COUNTRY)){
                mCountry =  bundle.getString(KEY_COUNTRY);
            }

            if(bundle.containsKey(KEY_AREA_CODE)){
                mAreaCode =  bundle.getString(KEY_AREA_CODE);
            }

            if(bundle.containsKey(KEY_PHONE_NUMBER)){
                mPhone = bundle.getString(KEY_PHONE_NUMBER);
            }

            mFullNumber = "+" + mAreaCode + "-" + mPhone;
        }
    }

    private void initUI(){
        mTvPhone = (TextView)findViewById(R.id.tv_number);
        mTvPhone.setText(mFullNumber);

        mTvChange = (TextView)findViewById(R.id.tv_change);
        mTvChange.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mBtnResend = (ButtonRaised)findViewById(R.id.btn_resend);
        mBtnResend.setButtonTitle(getString(R.string.live_book_resend_in , String.valueOf(mResendTime)));
        mBtnResend.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setResendBtnCountDown();
                onResend();
            }
        });

        mBtnSummit = (ButtonRaised)findViewById(R.id.btn_summit);
        mBtnSummit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onSummit();
            }
        });
        mBtnSummit.setEnabled(false);

        mBtnErrorBack = (ButtonRaised) findViewById(R.id.btn_error_back);
        mBtnErrorBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        //
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
        mEtVerifyCode = (MaterialTextField)findViewById(R.id.et_code);
        mEtVerifyCode.setHint(getResources().getString(R.string.live_book_verifycode_hint_tips));
        mEtVerifyCode.getEditor().addTextChangedListener(textWatcher);

        mConstraintLayoutContent = (ConstraintLayout) findViewById(R.id.cly_content);
        mConstraintLayoutError = (ConstraintLayout) findViewById(R.id.cly_error);

        //判断是错误页 还是 验证页
        if(mIsSuccess){
            mConstraintLayoutContent.setVisibility(View.VISIBLE);
            mConstraintLayoutError.setVisibility(View.GONE);
        }else{
            mConstraintLayoutContent.setVisibility(View.GONE);
            mConstraintLayoutError.setVisibility(View.VISIBLE);
        }

        setResendBtnCountDown();

    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        if(msg != null){
            switch (msg.what) {
                case REQUEST_SUCCESS:
                    setResult(RESULT_OK);
                    finish();
                    break;
                case REQUEST_FAILED:
                    if(IntToEnumUtils.intToHttpErrorType(msg.arg1) ==  HttpLccErrType.HTTP_LCC_ERR_MORE_TWENTY_PHONE){
                        mConstraintLayoutContent.setVisibility(View.GONE);
                        mConstraintLayoutError.setVisibility(View.VISIBLE);
                    }else{
                        Toast.makeText(mContext , String.valueOf(msg.obj) , Toast.LENGTH_LONG).show();
                    }
                    break;
                case COUNT_DOWN:
                    if(mResendTime > 0){
                        mBtnResend.setButtonTitle(getString(R.string.live_book_resend_in , String.valueOf(mResendTime)));
                        mBtnResend.setButtonBackground(getResources().getColor(R.color.white));
                        mBtnResend.setButtonTitleColor(getResources().getColor(R.color.text_color_grey));
                        mBtnResend.setEnabled(false);
                    }else{
                        mBtnResend.setButtonTitle(getString(R.string.live_book_resend));
                        mBtnResend.setButtonBackground(getResources().getColor(R.color.theme_sky_blue));
                        mBtnResend.setButtonTitleColor(getResources().getColor(R.color.white));
                        mBtnResend.setEnabled(true);
                    }

                    break;
                case REQUEST_RESNED_SUCCESS:

                    break;
                case REQUEST_RESNED_FAILED:
                    Toast.makeText(mContext , String.valueOf(msg.obj) , Toast.LENGTH_LONG).show();
                    break;
            }
        }
    }

    /**
     * 重发按钮倒计时
     */
    private void setResendBtnCountDown(){
        mResendTime = MAX_RESEND_TIME;
        mIsCanResend = false;

        Runnable r = new Runnable() {
            @Override
            public void run() {
                while (!mIsCanResend){
                    sendEmptyUiMessage(COUNT_DOWN);
                    if(mResendTime == 0){
                        mIsCanResend = true;
                        break;
                    }

                    try {
                        Thread.sleep(1000);
                    }catch (Exception e){}
                    mResendTime--;
                }

            }
        };

        new Thread(r).start();
    }

    /**
     * 检查数据是否完整
     */
    private void doCheckData(){
        if(mEtVerifyCode.getText().length() < 1){
            mBtnSummit.setButtonBackground(getResources().getColor(R.color.black3));
            mBtnSummit.setEnabled(false);
        }else{
            mBtnSummit.setButtonBackground(getResources().getColor(R.color.theme_sky_blue));
            mBtnSummit.setEnabled(true);
        }
    }

    /**
     * 重发验证码
     */
    private void onResend(){
        LiveRequestOperator.getInstance().GetPhoneVerifyCode(mCountry, mAreaCode, mPhone, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                if(isSuccess){
                    sendEmptyUiMessage(REQUEST_RESNED_SUCCESS);
                }else{
                    Message msg = new Message();
                    msg.what = REQUEST_RESNED_FAILED;
                    msg.obj = errMsg;
                    sendUiMessage(msg);
                }
            }
        });
    }

    /**
     * 提交
     */
    private void onSummit(){
        LiveRequestOperator.getInstance().SubmitPhoneVerifyCode(mCountry, mAreaCode, mPhone, mEtVerifyCode.getText().toString() , new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                if(isSuccess){
                    sendEmptyUiMessage(REQUEST_SUCCESS);
                }else{
                    Message msg = new Message();
                    msg.what = REQUEST_FAILED;
                    msg.obj = errMsg;
                    msg.arg1 = errCode;
                    sendUiMessage(msg);
                }
            }
        });
    }
}
