package com.qpidnetwork.livemodule.liveshow.authorization;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseNavFragment;
import com.qpidnetwork.livemodule.httprequest.OnRequestGetValidateCodeCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.LSValidateCodeType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.model.LoginParam;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.SoftKeyboardSizeWatchLayout;
import com.qpidnetwork.qnbridgemodule.view.textView.circularEditText.CircularEditText;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link FragmentLogin.OnFragmentInteractionListener} interface
 * to handle interaction events.
 */
public class FragmentLogin extends BaseNavFragment implements
        IAuthorizationListener,
        SoftKeyboardSizeWatchLayout.OnResizeListener{
    public static final String PARAMS_KEY_DIALOG_MSG = "PARAMS_KEY_DIALOG_MSG";

    @Override
    public void OnSoftPop(int height) {

    }

    @Override
    public void OnSoftClose() {

    }

    private enum RequestFlag {
        REQUEST_SUCCESS,
        REQUEST_FAIL,
        REQUEST_CHECKCODE_SUCCESS,
        REQUEST_CHECKCODE_FAIL,
        REQUEST_ONLINE_SUCCESS,
        REQUEST_ONLINE_FAIL,
    }

    //控件
    private Button btnLogin;
    private CircularEditText cdtAccount, cdtPw, cdtCode;
    private ImageView imageViewCheckCode;
    private TextView textViewForgot;
    private SoftKeyboardSizeWatchLayout sl_root;

    //变量
    private boolean mIsGettingCheckCode = false;
    private boolean mbHasGetCheckCode = false;
    private String mDialogMsg = "";

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_login_firsttime, container, false);
        sl_root = view.findViewById(R.id.sl_root);
        sl_root.addOnResizeListener(this);

        btnLogin = view.findViewById(R.id.btn_login);
        btnLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                login();
            }
        });

        cdtAccount = view.findViewById(R.id.cdt_account);
        cdtPw = view.findViewById(R.id.cdt_pw);
        cdtPw.setPassword();
        cdtPw.addCircularEditTextEventListener(new CircularEditText.OnCircularEditTextEventListener() {
            @Override
            public void onClickedToResetUI() {

            }

            @Override
            public void onShowError() {
                textViewForgot.setTextColor(ContextCompat.getColor(mContext, R.color.white));
            }

            @Override
            public void onShowNormal() {
                textViewForgot.setTextColor(ContextCompat.getColor(mContext, R.color.login_hint_txt));
            }
        });
        cdtCode = view.findViewById(R.id.cdt_code);
        cdtCode.setVisibility(View.GONE);
        cdtCode.addCircularEditTextEventListener(new CircularEditText.OnCircularEditTextEventListener() {
            @Override
            public void onClickedToResetUI() {

            }

            @Override
            public void onShowError() {
                cdtAccount.resetUI();
                cdtPw.resetUI();
            }

            @Override
            public void onShowNormal() {

            }
        });

        //忘记密码
        textViewForgot = new TextView(mContext);
        textViewForgot.setText(R.string.login_forget_password);
        textViewForgot.setTextSize(DisplayUtil.px2sp(mContext , getResources().getDimensionPixelSize(R.dimen.live_size_14sp)));
        textViewForgot.setTextColor(ContextCompat.getColor(mContext,R.color.login_hint_txt));
        textViewForgot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //去找回密码界面
