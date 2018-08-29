package com.qpidnetwork.anchor.view;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.text.TextUtils.TruncateAt;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;


@SuppressLint("RtlHardcoded")
public class MaterialAppBar extends LinearLayout {

	public static int TOUCH_FEEDBACK_HOLO_DARK = R.drawable.touch_feedback_holo_dark_circle;
	public static int TOUCH_FEEDBACK_HOLO_LIGHT = R.drawable.touch_feedback_holo_light_circle;

	private int this_width = 0;
	private float this_height = getContext().getResources().getDimension(R.dimen.actionbar_height);
	private Context this_context;
	private LinearLayout button_area;
	private LinearLayout center_title_area;		//add by hunter,添加title居中支持
	private LinearLayout leftButtons;
	private LinearLayout rightButtons;
	private int default_touch_feedback = TOUCH_FEEDBACK_HOLO_DARK;
	private OnClickListener onClickListener;
	private int shadow_depth = 4;
	private boolean shadow_calculated = false;
	private MaterialDropDownMenu  drop_menu;
	private OnClickListener mOnTitleClickListener = null;
	
	public MaterialAppBar(Context context, AttributeSet attrs) {
		super(context, attrs);
		this_context = context;
		// TODO Auto-generated constructor stub
		this.setOrientation(LinearLayout.VERTICAL);
		shadow_depth = (int) (2.00 * this_context.getResources()
				.getDisplayMetrics().density);

		LayoutParams content_area_params = new LayoutParams(
				LayoutParams.MATCH_PARENT,
				LayoutParams.MATCH_PARENT);
		content_area_params.weight = 1;
		content_area_params.gravity = Gravity.CENTER_VERTICAL;

		FrameLayout content = new FrameLayout(this_context);
		content.setLayoutParams(content_area_params);

		LayoutParams shadow_params = new LayoutParams(
				LayoutParams.MATCH_PARENT, shadow_depth);
		shadow_params.weight = 0;

		View shadow = new View(this_context);
		shadow.setBackgroundResource(R.drawable.rectangle_grey_shawdow);
		shadow.setLayoutParams(shadow_params);

		this.addView(content);
		this.addView(shadow); //解决界面衔接处黑色线


		//添加按钮区域
		FrameLayout.LayoutParams button_area_params = new FrameLayout.LayoutParams(
				LayoutParams.MATCH_PARENT,
				LayoutParams.MATCH_PARENT);
		button_area_params.gravity = Gravity.CENTER_VERTICAL;
		
		button_area = new LinearLayout(this_context);
		button_area.setOrientation(LinearLayout.HORIZONTAL);
		button_area.setLayoutParams(button_area_params);
		content.addView(button_area);

		leftButtons = new LinearLayout(this_context);
		rightButtons = new LinearLayout(this_context);

		LayoutParams left_params = new LayoutParams(
				LayoutParams.MATCH_PARENT,
				LayoutParams.MATCH_PARENT);
		left_params.weight = 1;
		left_params.gravity = Gravity.LEFT | Gravity.CENTER_VERTICAL;
		leftButtons.setLayoutParams(left_params);
		leftButtons.setOrientation(LinearLayout.HORIZONTAL);

		LayoutParams right_params = new LayoutParams(
				LayoutParams.WRAP_CONTENT,
				LayoutParams.MATCH_PARENT);
		right_params.weight = 0;
		right_params.gravity = Gravity.RIGHT | Gravity.CENTER_VERTICAL;
		rightButtons.setLayoutParams(right_params);
		rightButtons.setOrientation(LinearLayout.HORIZONTAL);
		
		button_area.addView(leftButtons);
		button_area.addView(rightButtons);

		//添加居中的tile
		center_title_area = new LinearLayout(this_context);

		FrameLayout.LayoutParams center_title_params = new FrameLayout.LayoutParams(
				LayoutParams.WRAP_CONTENT,
				LayoutParams.MATCH_PARENT);
		center_title_params.gravity = Gravity.CENTER;

		center_title_area.setLayoutParams(center_title_params);
		content.addView(center_title_area);


		this.setBackgroundColor(Color.TRANSPARENT);
		this.setFocusable(false);

	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		this_width = MeasureSpec.getSize(widthMeasureSpec);
		//this_height = MeasureSpec.getSize(heightMeasureSpec);
		

		if (!shadow_calculated)
			this.getLayoutParams().height = (int)this_height + shadow_depth;
		shadow_calculated = true;
		setMeasuredDimension(this_width, (int)this_height + shadow_depth);
	}

