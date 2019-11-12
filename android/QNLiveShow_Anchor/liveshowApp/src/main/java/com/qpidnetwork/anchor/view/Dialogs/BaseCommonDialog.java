package com.qpidnetwork.anchor.view.Dialogs;

import android.content.Context;
import android.content.DialogInterface;
import android.support.annotation.LayoutRes;
import android.support.annotation.StyleRes;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.view.BaseSafeDialog;

/**
 * Created by Hardy on 2016/6/30.
 * 所有 dialog 的父类
 */
public abstract class BaseCommonDialog {

    // 一般样式的弹窗
    private final int NORMAL_STYLE = -1;

    protected Context mContext;
    private boolean cancelable = true;

    protected BaseSafeDialog dialog;

    public BaseCommonDialog(Context context, @LayoutRes int layoutId) {
        init(context, layoutId, NORMAL_STYLE);
    }

    public BaseCommonDialog(Context context, @LayoutRes int layoutId, @StyleRes int styleId) {
        init(context, layoutId, styleId);
    }

    private void init(Context context, @LayoutRes int layoutId, @StyleRes int styleId) {
        mContext = context;
        initOnDismissListener();

        View rootView = LayoutInflater.from(mContext).inflate(layoutId, null);
        //
        initView(rootView);

        if (styleId == NORMAL_STYLE) {
            dialog = new BaseSafeDialog(mContext, R.style.CustomTheme_SimpleDialog);     // 通用的 dialog 属性
        } else {
            dialog = new BaseSafeDialog(mContext, styleId);
        }
        dialog.setContentView(rootView);
        dialog.setCancelable(cancelable);
        dialog.setCanceledOnTouchOutside(cancelable);
        dialog.setOnDismissListener(onDismissListener);
        // anim
        if (getWindowAnimStyleRes() != -1) {
            dialog.getWindow().setWindowAnimations(getWindowAnimStyleRes());
        }
        // dialog 的 Attributes 属性，一定要设置在 setContentView() 方法之后，否则无效
        initDialogAttributes(getDialogParams());
    }

    /**
     * 初始化窗体里的子控件
     *
     * @param v
     */
    public abstract void initView(View v);

    /**
     * 设置窗口的宽高、位置等
     *
     * @param params
     */
    public abstract void initDialogAttributes(WindowManager.LayoutParams params);


    @StyleRes
    public int getWindowAnimStyleRes() {
        return -1;
    }

    public void setDialogCancelable(boolean cancelable) {
        if (dialog != null) {
            this.cancelable = cancelable;

            dialog.setCancelable(cancelable);
            dialog.setCanceledOnTouchOutside(cancelable);
        }
    }

    public void setDialogParams(WindowManager.LayoutParams params) {
        if (dialog != null) {
            dialog.getWindow().setAttributes(params);
        }
    }

    public WindowManager.LayoutParams getDialogParams() {
        if (dialog != null) {
            return dialog.getWindow().getAttributes();
        }
        return new WindowManager.LayoutParams();
    }


    public void show() {
        if (dialog != null && !dialog.isShowing()) {
            dialog.show();
        }
    }

    public void dismiss() {
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
        }
    }

    public boolean isShowing(){
        boolean isShowing = false;
        if(dialog != null){
            isShowing = dialog.isShowing();
        }
        return isShowing;
    }

    public void destroy() {
        dismiss();

        dialog = null;
        onDismissListener = null;
        mContext = null;
    }

    public int getDialogNormalWidth() {
//        return (int) (DisplayUtil.getScreenWidth(mContext) / 4 * 3.2);
        return DisplayUtil.getScreenWidth(mContext) -
                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_20dp) * 2;      // 左右边距
    }


    private DialogInterface.OnDismissListener onDismissListener;

    private void initOnDismissListener() {
        onDismissListener = new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {
                onDlgDismiss();
            }
        };
    }


    public void onDlgDismiss() {
    }


    public void changeNight(boolean isNight) {

    }
}
