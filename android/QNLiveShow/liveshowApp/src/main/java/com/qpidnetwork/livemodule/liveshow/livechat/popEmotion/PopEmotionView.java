package com.qpidnetwork.livemodule.liveshow.livechat.popEmotion;

import android.app.Activity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.LinearLayout;

import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigEmotionItem;
import com.qpidnetwork.livemodule.view.SoftKeyboardStateHelper;

import java.util.ArrayList;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Function;
import io.reactivex.schedulers.Schedulers;
import com.qpidnetwork.livemodule.R;

/**
 * 输入建议弹出表情控件
 * @author Jagger
 * 2017-5-4
 */
public class PopEmotionView {
	
	/**
	 * 表情点击事件响应
	 * @author Jagger
	 * 2017-5-4
	 */
	public interface PopEmotionListener{
		void onEmotionItemClick(OtherEmotionConfigEmotionItem emotionItem);
		void onMagicItemClick(MagicIconItem magicIconItem);
	}
	
	/**
	 * 输入事件响应
	 * @author Jagger
	 * 2017-5-4
	 */
	private interface InputListener{
		void inputTick(String text);
	}
	
	/**
	 * 接收键盘输入内容，从而触发doFindEmotions()处理匹配表情
	 * @author Jagger
	 * 2017-5-4
	 */
	private class InputFeed{
//		private Vector<String> mTextList = new Vector<String>();
		private InputListener mInputListener ;
		
		/**
		 * 注册监听器
		 * @param listener
		 */
		public void register(InputListener listener){
			mInputListener = listener;
		}
		
		/**
		 * 接收输入的文字
		 * @param text
		 */
		public void input(String text){
//			mTextList.add(text);
			if(mInputListener != null){
				mInputListener.inputTick(text);
			}
		}
	}
	
	//控件
	private Activity mActivity;								//所附属的窗体
	private View mAnchorView;								//锚控件(EditText)
	private UnblockPopupWindow mUnblockPopupWindow;			//弹出的控件
	private LinearLayout mContentView;						//弹出的控件层次关系-->mUnblockPopupWindow[mContentView[mRecyclerView[mAdapter]]]
	private RecyclerView mRecyclerView;
	private PopemotionsAdapter mAdapter;
	private SoftKeyboardStateHelper mSoftKeyboardStateHelper;//键盘显示事件
	
	//变量 
	private int MAX = 3;									//最大显示表情数量(可扩展 无限制)
	private OtherEmotionConfigEmotionItem[] mEmotionItems;	//高表配置数据源
	private MagicIconItem[] mMagicIconItems;				//小高表配置数据源
	private PopEmotionListener mPopEmotionListener;			//点击表情响应
	private boolean mIsWork = true;							//是否要接收文字
	private InputFeed mInputFeed;							//接收输入的文字与匹配器建立关系的东东
	private ArrayList<PopEmotionItem> mPopEmotionItems = new ArrayList<PopEmotionItem>();	//存放要显示的表情(高表,小高表)配置,就是匹配结果
	
	public PopEmotionView(Activity activity){
		mActivity = activity;
		if(LiveChatManager.getInstance().GetEmotionConfigItem() != null && LiveChatManager.getInstance().GetEmotionConfigItem().manEmotionList != null){
			mEmotionItems = LiveChatManager.getInstance().GetEmotionConfigItem().manEmotionList;
		}
		
		if(LiveChatManager.getInstance().GetMagicIconConfigItem() != null && LiveChatManager.getInstance().GetMagicIconConfigItem().magicIconArray!=null){
			mMagicIconItems = LiveChatManager.getInstance().GetMagicIconConfigItem().magicIconArray;
		}
		
		mInputFeed = new InputFeed();
		mSoftKeyboardStateHelper = new SoftKeyboardStateHelper((ViewGroup)mActivity.findViewById(Window.ID_ANDROID_CONTENT));
		doFindEmotions();
	}
	
	/**
	 * 绑定控件
	 * @param anchorView
	 * @param listener
	 */
	public void bind(View anchorView , PopEmotionListener listener){
		mAnchorView = anchorView;
		mPopEmotionListener = listener;

		mSoftKeyboardStateHelper.addSoftKeyboardStateListener(new SoftKeyboardStateHelper.SoftKeyboardStateListener() {
			
			@Override
			public void onSoftKeyboardOpened(int keyboardHeightInPx) {
				// TODO Auto-generated method stub
			}
			
			@Override
			public void onSoftKeyboardClosed() {
				// TODO Auto-generated method stub
				hidePopupWindow();
			}
		});
	}
	
	/**
	 * 解绑
	 */
	public void unbind(){
		mPopEmotionListener = null;
		mSoftKeyboardStateHelper.removeAllSoftKeyboardStateListener();
	}
	
	/**
	 * 启动匹配
	 */
	public void turnOn(){
		mIsWork = true;
		
	}
	
	/**
	 * 关闭匹配
	 */
	public void turnOff(){
		mIsWork = false;
		hidePopupWindow();
	}
	
	/**
	 * 输入内容
	 * @param text
	 */
	public void inputText(String text){
		if(mIsWork){
			mInputFeed.input(text);
		}
	}
	
