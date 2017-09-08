package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseDialog;
import com.qpidnetwork.livemodule.utils.DisplayUtil;

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
		contentView  = LayoutInflater.from(context).inflate(R.layout.view_material_progress_dialog, null);
		message = (TextView)contentView.findViewById(R.id.text1);
		progress = (MaterialProgressBar)contentView.findViewById(R.id.progress);
        this.setContentView(contentView);
	}
	
	public TextView getMessage(){
		return message;
	}
	
	public void setMessage(CharSequence text){
		getMessage().setText(text);
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
