package com.dou361.dialogui.listener;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;

import com.dou361.dialogui.bean.BuildBean;
import com.dou361.dialogui.bean.TieBean;
import com.dou361.dialogui.config.DialogConfig;

import java.util.List;

/**
 * Created by Administrator on 2016/10/9 0009.
 */
public class DialogAssigner implements Assignable {

    private static DialogAssigner instance;

    private DialogAssigner() {

    }

    public static DialogAssigner getInstance() {
        if (instance == null) {
            instance = new DialogAssigner();
        }
        return instance;
    }


    @Override
    public BuildBean assignDatePick(Context context,int gravity, String dateTitle, long date, int dateType, int tag, DialogUIDateTimeSaveListener listener) {
        BuildBean bean = new BuildBean();
        bean.mContext = context;
        bean.dateTitle = dateTitle;
        bean.gravity = gravity;
        bean.cancelable = true;
        bean.outsideTouchable = true;
        bean.type = DialogConfig.TYPE_DATEPICK;
        bean.dateTimeListener = listener;
        bean.dateType = dateType;
        bean.date = date;
        bean.tag = tag;
        return bean;
    }

    @Override
    public BuildBean assignLoading(Context context, CharSequence msg,boolean isVertical, boolean cancleable, boolean outsideTouchable, boolean isWhiteBg) {
        BuildBean bean = new BuildBean();
        bean.mContext = context;
        bean.msg = msg;
        bean.isVertical = isVertical;
        bean.isWhiteBg = isWhiteBg;
        bean.gravity = Gravity.CENTER;
        bean.cancelable = cancleable;
        bean.outsideTouchable = outsideTouchable;
        bean.type = DialogConfig.TYPE_LOADING;
        return bean;
    }

    @Override
    public BuildBean assignMdLoading(Context context, CharSequence msg,boolean isVertical, boolean cancleable, boolean outsideTouchable, boolean isWhiteBg) {
        BuildBean bean = new BuildBean();
        bean.mContext = context;
        bean.msg = msg;
        bean.isVertical = isVertical;
        bean.isWhiteBg = isWhiteBg;
        bean.gravity = Gravity.CENTER;
        bean.cancelable = cancleable;
        bean.outsideTouchable = outsideTouchable;
        bean.type = DialogConfig.TYPE_MD_LOADING;
        return bean;
    }

    @Override
    public BuildBean assignMdAlert(Activity activity, CharSequence title, CharSequence msg, boolean cancleable, boolean outsideTouchable, DialogUIListener listener) {
        BuildBean bean = new BuildBean();
        bean.mContext = activity;
        bean.msg = msg;
        bean.title = title;
        bean.gravity = Gravity.CENTER;
        bean.cancelable = cancleable;
        bean.outsideTouchable = outsideTouchable;
        bean.listener = listener;
        bean.type = DialogConfig.TYPE_MD_ALERT;
        bean.btn1Color = DialogConfig.mdBtnColor;
        bean.btn2Color = DialogConfig.mdBtnColor;
        bean.btn3Color = DialogConfig.mdBtnColor;
        return bean;
    }

    @Override
    public BuildBean assignMdAlert(Activity activity, CharSequence title, CharSequence msg, CharSequence firstTxt, CharSequence secondTxt,  boolean cancelable, boolean outsideTouchable, DialogUIListener listener) {
        BuildBean bean = new BuildBean();
        bean.mContext = activity;
        bean.msg = msg;
        bean.title = title;
        bean.gravity = Gravity.CENTER;
        bean.cancelable = cancelable;
        bean.outsideTouchable = outsideTouchable;
        bean.listener = listener;
        bean.type = DialogConfig.TYPE_MD_ALERT;
        bean.text1 = firstTxt;
        bean.text2 = secondTxt;
        bean.btn1Color = DialogConfig.mdBtnColor;
        bean.btn2Color = DialogConfig.mdBtnColor;
        bean.btn3Color = DialogConfig.mdBtnColor;
        return bean;
    }

    @Override
    public BuildBean assignSingleChoose(Activity context, CharSequence title, int defaultChosen, CharSequence[] words, boolean cancleable, boolean outsideTouchable, DialogUIItemListener listener) {
        BuildBean bean = new BuildBean();
        bean.mContext = context;
        bean.title = title;
        bean.gravity = Gravity.CENTER;
        bean.cancelable = cancleable;
        bean.outsideTouchable = outsideTouchable;
        bean.itemListener = listener;
        bean.wordsMd = words;
        bean.type = DialogConfig.TYPE_SINGLE_CHOOSE;
        bean.defaultChosen = defaultChosen;
        bean.btn1Color = DialogConfig.mdBtnColor;
        bean.btn2Color = DialogConfig.mdBtnColor;
        bean.btn3Color = DialogConfig.mdBtnColor;
        return bean;
    }

    @Override
    public BuildBean assignMdMultiChoose(Activity context, CharSequence title, CharSequence[] words, boolean[] checkedItems, boolean cancleable, boolean outsideTouchable, DialogUIListener btnListener) {
        BuildBean bean = new BuildBean();
        bean.mContext = context;
        bean.msg = title;
        bean.title = title;
        bean.gravity = Gravity.CENTER;
        bean.cancelable = cancleable;
        bean.outsideTouchable = outsideTouchable;
        bean.listener = btnListener;
        bean.wordsMd = words;
        bean.checkedItems = checkedItems;
        bean.type = DialogConfig.TYPE_MD_MULTI_CHOOSE;
        bean.btn1Color = DialogConfig.mdBtnColor;
        bean.btn2Color = DialogConfig.mdBtnColor;
        bean.btn3Color = DialogConfig.mdBtnColor;
        return bean;
    }

