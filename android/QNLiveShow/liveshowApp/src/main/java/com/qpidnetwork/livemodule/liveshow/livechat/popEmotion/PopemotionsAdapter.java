package com.qpidnetwork.livemodule.liveshow.livechat.popEmotion;

import android.content.Context;
import android.graphics.BitmapFactory;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livechat.LCEmotionItem;
import com.qpidnetwork.livemodule.livechat.LCMagicIconItem;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerEmotionListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerMagicIconListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconConfig;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigEmotionItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigItem;
import com.qpidnetwork.livemodule.liveshow.livechat.popEmotion.PopEmotionItem.EmotionType;
import com.qpidnetwork.livemodule.view.EmotionPlayer;
import com.qpidnetwork.livemodule.view.MaterialProgressBar;

import java.io.File;
import java.util.List;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;

public class PopemotionsAdapter extends RecyclerView.Adapter<PopemotionsAdapter.MyViewHolder> implements LiveChatManagerMagicIconListener,LiveChatManagerEmotionListener {
	
	private Context mContext;
	private LayoutInflater mInflater;
	private List<PopEmotionItem> mPopEmotionItems;
	private boolean onBind;
	private DownloadFeed mDownloadFeed;
	private OnItemClickListener mOnItemClickListener;
	
	/**
	 * 表情点击回调接口
	 * @author Jagger
	 * 2017-5-10
	 */
	public interface OnItemClickListener{
		void onEmotionClick(OtherEmotionConfigEmotionItem emotion);
		void onMagicIconClick(MagicIconItem magicIcon);
	}
	
	public PopemotionsAdapter(Context context , List<PopEmotionItem> popEmotionItems){
		mContext = context;
		mInflater = LayoutInflater.from(mContext);
		mPopEmotionItems = popEmotionItems;
		mDownloadFeed = new DownloadFeed();
		
		LiveChatManager.getInstance().RegisterMagicIconListener(this);
		LiveChatManager.getInstance().RegisterEmotionListener(this);
		
		initDownloadObservable();
	}

	public class MyViewHolder extends RecyclerView.ViewHolder{
		View mView;
		LinearLayout mLL4img;
		TextView mTxt;
		MaterialProgressBar mMaterialProgressBar;
		ImageView iv ;
		EmotionPlayer eplayer;
		
		public MyViewHolder(View v) {
			super(v);
			// TODO Auto-generated constructor stub
			mView = v;
		}
		
		/**
		 * 回收内存
		 */
		public void recycle(){
			if(iv != null){
				iv = null;
			}
			
			if(eplayer != null){
				if(eplayer.isPlaying()){
					eplayer.stop();
				}
				eplayer = null;
			}
			
			mLL4img.removeAllViews();
		}
		
		/**
		 * 显示表情
		 * @param popEmotionItem
		 */
		public void loadPic(PopEmotionItem popEmotionItem){
			//小高表,用普通Imageview显示
			if(popEmotionItem.type == EmotionType.MagicIcon){
				LCMagicIconItem item = LiveChatManager.getInstance().GetMagicIconInfo(((MagicIconItem)popEmotionItem.emotion).id);
				String localPath = item.getThumbPath();
				if(iv == null){
					iv = new ImageView(mView.getContext());
					iv.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.MATCH_PARENT));
					mLL4img.removeAllViews();
					mLL4img.addView(iv);
				}
				
