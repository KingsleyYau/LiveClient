package com.qpidnetwork.livemodule.liveshow.personal.book;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Message;
import android.view.View;
import android.widget.ImageView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
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

    //
    private String mCountry , mAreaCode , mPhone , mFullNumber;

    //
    private MaterialTextField mEditTextCode , mEditTextNumber;
    private ImageView mIvSelectCountryCode;
    private ButtonRaised mBtnSend;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_live_add_mobile);

        //设置头
        setTitle(getString(R.string.live_book_add_mobile_title), Color.GRAY);

        //
        initUI();
    }

    private void initUI(){
        mEditTextCode = (MaterialTextField) findViewById(R.id.et_code);
        mEditTextCode.setHint(getString(R.string.live_book_country_code));

        mEditTextNumber = (MaterialTextField) findViewById(R.id.et_number);
        mEditTextNumber.setHint(getString(R.string.live_book_mobile_number));
        mEditTextNumber.setTypePhone();

        mIvSelectCountryCode = (ImageView) findViewById(R.id.iv_select_country_code);
        mIvSelectCountryCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(mContext, SelectCountryActivity.class);
                startActivityForResult(intent, RESULT_COUNTRY);
            }
        });

        mBtnSend = (ButtonRaised)findViewById(R.id.btn_Send);
        mBtnSend.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onSummit();
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch(requestCode) {
            case RESULT_COUNTRY:
                // 选择国家码返回
                if( resultCode == RESULT_OK ) {
                    String countryCode = data.getExtras().getString(SelectCountryActivity.RESULT_COUNTRY_CODE);
                    mEditTextCode.setText(countryCode);

                    if(countryCode.indexOf("+")>0){
                        String[] cc = countryCode.split("\\+");
                        mCountry = cc[0];
                        mAreaCode = cc[1];
                    }else{
                        mCountry = countryCode;
                        mAreaCode = "";
                    }
                }
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
     * 提交
     */
    private void onSummit(){
        if (mEditTextCode.getText().length() < 3){
            mEditTextCode.setError(Color.RED, true);
            return;
        }

        if (mEditTextNumber.getText().length() < 3){
            mEditTextNumber.setError(Color.RED, true);
            return;
        }

        mPhone = mEditTextNumber.getText().toString();
        mFullNumber = "+" + mAreaCode + "-" + mPhone;

        RequestJniOther.GetPhoneVerifyCode(mCountry, mAreaCode, mPhone, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                if(isSuccess){
                    sendEmptyUiMessage(REQUEST_SUCCESS);
                }else{
                    Message msg = new Message();
                    msg.what = REQUEST_FAILED;
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
                    Intent intent = new Intent(mContext, VerifyMobileActivity.class);
                    intent.putExtra(VerifyMobileActivity.KEY_COUNTRY , mCountry);
                    intent.putExtra(VerifyMobileActivity.KEY_AREA_CODE , mAreaCode);
                    intent.putExtra(VerifyMobileActivity.KEY_PHONE_NUMBER, mEditTextNumber.getText().toString());
                    startActivityForResult(intent, RESULT_VERIFY_MOBILE);

                    break;
                case REQUEST_FAILED:
                    Toast.makeText(mContext , String.valueOf(msg.obj) , Toast.LENGTH_LONG).show();
                    break;
            }
        }
    }
}
