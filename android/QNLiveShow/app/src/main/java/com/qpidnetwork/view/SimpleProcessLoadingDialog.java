package com.qpidnetwork.view;

import android.app.Dialog;
import android.content.Context;
import android.support.annotation.NonNull;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.liveshow.R;


/**
 * Description:
 * <p>
 * Created by Harry on 2017/5/24.
 */

public class SimpleProcessLoadingDialog extends Dialog {

    private Context mContext;
    private TextView tv_toast;

    public SimpleProcessLoadingDialog(@NonNull Context context){
        super(context, R.style.CustomTheme_SimpleDialog);
        this.mContext = context;
        View rootView = View.inflate(context,R.layout.view_simple_toast,null);
        tv_toast = (TextView)rootView.findViewById(R.id.tv_toast);
        setContentView(rootView);
    }

    public SimpleProcessLoadingDialog(@NonNull Context context, int toastStrId) {
        this(context);
        tv_toast.setText(context.getResources().getString(toastStrId));
    }

    public void show(int toastStrId){
        tv_toast.setText(mContext.getResources().getString(toastStrId));
        if(!isShowing()){
            show();
        }
    }

    public void show(String toastStr){
        tv_toast.setText(toastStr);
        if(!isShowing()){
            show();
        }
    }
}
