package com.qpidnetwork.livemodule.liveshow.googleanalytics;

import java.util.ArrayList;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;

/**
 * 用于对Dialog进行ScreenName统计
 * @author Samson Fan
 *
 */
public class AnalyticsDialog extends Dialog 
							implements DialogInterface.OnShowListener
									, DialogInterface.OnDismissListener
{
	protected Context mContext = null;
	private ArrayList<String> mOldTagNames = null;
	private ArrayList<String> mThisTagNames = new ArrayList<String>();
	
	public AnalyticsDialog(Context context) {
		super(context);
		
		// 设置context
		mContext = context;
		
		// 设置回调
     	this.setOnDismissListener(this);
     	this.setOnShowListener(this);
	}
    
    public AnalyticsDialog(Context context, int theme) {
        super(context, theme);
        
        // 设置context
        mContext = context;
        
        // 设置回调
     	this.setOnDismissListener(this);
     	this.setOnShowListener(this);
    }
    
	@Override
	public void onShow(DialogInterface arg0) {
		// 获取当前的tag路径
		Activity activity = (Activity)mContext;
		mOldTagNames = AnalyticsManager.newInstance().GetCurrTagNamesIncludeID(activity);

		// 去掉最后一个路径
		if (null != mOldTagNames && mOldTagNames.size() > 1) 
		{
			mThisTagNames.addAll(mOldTagNames);
			mThisTagNames.remove(mThisTagNames.size()-1);
		}
		
		// tag路径加上自己
		String name = this.getClass().getName();
		mThisTagNames.add(name);
		
		// 设置进入新tag路径
		String[] tagNames = new String[mThisTagNames.size()];
		mThisTagNames.toArray(tagNames);
		AnalyticsManager.newInstance().ReportPageSelected(activity, tagNames);
	}

	@Override
	public void onDismiss(DialogInterface arg0) {
		// 恢复原来tag路径
		Activity activity = (Activity)mContext;
		String[] tagNames = new String[mOldTagNames.size()];
		mOldTagNames.toArray(tagNames);
		AnalyticsManager.newInstance().ReportPageSelected(activity, tagNames);
	}
}
