package com.dou361.dialogui.listener;

import android.app.Activity;
import android.content.Context;
import android.view.View;

import com.dou361.dialogui.bean.BuildBean;
import com.dou361.dialogui.bean.TieBean;

import java.util.List;

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
 * 创建日期：2016/11/1 15:08
 * <p/>
 * 描 述：构建弹出框样式方法
 * <p/>
 * <p/>
 * 修订历史：
 * <p/>
 * ========================================
 */
public interface Assignable {

    /**
     * 日期选择器
     */
    BuildBean assignDatePick(Context context, int gravity, String dateTitle, long date, int dateType, int tag, DialogUIDateTimeSaveListener listener);

    /**
     * 加载框
     */
    BuildBean assignLoading(Context context, CharSequence msg,boolean isVertical, boolean cancleable, boolean outsideTouchable, boolean isWhiteBg);

     /**
     * Md加载框
     */
    BuildBean assignMdLoading(Context context, CharSequence msg,boolean isVertical, boolean cancleable, boolean outsideTouchable, boolean isWhiteBg);

    /**
     * md风格弹出框
     */
    BuildBean assignMdAlert(Activity activity, CharSequence title, CharSequence msg, boolean cancleable, boolean outsideTouchable, final DialogUIListener listener);

    /**
     * md风格弹出框
     */
    BuildBean assignMdAlert(Activity activity, CharSequence title, CharSequence msg, CharSequence firstTxt, CharSequence secondTxt, boolean cancelable, boolean outsideTouchable, final DialogUIListener listener);

    /**
     * md风格多选框
     */
    BuildBean assignMdMultiChoose(Activity context, CharSequence title, final CharSequence[] words, final boolean[] checkedItems, boolean cancleable, boolean outsideTouchable,
                                  final DialogUIListener btnListener);

    /**
     * 单选框
     */
    BuildBean assignSingleChoose(Activity context, CharSequence title, final int defaultChosen, final CharSequence[] words, boolean cancleable, boolean outsideTouchable,
                                 final DialogUIItemListener listener);

    /**
     * 提示弹出框
     */
    BuildBean assignAlert(Context activity, CharSequence title, CharSequence msg, CharSequence hint1, CharSequence hint2,
                          CharSequence firstTxt, CharSequence secondTxt, boolean isVertical, boolean cancleable, boolean outsideTouchable, final DialogUIListener listener);

    /**
     * 提示弹出框
     */
    BuildBean assignAlert(Context activity, CharSequence title, CharSequence msg,
                          CharSequence hint1, CharSequence hint2,
                          CharSequence firstTxt, CharSequence secondTxt,
                          int firstTxtColorResId,int secondTxtColorResId,
                          boolean isVertical, boolean cancleable, boolean outsideTouchable, final DialogUIListener listener);

    /**
     * 中间弹出列表
     */
    BuildBean assignSheet(Context context, CharSequence titleTxt, List<TieBean> datas, CharSequence bottomTxt, int gravity, boolean cancleable, boolean outsideTouchable, final DialogUIItemListener listener);

    /**
     * md风格弹出列表
     */
    BuildBean assignMdBottomSheet(Context context, boolean isVertical, CharSequence title, List<TieBean> datas,int columnsNum, boolean cancleable, boolean outsideTouchable, DialogUIItemListener listener);

    /**
     * 自定义弹出框
     */
    BuildBean assignCustomAlert(Context context, View contentView, CharSequence firstTxt, CharSequence secondTxt, int gravity, boolean cancleable, boolean outsideTouchable, DialogUIListener btnListener);

    /**
     * 自定义弹出框
     */
    BuildBean assignCustomAlert(Context context, View contentView, CharSequence firstTxt, CharSequence secondTxt, int gravity, boolean cancleable, boolean outsideTouchable, boolean isBgTransparent, DialogUIListener btnListener);


    /**
     * 自定义底部弹出框
     */
    BuildBean assignCustomBottomAlert(Context context, View contentView, boolean cancleable, boolean outsideTouchable);


}