//                PasswordResetActivity.startAct(mContext);
                startActivity(new Intent(getActivity(), LiveRegisterResetPasswordActivity.class));
            }
        });
        cdtPw.addRightView(textViewForgot, LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);


        //验证码图片
        imageViewCheckCode = new ImageView(mContext);
        imageViewCheckCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                doGetCheckCode();
            }
        });
        cdtCode.addRightView(imageViewCheckCode, mContext.getResources().getDimensionPixelSize(R.dimen.live_size_80dp),mContext.getResources().getDimensionPixelSize(R.dimen.live_size_30dp));
        return view;
    }

    @Override
    public void onResume() {
        super.onResume();

        doGetCheckCode();

        // 增加登录状态改变监听
        LoginManager.getInstance().register(this);

        //向Activity取参数
        getActivityBundle();

        //取本地数据,以判断是否走初始启动流程
        doGetAccountInfoInDB();
    }

    @Override
    protected void onGetActivityBundle() {
        super.onGetActivityBundle();

        Bundle bundle = getArguments();
        mDialogMsg = bundle.getString(PARAMS_KEY_DIALOG_MSG);
        if(!TextUtils.isEmpty(mDialogMsg)){
            doShowDialog(mDialogMsg);
        }
    }

    @Override
    public void onDestroyView() {
        // 去除登录状态改变监听
        LoginManager.getInstance().unRegister(this);

        //解绑监听器，防止泄漏
        if(sl_root != null){
            sl_root.removeOnResizeListener(this);
        }

        super.onDestroyView();
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        // 收起菊花
        hideLoading();
        HttpRespObject obj = (HttpRespObject) msg.obj;
        switch (RequestFlag.values()[msg.what]) {
            case REQUEST_SUCCESS: {
                // 登录成功
                onFinishAct();
            }
            break;
            case REQUEST_FAIL: {
                // 登录失败显示其他方式
//			buttonForget.setVisibility(View.VISIBLE);
                //buttonLoginWithFacebook.setVisibility(View.VISIBLE);

//			switch (obj.errCode) {
//				case RequestErrorCode.LOCAL_ERROR_CODE_TIMEOUT:{
//					// 本地错误
//					}
//				case RequestErrorCode.LOCAL_ERROR_CODE_PARSEFAIL:{
//                ToastUtil.showToast(mContext, obj.errMsg);
//					}break;
//				case RequestErrorCode.MBCE1001:{
//					// 用户名与密码不正确
//					editTextName.setError(Color.RED, true);
//					editTextPassword.setError(Color.RED, false, false);
//
//					//test
////					Intent i = new Intent(mContext, ReactivateProfileActivity.class);
////					startActivityForResult(i, ReactivateProfileActivity.REQUEST_CODE);
//
//					}break;
//				case RequestErrorCode.MBCE1002:{
//					// 会员帐号暂停
//					}
//				case RequestErrorCode.MBCE1003:{
//					// 帐号被冻结
//					editTextName.setError(Color.RED, true);
//					}break;
//				case RequestErrorCode.MBCE1012: {
//					// 验证码为空
//					}
//				case RequestErrorCode.MBCE1013:{
//					// 验证码无效
//
//					// 重新获取验证码
//					layoutCheckCode.setVisibility(View.VISIBLE);
//					editTextCheckcode.setError(Color.RED, true);
//					editTextCheckcode.setText("");
//					}break;
//				case RequestErrorCode.MBCE1006: {
//					// 分站被注销需要重新激活
//					Intent i = new Intent(mContext, ReactivateProfileActivity.class);
//					startActivityForResult(i, ReactivateProfileActivity.REQUEST_CODE);
//					}break;
//				default:{
//					// 其他会员账号错误
//					editTextName.setError(Color.RED, true);
//					editTextPassword.setError(Color.RED, true);
//					}break;
//			}
//			if(!TextUtils.isEmpty(obj.errno) && !obj.errno.equals(RequestErrorCode.LOCAL_ERROR_CODE_TIMEOUT)){
//				//登录非网络原因，都需重新刷新验证码
//				doGetCheckCode();
//			}

                HttpLccErrType lccErrType = IntToEnumUtils.intToHttpErrorType(obj.errCode);
                switch (lccErrType) {
                    case HTTP_LCC_ERR_PLOGIN_PASSWORD_INCORRECT:
                        cdtAccount.showError();
                        cdtPw.showError();

                        cdtCode.resetUI();
                        break;
                    case HTTP_LCC_ERR_PLOGIN_ENTER_VERIFICATION:
                    case HTTP_LCC_ERR_PLOGIN_VERIFICATION_WRONG:
                        cdtCode.showError();

                        cdtAccount.resetUI();
                        cdtPw.resetUI();
                        break;
                }

//                Log.i("Jagger", "REQUEST_FAIL:" + obj.errMsg);
                ToastUtil.showToast(mContext, obj.errMsg);
                textViewForgot.setVisibility(View.VISIBLE);
                doGetCheckCode();
            }
            break;
            case REQUEST_CHECKCODE_SUCCESS: {
                // 获取验证码成功
                cdtCode.setVisibility(View.VISIBLE);
                imageViewCheckCode.setClickable(true);

                if (obj != null && obj.data != null) {
                    Bitmap bitmap = (Bitmap) obj.data;
                    imageViewCheckCode.setImageBitmap(bitmap);
                    imageViewCheckCode.setVisibility(View.VISIBLE);
                    mbHasGetCheckCode = true;
                } else {
//				if( !mbHasGetCheckCode ) {
//					// 从来未获取到验证码
//					buttonRetry.setVisibility(View.VISIBLE);
//					imageViewCheckCode.setVisibility(View.GONE);
//				} else {
                    // 已经获取成功过
//                    buttonRetry.setVisibility(View.GONE);
                    imageViewCheckCode.setVisibility(View.GONE);
                    mbHasGetCheckCode = false;
//				}
                }
            }
            break;
            case REQUEST_CHECKCODE_FAIL: {
                // 获取验证码失败
//			switch (obj.errno) {
//			case RequestErrorCode.LOCAL_ERROR_CODE_TIMEOUT:{
//				// 本地错误
//				}
//			case RequestErrorCode.LOCAL_ERROR_CODE_PARSEFAIL:{
//                ToastUtil.showToast(mContext, obj.errMsg);
//				}break;
//			default:{
//				}break;
//			}
                ToastUtil.showToast(mContext, obj.errMsg);
            }
            break;
        }
    }

    //新加
    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        Message msg = Message.obtain();
        HttpRespObject obj = new HttpRespObject(isSuccess, errCode, errMsg, null);
        if( isSuccess ) {
            // 登录成功
            msg.what = RequestFlag.REQUEST_SUCCESS.ordinal();
            obj.data = item;
        } else {
            // 登录失败
            msg.what = RequestFlag.REQUEST_FAIL.ordinal();
        }
        msg.obj = obj;
        sendUiMessage(msg);
    }

    @Override
    public void onLogout(boolean isMannual) {

    }

    /**
     * 读取共享DB中的帐号信息
     */
    private void doGetAccountInfoInDB(){
        LoginParam param = LoginManager.getInstance().getAccountInfo();
        if( param != null ) {
            switch (param.loginType) {
                case Password :{
                    if( param.account != null ) {
                        cdtAccount.setText(param.account);
                    }

                    if( param.password != null ) {
                        cdtPw.setText(param.password);
                    }
                }break;
                default:
                    break;
            }
        }
    }

    /**
     * 验证码码
     */
    private void doGetCheckCode() {
        if(mIsGettingCheckCode)
            return;

        mIsGettingCheckCode = true;
        imageViewCheckCode.setClickable(false);
        cdtCode.setText("");
//		RequestJni.StopAllRequest();
        RequestJniAuthorization.GetValidateCode(LSValidateCodeType.login, new OnRequestGetValidateCodeCallback(){

            @Override
            public void OnGetValidateCode(boolean isSuccess, int errno, String errmsg, byte[] data) {
                mIsGettingCheckCode = false;

                Message msg = Message.obtain();
                HttpRespObject obj = new HttpRespObject(isSuccess, errno, errmsg, null);
                if( isSuccess ) {
                    // 获取验证码成功
                    msg.what = RequestFlag.REQUEST_CHECKCODE_SUCCESS.ordinal();
                    if( data.length != 0 ) {
                        obj.data = BitmapFactory.decodeByteArray(data, 0, data.length);
                    }
                } else {
                    // 获取验证码失败
                    msg.what = RequestFlag.REQUEST_CHECKCODE_FAIL.ordinal();
                }
                msg.obj = obj;
                mUiHandler.sendMessage(msg);
            }
        });
    }

    /**
     * 登录
     */
    private void login(){
        if( cdtAccount.getText().length() == 0 ) {
            cdtAccount.showError();

            cdtPw.resetUI();
            cdtCode.resetUI();
            return;
        }

        if( cdtPw.getText().length() == 0 ) {
            cdtPw.showError();

            cdtAccount.resetUI();
            cdtCode.resetUI();
            return;
        }

        if(mbHasGetCheckCode && cdtCode.getText().length() == 0 ) {
            cdtCode.showError();

            cdtAccount.resetUI();
            cdtPw.resetUI();
            return;
        }

        // 此处该弹菊花
        showLoading(getString(R.string.txt_login_loading));
        LoginManager.getInstance().loginByUsernamePassword(
                cdtAccount.getText(),
                cdtPw.getText(),
                cdtCode.getText());
    }

    /**
     * 提示框
     * @param msg
     */
    private void doShowDialog(String msg){
        if(TextUtils.isEmpty(mDialogMsg) || getActivity() == null){
            return;
        }

        DialogUIUtils.showAlert(
                getActivity(),
                getString(R.string.app_name),
                msg,
                "",
                "",
                getString(R.string.common_btn_ok),
                "",
                true,
                true,
                true,
                null
        ).show();
    }
}