				if (!TextUtils.isEmpty(localPath) && (new File(localPath).exists())) {
					//在缓存中
					if(mMaterialProgressBar.isSpinning()){
						mMaterialProgressBar.stopSpinning();
						mMaterialProgressBar.setVisibility(View.GONE);
					}
					
					iv.setImageBitmap(BitmapFactory.decodeFile(localPath));
				} else {
					//要下载
//					iv.setImageResource(R.drawable.ic_default_preminum_emotion_grey_56dp);
					mMaterialProgressBar.setVisibility(View.VISIBLE);
					mMaterialProgressBar.spin();
					LiveChatManager.getInstance().GetMagicIconThumbImage(item.getMagicIconId());
				}
			}else if(popEmotionItem.type == EmotionType.Emotion){
				LCEmotionItem emotionItem = LiveChatManager.getInstance().GetEmotionInfo(((OtherEmotionConfigEmotionItem)popEmotionItem.emotion).fileName);
				if(eplayer == null){
					eplayer = new EmotionPlayer(mView.getContext());
					eplayer.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.MATCH_PARENT));
					mLL4img.removeAllViews();
					mLL4img.addView(eplayer);
				}
				
				if(emotionItem.playBigImages.size()>0){
					//在缓存中
					if(mMaterialProgressBar.isSpinning()){
						mMaterialProgressBar.stopSpinning();
						mMaterialProgressBar.setVisibility(View.GONE);
					}
					
					if(!eplayer.isPlaying()){
//						eplayer.setBackgroundResource(R.color.transparent_full);
						eplayer.setImageList(emotionItem.playBigImages);
						eplayer.play();
					}
				}else{
					//要下载
					mMaterialProgressBar.setVisibility(View.VISIBLE);
					mMaterialProgressBar.spin();
					
//					eplayer.setBackgroundResource(R.drawable.ic_default_preminum_emotion_grey_56dp);
					LiveChatManager.getInstance().GetEmotionPlayImage(emotionItem.emotionId);
				}
			}
		}
	}

	@Override
	public int getItemCount() {
		// TODO Auto-generated method stub
		return mPopEmotionItems.size();
	}

	@Override
	public void onBindViewHolder(MyViewHolder viewHolder, int i) {
		// TODO Auto-generated method stub
		
		onBind = true;
		if(mPopEmotionItems.get(i).type == EmotionType.Emotion){
			final OtherEmotionConfigEmotionItem emotion = (OtherEmotionConfigEmotionItem)mPopEmotionItems.get(i).emotion;
			//价格
			viewHolder.mTxt.setText(String.format(mContext.getResources().getString(R.string.livechat_emotion_preview_price), "" + emotion.price));
			//图片
			viewHolder.loadPic(mPopEmotionItems.get(i));
			
			//点击事件
			if(mOnItemClickListener != null){
				viewHolder.itemView.setOnClickListener(new OnClickListener() {
					
					@Override
					public void onClick(View v) {
						// TODO Auto-generated method stub
						mOnItemClickListener.onEmotionClick(emotion);
					}
				});
			}
		}else if(mPopEmotionItems.get(i).type == EmotionType.MagicIcon){
			final MagicIconItem emotion = (MagicIconItem)mPopEmotionItems.get(i).emotion;
			//价格
			viewHolder.mTxt.setText(String.format(mContext.getResources().getString(R.string.livechat_emotion_preview_price), "" + emotion.price));
			//图片
			viewHolder.loadPic(mPopEmotionItems.get(i));
			//点击事件
			if(mOnItemClickListener != null){
				viewHolder.itemView.setOnClickListener(new OnClickListener() {
					
					@Override
					public void onClick(View v) {
						// TODO Auto-generated method stub
						mOnItemClickListener.onMagicIconClick(emotion);
					}
				});
			}
		}
		onBind = false;
	}

	@Override
	public MyViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
		// TODO Auto-generated method stub
		View view = mInflater.inflate(R.layout.item_in_popemotion_lc, viewGroup , false);
		MyViewHolder viewHolder = new MyViewHolder(view);
		viewHolder.mLL4img = (LinearLayout)view.findViewById(R.id.llEmotionIcon);
		viewHolder.mTxt = (TextView)view.findViewById(R.id.tvEmotionPrice);
		viewHolder.mMaterialProgressBar = (MaterialProgressBar)view.findViewById(R.id.pbDownload);
		return viewHolder;
	}
	
	@Override
	public void onDetachedFromRecyclerView(RecyclerView recyclerView) {
		// TODO Auto-generated method stub
		super.onDetachedFromRecyclerView(recyclerView);
		//反注册表情下载监听
		LiveChatManager.getInstance().UnregisterMagicIconListener(this);
		LiveChatManager.getInstance().UnregisterEmotionListener(this);
	}
	
	/**
	 * 当ViewHolder看不见时,会调用onViewDetachedFromWindow,
	 * 但之后不一定会调用onViewRecycled,
	 * onViewRecycled是在系统认为这个ViewHolde已经滑得很远了,才会调用,
	 * 但若要再显示它时,一定会调用onBindViewHolder
	 */
	@Override
	public void onViewRecycled(MyViewHolder holder) {
		// TODO Auto-generated method stub
		super.onViewRecycled(holder);
		//回收资源
		holder.recycle();
	}
	
	/**
	 * 设置表情点击响应
	 * @param listener
	 */
	public void setOnItemClickListener(OnItemClickListener listener){
		mOnItemClickListener = listener;
	}
	
	//----------------- 以下 处理下载事件与UI刷新 -------------------------
	/**
	 * 表情下载完成事件触发器
	 * @author Jagger
	 * 2017-5-10
	 */
	private class DownloadFeed{
		private DownloadListener mDownloadListener;
		/**
		 * 注册监听器
		 * @param listener
		 */
		public void register(DownloadListener listener){
			mDownloadListener = listener;
		}
		
		public void downloadFinish(boolean result){
			if(mDownloadListener != null){
				mDownloadListener.onDownloadFinish(result);
			}
		}
	}

	/**
	 * 响应表情下载完成事件
	 * @author Jagger
	 * 2017-5-10
	 */
	private interface DownloadListener{
		void onDownloadFinish(boolean result);
	}
	
	/**
	 * 初始化下载监听者
	 * (因为表情有可能在短时间(几毫秒)内下载完成,
	 * 避免不过度高频刷新UI,
	 * 使用throttleLast取某段时间中最后一次下载完成事件通知UI刷新)
	 */
	private void initDownloadObservable(){
		Observable.create(new ObservableOnSubscribe<Boolean>() {

			@Override
			public void subscribe(final ObservableEmitter<Boolean> emitter)
					throws Exception {
				// TODO Auto-generated method stub
				DownloadListener l = new DownloadListener() {
					
					@Override
					public void onDownloadFinish(boolean result) {
						// TODO Auto-generated method stub
						emitter.onNext(result);
					}
				};
				mDownloadFeed.register(l);
			}
		})
		.throttleLast(500, TimeUnit.MILLISECONDS)	//只发射500毫秒内最后接收的结果
		.subscribeOn(Schedulers.io())				//io线程发射结果
		.observeOn(AndroidSchedulers.mainThread())	//主线程控制刷新
		.subscribe(new Consumer<Boolean>() {

			@Override
			public void accept(Boolean result) throws Exception {
				// TODO Auto-generated method stub
				if(!onBind){
					notifyDataSetChanged();
				}
			}
		});
	}

	//--------------------以下是 小高表事件回调 -----------------------------
	@Override
	public void OnGetMagicIconConfig(boolean success, String errno,
			String errmsg, MagicIconConfig item) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnSendMagicIcon(LiveChatErrType errType, String errmsg,
			LCMessageItem item) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnRecvMagicIcon(LCMessageItem item) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnGetMagicIconSrcImage(boolean success,
			LCMagicIconItem magicIconItem) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnGetMagicIconThumbImage(boolean success,
			LCMagicIconItem magicIconItem) {
		// TODO Auto-generated method stub
//		if(success && !onBind){
//			this.notifyDataSetChanged();
//		}
		
		mDownloadFeed.downloadFinish(success);
		
	}

	//----------------- 以下是 高表事件回调 -----------------------------
	
	@Override
	public void OnGetEmotionConfig(boolean success, String errno,
			String errmsg, OtherEmotionConfigItem item) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnSendEmotion(LiveChatErrType errType, String errmsg,
			LCMessageItem item) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnRecvEmotion(LCMessageItem item) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnGetEmotionImage(boolean success, LCEmotionItem emotionItem) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnGetEmotionPlayImage(boolean success, LCEmotionItem emotionItem) {
		// TODO Auto-generated method stub
//		if(success && !onBind){
//			this.notifyDataSetChanged();
//		}
		mDownloadFeed.downloadFinish(success);
	}

	@Override
	public void OnGetEmotion3gp(boolean success, LCEmotionItem emotionItem) {
		// TODO Auto-generated method stub
		
	}

}
