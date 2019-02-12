package com.qpidnetwork.livemodule.liveshow.livechat.normalexp;

import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.livechat.LCEmotionItem;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerEmotionListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigEmotionItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigTypeItem;
import com.qpidnetwork.livemodule.view.AbilitySwapablePageView;
import com.qpidnetwork.livemodule.view.DotsView;
import com.qpidnetwork.livemodule.view.MaterialProgressBar;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * @author Yanni
 * 
 * @version 2016-6-4
 */
public class EmotionsFragment extends BaseFragment implements LiveChatManagerEmotionListener,OnPageChangeListener{
	
	private static final int GET_EMOTION_CALLBACK = 1;
	
	private AbilitySwapablePageView mViewPager;
	private MaterialProgressBar mProgress;
	private DotsView dvPoint;
	
	private LiveChatManager mLiveChatManager;
	private OtherEmotionConfigItem mEmotionConfig;// 高表配置
	
	private EmotionVpAdapter mEmotionVpAdapter;// 高表ViewPagerAdatpter

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		View view = inflater.inflate(R.layout.fragment_live_magicicon_lc, null);
		mViewPager = (AbilitySwapablePageView) view.findViewById(R.id.viewPager);
		mProgress = (MaterialProgressBar) view.findViewById(R.id.progress);
		dvPoint = (DotsView) view.findViewById(R.id.dvPoint);
		mViewPager.addOnPageChangeListener(this);
		return view;
	}
	
	@Override
	public void onActivityCreated(@Nullable Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onActivityCreated(savedInstanceState);
		mLiveChatManager = LiveChatManager.getInstance();
		mLiveChatManager.RegisterEmotionListener(this);
		mEmotionConfig = mLiveChatManager.GetEmotionConfigItem();
		
		if (mEmotionConfig == null) {
			// 本地无配置，调用接口获取或更新
			mProgress.setVisibility(View.VISIBLE);
			mLiveChatManager.GetEmotionConfig();
		}else{
			updateView();//填充数据
		}
	}
	
	/**
	 * 更新Ui
	 */
	private void updateView() {
		// TODO Auto-generated method stub
		OtherEmotionConfigEmotionItem[] emotionArray = getOrderByTypeItemArray();//取出排序后高表数据
		if(emotionArray != null && emotionArray.length > 0){
			mEmotionVpAdapter = new EmotionVpAdapter(getChildFragmentManager(),getActivity(), emotionArray);
			mEmotionVpAdapter.setOnItemClickCallback(onItemClickCallback);
			dvPoint.setDotCount(mEmotionVpAdapter.getCount());
			mViewPager.setAdapter(mEmotionVpAdapter);
		}
	}
	
	/**
	 * @return 根据类型排序
	 */
	private OtherEmotionConfigEmotionItem[] getOrderByTypeItemArray(){
		
		OtherEmotionConfigTypeItem[] emotionType = mEmotionConfig.typeList;//小高表type
		OtherEmotionConfigEmotionItem[] emotionItem = mEmotionConfig.manEmotionList;//小高表item
		
		List<OtherEmotionConfigEmotionItem> itemList = new ArrayList<OtherEmotionConfigEmotionItem>();
		
		if(emotionItem==null||emotionItem.length==0){//item为空直接return
			return null;
		}
		
		//type不为空遍历typeItem
		if(emotionType !=null && emotionType.length > 0){
			for (OtherEmotionConfigTypeItem type : emotionType) {
				for (OtherEmotionConfigEmotionItem item : emotionItem) {
					if(item.typeId.equals(type.typeId)){
						itemList.add(item);
					}
				}
			}
		}
		
		
		if(itemList != null && itemList.size() > 0){
			int size = itemList.size();
			return (OtherEmotionConfigEmotionItem[]) itemList.toArray(new OtherEmotionConfigEmotionItem[size]);
		}else{//type为空 item不为空
			return emotionItem;
		}
	}

	
	
	@Override
	public void onDetach() {
		// TODO Auto-generated method stub
		super.onDetach();
		mLiveChatManager.UnregisterEmotionListener(this);
	}
	
	
	@Override
	protected void handleUiMessage(Message msg) {
		// TODO Auto-generated method stub
		super.handleUiMessage(msg);
		switch (msg.what) {
		case GET_EMOTION_CALLBACK:
			mProgress.setVisibility(View.GONE);
			if (msg.arg1 == 1) {// 高表请求成功
				OtherEmotionConfigItem item = (OtherEmotionConfigItem) msg.obj;
				if (item != null) {
					if (mEmotionConfig == null) {
						mEmotionConfig = mLiveChatManager.GetEmotionConfigItem();
						updateView();
					}
				}
			}
			break;
		default:
			break;
		}
	}
	
	
	private EmotionsItemFragment.OnItemClickCallback onItemClickCallback = new EmotionsItemFragment.OnItemClickCallback(){

		@Override
		public void onItemClick() {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void onItemLongClick() {
			// TODO Auto-generated method stub
			mViewPager.setPagingEnabled(false);
			Log.v("paging", "false");
		}

		@Override
		public void onItemLongClickUp() {
			// TODO Auto-generated method stub
			mViewPager.setPagingEnabled(true);
		}
		
	};
	
	

	

	@Override
	public void onPageScrollStateChanged(int arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onPageScrolled(int arg0, float arg1, int arg2) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onPageSelected(int position) {
		// TODO Auto-generated method stub
		dvPoint.selectDot(position);
	}

	@Override
	public void OnGetEmotionConfig(boolean success, String errno,
			String errmsg, OtherEmotionConfigItem item) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		msg.what = GET_EMOTION_CALLBACK;
		msg.arg1 = success ? 1 : 0;
		msg.obj = item;
		sendUiMessage(msg);
	}

	@Override
	public void OnSendEmotion(LiveChatClientListener.LiveChatErrType errType, String errmsg,
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
		
	}

	@Override
	public void OnGetEmotion3gp(boolean success, LCEmotionItem emotionItem) {
		// TODO Auto-generated method stub
		
	}

}
