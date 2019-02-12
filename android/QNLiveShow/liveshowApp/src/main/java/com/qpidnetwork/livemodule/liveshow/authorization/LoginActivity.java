package com.qpidnetwork.livemodule.liveshow.authorization;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Message;
import android.text.InputType;
import android.text.TextUtils;
import android.text.method.HideReturnsTransformationMethod;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.dou361.dialogui.DialogUIUtils;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.httprequest.OnRequestGetValidateCodeCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.LSValidateCodeType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.model.LoginParam;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.KeyBoardManager;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.SoftKeyboardSizeWatchLayout;

/**
 * 认证模块
 * 登录界面 
 * @author 原作Max.Chiu　从QN移来by Jagger 2018-9-18
 *
 */
public class LoginActivity extends BaseFragmentActivity
						   implements IAuthorizationListener,
									  SoftKeyboardSizeWatchLayout.OnResizeListener
{
	private static final String PARAMS_KEY_DIALOG_MSG = "PARAMS_KEY_DIALOG_MSG";

	private enum RequestFlag {
		REQUEST_SUCCESS,
		REQUEST_FAIL,
		REQUEST_CHECKCODE_SUCCESS,
		REQUEST_CHECKCODE_FAIL,
		REQUEST_ONLINE_SUCCESS,
		REQUEST_ONLINE_FAIL,
	}
	
	private TextView textViewOnline;
	
	private MaterialTextField editTextName;
	private MaterialTextField editTextPassword;
	private ImageButton imageViewVisiblePassword;
	
	private RelativeLayout layoutCheckCode;
	private MaterialTextField editTextCheckcode;
	
	private ButtonRaised buttonForget;
//	private ButtonRaised buttonLoginWithFacebook;
	
	private ImageView imageViewCheckCode;
	private ButtonRaised buttonRetry;

	//为了提前记录键盘高度,　在聊天界面中好配置界面
	private SoftKeyboardSizeWatchLayout sl_root;
	private boolean isKeyboardShow = false;

	//那个白色的框框
	private LinearLayout ll_bg;
	
//	private boolean mbHasGetCheckCode = false;
	private boolean mIsGettingCheckCode = false;

	private String mDialogMsg = "";

	/**
	 * 外部启动入口
	 * @param context
	 * @param dialogMsg
	 */
	public static void launchActivityWithDialog(Context context, String dialogMsg){
		if(context instanceof Activity){
			Intent intent = new Intent(context, LoginActivity.class);
			if(!TextUtils.isEmpty(dialogMsg)){
				intent.putExtra(PARAMS_KEY_DIALOG_MSG, dialogMsg);
			}
			context.startActivity(intent);
			((Activity)context).overridePendingTransition(R.anim.anim_activity_fade_in, R.anim.anim_activity_fade_out);
		}
	}
	
	@SuppressWarnings("deprecation")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
//		this.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
		setImmersionBarArtts(R.color.transparent_full);

		Intent theIntent = getIntent();
		//add by Jagger 2018-3-9
		//判空
		if(theIntent != null){

			if(theIntent.hasExtra(PARAMS_KEY_DIALOG_MSG)){
				mDialogMsg = theIntent.getStringExtra(PARAMS_KEY_DIALOG_MSG);
			}
		}

    	//
		initView();
		
		// 读取本地缓存
		LoginParam param = LoginManager.getInstance().getAccountInfo();
    	if( param != null ) {
    		switch (param.loginType) {
				case Password :{
					if(!TextUtils.isEmpty(param.account)) {
						//优先显示用户名
						editTextName.setText(param.account);
					}else if(!TextUtils.isEmpty(param.memberId)) {
						//若无 则显示用户ID
						editTextName.setText(param.memberId);
					}

					if( !TextUtils.isEmpty(param.password)) {
						editTextPassword.setText(param.password);
					}
				}break;
				default:
					break;
				}
    	}
		
		// 增加登录状态改变监听
		LoginManager.getInstance().register(this);

		switch (LoginManager.getInstance().getLoginStatus()) {
			case Default: {
				// 调用刷新注册码接口
				doGetCheckCode();
			}break;
			case Logining:{
				// 此处该弹菊花
				showProgressDialog("Logining...");
			}break;
			case Logined:{
				// 登录成功
				finish();
			}break;
			default:
				break;
		}
		
		// 获取在线人数
//		OnlineCount();
	}
	
	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();

		switch (LoginManager.getInstance().getLoginStatus()) {
			case Default: {
			}
			break;
			case Logining: {
				// 此处该弹菊花
				showProgressDialog(getString(R.string.txt_login_loading));
			}
			case Logined: {
			}
			break;
			default:
				break;
		}
	}
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		
		// 去除登录状态改变监听
		LoginManager.getInstance().unRegister(this);
	}
	
	/**
	 * 点击登录
	 * @param view
	 */
	public void onClickLogin(View view) {
		login();
	}
	
	/**
	 * 点击忘记密码
	 * @param view
	 */
	public void onClickForget(View view) {
		startActivity(new Intent(this, LiveRegisterResetPasswordActivity.class));
	}
	
	/**
	 * toggle visibility of password
	 */
	public void onClickVisiblePassword(View view){
		if (editTextPassword.getEditor().getInputType() == InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD ||
				editTextPassword.getEditor().getTransformationMethod() == HideReturnsTransformationMethod.getInstance()){
			editTextPassword.setPassword();
			imageViewVisiblePassword.setImageResource(R.drawable.ic_visible_grey600_24dp);
		}else{
			editTextPassword.setVisiblePassword();
			imageViewVisiblePassword.setImageResource(R.drawable.ic_invisible_grey600_24dp);
		}
		
		editTextPassword.getEditor().setSelection(editTextPassword.getText().length());
		
	}
	
	/**
	 * 验证码码
	 */
	private void doGetCheckCode() {
		if(mIsGettingCheckCode)
			return;

		mIsGettingCheckCode = true;
		buttonRetry.setVisibility(View.GONE);
		imageViewCheckCode.setClickable(false);
		editTextCheckcode.setText("");
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
				mHandler.sendMessage(msg);
			}
		});
	}
	
	/**
	 * 登录
	 */
	private void login(){
		if( editTextName.getText().toString().length() == 0 ) {
			editTextName.setError(Color.RED, true);
			return;
		}
		
		if( editTextPassword.getText().toString().length() == 0 ) {
			editTextPassword.setError(Color.RED, true);
			return;
		}
		
		// 此处该弹菊花
		showProgressDialog(getString(R.string.txt_login_loading));
		LoginManager.getInstance().loginByUsernamePassword(
				editTextName.getText().toString(),
				editTextPassword.getText().toString(),
				editTextCheckcode.getText().toString());
	}
	
	/**
	 * 点击验证码码
	 * @param view
	 */
	public void onClickCheckCode(View view) {
		// 调用刷新注册码接口
		doGetCheckCode();
	}
	
	public void initView() {
		setContentView(R.layout.activity_live_login);

		//add by Jagger 2018-7-26
		sl_root = (SoftKeyboardSizeWatchLayout)findViewById(R.id.sl_root);
		sl_root.addOnResizeListener(this);
		sl_root.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View view) {
				//点击窗体外部, 优先关闭键盘
				if(isKeyboardShow){
					hideSoftInput();
				}else {
					finish();
				}

			}
		});

		//输入栏宽度随屏幕大小改变（和QN一样）
		ll_bg = (LinearLayout) findViewById(R.id.ll_bg);
		ll_bg.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View view) {
				//空事件, 以免点到空白处 窗口会关闭
			}
		});
