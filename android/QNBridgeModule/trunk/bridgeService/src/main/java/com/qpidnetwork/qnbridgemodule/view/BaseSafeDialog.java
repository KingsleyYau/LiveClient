package com.qpidnetwork.qnbridgemodule.view;

import android.app.Dialog;
import android.content.Context;

import com.qpidnetwork.qnbridgemodule.util.UIUtils;


/**
 * Created by Hardy on 2016/5/30.
 * <p/>
 * 安全退出的 dialog，判断依赖的 Act 是否还存在，在决定是否 dismiss 或者 show
 */
public class BaseSafeDialog extends Dialog {

    private Context mActivity;

    public BaseSafeDialog(Context context) {
        super(context);
        mActivity = context;
    }

    public BaseSafeDialog(Context context, int themeResId) {
        super(context, themeResId);
        mActivity = context;
    }

    @Override
    public void dismiss() {
        if (!UIUtils.isActExist(mActivity)) {
            return;
        }

        try {
            super.dismiss();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void show() {
        if (!UIUtils.isActExist(mActivity)) {
            return;
        }

        try {
            super.show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
