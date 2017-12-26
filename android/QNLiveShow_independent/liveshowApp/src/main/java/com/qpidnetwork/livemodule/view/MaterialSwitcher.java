package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;

public class MaterialSwitcher extends LinearLayout implements OnClickListener{

	private boolean checked = false;
	private Context context;
	
	private ImageView icon;
	private TextView textView;
	
	public MaterialSwitcher(Context context){
		this(context, null);
	}
	
	public MaterialSwitcher(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
		
		this.context = context;
		this.addView(getView());
		this.setClickable(true);
		this.setOnClickListener(this);
	}
	
	
	private View getView(){
		View view = LayoutInflater.from(context).inflate(R.layout.view_live_material_switcher, null);
		icon = (ImageView)view.findViewById(R.id.icon);
		textView = (TextView)view.findViewById(R.id.textView);
		return view;
	}
	
	public void setChecked( boolean checked ){
		this.checked = checked;
		if (this.checked){
			icon.setImageResource(R.drawable.ic_check_box_green009688_24dp);
		}else{
			icon.setImageResource(R.drawable.ic_check_box_outline_blank_grey600_24dp);
		}
	}
	
	public boolean getChecked(){
		return this.checked;
	}
	
	public void setText(CharSequence text){
		getTextView().setText(text);
	}
	
	public TextView getTextView(){
		return this.textView;
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		setChecked(!this.checked);
	}
	
	

}
