package com.qpidnetwork.anchor.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Base64;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

public class CrashPerfence {
	
	static public class CrashParam implements Serializable {
		/**
		 * 
		 */
		private static final long serialVersionUID = 2951362832580476695L;
		public CrashParam(
				boolean bUploadCrash,
				boolean bRemember
				) { 
			this.bUploadCrash = bUploadCrash;
			this.bRemember = bRemember;
		}
		
		public boolean bUploadCrash = false;
		public boolean bRemember = false;
	}
	
	/**
	 * 缓存参数
	 * @param context	上下文
	 * @param item		
	 */
	public static void SaveCrashParam(Context context, CrashParam item) {
		SharedPreferences mSharedPreferences = context.getSharedPreferences("base64", Context.MODE_PRIVATE); 
		
		ByteArrayOutputStream baos = new ByteArrayOutputStream();  
        ObjectOutputStream oos;
		try {
			oos = new ObjectOutputStream(baos);
			if( item != null ) {
		        oos.writeObject(item);  
			}
	        String personBase64 = new String(Base64.encode(baos.toByteArray(), Base64.DEFAULT));  
	        SharedPreferences.Editor editor = mSharedPreferences.edit();  
	        editor.putString("CrashParam", personBase64);  
	        editor.commit();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}  
	}
	
	/**
	 * 获取缓存
	 * @param context	上下文
	 * @return			
	 */
	public static CrashParam GetCrashParam(Context context) {
		CrashParam item = null;
		
        try {  
            SharedPreferences mSharedPreferences = context.getSharedPreferences("base64", Context.MODE_PRIVATE);  
            String personBase64 = mSharedPreferences.getString("CrashParam", "");  
            byte[] base64Bytes = Base64.decode(personBase64.getBytes(), Base64.DEFAULT);  
            ByteArrayInputStream bais = new ByteArrayInputStream(base64Bytes);  
            ObjectInputStream ois = new ObjectInputStream(bais);  
            item = (CrashParam) ois.readObject();  
        } catch (Exception e) {  
            e.printStackTrace();  
        }  
        
		return item;
	}
}
