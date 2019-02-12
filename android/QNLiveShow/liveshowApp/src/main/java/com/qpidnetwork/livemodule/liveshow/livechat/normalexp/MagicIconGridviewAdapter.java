package com.qpidnetwork.livemodule.liveshow.livechat.normalexp;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.graphics.Point;
import android.os.Build;
import android.text.TextUtils;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout.LayoutParams;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livechat.LCMagicIconItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconItem;

import java.io.File;
import java.util.List;

/**
 * @author Yanni
 * 
 * @version 2016-6-1
 */
public class MagicIconGridviewAdapter extends BaseAdapter {

	private List<MagicIconItem> mIconItemList;
	private Context mContext;
	private LiveChatManager mLiveChatManager;
	private int mGvItemHeight;

	public MagicIconGridviewAdapter(Context context, int gvItemHeigth,
			List<MagicIconItem> iconItemList) {
		super();
		// TODO Auto-generated constructor stub
		this.mContext = context;
		this.mGvItemHeight = gvItemHeigth;
		this.mIconItemList = iconItemList;
		mLiveChatManager = LiveChatManager.getInstance();
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mIconItemList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return mIconItemList.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@SuppressLint("NewApi")
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		ViewHolder viewHolder;
		if (convertView == null) {
			viewHolder = new ViewHolder();

			float density = mContext.getResources().getDisplayMetrics().density;
			Display display = ((Activity) mContext).getWindowManager().getDefaultDisplay();
			Point size = new Point();

			if (Build.VERSION.SDK_INT > 12) {
				display.getSize(size);
			} else {
				size.x = display.getWidth();
				size.y = display.getHeight();
			}

			int item_size = (int) (((float) size.x - (int) (4.0f * density)) / 5);

			convertView = LayoutInflater.from(mContext).inflate(R.layout.item_live_magic_icon_lc, null);
			viewHolder.ivImg = (ImageView) convertView.findViewById(R.id.icon);

			if(mGvItemHeight>0){
				convertView.setLayoutParams(new AbsListView.LayoutParams(LayoutParams.MATCH_PARENT, mGvItemHeight));
			}
//			convertView.setBackgroundColor(mContext.getResources().getColor(R.color.red_light));
			//convertView.setBackgroundColor(Color.BLUE);
			convertView.setTag(viewHolder);
			
		} else {
			viewHolder = (ViewHolder) convertView.getTag();
		}
		LCMagicIconItem item = mLiveChatManager.GetMagicIconInfo(mIconItemList.get(position).id);
		String localPath = item.getThumbPath();
		if (!TextUtils.isEmpty(localPath) && (new File(localPath).exists())) {
			viewHolder.ivImg.setImageBitmap(BitmapFactory.decodeFile(localPath));
		} else {
			mLiveChatManager.GetMagicIconThumbImage(item.getMagicIconId());
		}
		return convertView;
	}

	public static class ViewHolder {
		ImageView ivImg;
	}

}