//		float density = getResources().getDisplayMetrics().density;
//		Display display = this.getWindow().getWindowManager().getDefaultDisplay();
//    	Point size = new Point();
//
//    	if (Build.VERSION.SDK_INT > 12){
//    		display.getSize(size);
//    	}else{
//    		size.y = display.getHeight();
//    		size.x = display.getWidth();
//    	}
//
//    	int width_times =  Math.round((float)size.x / (56.0f * density));
//    	float dialog_width = ((float)(width_times - 1) * 56.0f * density);
//    	LayoutParams layoutParams = ll_bg.getLayoutParams();
//		layoutParams.width = (int)dialog_width;
//		ll_bg.setLayoutParams(layoutParams);

		//
		editTextName = (MaterialTextField) findViewById(R.id.editTextName);
		editTextName.setHint(getString(R.string.live_login_email_or_id));
		editTextName.getEditor().setHintTextColor(getResources().getColor(R.color.text_color_grey));
		editTextName.setFocusedStateColor(getResources().getColor(R.color.green));
//		editTextName.setEmail();	//解决部分手机键盘高度计算问题
		
		editTextPassword = (MaterialTextField) findViewById(R.id.editTextPassword);
		editTextPassword.setHint(getString(R.string.live_login_password));
		editTextPassword.getEditor().setHintTextColor(getResources().getColor(R.color.text_color_grey));
		editTextPassword.setFocusedStateColor(getResources().getColor(R.color.green));
		editTextPassword.setPassword();
		
		imageViewVisiblePassword = (ImageButton)findViewById(R.id.imageViewVisiblePassword);
		
		layoutCheckCode = (RelativeLayout) findViewById(R.id.layoutCheckCode);
		layoutCheckCode.setVisibility(View.GONE);
		buttonRetry = (ButtonRaised) findViewById(R.id.buttonRetry);
		buttonRetry.setVisibility(View.GONE);
		
		editTextCheckcode = (MaterialTextField) findViewById(R.id.editTextCheckCode);
		editTextCheckcode.setHint(getString(R.string.live_login_secure_code));
		editTextCheckcode.getEditor().setHintTextColor(getResources().getColor(R.color.text_color_grey));
		editTextCheckcode.setFocusedStateColor(getResources().getColor(R.color.green));
		editTextCheckcode.setNoPredition();
		
		buttonForget = (ButtonRaised) findViewById(R.id.buttonForget);
