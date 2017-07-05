package com.qpidnetwork.liveshow.authorization;

import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.View;

import com.qpidnetwork.httprequest.OnVerifyPhoneNumberCallback;
import com.qpidnetwork.httprequest.RequestJniAuthorization;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.liveshow.welcome.LoginChooserActivity;
import com.qpidnetwork.view.SimpleDoubleBtnTipsDialog;

/**
 * Description:选择国家并输入手机号
 * <p>
 * Created by Harry on 2017/5/22.
 */

public class SignUpByMobileActivity extends BaseSetCountryAndNumbActivity {

    private final int MSG_WHAT_VERIFY_PHONENUMBER = 0;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = getClass().getSimpleName();
        super.onCreate(savedInstanceState);
        setTitleBarVisibility(View.VISIBLE);
        setBackTitleVisibility(View.VISIBLE);
        setTitle(R.string.txt_signup_title);
    }

    public void onClick(View view){
        super.onClick(view);
        switch (view.getId()){
            case R.id.tv_gotoRecVerfCode:
                verifyPhoneNumber();
                break;
        }
    }

    /**
     * 判断手机号码是否已有注册帐号
     */
    private void verifyPhoneNumber(){
        String phoneNumber = et_phoneNumber.getText().toString();
        String countryCode = tv_countryCode.getText().toString();
        //判断手机号是否已经注册
        if(null != dialog && dialog.isShowing()){
            dialog.dismiss();
        }
        dialog = new SimpleDoubleBtnTipsDialog(SignUpByMobileActivity.this, 0, 0, R.string.tip_verifPhoneNumber, null);
        dialog.setCancelable(false);
        dialog.setCanceledOnTouchOutside(false);
        dialog.show();

        RequestJniAuthorization.VerifyPhoneNumber(phoneNumber,countryCode,new OnVerifyPhoneNumberCallback(){
            @Override
            public void onVerifyPhoneNumber(boolean isSuccess, int errCode, String errMsg, boolean isRegister) {
                Log.d(TAG,"onVerifyPhoneNumber-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg+" isRegister:"+isRegister);
                Message msg = Message.obtain();
                msg.what = MSG_WHAT_VERIFY_PHONENUMBER;
                msg.obj = new HttpRespObject(isSuccess,errCode,errMsg, Boolean.valueOf(isRegister));
                sendUiMessage(msg);
            }
        });
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case MSG_WHAT_VERIFY_PHONENUMBER:{
                dismissCustomDialog();
                HttpRespObject respObject = (HttpRespObject)msg.obj;
                if(respObject.isSuccess){
                    boolean isRegister = (Boolean)respObject.data;
                    if(isRegister){
                        //号码已注册
                        showPhoneNumberRegistedDialog();
                    }else{
                        String phoneNumber = et_phoneNumber.getText().toString();
                        String countryCode = tv_countryCode.getText().toString();
                        String selectedCountry = tv_selectedCountry.getText().toString();
                        startActivityForResult(SignUpSendVerifCodeActivity.getIntent(mContext, countryCode,
                                selectedCountry, phoneNumber), LoginChooserActivity.REQ_SINGUP_MOBILE);
                    }
                }else{
                    //接口失败
                    showToast(respObject.errMsg);
                }
            }break;
            default:
                break;
        }
    }

    /**
     * 号码已注册Dialog
     */
    private void showPhoneNumberRegistedDialog(){
        showCustomDialog(R.string.txt_cancel,R.string.txt_login,R.string.tip_phoneRegisted,
                false,false,new SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener() {
                    @Override
                    public void onCancelBtnClick() {
                        dismissCustomDialog();
                    }

                    @Override
                    public void onConfirmBtnClick() {
                        dismissCustomDialog();
                        Intent data = new Intent();
                        data.putExtra("phoneNumber",et_phoneNumber.getText().toString());
                        setResult(LoginChooserActivity.RSP_SINGUP_MOBILE_REGISTED,data);
                        finish();
                    }
                });
    }

    /**
     * 返回当前activity的视图布局ID
     *
     * @return
     */
    @Override
    public int getActivityViewId() {
        return super.getActivityViewId();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(LoginChooserActivity.REQ_SINGUP_MOBILE == requestCode && LoginChooserActivity.RSP_SINGUP_SUCCESSED == resultCode){
            setResult(resultCode,data);
            this.finish();
        }
    }
}
