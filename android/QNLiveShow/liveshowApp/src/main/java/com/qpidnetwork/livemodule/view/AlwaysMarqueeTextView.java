package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewDebug;
import android.widget.TextView;

/**
 * 一直可获得焦点的TEXTVIEW
 * (走马灯专用)
 * @author Jagger
 * 2017-6-21
 */
public class AlwaysMarqueeTextView extends TextView {
	
	public AlwaysMarqueeTextView(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
	}
	
	public AlwaysMarqueeTextView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
	}
	
	public AlwaysMarqueeTextView(Context context, AttributeSet attrs,
                                 int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		// TODO Auto-generated constructor stub
	}

	@Override
	@ViewDebug.ExportedProperty(category = "focus")
	public boolean isFocused() {
		// TODO Auto-generated method stub
		return true;
	}
	
}
