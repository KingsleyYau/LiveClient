package com.qpidnetwork.livemodule.view.wrap;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.AttributeSet;
import android.view.View;
import android.widget.AdapterView;
import android.widget.RelativeLayout;

/**
 * 标签控件
 * @author ?
 * 于2017-6-15被Jagger修改
 * 问题:当进入个人信息界面,兴趣为空时;选择兴趣(1~2)个,返回个人信息界面,但没看到被选择的兴趣;
 * 原因:控件高度计算结果为0
 */
public class WrapListView extends RelativeLayout {

	private WrapBaseAdapter myCustomAdapter;
	private static boolean addChildType;
	private int dividerHeight = 0;
	private int dividerWidth = 0;
    
	private final Handler handler = new Handler(Looper.getMainLooper()) {
		public void handleMessage(Message msg) {
			super.handleMessage(msg);
			try {
				if (msg.getData().containsKey("getRefreshThreadHandler")) {
					WrapListView.setAddChildType(false);
					WrapListView.this.myCustomAdapter
							.notifyCustomListView(WrapListView.this);
				}
			} catch (Exception e) {

			}
		}
	};

	public WrapListView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	protected void onLayout(boolean arg0, int argLeft, int argTop,
			int argRight, int argBottom) {
		//del by Jagger 2017-6-15
//		int count = getChildCount();
////		int row = 0;
//		int lengthX = 0;
//		int lengthY = 0;
//		for (int i = 0; i < count; ++i) {
//			View child = getChildAt(i);
//			int width = child.getMeasuredWidth();
//			int height = child.getMeasuredHeight();
//
//			if (lengthX == 0)
//				lengthX += width;
//			else {
//				lengthX += width + getDividerWidth();
//			}
//
//			if ((i == 0) && (lengthX <= argRight)) {
//				lengthY += height;
//			}
//
//			if (lengthX > argRight) {
//				lengthX = width;
//				lengthY += getDividerHeight() + height;
////				++row;
//				child.layout(lengthX - width, lengthY - height, lengthX,
//						lengthY);
//			} else {
//				child.layout(lengthX - width, lengthY - height, lengthX,
//						lengthY);
//			}
//		}
//		ViewGroup.LayoutParams lp = getLayoutParams();
//		lp.height = lengthY;
//		
//		setLayoutParams(lp);
//		if (isAddChildType())
//			new Thread(new RefreshCustomThread()).start();
		
		//add by Jagger 2017-6-15
		int x = getPaddingLeft();
        int y = getPaddingTop();
        int contentWidth = argRight - argLeft;
        int maxItemHeight = 0;

        int count = getChildCount();
        for (int i = 0; i < count; i++) {
            View view = getChildAt(i);

            if (contentWidth < x + view.getMeasuredWidth()) {
                x = getPaddingLeft();
                y += getDividerHeight();
                y += maxItemHeight;
                maxItemHeight = 0;
            }
            view.layout(x, y, x + view.getMeasuredWidth(), y + view.getMeasuredHeight());
            x += view.getMeasuredWidth();
//            x += getDividerWidth();
            maxItemHeight = Math.max(maxItemHeight, view.getMeasuredHeight());
        }
	}

	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		//del by Jagger 2017-6-15
//		int width = View.MeasureSpec.getSize(widthMeasureSpec);
//		int height = View.MeasureSpec.getSize(heightMeasureSpec);
//		setMeasuredDimension(width, height);
//
//		for (int i = 0; i < getChildCount(); ++i) {
//			View child = getChildAt(i);
//			child.measure(0, 0);
//		}
//		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		
		//add by Jagger 2017-6-15
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        int maxWidth = MeasureSpec.getSize(widthMeasureSpec) - getPaddingLeft() - getPaddingRight();
        int maxItemHeight = 0;
        int currWidth = 0;
        int contentHeight = 0;
        boolean begin = false;