//		buttonLoginWithFacebook = (ButtonRaised) findViewById(R.id.buttonLoginWithFacebook);
		
		imageViewCheckCode = (ImageView) findViewById(R.id.imageViewCheckCode);
		imageViewCheckCode.setImageDrawable(null);
		
		buttonForget.setVisibility(View.GONE);
//		buttonLoginWithFacebook.setVisibility(View.GONE);

		if(!TextUtils.isEmpty(mDialogMsg)){
			doShowDialog(mDialogMsg);
		}
	}
	
	@Override
	protected void handleUiMessage(Message msg) {
		// TODO Auto-generated method stub
		super.handleUiMessage(msg);
		// 收起菊花
		hideProgressDialog();
		HttpRespObject obj = (HttpRespObject) msg.obj;
		switch ( RequestFlag.values()[msg.what] ) {
		case REQUEST_SUCCESS:{
			// 登录成功
			finish();
			}break;
		case REQUEST_FAIL:{
			// 登录失败显示其他方式
//			buttonForget.setVisibility(View.VISIBLE);
			//buttonLoginWithFacebook.setVisibility(View.VISIBLE);
			
//			switch (obj.errCode) {
//				case RequestErrorCode.LOCAL_ERROR_CODE_TIMEOUT:{
//					// 本地错误
//					}
//				case RequestErrorCode.LOCAL_ERROR_CODE_PARSEFAIL:{
//					Toast.makeText(mContext, obj.errmsg, Toast.LENGTH_SHORT).show();
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

			Log.i("Jagger" , "REQUEST_FAIL:" + obj.errMsg);
			Toast.makeText(mContext , obj.errMsg, Toast.LENGTH_LONG).show();
			buttonForget.setVisibility(View.VISIBLE);
			doGetCheckCode();
		}break;
		case REQUEST_CHECKCODE_SUCCESS:{
			// 获取验证码成功
			layoutCheckCode.setVisibility(View.VISIBLE);
			buttonRetry.setVisibility(View.GONE);
//			mbHasGetCheckCode = true;
			imageViewCheckCode.setClickable(true);
			
			if( obj != null && obj.data != null ) {
				Bitmap bitmap = (Bitmap)obj.data;
				imageViewCheckCode.setImageBitmap(bitmap);
				imageViewCheckCode.setVisibility(View.VISIBLE);
			} else {
//				if( !mbHasGetCheckCode ) {
//					// 从来未获取到验证码
//					buttonRetry.setVisibility(View.VISIBLE);
//					imageViewCheckCode.setVisibility(View.GONE);
//				} else {
					// 已经获取成功过
					buttonRetry.setVisibility(View.GONE);
					imageViewCheckCode.setVisibility(View.VISIBLE);
//				}
			}
		}break;
		case REQUEST_CHECKCODE_FAIL:{
			// 获取验证码失败
//			switch (obj.errno) {
//			case RequestErrorCode.LOCAL_ERROR_CODE_TIMEOUT:{
//				// 本地错误
//				}
//			case RequestErrorCode.LOCAL_ERROR_CODE_PARSEFAIL:{
//				Toast.makeText(mContext, obj.errmsg, Toast.LENGTH_SHORT).show();
//				}break;
//			default:{
//				}break;
//			}
			Toast.makeText(mContext, obj.errMsg, Toast.LENGTH_SHORT).show();
		}break;
//		case REQUEST_ONLINE_SUCCESS:{
//			// 获取站点在线人数成功
//			OtherOnlineCountItem[] otherOnlineCountItem = (OtherOnlineCountItem[])obj.body;
//			for(int i = 0; i < otherOnlineCountItem.length; i++) {
//				if( otherOnlineCountItem[i].site == WebSiteConfigManager.getInstance().getCurrentWebSite().getSiteId() ) {
//					textViewOnline.setText(String.valueOf(otherOnlineCountItem[i].onlineCount));
//					break;
//				}
//			}
//			}break;
		case REQUEST_ONLINE_FAIL:{
			
			}break;
		default:
			break;
		}
	}

	/**
	 * 提示框
	 * @param msg
	 */
	private void doShowDialog(String msg){
		if(TextUtils.isEmpty(mDialogMsg)){
			return;
		}

		DialogUIUtils.showAlert(
				this,
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

	@Override
	protected void onActivityResult(int requestCode , int resultCode , Intent data ) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
//		if(requestCode == ReactivateProfileActivity.REQUEST_CODE){
//			if(resultCode == ReactivateProfileActivity.RESULT_CODE_SUCCESS){
//				login();
//			}
//		}
	}

	@Override
	public void OnSoftPop(int height) {
		KeyBoardManager.saveKeyboardHeight(mContext , height);
		isKeyboardShow = true;
	}

	@Override
	public void OnSoftClose() {
		isKeyboardShow = false;
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

	@Override
	public void finish() {
		super.finish();
		overridePendingTransition(R.anim.anim_activity_fade_in, R.anim.anim_activity_fade_out);
	}
}