	/**
	 * 匹配
	 */
	private void doFindEmotions(){
		Observable.create(new ObservableOnSubscribe<String>() {

			@Override
			public void subscribe(final ObservableEmitter<String> emitter)
					throws Exception {
				// TODO Auto-generated method stub
					InputListener listener = new InputListener() {
					
					@Override
					public void inputTick(String text) {
						// TODO Auto-generated method stub
						emitter.onNext(text);
					}
				};
				mInputFeed.register(listener);
			}
		})
//		.throttleLast(500, TimeUnit.MILLISECONDS)
		.subscribeOn(Schedulers.io())		//io线程接收键盘输入
		.observeOn(Schedulers.newThread())	//子线程匹配表情
		.flatMap(new Function<String,  Observable<ArrayList<PopEmotionItem>>>() {

			@Override
			public Observable<ArrayList<PopEmotionItem>> apply(String text) throws Exception {
				// TODO Auto-generated method stub
//				Thread.sleep(3000);	//test 我可能会处理得很慢
				ArrayList<PopEmotionItem> popEmotionItems = new ArrayList<PopEmotionItem>();
				text = text.toUpperCase();
				int sum = 0;
				//遍历小高表
				if(mMagicIconItems != null){
					for(int k = 0 ; k < mMagicIconItems.length ; k++){
						if(sum == MAX)break;
						if(mMagicIconItems[k].title.toUpperCase().startsWith(text)){
							PopEmotionItem emtion = new PopEmotionItem();
							emtion.type =
									PopEmotionItem.EmotionType.MagicIcon;
							emtion.emotion = mMagicIconItems[k];
							popEmotionItems.add(emtion);
							sum ++;
						}
					}
				}
				
				if(mEmotionItems != null){
					//遍历高表
					for(int i = 0 ; i < mEmotionItems.length ; i++){
						if(sum == MAX)break;
						if(mEmotionItems[i].title.toUpperCase().startsWith(text)){
//							emtion.mEmotions.add(mEmotionItems[i]);
							PopEmotionItem emtion = new PopEmotionItem();
							emtion.type = PopEmotionItem.EmotionType.Emotion;
							emtion.emotion = mEmotionItems[i];
							popEmotionItems.add(emtion);
							sum ++;
						}
					}
				}
				
				return Observable.just(popEmotionItems);
			}
		})
		.observeOn(AndroidSchedulers.mainThread())//主线程显示表情
		.subscribe(new Observer<ArrayList<PopEmotionItem>>() {

			@Override
			public void onComplete() {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onError(Throwable arg0) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onNext(ArrayList<PopEmotionItem> popEmotionItems) {
				// TODO Auto-generated method stub
				//更新数据源
				mPopEmotionItems.clear();
				mPopEmotionItems.addAll(popEmotionItems);
				showPopupWindow();
			}

			@Override
			public void onSubscribe(Disposable arg0) {
				// TODO Auto-generated method stub
				
			}
		});
		
	}
	
	/**
	 * 弹出表情
	 */
	private void showPopupWindow(){
		if(mPopEmotionItems.size() > 0){
			if(mUnblockPopupWindow == null){
				//容器
				mContentView = (LinearLayout)LayoutInflater.from(mAnchorView.getContext()).inflate(R.layout.layout_popemotion_lc, null);
				//得到控件
				mRecyclerView = (RecyclerView)mContentView.findViewById(R.id.rvh_popemotions);
				//设置布局管理器
				LinearLayoutManager linearLayoutManager = new LinearLayoutManager(mActivity);
				linearLayoutManager.setAutoMeasureEnabled(true);
				linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
				mRecyclerView.setLayoutManager(linearLayoutManager);
				mRecyclerView.addItemDecoration(new LinearLayoutSpacesItemDecoration(2,0));
				//设置适配器
				mAdapter = new PopemotionsAdapter(mActivity , mPopEmotionItems);
				mAdapter.setOnItemClickListener(new PopemotionsAdapter.OnItemClickListener() {
					
					@Override
					public void onMagicIconClick(MagicIconItem magicIcon) {
						// TODO Auto-generated method stub

						//关闭
						hidePopupWindow();
						//回调
						if(mPopEmotionListener != null){
							mPopEmotionListener.onMagicItemClick(magicIcon);
						}
					}
					
					@Override
					public void onEmotionClick(OtherEmotionConfigEmotionItem emotion) {
						// TODO Auto-generated method stub
						
						//关闭
						hidePopupWindow();
						//回调
						if(mPopEmotionListener != null){
							mPopEmotionListener.onEmotionItemClick(emotion);
						}
					}
				});
				mRecyclerView.setAdapter(mAdapter);
				
				//控制显示
				mUnblockPopupWindow = new UnblockPopupWindow(mActivity);
				mUnblockPopupWindow.show(mAnchorView, mContentView, 0, 0);
			}else{
				mAdapter.notifyDataSetChanged();
			}
		}else{
			hidePopupWindow();
		}
	}
	
	/**
	 * 隐藏 并 回收
	 */
	private void hidePopupWindow(){
		if(mUnblockPopupWindow != null){
			mUnblockPopupWindow.dismiss();
			//各种回收
			mRecyclerView.setAdapter(null);
			mRecyclerView.removeAllViews();
			mRecyclerView = null;
			mUnblockPopupWindow = null;
		}
	}
}
