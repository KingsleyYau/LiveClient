package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.httprequest.LiveDomainRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.livemodule.view.MaterialAppBar;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;


/**
 * MyProfile模块
 * modify by Hardy
 *
 * @author Max.Chiu
 */
public class MyProfileChangePasswordActivity extends BaseFragmentActivity implements OnRequestCallback, OnClickListener {

    private enum RequestFlag {
        REQUEST_SUCCESS,
        REQUEST_FAIL,
    }

    //private TextView textViewTips;
    private MaterialTextField editTextCurrentPassword;
    private MaterialTextField editTextNewPassword;
    private MaterialTextField editTextConfirmPassword;
    private MaterialAppBar appbar;
    private ButtonRaised btnChange;

    //变量
    private String mTempNewPassword;    //用于入库

    public static void startAct(Context context) {
        Intent intent = new Intent(context, MyProfileChangePasswordActivity.class);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_profile_change_password_live);

        InitView();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    /**
     * 点击取消
     *
     * @param v
     */
    public void onClickCancel(View v) {
        finish();
    }

    /**
     * 点击改变密码
     *
     * @param v
     */
    public void onClickChange(View v) {
        if (CheckPassword()) {
            // 此处应有菊花
            showProgressDialog("Loading...");
            mTempNewPassword = editTextNewPassword.getText().toString();
//            RequestOperator.getInstance().ChangePassword(
            LiveDomainRequestOperator.getInstance().ChangePassword(
                    mTempNewPassword,
                    editTextCurrentPassword.getText().toString(),
                    this
            );
        }
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.common_button_back) {
            onClickCancel(v);
        }
    }

    public void InitView() {
        appbar = (MaterialAppBar) findViewById(R.id.appbar);
        appbar.setTouchFeedback(MaterialAppBar.TOUCH_FEEDBACK_HOLO_LIGHT);
        appbar.addButtonToLeft(R.id.common_button_back, "", R.drawable.ic_close_grey600_24dp);
        appbar.setTitle(getString(R.string.Change_Password), getResources().getColor(R.color.text_color_dark));
        appbar.setOnButtonClickListener(this);

        //textViewTips = (TextView) findViewById(R.id.textViewTips);
        //textViewTips.setVisibility(View.GONE);

        editTextCurrentPassword = (MaterialTextField) findViewById(R.id.editTextCurrentPassword);
        editTextCurrentPassword.setPassword();
        editTextCurrentPassword.setHint("Your current password");

        editTextNewPassword = (MaterialTextField) findViewById(R.id.editTextNewPassword);
        editTextNewPassword.setPassword();
        editTextNewPassword.setHint("New password");

        editTextConfirmPassword = (MaterialTextField) findViewById(R.id.editTextConfirmPassword);
        editTextConfirmPassword.setPassword();
        editTextConfirmPassword.setHint("Confirm Password");

        btnChange = (ButtonRaised) findViewById(R.id.btnChange);
        //edit by Jagger 设置为主题颜色
//        btnChange.setButtonBackground(getResources().getColor(WebSiteConfigManager.getInstance().getCurrentWebSite().getSiteColor()));
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        // 收起菊花
        hideProgressDialog();
//        RequestBaseResponse obj = (RequestBaseResponse) msg.obj;
        HttpRespObject obj = (HttpRespObject) msg.obj;
        switch (RequestFlag.values()[msg.what]) {
            case REQUEST_SUCCESS: {
                //更新共享数据库中密码 add by Jagger 2018-10-11
                if(!TextUtils.isEmpty(mTempNewPassword)){
                    LoginManager.getInstance().updatePassword(mTempNewPassword);
                }

                // 改变密码成功
                finish();
            }
            break;

            case REQUEST_FAIL: {
                // 请求失败
                ToastUtil.showToast(mContext, obj.errMsg);
//                editTextCurrentPassword.setError(Color.RED, true);
            }
            break;

            default:
                break;
        }
    }

    /**
     * 检查新密码是否正确
     *
     * @return
     */
    public boolean CheckPassword() {
        if (editTextCurrentPassword.getText().toString().length() == 0) {
            // 沒輸入當前密碼
            editTextCurrentPassword.setError(Color.RED, true);
            return false;
        } else if (editTextNewPassword.getText().toString().length() == 0) {
            editTextNewPassword.setError(Color.RED, true);
            return false;
        } else if (editTextConfirmPassword.getText().toString().length() == 0) {
            editTextConfirmPassword.setError(Color.RED, true);
            return false;
        } else if (editTextNewPassword.getText().toString().length() < 6) {
            // 新密小于6位
            MaterialDialogAlert alert = new MaterialDialogAlert(mContext);
            alert.setMessage("Password must more than 6 characters.");
            alert.addButton(alert.createButton(getString(R.string.common_btn_ok), null));
            alert.show();

            editTextNewPassword.setError(Color.RED, true);
            return false;
        } else if (editTextNewPassword.getText().toString().length() > 12) {
            // 新密大于12位
            MaterialDialogAlert alert = new MaterialDialogAlert(mContext);
            alert.setMessage("Password can't exceed 12 characters.");
            alert.addButton(alert.createButton(getString(R.string.common_btn_ok), null));
            alert.show();

            editTextNewPassword.setError(Color.RED, true);
            return false;
        } else if (editTextNewPassword.getText().toString().compareTo(editTextConfirmPassword.getText().toString()) != 0) {
            // 检查2个新密码是否一样
            MaterialDialogAlert alert = new MaterialDialogAlert(mContext);
            alert.setMessage("New passwords do not match.");
            alert.addButton(alert.createButton(getString(R.string.common_btn_ok), null));
            alert.show();

            editTextConfirmPassword.setError(Color.RED, true);
            return false;
        }
        return true;
    }


    // QN old
//    @Override
//    public void OnRequest(boolean isSuccess, String errno, String errmsg) {
//        Message msg = Message.obtain();
//        RequestBaseResponse obj = new RequestBaseResponse(isSuccess, errno, errmsg, null);
//        if (isSuccess) {
//            // 改变密码成功
//            msg.what = RequestFlag.REQUEST_SUCCESS.ordinal();
//        } else {
//            // 失败
//            msg.what = RequestFlag.REQUEST_FAIL.ordinal();
//        }
//        msg.obj = obj;
//        sendUiMessage(msg);
//    }

    @Override
    public void onRequest(boolean isSuccess, int errCode, String errMsg) {
        Message msg = Message.obtain();
//        RequestBaseResponse obj = new RequestBaseResponse(isSuccess, errno, errmsg, null);
        HttpRespObject obj = new HttpRespObject(isSuccess, errCode, errMsg, null);
        if (isSuccess) {
            // 改变密码成功
            msg.what = RequestFlag.REQUEST_SUCCESS.ordinal();
        } else {
            // 失败
            msg.what = RequestFlag.REQUEST_FAIL.ordinal();
        }
        msg.obj = obj;
        sendUiMessage(msg);
    }

}
