package com.qpidnetwork.qnbridgemodule.fcm;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.os.AsyncTask;
import android.text.TextUtils;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.qpidnetwork.qnbridgemodule.interfaces.OnGcmGenerateRegisterIdCallback;
import com.qpidnetwork.qnbridgemodule.util.Log;

public class FCMPushManager {
	public static final String PROJECT_ID = "projectId";
	public static final String PROPERTY_REG_ID = "registration_id";
	private static final String PROPERTY_APP_VERSION = "appVersion";
	private static final String APP_TOKEN_PREFERENCE = "tokenPref";
	static final String TAG = "GCMPushManager";

	private Context mContext;
	private String SENDER_ID = "";
	private static FCMPushManager mGcmPushManager;

	public static FCMPushManager getInstance(Context context){
		if(mGcmPushManager == null){
			mGcmPushManager = new FCMPushManager(context);
		}
		return mGcmPushManager;
	}

	private FCMPushManager(Context context){
		mContext = context.getApplicationContext();
	}

	/**
	 * 外部设置GMC SENDID
	 * @param gcmSenderId
	 */
	public void setSenderID(String gcmSenderId){
		Log.i(TAG, "gcmSenderId is : " + gcmSenderId);
		SENDER_ID = gcmSenderId;
	}

	/**
	 * 生成GCM RegisterId
	 * @param callback
	 * @return
	 */
	public void generateRegId(OnGcmGenerateRegisterIdCallback callback){
		String regid = "";
		boolean isInterrupt = false;
		if(checkPlayServices()){
			regid = getRegistrationId(mContext);
			if(isNeedNewRegister(regid)){
				//需要重置regId
				regid = "";
				if(!TextUtils.isEmpty(SENDER_ID)){
					isInterrupt = true;
					registerInBackground(callback);
				}else{
					Log.i(TAG, "SENDER_ID is NULL ");
				}
			}else{
				Log.i(TAG, "regId = " + regid);
				//无需重置，直接使用
			}
		}else{
			Log.i(TAG, "No valid Google Play Services APK found.");
		}
		if(!isInterrupt){
			callback.onGcmGenerateRegisterId(regid);
		}
	}
	
	private boolean checkPlayServices(){
		int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(mContext);
		if(resultCode != ConnectionResult.SUCCESS){
			if(GooglePlayServicesUtil.isUserRecoverableError(resultCode)){
				Log.i(TAG, "Google play service error: " + GooglePlayServicesUtil.getErrorString(resultCode));
			}else{
				Log.i(TAG, "This device is not support.");
			}
			return false;
		}
		return true;
	}
	
	/**
	 * 是否需要重新注册
	 * @return
	 */
	private boolean isNeedNewRegister(String regId){
		boolean isNeedRegister = false;
		String oldProjectId = getProjectId();
		if(!TextUtils.isEmpty(SENDER_ID)
				&& !SENDER_ID.equals(oldProjectId)){
			storeProjectId(SENDER_ID);
			isNeedRegister = true;
		}else{
			SENDER_ID = oldProjectId;
			if(regId.isEmpty()){
				isNeedRegister = true;
			}
		}
		return isNeedRegister;
	}
	
	@SuppressLint("StaticFieldLeak")
	private void registerInBackground(final OnGcmGenerateRegisterIdCallback callback){
		new AsyncTask<Void, Void, String>() {

			@Override
			protected String doInBackground(Void... params) {
				String regid = "";
				String msg = "";
				try {
					// fcm
					regid = InstanceIDUtil.getFCMToken();

					Log.i(TAG, "Register regid : " + regid + " length: " + regid.length());
					msg = "Device registered, registration ID=" + regid;

					storeRegistrationId(mContext, regid);

				} catch (Exception e) {
					msg = "Error : " + e.getMessage();
				}

				callback.onGcmGenerateRegisterId(regid);
				Log.i(TAG, "doInBackground  msg : " + msg + " regid: " + regid + " SENDER_ID: " + SENDER_ID);

				return msg;
			}
			
			@Override
			protected void onPostExecute(String result) {
				super.onPostExecute(result);
			}
		}.execute(null, null, null);


	}

	private void storeRegistrationId(Context context, String regId){
		final SharedPreferences prefs = getGcmPreferences(context);
		int appVersion = getAppVersion(context);
		SharedPreferences.Editor editor = prefs.edit();
		editor.putString(PROPERTY_REG_ID, regId);
		editor.putInt(PROPERTY_APP_VERSION, appVersion);
		editor.commit();
	}
	
	private String getRegistrationId(Context context){
		final SharedPreferences prefs = getGcmPreferences(context);
		String registrationId = prefs.getString(PROPERTY_REG_ID, "");
		if(registrationId.isEmpty()){
			Log.i(TAG, "Registration not found");
			return "";
		}
		
		int registeredVersion = prefs.getInt(PROPERTY_APP_VERSION, Integer.MIN_VALUE);
		int currentVersion = getAppVersion(context);
		if(registeredVersion !=  currentVersion){
			Log.i(TAG, "App version changed");
			return "";
		}
		return registrationId;
	}
	
	/**
	 * 保存ProjectId
	 * @param projectId
	 * @return
	 */
	private void storeProjectId(String projectId){
		SharedPreferences prefs = getGcmPreferences(mContext);
		SharedPreferences.Editor editor = prefs.edit();
		editor.putString(PROJECT_ID, projectId);
		editor.commit();
	}
	
	/**
	 * 读取本地保存ProjectId，用于处理是否重新生成TokenId
	 * @return
	 */
	private String getProjectId(){
		SharedPreferences prefs = getGcmPreferences(mContext);
		String projectId = prefs.getString(PROJECT_ID, "");
		return projectId;
	}
	
	private int getAppVersion(Context context){
		try {
			PackageInfo packageInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
			return packageInfo.versionCode;
		} catch (Exception e) {
			throw new RuntimeException("Could not get package name: " + e);
		}
	}

	private SharedPreferences getGcmPreferences(Context context){
		return mContext.getSharedPreferences(APP_TOKEN_PREFERENCE, Context.MODE_PRIVATE);
	}
}
