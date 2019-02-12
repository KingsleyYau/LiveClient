package com.qpidnetwork.livemodule.liveshow.liveroom.announcement;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;


/**
 * Description:
 * <p>
 * Created by Harry on 2017/12/7.
 */

public class WarningDialog extends Dialog implements View.OnClickListener {

    private final String TAG = WarningDialog.class.getSimpleName();
    private Context mContext;
    private View rootView;
    private TextView tv_OK;
    private TextView tv_warningContent;

    public WarningDialog(Context context) {
        super(context, R.style.CustomTheme_SimpleDialog);
        Log.d(TAG, "WarningDialog");
        this.mContext = context;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.rootView = View.inflate(mContext, R.layout.view_warning_dialog, null);
        setContentView(rootView);
        initView();
        getWindow().setLayout(WindowManager.LayoutParams.MATCH_PARENT,WindowManager.LayoutParams.WRAP_CONTENT);
        setCanceledOnTouchOutside(false);
        setCancelable(true);
    }

    private void initView(){
        tv_OK = (TextView) rootView.findViewById(R.id.tv_OK);
        tv_OK.setOnClickListener(this);
        tv_warningContent = (TextView) rootView.findViewById(R.id.tv_warningContent);
    }

    /**
     *
     * @param warnContent
     */
    public void show(String warnContent) {
        super.show();
        tv_warningContent.setText(warnContent);
    }

    @Override
    public void onClick(View v) {
        int viewId = v.getId();
        if(viewId == R.id.tv_OK){
            dismiss();
        }
    }
}
