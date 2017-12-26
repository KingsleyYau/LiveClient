package com.qpidnetwork.livemodule.view;

import java.util.ArrayList;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.ColorDrawable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.Log;

public class MaterialDropDownMenu {

	
	
	private PopupWindow mPopupWindow;
	private Context mContext;
	private OnClickCallback mCallback;
	private String[] mMenuItems;
	private ListView listView;
	private ListAdapter mAdpt;
	
	
	public MaterialDropDownMenu(Context context, ListAdapter adpt, OnClickCallback callback, Point size){
		mAdpt = adpt;
		initialize(context, callback, size);
	}
	

	public MaterialDropDownMenu(Context context, String[] menuItems, OnClickCallback callback, Point size){
		mMenuItems = menuItems;
		initialize(context, callback, size);
	}
	
	
	
	private void initialize(Context context, OnClickCallback callback, Point size){
		mContext = context;
		mCallback = callback;
		mPopupWindow = new PopupWindow(createContentView(), size.x, size.y, true);
		mPopupWindow.setTouchable(true);
		mPopupWindow.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT)); 
	}
	
	
	private View createContentView(){
		

		
		View v = LayoutInflater.from(mContext).inflate(R.layout.view_live_material_popup_menu, null);
		listView = (ListView)v.findViewById(R.id.listView);
        
        listView.setOnItemClickListener(new OnItemClickListener(){

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				// TODO Auto-generated method stub
				mPopupWindow.dismiss();
				Log.v("listview", "click");
				if (mCallback != null) mCallback.onClick(arg0, arg1, arg2);
			}
        	
        });
        
        if (mAdpt != null){
        	listView.setAdapter(mAdpt);
        }else if(mMenuItems != null){
        	listView.setAdapter(new ThisAdapter(mContext, mMenuItems));
        }
        
        return v;
		
	}
	
	
	public void setMenuItems(String[] items){
		mMenuItems = items;
		listView.setAdapter(new ThisAdapter(mContext, mMenuItems));
		
	}
	
	public void showAsDropDown(View anchor){
		
		
		mPopupWindow.showAsDropDown(anchor, 0, (int)(-42.0f * mContext.getResources().getDisplayMetrics().density));;
	}

    public interface OnClickCallback{
    	public void onClick(AdapterView<?> adptView, View v, int which);
    }
    
    
    
    
    class ThisAdapter extends ArrayAdapter<ArrayList<String>>{

    	private String[] mListData;
    	private Context mContext;
    	private ArrayList<View> views;
    	

    	public ThisAdapter(Context context, String[] objects) {
    		super(context, 0);
    		mListData = objects;
    		mContext = context;
    		views = new ArrayList<View>();
    	}


    	@Override
    	public int getCount() {
    		// TODO Auto-generated method stub
    		return mListData.length;
    	}



    	@Override
    	public long getItemId(int position) {
    		// TODO Auto-generated method stub
    		return 0;
    	}

    	@Override
    	public View getView(int position, View convertView, ViewGroup parent) {
    		// TODO Auto-generated method stub
    		
    		if (position + 1 <= views.size()){
    			return views.get(position);
    		}
    		
    		float density = mContext.getResources().getDisplayMetrics().density;
    		int item_height = (int)(48.0f * density);
    		int padding = (int)(24.0f * density);

    		
    		AbsListView.LayoutParams params = new AbsListView.LayoutParams(LayoutParams.MATCH_PARENT, item_height);
    		LinearLayout item = new LinearLayout(mContext);
    		item.setPadding(padding, 0, padding, 0);
    		item.setOrientation(LinearLayout.HORIZONTAL);
    		item.setLayoutParams(params);
    		item.setClickable(false);
    		item.setGravity(Gravity.CENTER);
    		
    		
    		TextView text = new TextView(mContext);
    		LayoutParams tp = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
    		tp.gravity = Gravity.CENTER;
    		text.setTextSize(18);
    		text.setTextColor(mContext.getResources().getColor(R.color.text_color_dark));
    		text.setLayoutParams(tp);
    		text.setId(android.R.id.text1);
    		text.setText(mListData[position]);
    		text.setGravity(Gravity.CENTER);
    		text.setClickable(false);
    		
    		item.addView(text);
    		
    		views.add(item);
    		
    		return item;
    	
    	
    	}
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    }
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
