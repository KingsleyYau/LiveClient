package com.qpidnetwork.livemodule.liveshow;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.View;
import android.widget.ProgressBar;

import com.qpidnetwork.livemodule.R;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/12/28.
 */

public class LoadingDialog extends Dialog {

    private Context mContext;
    private View rootView;
    private ProgressBar pb_loading;

    public LoadingDialog(@NonNull Context context) {
        super(context, R.style.CustomTheme_LoadingDialog);
        mContext = context;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        rootView = View.inflate(mContext, R.layout.view_loading_dialog,null);
        setContentView(rootView);
        initView();
    }

    public void initView(){
        pb_loading = (ProgressBar) rootView.findViewById(R.id.pb_loading);
    }

}
