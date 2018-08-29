package com.qpidnetwork.livemodule.liveshow.personal.book;

import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.view.ButtonRaised;

/**
 * 新增号码
 * Created by Jagger on 2017/9/29.
 */
public class AddMobileActivity extends BaseActionBarFragmentActivity {
    public static String RESULT_FULL_NUMBER = "RESULT_FULL_NUMBER";
    private final int REQUEST_SUCCESS = 0;
    private final int REQUEST_FAILED = 1;

    //编辑国家
    private static final int RESULT_COUNTRY = 4;
    //验证号码
    private static final int RESULT_VERIFY_MOBILE = 3;

    private String mCountry;
    private String mAreaCode;
    private String mPhone;
    private String mFullNumber;

    private TextView mTvTextCode;
    private EditText  mEditTextNumber;
    private ImageView mIvSelectCountryCode;
    private ButtonRaised mBtnSend;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_live_add_mobile);
        TAG = AddMobileActivity.class.getSimpleName();
        //设置头
        setTitle(getString(R.string.live_book_add_mobile_title), R.color.theme_default_black);
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

        //初始化国家码
        String[] cc = getResources().getString(R.string.live_book_default_country_code).split("\\+");
        mCountry = cc[0];
        mAreaCode = cc[1];

        mTvTextCode = (TextView) findViewById(R.id.tv_code);
        mTvTextCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                doSelectCode();
            }
        });

        mEditTextNumber = (EditText) findViewById(R.id.et_number);
        mEditTextNumber.addTextChangedListener(textWatcher);

        mIvSelectCountryCode = (ImageView) findViewById(R.id.iv_select_country_code);
        mIvSelectCountryCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                doSelectCode();
            }
        });

        mBtnSend = (ButtonRaised)findViewById(R.id.btn_Send);
        mBtnSend.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onSummit();
            }
        });
        mBtnSend.setEnabled(false);

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch(requestCode) {
            case RESULT_COUNTRY:
                // 选择国家码返回
                if( resultCode == RESULT_OK ) {
                    String countryCode = data.getExtras().getString(SelectCountryActivity.RESULT_COUNTRY_CODE);
                    mTvTextCode.setText(countryCode);
                    if(countryCode.indexOf("+")>0){
                        String[] cc = countryCode.split("\\+");
                        mCountry = cc[0];
                        mAreaCode = cc[1];
                    }else{
                        mCountry = countryCode;
                        mAreaCode = "";
                    }
                }
                doCheckData();
                break;
            case RESULT_VERIFY_MOBILE:
                //验证成功
                if( resultCode == RESULT_OK ) {
                    Intent intent = new Intent();
                    intent.putExtra(RESULT_FULL_NUMBER , mFullNumber);
                    setResult(RESULT_OK,intent);
                    finish();
                }
                break;
            default:break;
        }
    }

    /**
     * 选区号
     */
    private void doSelectCode(){
        Intent intent = new Intent(mContext, SelectCountryActivity.class);
        startActivityForResult(intent, RESULT_COUNTRY);
    }

    /**
     * 检查数据是否完整
     */
    private void doCheckData(){
        if(mTvTextCode.getText().length() < 1 || mEditTextNumber.getText().length() < 1){
            mBtnSend.setButtonBackground(getResources().getColor(R.color.black3));
            mBtnSend.setEnabled(false);
        }else{
            mBtnSend.setButtonBackground(getResources().getColor(R.color.theme_sky_blue));
            mBtnSend.setEnabled(true);
        }
    }

    /**
     * 提交
     */
    private void onSummit(){
        if (mTvTextCode.getText().length() < 1){
            return;
        }

        if (mEditTextNumber.getText().length() < 1){
            return;
        }
        mPhone = mEditTextNumber.getText().toString();
        mFullNumber = getResources().getString(R.string.live_book_fullnumber,mAreaCode,mPhone);
        Log.d(TAG,"onSummit-mPhone:"+mPhone+" mFullNumber:"+mFullNumber+" mBtnSend.enable:"+mBtnSend.isEnabled());
        //因为没有正则规则校验等耗时逻辑，所以无需增加额外的boolean变量开关来进行控制
        mBtnSend.setEnabled(false);
        LiveRequestOperator.getInstance().GetPhoneVerifyCode(mCountry, mAreaCode, mPhone, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                Log.d(TAG,"onSummit-onRequest-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
                if(isSuccess){
                    sendEmptyUiMessage(REQUEST_SUCCESS);
                }else{
                    Message msg = new Message();
                    msg.what = REQUEST_FAILED;
                    msg.arg1 = errCode;
                    msg.obj = errMsg;
                    sendUiMessage(msg);
                }
            }
        });
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        if(msg != null){
            switch (msg.what) {
                case REQUEST_SUCCESS:
                    mBtnSend.setEnabled(true);
                    Intent intent = new Intent(mContext, VerifyMobileActivity.class);
                    intent.putExtra(VerifyMobileActivity.KEY_IS_SUCCESS , true);
                    intent.putExtra(VerifyMobileActivity.KEY_COUNTRY , mCountry);
                    intent.putExtra(VerifyMobileActivity.KEY_AREA_CODE , mAreaCode);
                    intent.putExtra(VerifyMobileActivity.KEY_PHONE_NUMBER, mEditTextNumber.getText().toString());
                    startActivityForResult(intent, RESULT_VERIFY_MOBILE);

                    break;
                case REQUEST_FAILED:
                    mBtnSend.setEnabled(true);
                    if(msg.arg1 == 10066){
                        Intent intentError = new Intent(mContext, VerifyMobileActivity.class);
                        intentError.putExtra(VerifyMobileActivity.KEY_IS_SUCCESS , false);
                        startActivityForResult(intentError, RESULT_VERIFY_MOBILE);
                    }else{
                        Toast.makeText(mContext , String.valueOf(msg.obj) , Toast.LENGTH_LONG).show();
                    }
                    break;
            }
        }
    }
}
