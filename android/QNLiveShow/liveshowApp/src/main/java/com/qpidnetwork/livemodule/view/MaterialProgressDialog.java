package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.view.BaseDialog;

public class MaterialProgressDialog extends BaseDialog {
	
	
	private View contentView;
	private TextView message;
	private MaterialProgressBar progress;

	public MaterialProgressDialog(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
		init(context);
	}
	
	public MaterialProgressDialog(Context context , int theme) {
		super(context , theme);
		// TODO Auto-generated constructor stub
		init(context);
	}
	
	private void init(Context context){
		this.getWindow().setLayout(DisplayUtil.dip2px(context, 104), DisplayUtil.dip2px(context, 120));
		contentView  = LayoutInflater.from(context).inflate(R.layout.view_live_material_progress_dialog, null);
		message = (TextView)contentView.findViewById(R.id.text1);
		progress = (MaterialProgressBar)contentView.findViewById(R.id.progress);
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
	
	@Override public void show(){
		progress.requestLayout();
		if (!progress.isSpinning()){
			progress.spin();
		}
		super.show();
	}
	
	@Override public void dismiss(){
		progress.stopSpinning();
		super.dismiss();
	}

}
