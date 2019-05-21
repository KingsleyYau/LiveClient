package com.qpidnetwork.livemodule.liveshow.authorization;

import android.content.Context;
import android.content.Intent;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.Display;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.livemodule.view.MovingImageView;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.KeyBoardManager;

/**
 * 认证模块 注册主界面
 * 
 * @author 原作Max.Chiu　从QN移来by Jagger 2018-9-18
 * 
 */
public class RegisterActivity extends BaseFragmentActivity implements IAuthorizationListener,MovingImageView.onImageMovingEvent {

//	@SuppressWarnings("unused")
//	private class LoginMessageItem {
//		public LoginMessageItem(String errno, String errmsg, LoginItem item,
//				LoginErrorItem errItem) {
//			this.errno = errno;
//			this.errmsg = errmsg;
//			this.item = item;
//			this.errItem = errItem;
//		}
//
//		public String errno;
//		public String errmsg;
//		public LoginItem item;
//		public LoginErrorItem errItem;
//	}

	private static final String PARAMS_KEY_URL = "url";
	private static final String PARAMS_KEY_DIALOG_MSG = "PARAMS_KEY_DIALOG_MSG";
	public static final int REQUEST_FAIL = 0;
	public static final int REQUEST_SUCCESS = 1;

	private RelativeLayout rlRoot;
	private ButtonRaised mButtonLogin;
//	private TextView mTextViewLogin;
//	private ButtonRaised buttonFacebook;
	private MovingImageView mFloatingBg;
	private ImageView backImage;
	private MovingImageView.Images mImages;

	private String mUrl = "";
	private String mDialogMsg = "";

	/**
	 * 外部启动入口
	 * @param context
	 */
	public static void launchRegisterActivity(Context context){
		launchRegisterActivity(context , "");
	}

	/**
	 * 外部启动入口
	 * @param context
	 * @param url
	 */
	public static void launchRegisterActivity(Context context, String url){
		Intent intent = new Intent(context, RegisterActivity.class);
		if(!TextUtils.isEmpty(url)){
			intent.putExtra(PARAMS_KEY_URL, url);
		}
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
		context.startActivity(intent);
	}

	/**
	 * 外部启动入口
	 * @param context
	 * @param dialogMsg
	 */
	public static void launchRegisterActivityWithDialog(Context context, String dialogMsg){
		Intent intent = new Intent(context, RegisterActivity.class);
		if(!TextUtils.isEmpty(dialogMsg)){
			intent.putExtra(PARAMS_KEY_DIALOG_MSG, dialogMsg);
		}
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
		context.startActivity(intent);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		//
		// Bundle bundle = getIntent().getExtras();
		// if( bundle != null ) {
		// // 是否直接返回主界面
		// mbReturnHome = bundle.getBoolean((RETURN_HOME), false);
		// }
		setImmersionBarArtts(R.color.transparent_full);

		initView();

		Intent theIntent = getIntent();
		//add by Jagger 2018-3-9
		//判空
		if(theIntent != null){
			if(theIntent.hasExtra(PARAMS_KEY_URL)){
				mUrl = theIntent.getStringExtra(PARAMS_KEY_URL);
			}

			if(theIntent.hasExtra(PARAMS_KEY_DIALOG_MSG)){
				mDialogMsg = theIntent.getStringExtra(PARAMS_KEY_DIALOG_MSG);
			}
		}

		LoginManager.getInstance().register(this);

		if(LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logined){
			//此时已登录成功
//			new AppUrlHandler(this).urlOpenActivity(mUrl);
//			finish();
			//edit by Jagger 2018-9-29
			URL2ActivityManager.getInstance().URL2Activity(mContext , mUrl);
			finish();
		}else{
			//未登录成功，走旧的逻辑
//			LoginParam param = LoginManager.getInstance().getAccountInfo();
//			if (param != null) {
//				switch (param.) {
//					case Default: {
//						Intent intent = new Intent(mContext, LoginActivity.class);
//						startActivity(intent);
//					}
//					break;
//					default:
//						break;
//				}
//			}

			//edit by Jagger 2018-9-29
			if(!TextUtils.isEmpty(mDialogMsg)){
				LoginActivity.launchActivityWithDialog(mContext, mDialogMsg);
			}else{
				Intent intent = new Intent(mContext, LoginActivity.class);
				startActivity(intent);
			}

			//add by Jagger 2017-4-26
//			reflashUiBySynConfigIncache();
			//
//			ConfigManager.getInstance().GetOtherSynConfigItem(this);
		}
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
	}

