package net.qdating.utils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.lang.Thread.UncaughtExceptionHandler;
import java.lang.reflect.Field;
import java.util.Calendar;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Build;
import android.os.Environment;

public class CrashHandler implements UncaughtExceptionHandler {
	private static CrashHandler gCrashHandler;
    
	public static CrashHandler newInstance(Context context) {
		if( gCrashHandler == null ) {
			gCrashHandler = new CrashHandler(context);
		} 
		return gCrashHandler;
	}
	
	public static CrashHandler getInstance() {
		return gCrashHandler;
	}
	
	public CrashHandler(Context context)  {
		mContext = context;
        mDefaultHandler = Thread.getDefaultUncaughtExceptionHandler();   
        Thread.setDefaultUncaughtExceptionHandler(this);   
	}
	
    private Thread.UncaughtExceptionHandler mDefaultHandler;  
    private Context mContext;
	
    @Override  
    public void uncaughtException(Thread thread, Throwable ex) {   
    	handleException(ex);
    	
        if ( mDefaultHandler != null ) {   
            mDefaultHandler.uncaughtException(thread, ex);   
        }  
        
        try {   
            Thread.sleep(1000);   
        } catch (InterruptedException e) {   
        	
        }
        
        android.os.Process.killProcess(android.os.Process.myPid());
        System.exit(9); 
    }
    
    private boolean handleException(Throwable ex) {   
        if (ex == null) {   
            return false;   
        }
        
        SaveCrashInfoToFile(ex); 
        
        return true;   
    }     
	    
    /**  
     * 保存错误信息到文件中  
     * @param ex  
     * @return  
     */  
    private String SaveCrashInfoToFile(Throwable ex) { 
    	// 保存应用版本信息
    	StringBuffer sb = new StringBuffer();  
    	
	   	try {
	   		PackageManager pm = mContext.getPackageManager();  
	        PackageInfo pi = pm.getPackageInfo(mContext.getPackageName(), PackageManager.GET_ACTIVITIES);  
	        if (pi != null) {
	        	String versionName = pi.versionName == null ? "null" : pi.versionName;  
	            String versionCode = String.valueOf(pi.versionCode);  
	            String packagename = pi.packageName == null ? "null" : pi.packageName;
	             
	            sb.append("packagename" + " = " + packagename + "\n");
	            sb.append("versionCode" + " = " + versionCode + "\n");
	            sb.append("versionName" + " = " + versionName + "\n");
	        }  
	    } catch (NameNotFoundException e) {  
	    } 
	   	
	   	// 保存设备信息
        Field[] fields = Build.class.getDeclaredFields();  
        for (Field field : fields) {  
            try {  
                field.setAccessible(true);  
                sb.append(field.getName() + " = " + field.get(null).toString() + "\n");  
            } catch (Exception e) {  
            }  
        }
        
        sb.append("\n");
        
        // 保存网络状态信息
        
        if( ex != null ) {
            // 保存异常信息
            Writer info = new StringWriter(); 
            PrintWriter printWriter = new PrintWriter(info);   
            ex.printStackTrace(printWriter);   
      
            Throwable cause = ex.getCause();   
            while (cause != null) {   
                cause.printStackTrace(printWriter); 
                cause = cause.getCause();
            }   
      
            String result = info.toString();  
            sb.append(result);
            
            printWriter.close(); 
        }

        try {   
            Calendar cal = Calendar.getInstance();
            int year = cal.get(Calendar.YEAR);
            int month = cal.get(Calendar.MONTH)+1;
            int day = cal.get(Calendar.DAY_OF_MONTH);
            int hour = cal.get(Calendar.HOUR_OF_DAY);
            int min = cal.get(Calendar.MINUTE);
            
            byte[] buf = sb.toString().getBytes();
            
    		File path = Environment.getExternalStorageDirectory();
            String fileName = path.getAbsolutePath() + "/coollive/";
            fileName += String.format("%d-%d-%d[%d-%d]", 
            		year, 
            		month, 
            		day, 
            		hour, 
            		min);
            File file = new File(fileName);  
            if( !file.exists() ) {
            	file.createNewFile();  
            }
            
            FileOutputStream fos = new FileOutputStream(file); 
            fos.write(buf);            
            fos.close(); 
            
        } catch (Exception e) {   
        	Log.d("CrashHandler", "SaveCrashInfoToFile( " + e.toString() +" )");
        }   
        return null;   
    }
    
    public void SaveAppVersionFile() {
    	// 保存应用版本信息
    	StringBuffer sb = new StringBuffer();  
    	String versionCode = "";
	   	try {
	   		PackageManager pm = mContext.getPackageManager();  
	        PackageInfo pi = pm.getPackageInfo(mContext.getPackageName(), PackageManager.GET_ACTIVITIES);  
	        if (pi != null) {
	        	String versionName = pi.versionName == null ? "null" : pi.versionName;  
	            versionCode = String.valueOf(pi.versionCode);  
	            String packagename = pi.packageName == null ? "null" : pi.packageName;
	             
	            sb.append("packagename" + " = " + packagename + "\n");
	            sb.append("versionCode" + " = " + versionCode + "\n");
	            sb.append("versionName" + " = " + versionName + "\n");
	        }  
	    } catch (NameNotFoundException e) {  
	    } 
	   	
	   	// 保存设备信息
        Field[] fields = Build.class.getDeclaredFields();  
        for (Field field : fields) {  
            try {  
                field.setAccessible(true);  
                sb.append(field.getName() + " = " + field.get(null).toString() + "\n");  
            } catch (Exception e) {  
            }  
        }
        
        sb.append("\n");
        
		File path = Environment.getExternalStorageDirectory();
        String fileName = path.getAbsolutePath() + "/coollive/version/";
        File dir = new File(fileName);
        dir.mkdirs();
    	File file = new File(fileName + versionCode);
    	if( !file.exists() ) {
    		try {   
    			file.createNewFile();
    			FileOutputStream fos = new FileOutputStream(file); 
                fos.write(sb.toString().getBytes());            
                fos.close(); 
    		} catch (Exception e) {  
    	    } 
    	}
    }
}
