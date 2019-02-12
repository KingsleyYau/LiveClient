package com.qpidnetwork.livemodule.liveshow.authorization;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestGetValidateCodeCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.LSValidateCodeType;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.ByteUtil;

/**
 * Jagger
 */
public class LiveRegisterResetPasswordActivity extends BaseActionBarFragmentActivity {

    //控件
    private MaterialTextField editTextEmail;
    private RelativeLayout layoutCheckCode;
    private MaterialTextField editTextCheckcode;
    private ImageView imageViewCheckCode;

    private enum RequestFlag {
        REQUEST_SUCCESS,
        REQUEST_FAIL,
        REQUEST_CHECKCODE_SUCCESS,
        REQUEST_CHECKCODE_FAIL,
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_live_register_reset_password);

        // 2018/10/26 Hardy
        setTitleBackResId(R.drawable.ic_close_grey600_24dp);
        setTitle(getString(R.string.live_forgot_password), R.color.theme_default_black);
        // 2018/10/26 Hardy

        //设置头
//        setTitle(getString(R.string.my_package_title), R.color.theme_default_black);
        hideTitleBarBottomDivider();

        initViews();

        // 调用刷新注册码接口
        doGetCheckCode();
    }

    private void initViews() {
        editTextEmail = (MaterialTextField) findViewById(R.id.editTextEmail);
        editTextEmail.setHint(getResources().getString(R.string.live_enter_your_email));
        editTextEmail.setEmail();
        layoutCheckCode = (RelativeLayout) findViewById(R.id.layoutCheckCode);
        layoutCheckCode.setVisibility(View.GONE);

        editTextCheckcode = (MaterialTextField) findViewById(R.id.editTextCheckCode);
        editTextCheckcode.setHint(getResources().getString(R.string.live_enter_verification_code));
        editTextCheckcode.setNoPredition();

        //2018/10/26 Hardy
//        int normal_color = ContextCompat.getColor(this, R.color.thin_grey);
        int focus_color = ContextCompat.getColor(this, R.color.green);
//        editTextEmail.setNormalStateColor(normal_color);
//        editTextCheckcode.setNormalStateColor(normal_color);
        editTextEmail.setFocusedStateColor(focus_color);
        editTextCheckcode.setFocusedStateColor(focus_color);
        //2018/10/26 Hardy

        imageViewCheckCode = (ImageView) findViewById(R.id.imageViewCheckCode);
        imageViewCheckCode.setImageDrawable(null);
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        // 收起菊花
        hideProgressDialog();
        HttpRespObject obj = (HttpRespObject) msg.obj;
        switch (RequestFlag.values()[msg.what]) {
            case REQUEST_SUCCESS: {
                // 打开成功界面
                Intent intent = new Intent(mContext, LiveRegisterResetPasswordSuccessfulActivity.class);
                intent.putExtra(LiveRegisterResetPasswordSuccessfulActivity.INPUT_EMAIL_KEY, editTextEmail.getText().toString());
                startActivity(intent);

//                Log.v("email address", editTextEmail.getText().toString());

                // 改变密码成功
                finish();
            }
            break;
            case REQUEST_FAIL: {
                // 收起菊花
                Toast.makeText(mContext, obj.errMsg, Toast.LENGTH_LONG).show();

                // 改变密码失败
//                switch (obj.errno) {
//                    case RequestErrorCode.MBCE1012: {
//                        // 验证码无效
//                    }
//                    case RequestErrorCode.MBCE1013:{
//                        // 验证码无效
//                        layoutCheckCode.setVisibility(View.VISIBLE);
//                    }break;
//                    default:
//                        break;
//                }
                layoutCheckCode.setVisibility(View.VISIBLE);
            }
            break;
            case REQUEST_CHECKCODE_SUCCESS: {
                // 获取验证码成功
                if (obj != null && obj.data != null) {
                    Bitmap bitmap = (Bitmap) obj.data;
                    imageViewCheckCode.setImageBitmap(bitmap);
                    layoutCheckCode.setVisibility(View.VISIBLE);
                } else {
                    layoutCheckCode.setVisibility(View.GONE);
                }
            }
            break;
            default:
                break;
        }
    }

    /**
     * 点击验证码码
     *
     * @param view
     */
    public void onClickCheckCode(View view) {
        // 调用刷新注册码接口
        doGetCheckCode();
    }

    /**
     * 点击改变密码
     *
     * @param v
     */
    public void onClickReset(View v) {
        // 此处该弹菊花

        if (editTextEmail.getText().length() < 10) {
            editTextEmail.setError(Color.RED, true);
            return;
        }

        //如果需要填写验证码 再判空
        if (layoutCheckCode.getVisibility() == View.VISIBLE) {
            if (editTextCheckcode.getText().length() < 4) {
                editTextCheckcode.setError(Color.RED, true);
                return;
            }
        }

        showProgressDialog("Loading...");
        RequestJniAuthorization.FindPassword(
                editTextEmail.getText().toString(),
                editTextCheckcode.getText().toString(),
                new OnRequestCallback() {
                    @Override
                    public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                        errMsg = ByteUtil.HtmlTagToTextTag(errMsg);
                        //
                        Message msg = Message.obtain();
                        HttpRespObject obj = new HttpRespObject(isSuccess, errCode, errMsg, null);
                        if (isSuccess) {
                            // 成功
                            msg.what = RequestFlag.REQUEST_SUCCESS.ordinal();
                        } else {
                            // 失败
                            msg.what = RequestFlag.REQUEST_FAIL.ordinal();
                            ;
                        }
                        msg.obj = obj;
                        sendUiMessage(msg);
                    }
                });

        //test
//        Intent intent = new Intent(mContext, LiveRegisterResetPasswordSuccessfulActivity.class);
//        intent.putExtra(LiveRegisterResetPasswordSuccessfulActivity.INPUT_EMAIL_KEY, editTextEmail.getText().toString());
//        startActivity(intent);
        //end test
    }

    /**
     * 验证码码
     */
    public void doGetCheckCode() {
        RequestJniAuthorization.GetValidateCode(LSValidateCodeType.findPw, new OnRequestGetValidateCodeCallback() {

            @Override
            public void OnGetValidateCode(boolean isSuccess, int errno, String errmsg, byte[] data) {
                Message msg = Message.obtain();
                HttpRespObject obj = new HttpRespObject(isSuccess, errno, errmsg, null);
                if (isSuccess) {
                    // 获取验证码成功
                    msg.what = RequestFlag.REQUEST_CHECKCODE_SUCCESS.ordinal();
                    if (data.length != 0) {
                        obj.data = BitmapFactory.decodeByteArray(data, 0, data.length);
                    }
                } else {
                    // 获取验证码失败
                    msg.what = RequestFlag.REQUEST_CHECKCODE_FAIL.ordinal();
                }
                msg.obj = obj;
                mHandler.sendMessage(msg);
            }
        });
    }
}
