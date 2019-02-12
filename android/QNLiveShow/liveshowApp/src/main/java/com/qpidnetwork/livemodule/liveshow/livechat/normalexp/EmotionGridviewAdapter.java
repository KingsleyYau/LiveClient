package com.qpidnetwork.livemodule.liveshow.livechat.normalexp;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout.LayoutParams;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigEmotionItem;
import com.qpidnetwork.livemodule.liveshow.livechat.LiveChatTalkActivity;
import com.qpidnetwork.livemodule.liveshow.livechat.downloader.EmotionImageDownloader;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.view.EmotionPreviewer;
import com.qpidnetwork.qnbridgemodule.util.BroadcastManager;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.List;

/**
 * @author Yanni
 * 
 * @version 2016-6-3
 */
public class EmotionGridviewAdapter extends BaseAdapter {

	private Context mContext;
	private List<OtherEmotionConfigEmotionItem> mEmotionItemList;
	private GridView gridView;
	private int mGvItemHeight;
	private EmotionPreviewer preview;
	private boolean canScroll = true;
	private EmotionsItemFragment.OnItemClickCallback onItemClickCallback;
	private int previewPosition = 0;

	public EmotionGridviewAdapter(Context context, int gvItemHeigth,
			List<OtherEmotionConfigEmotionItem> emotionItemList,
			GridView gridView, EmotionsItemFragment.OnItemClickCallback callback) {
		super();
		// TODO Auto-generated constructor stub
		this.mContext = context;
		this.mGvItemHeight = gvItemHeigth;
		this.preview = new EmotionPreviewer(mContext);
		this.mEmotionItemList = emotionItemList;
		this.gridView = gridView;
		this.gridView.setClickable(true);
		this.gridView.setLongClickable(true);
		this.onItemClickCallback = callback;
		this.gridView.setOnTouchListener(touch);
		this.gridView.setOnItemClickListener(itemOnClick);
		this.gridView.setOnItemLongClickListener(itemOnLongClick);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mEmotionItemList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return mEmotionItemList.get(position);
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
		if (convertView == null) {

			DisplayMetrics dm = new DisplayMetrics();
			((Activity) mContext).getWindowManager().getDefaultDisplay().getMetrics(dm);
			
			int item_width = (dm.widthPixels-DisplayUtil.dip2px(mContext, (4*4)+20))/5;
			
			convertView = LayoutInflater.from(mContext).inflate(R.layout.item_live_gridview_emotion, null);
			if(mGvItemHeight>0){
				convertView.setLayoutParams(new AbsListView.LayoutParams(LayoutParams.MATCH_PARENT, (mGvItemHeight-DisplayUtil.dip2px(mContext, 1))/2));
			}else{
				convertView.setLayoutParams(new AbsListView.LayoutParams(LayoutParams.MATCH_PARENT, item_width));
			}
			
			ViewHolder holder = new ViewHolder();
			holder.imageView = (ImageView) convertView.findViewById(R.id.icon);
			holder.price = (TextView) convertView.findViewById(R.id.price);

			convertView.setTag(holder);

		}

		ViewHolder holder = (ViewHolder) convertView.getTag();
		holder.price.setText(mEmotionItemList.get(position).price + "");
		new EmotionImageDownloader().displayEmotionImage(holder.imageView,null, mEmotionItemList.get(position).fileName);
		convertView.setTag(R.id.item_position, position);

		// convertView.setOnClickListener(itemOnClick);
		// convertView.setOnLongClickListener(itemLongClick);
		// convertView.setLongClickable(true);

		return convertView;
	}

	public static class ViewHolder {
		ImageView imageView;
		TextView price;
	}

	OnItemClickListener itemOnClick = new OnItemClickListener() {

		@Override
		public void onItemClick(AdapterView<?> arg0, View arg1, int position,
				long arg3) {
			// TODO Auto-generated method stub
			OtherEmotionConfigEmotionItem b = mEmotionItemList.get(position);
			Intent intent = new Intent(LiveChatTalkActivity.SEND_EMTOTION_ACTION);
			intent.putExtra(LiveChatTalkActivity.EMOTION_ID, b.fileName);
//			mContext.sendBroadcast(intent);
			BroadcastManager.sendBroadcast(mContext,intent);

			// if (onItemClickCallback != null )
			// onItemClickCallback.onItemLongClick();
		}

	};

	OnItemLongClickListener itemOnLongClick = new OnItemLongClickListener() {

		@Override
		public boolean onItemLongClick(AdapterView<?> arg0, View arg1,
				int position, long arg3) {
			// TODO Auto-generated method stub
			Log.v("ong", "ong click");
			// OtherEmotionConfigEmotionItem b = (OtherEmotionConfigEmotionItem)
			// mEmotionList.get(position);
			if (!preview.isShowing()) {
				preview.showAtLocation(arg0.getRootView(), Gravity.CENTER, 0, 0);
				canScroll = false;
				previewPosition = position;
				playEmotion();
				if (onItemClickCallback != null)
					onItemClickCallback.onItemLongClick();
			}

			return true;
		}
	};

	OnTouchListener touch = new OnTouchListener() {

		@Override
		public boolean onTouch(View v, MotionEvent event) {
			// TODO Auto-generated method stub
			// Log.v(" m", event.getX() + "");
			if (event.getAction() == MotionEvent.ACTION_UP) {
				if (preview.isShowing())
					preview.dismiss();
				if (onItemClickCallback != null)
					onItemClickCallback.onItemLongClickUp();
				canScroll = true;
			}

			if (canScroll) {
				return false;
			} else {
				playEmotionByTouchPosition(0, event.getX(), event.getY());
				return true;
			}

			// return false;
		}

	};

	private void playEmotionByTouchPosition(int Xoffset, float x, float y) {

		int which = gridView.pointToPosition((int) x, (int) y);
		if (which != AdapterView.INVALID_POSITION) {
			if (previewPosition != which) {
				previewPosition = which;
				playEmotion();
			}
		}

	}

	private void playEmotion() {
		OtherEmotionConfigEmotionItem item = (OtherEmotionConfigEmotionItem) this.getItem(previewPosition);
		preview.setEmotionItem(item);
		Log.v("item", item.title + " title");
	}

}