	@Override
	protected void onResume() {
		super.onResume();

		// 增加登录状态改变监听
		if (!mFloatingBg.isAutoStopped)
			mFloatingBg.runAnimate(mFloatingBg.mode);

	}

	@Override
	public void onPause() {
		super.onPause();

		// 删除登录状态改变监听
		mFloatingBg.stopAnimate();

	}

	@Override
	public void onDestroy() {
		mFloatingBg.stopAnimate();
		LoginManager.getInstance().unRegister(this);
		//add by Jagger 2018-3-9
		//手动清空参数,以免重复调用URL跳转
		mUrl = "";
		super.onDestroy();
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			LoginManager.getInstance().unRegister(this);
			finish();
			return true;
		}
		return super.onKeyDown(keyCode, event);
	}

	/**
	 * 点击登录
	 * 
	 * @param v
	 */
	public void onClickLogin(View v) {
		Intent intent = new Intent(mContext, LoginActivity.class);
		startActivity(intent);
	}

	public void initView() {
//		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_live_register);

		int[] imgesResourceIds = new int[] { R.drawable.img_cool_360dp_width_1,
				R.drawable.img_cool_360dp_width_3, R.drawable.long_gallery };

		mImages = new MovingImageView.Images(imgesResourceIds);

		backImage = (ImageView) findViewById(R.id.back_image);
//		mTextViewLogin = (TextView) findViewById(R.id.textLogin);
		mButtonLogin = (ButtonRaised) findViewById(R.id.buttonLogin);
//		buttonFacebook = (ButtonRaised) findViewById(R.id.buttonFacebook);

		mFloatingBg = (MovingImageView) findViewById(R.id.floatingBackground);
		mFloatingBg.setImageResource(mImages.getNext());
		mFloatingBg.setDuration(6000);
		mFloatingBg.setMode(MovingImageView.TranslateMode.YTRANSLATE);
		mFloatingBg.runAnimate(500);

		mFloatingBg.setCallback(this);

		// 获取keyboard高度
		if (KeyBoardManager.getKeyboardHeight(this) <= 0) {
			initKeyboardDetect();
		}
	}

	/**
	 * 获取软键盘高度
	 */
	private void initKeyboardDetect() {
		rlRoot = (RelativeLayout) findViewById(R.id.rlRoot);
		rlRoot.getViewTreeObserver().addOnGlobalLayoutListener(
				new ViewTreeObserver.OnGlobalLayoutListener() {

					@SuppressWarnings("deprecation")
					@Override
					public void onGlobalLayout() {
						// TODO Auto-generated method stub
						Rect r = new Rect();
						rlRoot.getRootView().getWindowVisibleDisplayFrame(r);
						
						WindowManager windowManager = getWindowManager();
						Display display = windowManager.getDefaultDisplay();
						int screenHeight = display.getHeight();

						int heightDifference = screenHeight
								- (r.bottom - r.top);
						if (heightDifference - r.top > 0) {
							int keyboardHeight = heightDifference - r.top;
							KeyBoardManager.saveKeyboardHeight(mContext, keyboardHeight);
						}
					}
				});
	}

	@Override
	protected void handleUiMessage(Message msg) {
		// TODO Auto-generated method stub
		super.handleUiMessage(msg);
		// 收起菊花
		hideProgressDialog();
		switch (msg.what) {
		case REQUEST_SUCCESS: {
			// facebook登录成功跳转主界面
			// Intent intent = new Intent(LoginNewActivity.this,
			// HomeActivity.class);
			// intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			// startActivity(intent);

			//dey by Jagger 2018-3-9
			//移去下面了,都finish了,这个context失效了,导致下面代码使用时有可能为null
			//可能引起 bug #9564
//			finish();

//			new AppUrlHandler(this).urlOpenActivity(mUrl);

			//edit by Jagger 2018-9-29
			if(!TextUtils.isEmpty(mUrl)){
				URL2ActivityManager.getInstance().URL2Activity(mContext , mUrl);
			}
			finish();
		    }
			break;
		case REQUEST_FAIL: {
//			// facebook登录失败, 根据错误码选择显示界面
//			LoginMessageItem loginItem = (LoginMessageItem) msg.obj;
//			switch (loginItem.errno) {
//			case RequestErrorCode.MBCE64001: {
//				// facebook没有邮箱，显示输入邮箱
//				startActivity(new Intent(LoginNewActivity.this,
//						RegisterByFacebookActivity.class));
//			}
//				break;
//			case RequestErrorCode.MBCE64002: {
//				// facebook有邮箱，并且已经被qpidnetwork注册，显示输入密码，重新绑定
//				Intent intent = new Intent(LoginNewActivity.this,
//						RegisterFacebookPasswordActivity.class);
//				intent.putExtra(
//						RegisterFacebookPasswordActivity.REGISTER_FACEBOOK_LOGINERRORITEM_KEY,
//						loginItem.errItem);
//				startActivity(intent);
//			}
//				break;
//			default:
//				if(!TextUtils.isEmpty(loginItem.errmsg)){
//			ToastUtil.showToast(mContext, loginItem.errmsg);
//					.show();
//				}
//				break;
//			}

			if(msg.obj != null){
				HttpRespObject httpRespObject = (HttpRespObject)msg.obj;
				if(!TextUtils.isEmpty((httpRespObject.errMsg))){
					ToastUtil.showToast(mContext, httpRespObject.errMsg);
				}
			}

		}break;
		default:
			break;
		}
	}

