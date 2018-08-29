package com.qpidnetwork.anchor.utils;

import android.annotation.TargetApi;
import android.app.AppOpsManager;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Binder;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.text.TextUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.lang.reflect.Method;
import java.util.Properties;

/**
 * 高低版本兼容工具类
 * @author Hunter 
 * 2015.7.6
 */
public class CompatUtil {
	
	/**
	 * 解决4.4及以上版本与4.4一下版本读取系统相册差异化问题
	 * @return
	 */
	public static Intent getSelectPhotoFromAlumIntent(){
		Intent intent = new Intent();
		intent.setType("image/*");
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
			intent.setAction(Intent.ACTION_OPEN_DOCUMENT);
		}else{
			intent.setAction(Intent.ACTION_GET_CONTENT);
		}
		return intent;
	}

	/**
	 * 解决4.4及以上版本与4.4以下版本读取系统相册差异化问题
	 * @return
	 */
	public static String getSelectedPhotoPath(Context context, Uri contentUri){
		String filePath = "";
		if((Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) ){
			return doSelectedPhotoPath4KITKATPlus(context , contentUri);
		}else{
			if(!TextUtils.isEmpty(contentUri.getAuthority())){
			    String[] projection = { MediaStore.Images.Media.DATA };
			    try{
				    Cursor cursor = context.getContentResolver().query(contentUri, projection, null, null, null);
				    if( cursor != null ) {
				    	cursor.moveToFirst();
				    	int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
				    	filePath = cursor.getString(column_index);
				    	cursor.close();
				    }
			    }catch(Exception e){
		    		e.printStackTrace();
			    }
			}else{
				String tempfilePath = contentUri.getPath();
				if(!TextUtils.isEmpty(tempfilePath)&&(tempfilePath.endsWith(".jpg")||tempfilePath.endsWith(".JPG"))){
					filePath = tempfilePath;
				}
			}
		}
		return filePath;
	}

	@TargetApi(Build.VERSION_CODES.KITKAT)
	private static String doSelectedPhotoPath4KITKATPlus(Context context, Uri contentUri){
		String filePath = "";
		if((DocumentsContract.isDocumentUri(context, contentUri))){
			String wholeID = DocumentsContract.getDocumentId(contentUri);
			if(wholeID.contains(":")){
				String id = wholeID.split(":")[1];
				String[] column = { MediaStore.Images.Media.DATA };
				String sel = MediaStore.Images.Media._ID + "= ?";
				try{
					Cursor cursor = context.getContentResolver().query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, column,
							sel, new String[] { id }, null);
					if(cursor != null){
						cursor.moveToFirst();
						int columnIndex = cursor.getColumnIndex(column[0]);
						filePath = cursor.getString(columnIndex);
						cursor.close();
					}
				}catch(Exception e){
					if(!TextUtils.isEmpty(id)){
						filePath = Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + id;
						if(new File(filePath).exists()){
							return filePath;
						}
					}
					e.printStackTrace();
				}
			}
		}
		return filePath;
	}
	
	//处理是否MIUI系统，添加兼容性问题
	private static final String KEY_MIUI_VERSION_CODE = "ro.miui.ui.version.code";
	private static final String KEY_MIUI_VERSION_NAME = "ro.miui.ui.version.name";
	private static final String KEY_MIUI_INTERNAL_STORAGE = "ro.miui.internal.storage";
	public static boolean IsMIUI(){
		boolean isMIUI = false;
		Properties prop = new Properties();
		try{
			prop.load(new FileInputStream(new File(Environment.getRootDirectory(), "build.prop")));
		}catch(IOException e){
			e.printStackTrace();
			return false;
		}
		isMIUI = prop.getProperty(KEY_MIUI_VERSION_CODE, null) != null
				|| prop.getProperty(KEY_MIUI_VERSION_NAME, null) != null
				|| prop.getProperty(KEY_MIUI_INTERNAL_STORAGE, null) != null;
		return isMIUI;
	}
	
	/**
	 * 浮窗权限是否打开检测
	 * @param context
	 * @return
	 */
	@TargetApi(Build.VERSION_CODES.KITKAT)
	public static boolean isMiuiFloatWindowOpAllowed(Context context){
		boolean isAllowed = false;
		final int version = Build.VERSION.SDK_INT;
		if(version >= 19){
			//OP_SYSTEM_ALERT_WINDOW = 24;
			isAllowed = checkOp(context, 24);
		}else{
			if((context.getApplicationInfo().flags & 1<<27) == 1){
				isAllowed = true;
			}else{
				isAllowed = false;
			}
		}
		return isAllowed;
	}
	
	@TargetApi(Build.VERSION_CODES.KITKAT)
	private static boolean checkOp(Context context, int op){
		boolean isAllowed = false;
		final int version = Build.VERSION.SDK_INT;
		if(version >= 19){
			AppOpsManager manager = (AppOpsManager)context.getSystemService(Context.APP_OPS_SERVICE);
			try{
				Class localClass = manager.getClass();
				Class[] arrayOfClass = new Class[3];
				arrayOfClass[0] = Integer.TYPE;
				arrayOfClass[1] = Integer.TYPE;
				arrayOfClass[2] = String.class;
				Method method = localClass.getMethod("checkOp", arrayOfClass);
				if(method != null){
					Object[] arrayOfObject = new Object[3];
					arrayOfObject[0] = Integer.valueOf(op);
					arrayOfObject[1] = Integer.valueOf(Binder.getCallingUid());
					arrayOfObject[2] = context.getPackageName();
					int m = ((Integer)method.invoke(manager, arrayOfObject)).intValue();
					if(m == AppOpsManager.MODE_ALLOWED){
						isAllowed = true;
					}
				}
			}catch(Exception e){
				e.printStackTrace();
			}
		}else{
			
		}
		return isAllowed;
	}
}
