package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;
import android.util.Base64;

import com.qpidnetwork.livemodule.httprequest.item.LSProfileItem;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

/**
 * MyProfile模块
 *
 * @author Max.Chiu
 */
public class MyProfilePerfenceLive {

    private static final String KEY = "LSProfileItem";

    /**
     * 2018/10/31
     * 清理本地用户信息
     *
     * @param context
     */
    public static void clearProfileItem(Context context) {
        SharedPreferences mSharedPreferences = context.getSharedPreferences("base64", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = mSharedPreferences.edit();
        editor.putString(KEY, "");
        editor.commit();
    }

    /**
     * 缓存个人资料
     *
     * @param context 上下文
     * @param item    个人资料
     */
//	public static void SaveProfileItem(Context context, ProfileItem item) {
    public static void SaveProfileItem(Context context, LSProfileItem item) {
        SharedPreferences mSharedPreferences = context.getSharedPreferences("base64", Context.MODE_PRIVATE);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ObjectOutputStream oos = null;
        try {
            oos = new ObjectOutputStream(baos);
            if (item != null)
                oos.writeObject(item);
            else {

            }
            String personBase64 = new String(Base64.encode(baos.toByteArray(), Base64.DEFAULT));
            SharedPreferences.Editor editor = mSharedPreferences.edit();
            editor.putString(KEY, personBase64);
            editor.commit();
        } catch (IOException e) {
            e.printStackTrace();
        }
        // 2018/11/10 Hardy
        finally {
            try {
                if (baos != null) {
                    baos.close();
                }
                if (oos != null) {
                    oos.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * 获取缓存个人资料
     *
     * @param context 上下文
     * @return 个人资料
     */
    public static LSProfileItem GetProfileItem(Context context) {
        LSProfileItem item = null;

        ByteArrayInputStream bais = null;
        ObjectInputStream ois = null;
        try {
            SharedPreferences mSharedPreferences = context.getSharedPreferences("base64", Context.MODE_PRIVATE);
            String personBase64 = mSharedPreferences.getString(KEY, "");
            byte[] base64Bytes = Base64.decode(personBase64.getBytes(), Base64.DEFAULT);

            // 2018/11/10 Hardy
            if (TextUtils.isEmpty(personBase64)) {
                return null;
            }

            bais = new ByteArrayInputStream(base64Bytes);
            ois = new ObjectInputStream(bais);

            item = (LSProfileItem) ois.readObject();
        } catch (Exception e) {
            e.printStackTrace();
        }
        // 2018/11/10 Hardy
        finally {
            try {
                if (bais != null) {
                    bais.close();
                }
                if (ois != null) {
                    ois.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return item;
    }

//	/**
//	 * 缓存信用点
//	 * @param context	上下文
//	 * @param item		个人资料
//	 */
//	public static void SaveOtherGetCountItem(Context context, OtherGetCountItem item) {
//		SharedPreferences mSharedPreferences = context.getSharedPreferences("base64", Context.MODE_PRIVATE);
//
//		ByteArrayOutputStream baos = new ByteArrayOutputStream();
//        ObjectOutputStream oos;
//		try {
//			oos = new ObjectOutputStream(baos);
//			if( item != null )
//				oos.writeObject(item);
//	        String personBase64 = new String(Base64.encode(baos.toByteArray(), Base64.DEFAULT));
//	        SharedPreferences.Editor editor = mSharedPreferences.edit();
//	        editor.putString("OtherGetCountItem", personBase64);
//	        editor.commit();
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//	}
//
//	/**
//	 * 获取缓存信用点
//	 * @param context	上下文
//	 * @return			个人资料
//	 */
//	public static OtherGetCountItem GetOtherGetCountItem(Context context) {
//		OtherGetCountItem item = null;
//
//        try {
//            SharedPreferences mSharedPreferences = context.getSharedPreferences("base64", Context.MODE_PRIVATE);
//            String personBase64 = mSharedPreferences.getString("OtherGetCountItem", "");
//            byte[] base64Bytes = Base64.decode(personBase64.getBytes(), Base64.DEFAULT);
//            ByteArrayInputStream bais = new ByteArrayInputStream(base64Bytes);
//            ObjectInputStream ois = new ObjectInputStream(bais);
//            item = (OtherGetCountItem) ois.readObject();
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//
//		return item;
//	}
//
//	/**
//	 * 缓存匹配女士条件
//	 * @param context		上下文
//	 * @param item			匹配女士item
//	 */
//	public static void SaveLadyMatch(Context context, LadyMatch item) {
//		SharedPreferences mSharedPreferences = context.getSharedPreferences("base64", Context.MODE_PRIVATE);
//
//		ByteArrayOutputStream baos = new ByteArrayOutputStream();
//        ObjectOutputStream oos;
//		try {
//			oos = new ObjectOutputStream(baos);
//			if( item != null )
//				oos.writeObject(item);
//	        String personBase64 = new String(Base64.encode(baos.toByteArray(), Base64.DEFAULT));
//	        SharedPreferences.Editor editor = mSharedPreferences.edit();
//	        editor.putString("LadyMatch", personBase64);
//	        editor.commit();
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//	}
//
//	/**
//	 * 获取缓存女士匹配条件
//	 * @param context		上下文
//	 * @return				匹配女士item
//	 */
//	public static LadyMatch GetLadyMatch(Context context) {
////		LadyMatch item = new LadyMatch();
//		LadyMatch item = null;
//
//        try {
//            SharedPreferences mSharedPreferences = context.getSharedPreferences("base64", Context.MODE_PRIVATE);
//            String personBase64 = mSharedPreferences.getString("LadyMatch", "");
//            byte[] base64Bytes = Base64.decode(personBase64.getBytes(), Base64.DEFAULT);
//            ByteArrayInputStream bais = new ByteArrayInputStream(base64Bytes);
//            ObjectInputStream ois = new ObjectInputStream(bais);
//            item = (LadyMatch) ois.readObject();
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//
//        if( item == null ) {
//        	item = new LadyMatch();
//        }
//
//		return item;
//	}
}