	public void setTouchFeedback(int resourceId) {
		default_touch_feedback = resourceId;
	}

	public void addOverflowButton(String[] menu, MaterialDropDownMenu.OnClickCallback listener, int icon) {
		
		final FrameLayout button = createButton(R.id.common_button_overflow, "overflow", icon);
		rightButtons.addView(button, rightButtons.getChildCount());
		Point size = new Point();
		size.x = (int)(180.0f * this.getResources().getDisplayMetrics().density);
		size.y = LayoutParams.WRAP_CONTENT;
		drop_menu = new MaterialDropDownMenu(this.getContext(), menu, listener, size);
		
		button.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				drop_menu.showAsDropDown(button);
			}
		});
		

	}


	
	public void addButtonToLeft(int btnId, String name, int icon) {
		leftButtons.addView(createButton(btnId, name, icon), 0);
	}


	
	public void addButtonToRight(int btnId, String name, int icon) {
		rightButtons.addView(createButton(btnId, name, icon));
	}
	
	public void addButtonToRight(int btnId, String tag, int icon, String name) {
		rightButtons.addView(createButton(btnId, tag, icon, name));
	}
	
	public FrameLayout createButton(int btnId, String tag, int icon) {
		return createButton(btnId, tag, icon, null);
	}
	
	public FrameLayout createButton(int btnId, String tag, int icon, String name) {
		int height = (Build.VERSION.SDK_INT >= 21) ? (int)(48.00 * this_context.getResources().getDisplayMetrics().density) : this.getLayoutParams().height;
		float density = this_context.getResources().getDisplayMetrics().density;
		
		int padding = (int) (12.00 * this_context.getResources().getDisplayMetrics().density);
		int badge_size = (int) (8.00 * density);

		// create button
		LayoutParams button_params = new LayoutParams(LayoutParams.WRAP_CONTENT, height);
		button_params.gravity = Gravity.CENTER;
		FrameLayout button = new FrameLayout(this_context);
		button.setLayoutParams(button_params);
		button.setMinimumWidth(height);
		button.setClickable(true);
		button.setId(btnId);
		button.setBackgroundResource(default_touch_feedback);
		if (tag != null) button.setTag(tag);

		// add icon to button
		FrameLayout.LayoutParams image_params = new FrameLayout.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT);
		image_params.gravity = Gravity.CENTER;
		ImageView image = new ImageView(this_context);
		image.setLayoutParams(image_params);
		
		if ( name == null || name.length() == 0 ) {
			image.setImageResource(icon);
		}
		
		image.setTag("image");
		image.setId(android.R.id.icon);
		button.addView(image);

		// add badge to the button
		FrameLayout.LayoutParams badge_params = new FrameLayout.LayoutParams(
				badge_size, badge_size, Gravity.TOP | Gravity.RIGHT);
		badge_params.rightMargin = (int)(8.0f * density);
		badge_params.topMargin = (int)(8.0f * density);
		ImageView badge = new ImageView(this_context);
		badge.setLayoutParams(badge_params);
		badge.setImageBitmap(drawBadge(0, badge.getLayoutParams().height));
		button.addView(badge);
		badge.setVisibility(View.GONE);
		badge.setTag("badge");
		
		// add textview to button
		FrameLayout.LayoutParams text_params = new FrameLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT, Gravity.CENTER);
		TextView textView = new TextView(this_context);
		textView.setLayoutParams(text_params);
		textView.setPadding(padding, 0, padding, 0);
		textView.setSingleLine();
		textView.setTag("text");
		textView.setTextSize(18);
		textView.setGravity(Gravity.CENTER);
		textView.setTextColor(getResources().getColor(R.color.white));
		if ( name != null && name.length() > 0 ) {
			textView.setText(name);
		}
		button.addView(textView);

		button.setOnClickListener(onClickListener);

		return button;

	}

	public void pushBadgeByName(String name, int color) {
		FrameLayout button = (FrameLayout) this.findViewWithTag(name);
		ImageView badge = (ImageView) button.findViewWithTag("badge");
		badge.setImageBitmap(drawBadge(color, badge.getLayoutParams().height));
		badge.setVisibility(View.VISIBLE);
	}
	
	public void pushBadgeById(int viewId, int color) {
		FrameLayout button = (FrameLayout) this.findViewById(viewId);
		ImageView badge = (ImageView) button.findViewWithTag("badge");
		badge.setImageBitmap(drawBadge(color, badge.getLayoutParams().height));
		badge.setVisibility(View.VISIBLE);
	}

	public void cancelBadgeByName(String name) {
		FrameLayout button = (FrameLayout) this.findViewWithTag(name);
		ImageView badge = (ImageView) button.findViewWithTag("badge");
		badge.setVisibility(View.GONE);
	}

	public void cancelBadgeById(int viewId) {
		FrameLayout button = (FrameLayout) this.findViewById(viewId);
		ImageView badge = (ImageView) button.findViewWithTag("badge");
		badge.setVisibility(View.GONE);
	}

	
	public void changeIconById(int id, int icon) {
		if (icon < 1)
			return;
		FrameLayout button = (FrameLayout) this.findViewById(id);
		ImageView imageView = (ImageView) button.findViewWithTag("image");
		TextView textView = (TextView) button.findViewWithTag("text");
		String name = textView.getText().toString();
		if ( name != null && name.length() > 0 ) {
			textView.setBackgroundResource(icon);
			textView.setText(name);
		} else {
			imageView.setImageResource(icon);
		}
	}
	
	public FrameLayout GetViewById(int id) {
		FrameLayout button = (FrameLayout) this.findViewWithTag(id);
		return button;
	}

	/**
	 * 添加自定义头
	 * 
	 * @param view
	 *            自定义头View
	 * @author Hunter
	 * @since 2015.4.24
	 */
	public void setCustomTitle(View view) {
		View titleView = (View) leftButtons.findViewWithTag("title");
		if (titleView != null)
			leftButtons.removeView(titleView);
		LayoutParams params = new LayoutParams(
				LayoutParams.WRAP_CONTENT,
				LayoutParams.WRAP_CONTENT);
		params.gravity = Gravity.CENTER;
		int delta = (int) ((72.00 * this_context.getResources()
				.getDisplayMetrics().density) - this.getLayoutParams().height);
		params.setMargins(delta, 0, 0, 0);
		view.setLayoutParams(params);
		view.setTag("title");
		if (leftButtons.getChildCount() > 0) {
			leftButtons.addView(view, 1);
		} else {
			leftButtons.addView(view);
		}
	}

	
	public void setOnTitleClick(OnClickListener l) {
		mOnTitleClickListener = l;
		View titleView = (View) leftButtons.findViewWithTag("title");
		if( titleView != null ) {
			titleView.setOnClickListener(mOnTitleClickListener);
		}
	}
	
	public void setTitle(String title, int color){
		setTitle(title, color, null, false);
	}
	
	public void setTitle(String title, int color, boolean clickable){
		setTitle(title, color, null, clickable);
	}
	
	public void setTitle(String title, int color, Drawable drawable){
		setTitle(title, color, drawable, false);
	}
	
	public void setTitle(String title, int color, Drawable drawable, boolean clickable) {
		View titleView = (View) leftButtons.findViewById(android.R.id.title);
		if (titleView != null)leftButtons.removeView(titleView);
		
		int dp8 = (int)(8.0f * this_context.getResources().getDisplayMetrics().density);
		LayoutParams params = new LayoutParams(
				LayoutParams.WRAP_CONTENT,
				LayoutParams.MATCH_PARENT);
		params.gravity = Gravity.CENTER;
		int delta = (int) ((72.00 * this_context.getResources().getDisplayMetrics().density) - (this.getLayoutParams().height + dp8));
		int textSize = 18;
		params.setMargins(delta, 0, 0, 0);
		TextView textView = new TextView(this_context);
		
		if (drawable != null){
			Rect rect = new Rect(0, 0, dp8* 3, dp8 * 3);
			drawable.setBounds(rect);
			textView.setCompoundDrawables(null, null, drawable, null);
		}
		
		textView.setTextSize(textSize);
		textView.setLayoutParams(params);
		textView.setTag("title");
		textView.setId(android.R.id.title);
		textView.getPaint().setFakeBoldText(true);
		textView.setGravity(Gravity.LEFT|Gravity.CENTER);
		textView.setPadding(dp8, 0, dp8, 0);
		textView.setSingleLine();
		textView.setEllipsize(TruncateAt.END);
		textView.setClickable(false);
		if (clickable){
			textView.setClickable(true);
			textView.setBackgroundResource((default_touch_feedback == TOUCH_FEEDBACK_HOLO_DARK) ? R.drawable.touch_feedback_holo_dark : R.drawable.touch_feedback_holo_light );
		}
		
//		if (leftButtons.getChildCount() > 0) {
//			leftButtons.addView(textView, 1);
//		} else {
//			leftButtons.addView(textView);
//		}
		center_title_area.addView(textView);

		textView.setText(title);
		if (color != 0)
			textView.setTextColor(color);

		if( mOnTitleClickListener != null ) {
			textView.setOnClickListener(mOnTitleClickListener);
		}
	}
	

	public void setOnButtonClickListener(OnClickListener listener) {
		onClickListener = listener;

		for (int i = 0; i < leftButtons.getChildCount(); i++) {
			if (leftButtons.getChildAt(i) instanceof FrameLayout) {
				leftButtons.getChildAt(i).setOnClickListener(listener);
			}
		}

		for (int i = 0; i < rightButtons.getChildCount(); i++) {
			View v = rightButtons.getChildAt(i);
			Object tag = v.getTag();
			if (v instanceof FrameLayout && tag != null && !tag.equals("overflow")) {
				v.setOnClickListener(listener);
			}
		}
	}

	
	public TextView getTitileView(){
		return (TextView)leftButtons.findViewById(android.R.id.title);
	}
	
	public String getNameByView(View v) {
		String name = v.getTag().toString();
		return name;
	}
	

	public void setButtonIconById(int buttonId, int resourceId){
		View view  = getButtonById(buttonId);
		ImageView image = (ImageView)view.findViewById(android.R.id.icon);
		image.setImageResource(resourceId);
	}

	public View getButtonById(int id) {
		return this.findViewById(id);
	}

	public void setAppbarBackgroundColor(int color) {
		button_area.setBackgroundColor(color);
	}

	@SuppressWarnings("deprecation")
	@SuppressLint("NewApi") 
	public void setAppbarBackgroundDrawable(Drawable drawable) {
		if (Build.VERSION.SDK_INT > 15) {
			button_area.setBackground(drawable);
		} else {
			button_area.setBackgroundDrawable(drawable);
		}

		// this.setBackgroundColor(Color.TRANSPARENT);
	}
	
	public void setButtonLayoutParams(String name, LayoutParams params){
		button_area.findViewWithTag(name).setLayoutParams(params);

		
	}

	private Bitmap drawBadge(int color, int size) {
		if (color == 0)
			color = Color.RED;
		Bitmap bmp = Bitmap.createBitmap(size, size, Config.ARGB_8888);
		Paint paint = new Paint();
		paint.setAntiAlias(true);
		paint.setColor(color);

		Canvas canvas = new Canvas(bmp);
		canvas.drawCircle(size / 2, size / 2, size / 2, paint);

		return bmp;

	}

}
