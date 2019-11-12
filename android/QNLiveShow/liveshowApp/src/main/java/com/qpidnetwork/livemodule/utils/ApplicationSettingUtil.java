package com.qpidnetwork.livemodule.utils;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;

import java.text.DecimalFormat;
import java.util.Locale;

/**
 * 应用程序相关设置工具
 * Created by Hunter Mun on 2017/5/26.
 */

public class ApplicationSettingUtil {

    /**
     * 是否Demo环境
     * @param context
     * @return
     */
    public static boolean isDemoEnviroment(Context context){
        boolean isDemo = true;
        try {
            PackageInfo pInfo;
            pInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
            isDemo = pInfo.versionName.matches(".*[a-zA-Z].*");
        } catch (PackageManager.NameNotFoundException e1) {

        }
        return isDemo;
    }

    /**
     * 获取默认国家code选项（格式 country（countrycode））
     * @return
     */
    public static String getDefaultCountryCode(Context context){
        LocalPreferenceManager preManager = new LocalPreferenceManager(context);
        String defaultCountryCode = preManager.getDefaultCountryCode();
        if(TextUtils.isEmpty(defaultCountryCode)){
            //为空 则依据当前的Local设置来填充
            String localCountryName = Locale.getDefault().getDisplayName(new Locale("EN"));
            String[] allCountryCodes = context.getResources().getStringArray(R.array.allCountryCodes);
            for(String indexCountryCode : allCountryCodes){
                if(indexCountryCode.startsWith(localCountryName)){
                    defaultCountryCode = indexCountryCode;
                    preManager.saveDefaultCountryCode(defaultCountryCode);
                    break;
                }
            }
        }
        return defaultCountryCode;
    }

    /**
     * 全局格式化金币值的显示方式
     * @param coinsValue
     * @return
     */
    public static String formatCoinValue(double coinsValue){

//        NumberFormat nf = NumberFormat.getNumberInstance();
//        nf.setGroupingUsed(false);
//        String c = nf.format(coinsValue);

        // 2019/10/9 Hardy
        if (coinsValue < 0) {
            coinsValue = 0;
        }

        //edit by Jagger 2019-9-16 保留小数点前1位和后两位 BUG#20749
        DecimalFormat df = new DecimalFormat("0.00");
        String c = df.format(coinsValue);

        return c;
    }
}
