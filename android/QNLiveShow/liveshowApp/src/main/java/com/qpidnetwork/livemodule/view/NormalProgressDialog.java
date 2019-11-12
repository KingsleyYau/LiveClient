package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.view.BaseDialog;

public class NormalProgressDialog extends BaseDialog {
    private View contentView;
    private TextView message;
    private ProgressBar progress;

    public NormalProgressDialog(Context context) {
        super(context);
        // TODO Auto-generated constructor stub
        init(context);
    }

    public NormalProgressDialog(Context context , int theme) {
        super(context , theme);
        // TODO Auto-generated constructor stub
        init(context);
    }

    private void init(Context context){
        this.getWindow().setLayout(DisplayUtil.dip2px(context, 104), DisplayUtil.dip2px(context, 120));
        contentView  = LayoutInflater.from(context).inflate(R.layout.view_live_normal_progress_dialog, null);
        message = (TextView)contentView.findViewById(R.id.text1);
        progress = (ProgressBar)contentView.findViewById(R.id.progress);
        this.setContentView(contentView);
    }

    public TextView getMessage(){
        return message;
    }

    public void setMessage(CharSequence text){
        //edit by Jagger 2018-2-6 没文字就隐藏TextView
        if(TextUtils.isEmpty(text)){
            getMessage().setVisibility(View.GONE);
        }else{
            getMessage().setVisibility(View.VISIBLE);
            getMessage().setText(text);
        }
    }
}
