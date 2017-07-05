package com.qpidnetwork.liveshow.authorization;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import com.qpidnetwork.framework.base.BaseFragmentActivity;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.utils.ApplicationSettingUtil;

/**
 * Description:选择国家并输入手机号
 * <p>
 * Created by Harry on 2017/5/22.
 */

public class BaseSetCountryAndNumbActivity extends BaseFragmentActivity {

    public TextView tv_selectedCountry,tv_countryCode,tv_gotoRecVerfCode;
    public EditText et_phoneNumber;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initBaseView();
        initBaseData();
    }

    private void initBaseView(){
        tv_selectedCountry = (TextView) findViewById(R.id.tv_selectedCountry);
        tv_gotoRecVerfCode = (TextView) findViewById(R.id.tv_gotoRecVerfCode);
        tv_countryCode = (TextView) findViewById(R.id.tv_countryCode);
        et_phoneNumber = (EditText) findViewById(R.id.et_phoneNumber);
        tv_gotoRecVerfCode.setEnabled(false);
        et_phoneNumber.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                et_phoneNumber.setTextColor(getResources().getColor(hasFocus ? R.color.txt_color_oninput : R.color.txt_color_uninput));
            }
        });
        et_phoneNumber.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                Log.d(TAG,"afterTextChanged-s:"+s.toString());
                if(null != tv_gotoRecVerfCode){
                   if(s.toString().length()>0){
                       tv_gotoRecVerfCode.setEnabled(true);

                   }else{
                       tv_gotoRecVerfCode.setEnabled(false);
                   }
                }
            }
        });
    }

    private void initBaseData(){
        String defaultCountryCode = ApplicationSettingUtil.getDefaultCountryCode(this);
        if(!TextUtils.isEmpty(defaultCountryCode)){
            tv_selectedCountry.setText(defaultCountryCode.substring(0, defaultCountryCode.indexOf("(")));
            tv_countryCode.setText(defaultCountryCode.substring(defaultCountryCode.indexOf("+"), defaultCountryCode.length()-1));
        }
    }

    public void onClick(View view){
        super.onClick(view);
        switch (view.getId()){
            case R.id.rl_mobileCode:
            case R.id.iv_mobileCode:
            case R.id.tv_countryCode:
            case R.id.tv_selectedCountry:
                startActivityForResult(new Intent(BaseSetCountryAndNumbActivity.this,SelecteCountryCodeActivity.class), SelecteCountryCodeActivity.REQ_SELECTCOUNTRY);
                break;
            case R.id.tv_gotoRecVerfCode:
                if(null == tv_selectedCountry || tv_selectedCountry.getText().length() == 0 || tv_countryCode.getText().length()<=1){
                    //提示：请选择国家区号
                    showToast("请选择国家区号");
                    return;
                }

                if(null == et_phoneNumber || et_phoneNumber.getText().length()==0){
                    //提示:请输入手机号码
                    showToast("请输入手机号码");
                    return;
                }
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
        return R.layout.activity_set_country_number;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(SelecteCountryCodeActivity.REQ_SELECTCOUNTRY == requestCode && resultCode == SelecteCountryCodeActivity.RES_SELECTCOUNTRY){
            if(null != data){
                String selectedCountryCode = data.getStringExtra("countryCode");
                new LocalPreferenceManager(mContext).saveDefaultCountryCode(selectedCountryCode);
                if(null != selectedCountryCode && null  != tv_selectedCountry && null != tv_countryCode){
                    tv_selectedCountry.setText(selectedCountryCode.substring(0, selectedCountryCode.indexOf("(")));
                    tv_countryCode.setText(selectedCountryCode.substring(selectedCountryCode.indexOf("+"), selectedCountryCode.length()-1));
                }
            }
        }
        Log.d(TAG,"onActivityResult-requestCode:"+requestCode+" resultCode:"+resultCode);
    }
}