        int count = getChildCount();
        for (int i = 0; i < count; i++) {
            View view = getChildAt(i);
            measureChild(view, widthMeasureSpec, heightMeasureSpec);

            if (maxWidth < currWidth + view.getMeasuredWidth()) {
                maxItemHeight += getDividerHeight();
                maxItemHeight += view.getMeasuredHeight();
                currWidth = 0;
                begin = true;
            }
            maxItemHeight = Math.max(maxItemHeight, view.getMeasuredHeight());
            if (!begin) {
                currWidth += getDividerWidth();
            } else {
                begin = false;
            }
            currWidth += view.getMeasuredWidth();

            maxWidth = Math.max(maxWidth, currWidth);

            setMeasuredDimension(measureWidth(widthMeasureSpec, maxWidth)
                    , measureHeight(heightMeasureSpec, maxItemHeight));

        }
	}
	
	//add by Jagger 2017-6-15
	private int measureWidth(int measureSpec, int contentWidth) {
        int result = 0;
        int specMode = MeasureSpec.getMode(measureSpec);
        int specSize = MeasureSpec.getSize(measureSpec);

        if (specMode == MeasureSpec.EXACTLY) {
            result = specSize;
        } else {
            result = contentWidth + getPaddingLeft() + getPaddingRight();
            if (specMode == MeasureSpec.AT_MOST) {
                result = Math.min(result, specSize);
            }
        }
        result = Math.max(result, getSuggestedMinimumWidth());
        return result;
    }

	//add by Jagger 2017-6-15
    private int measureHeight(int measureSpec, int contentHeight) {
        int result = 0;
        int specMode = MeasureSpec.getMode(measureSpec);
        int specSize = MeasureSpec.getSize(measureSpec);

        if (specMode == MeasureSpec.EXACTLY) {
            result = specSize;
        } else {
            result = contentHeight + getPaddingTop() + getPaddingBottom();
            if (specMode == MeasureSpec.AT_MOST) {
                result = Math.min(result, specSize);
            }
        }
        result = Math.max(result, getSuggestedMinimumHeight());
        return result;
    }

	static final boolean isAddChildType() {
		return addChildType;
	}

	public static void setAddChildType(boolean type) {
		addChildType = type;
	}

	final int getDividerHeight() {
		return this.dividerHeight;
	}

	public void setDividerHeight(int dividerHeight) {
		this.dividerHeight = dividerHeight;
	}

	final int getDividerWidth() {
		return this.dividerWidth;
	}

	public void setDividerWidth(int dividerWidth) {
		this.dividerWidth = dividerWidth;
	}

	public void setAdapter(WrapBaseAdapter adapter) {
		this.myCustomAdapter = adapter;
		setAddChildType(true);
		adapter.notifyCustomListView(this);
	}

	public void setOnItemClickListener(OnItemClickListener listener) {
		this.myCustomAdapter.setOnItemClickListener(listener);
	}

	public void setOnItemLongClickListener(OnItemLongClickListener listener) {
		this.myCustomAdapter.setOnItemLongClickListener(listener);
	}

	private final void sendMsgHanlder(Handler handler, Bundle data) {
		Message msg = handler.obtainMessage();
		msg.setData(data);
		handler.sendMessage(msg);
	}

	private final class RefreshCustomThread implements Runnable {
		private RefreshCustomThread() {

		}

		public void run() {
			Bundle b = new Bundle();
			try {
				Thread.sleep(50L);
			} catch (Exception localException) {
			} finally {
				b.putBoolean("getRefreshThreadHandler", true);
				WrapListView.this.sendMsgHanlder(WrapListView.this.handler,
						b);
			}
		}
	}

	public interface OnItemClickListener {
		public void onItemClick(AdapterView<?> paramAdapterView,
                                View paramView, int paramInt, long paramLong);
	}

	public interface OnItemLongClickListener {
		public boolean onItemLongClick(AdapterView<?> paramAdapterView,
                                       View paramView, int paramInt, long paramLong);
	}
}
