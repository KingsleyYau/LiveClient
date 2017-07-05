package com.qpidnetwork.liveshow.authorization;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.View;

import com.qpidnetwork.liveshow.R;

/**
 * Description:选择国家并输入手机号
 * <p>
 * Created by Harry on 2017/5/22.
 */

public class ModifyPasswordByMobileActivity extends BaseSetCountryAndNumbActivity {
    public static final int REQ_MOBILE_MODIFYPASSWORD = 8;
    public static final int RSP_MOBILE_MODIFYPASSWORD_SUCCESSED = 8;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = getClass().getSimpleName();
        super.onCreate(savedInstanceState);
    }

    public void onClick(View view){
        switch (view.getId()){
            case R.id.tv_gotoRecVerfCode:
                String phoneNumber = et_phoneNumber.getText().toString();
                String countryCode = tv_countryCode.getText().toString();
                String selectedCountry = tv_selectedCountry.getText().toString();

                Intent intent = null;
                intent = new Intent(ModifyPasswordByMobileActivity.this,ModifyPasswrodSendVerifCodeActivity.class);
                intent.putExtra(BaseVerificationCodeActivity.BUNDLE_SELECTED_COUNTRY_NAME,selectedCountry);
                intent.putExtra(BaseVerificationCodeActivity.BUNDLE_REGISTER_PHONENUMBER,phoneNumber);
                intent.putExtra(BaseVerificationCodeActivity.BUNDLE_SELECTED_COUNTRY_CODE,countryCode.substring(1));
                startActivityForResult(intent,REQ_MOBILE_MODIFYPASSWORD);
                break;
        }
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
        //密码修改成功后跳转制定界面
        if(REQ_MOBILE_MODIFYPASSWORD == requestCode){
            if(RSP_MOBILE_MODIFYPASSWORD_SUCCESSED == resultCode){
                this.finish();
            }

        }
    }
}
