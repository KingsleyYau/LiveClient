package com.dou361.dialogui.config;

import android.support.annotation.ColorRes;

import com.dou361.dialogui.R;

/**
 * ========================================
 * <p/>
 * 版 权：dou361.com 版权所有 （C） 2015
 * <p/>
 * 作 者：陈冠明
 * <p/>
 * 个人网站：http://www.dou361.com
 * <p/>
 * 版 本：1.0
 * <p/>
 * 创建日期：2016/11/1 15:13
 * <p/>
 * 描 述：公共配置
 * <p/>
 * <p/>
 * 修订历史：
 * <p/>
 * ========================================
 */
public class DialogConfig {

    @ColorRes
    public static int iosBtnColor = R.color.ios_btntext_blue;
    @ColorRes
    public static int lvItemTxtColor = R.color.text_item_33;
    @ColorRes
    public static int mdBtnColor = R.color.btn_alert;
    @ColorRes
    public static int titleTxtColor = R.color.text_title_11;
    @ColorRes
    public static int msgTxtColor = R.color.text_title_11;
    @ColorRes
    public static int inputTxtColor = R.color.text_input_44;


    public static CharSequence dialogui_btnTxt1 = "确定";
    public static CharSequence dialogui_btnTxt2 = "取消";
    public static CharSequence dialogui_bottomTxt = "取消";


    public static final int TYPE_LOADING = 1;
    public static final int TYPE_MD_LOADING = 2;
    public static final int TYPE_MD_ALERT = 3;
    public static final int TYPE_MD_MULTI_CHOOSE = 4;
    public static final int TYPE_SINGLE_CHOOSE = 5;
    public static final int TYPE_ALERT = 6;
    public static final int TYPE_SHEET = 10;
    public static final int TYPE_BOTTOM_SHEET = 14;
    public static final int TYPE_CUSTOM_ALERT = 15;
    public static final int TYPE_CUSTOM_BOTTOM_ALERT = 16;
    public static final int TYPE_DATEPICK = 19;


}