    @Override
    public BuildBean assignAlert(Context activity, CharSequence title, CharSequence msg, CharSequence hint1, CharSequence hint2,
                                 CharSequence firstTxt, CharSequence secondTxt, boolean isVertical, boolean cancleable, boolean outsideTouchable, DialogUIListener listener) {
        BuildBean bean = new BuildBean();
        bean.mContext = activity;
        bean.msg = msg;
        bean.title = title;
        bean.hint1 = hint1;
        bean.hint2 = hint2;
        bean.text1 = firstTxt;
        bean.text2 = secondTxt;
        bean.isVertical = isVertical;
        bean.gravity = Gravity.CENTER;
        bean.cancelable = cancleable;
        bean.outsideTouchable = outsideTouchable;
        bean.listener = listener;
        bean.type = DialogConfig.TYPE_ALERT;
        return bean;
    }

    @Override
    public BuildBean assignAlert(Context activity, CharSequence title, CharSequence msg,
                                 CharSequence hint1, CharSequence hint2,
                                 CharSequence firstTxt, CharSequence secondTxt, int firstTxtColorResId, int secondTxtColorResId,
                                 boolean isVertical, boolean cancleable, boolean outsideTouchable, DialogUIListener listener) {
        BuildBean bean = new BuildBean();
        bean.mContext = activity;
        bean.msg = msg;
        bean.title = title;
        bean.hint1 = hint1;
        bean.hint2 = hint2;
        bean.text1 = firstTxt;
        bean.text2 = secondTxt;
        if(firstTxtColorResId > 0){
            bean.btn1Color = firstTxtColorResId;
        }

        if(secondTxtColorResId > 0){
            bean.btn2Color = secondTxtColorResId;
        }

        bean.isVertical = isVertical;
        bean.gravity = Gravity.CENTER;
        bean.cancelable = cancleable;
        bean.outsideTouchable = outsideTouchable;
        bean.listener = listener;
        bean.type = DialogConfig.TYPE_ALERT;
        return bean;
    }


    @Override
    public BuildBean assignCustomAlert(Context context, View contentView, CharSequence firstTxt, CharSequence secondTxt,
                                       int gravity, boolean cancleable, boolean outsideTouchable, DialogUIListener btnListener) {
        BuildBean bean = new BuildBean();
        bean.mContext = context;
        bean.customView = contentView;
        bean.gravity = gravity;
        bean.cancelable = cancleable;
        bean.outsideTouchable = outsideTouchable;
        bean.type = DialogConfig.TYPE_CUSTOM_ALERT;
        bean.text1 = firstTxt;
        bean.text2 = secondTxt;
        //只显示一个按钮时，设置按钮排版是垂直，按钮才会两边都圆角
        if(TextUtils.isEmpty(secondTxt)){
            bean.isVertical = true;
        }
        bean.listener = btnListener;
        return bean;
    }

    @Override
    public BuildBean assignCustomAlert(Context context, View contentView, CharSequence firstTxt, CharSequence secondTxt,
                                       int gravity, boolean cancleable, boolean outsideTouchable, boolean isBgTransparent, DialogUIListener btnListener) {
        BuildBean bean = new BuildBean();
        bean.mContext = context;
        bean.customView = contentView;
        bean.gravity = gravity;
        bean.cancelable = cancleable;
        bean.outsideTouchable = outsideTouchable;
        bean.type = DialogConfig.TYPE_CUSTOM_ALERT;
        bean.text1 = firstTxt;
        bean.text2 = secondTxt;
        //只显示一个按钮时，设置按钮排版是垂直，按钮才会两边都圆角
        if(TextUtils.isEmpty(secondTxt)){
            bean.isVertical = true;
        }
        bean.isBgTransparent = isBgTransparent;
        bean.listener = btnListener;
        return bean;
    }

    @Override
    public BuildBean assignCustomBottomAlert(Context context, View contentView, boolean cancleable, boolean outsideTouchable) {
        BuildBean bean = new BuildBean();
        bean.mContext = context;
        bean.customView = contentView;
        bean.gravity = Gravity.BOTTOM;
        bean.cancelable = cancleable;
        bean.outsideTouchable = outsideTouchable;
        bean.type = DialogConfig.TYPE_CUSTOM_BOTTOM_ALERT;
        return bean;
    }


    @Override
    public BuildBean assignSheet(Context context, CharSequence titleTxt, List<TieBean> datas,CharSequence bottomTxt,int gravity, boolean cancleable, boolean outsideTouchable, DialogUIItemListener listener) {
        BuildBean bean = new BuildBean();
        bean.mContext = context;
        bean.itemListener = listener;
        bean.mLists = datas;
        bean.bottomTxt = bottomTxt;
        bean.gravity = gravity;
        bean.isVertical = true;
        bean.cancelable = cancleable;
        bean.outsideTouchable = outsideTouchable;
        bean.type = DialogConfig.TYPE_SHEET;
        bean.title = titleTxt;

        return bean;
    }

    @Override
    public BuildBean assignMdBottomSheet(Context context,boolean isVertical, CharSequence title, List<TieBean> datas, int columnsNum, boolean cancleable, boolean outsideTouchable, DialogUIItemListener listener) {
        BuildBean bean = new BuildBean();
        bean.mContext = context;
        bean.title = title;
        bean.isVertical = isVertical;
        bean.mLists = datas;
        bean.bottomTxt = "";
        bean.gravity = Gravity.BOTTOM;
        bean.cancelable = cancleable;
        bean.outsideTouchable = outsideTouchable;
        bean.itemListener = listener;
        bean.gridColumns = columnsNum;
        bean.type = DialogConfig.TYPE_BOTTOM_SHEET;
        return bean;
    }


}