//	@Override
//	public void OnGetOtherSynConfigItem(boolean isSuccess, String errno,
//			String errmsg, OtherSynConfigItem item) {
//		// TODO Auto-generated method stub
//		if (isSuccess ) {
//			reflashUiBySynConfig(item);
//		}
//	}
	
//	/**
//	 * 使用内存中的同步配置刷新UI
//	 */
//	private void reflashUiBySynConfigIncache(){
//		reflashUiBySynConfig(ConfigManager.getInstance().getSynConfigItem());
//	}
	
//	/**
//	 * 根据同步配置刷新UI
//	 * @param item
//	 */
//	private void reflashUiBySynConfig(OtherSynConfigItem item){
//		if (item != null && item.pub != null
//				&& item.pub.facebook_enable) {
//			buttonFacebook.setVisibility(View.VISIBLE);
//			mTextViewLogin.setVisibility(View.VISIBLE);
//			mButtonLogin.setVisibility(View.GONE);
//		} else {
//			mTextViewLogin.setVisibility(View.GONE);
//			mButtonLogin.setVisibility(View.VISIBLE);
//		}
//	}

	@Override
	public void onAnimationStopped() {
		// TODO Auto-generated method stub
		if (mImages.getNextPosition() == 1) {
			mFloatingBg.setMode(MovingImageView.TranslateMode.XTRANSLATE);
		} else {
			mFloatingBg.setMode(MovingImageView.TranslateMode.YTRANSLATE);
		}

		int nextImage = mImages.getNext();
		backImage.setImageResource(nextImage);
		mFloatingBg.setNextPhoto(nextImage);
	}

	@Override
	public void onBeforeSetNext() {
		// TODO Auto-generated method stub

	}

	@Override
	public void onNextPhotoSet() {
		// TODO Auto-generated method stub
		mFloatingBg.runAnimate(mFloatingBg.mode, 0);
	}

	//新加
	@Override
	public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
		HttpRespObject httpRespObject = new HttpRespObject(isSuccess , errCode , errMsg , item);

		Message msg = Message.obtain();
		if (isSuccess) {
			// 登录成功
			msg.what = REQUEST_SUCCESS;
		}
		//del by Jagger 2018-11-2 登录失败不需要发消息,因为在LoginActivity中已处理, 不然会重复处理
//		else {
//
//			// 登录失败
//			msg.what = REQUEST_FAIL;
//
//			msg.obj = httpRespObject;
//		}
		sendUiMessage(msg);
	}

	@Override
	public void onLogout(boolean isMannual) {

	}
}
