package com.qpidnetwork.livemodule.liveshow.livechat.normalexp;

import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.livechat.LCMagicIconItem;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerMagicIconListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconConfig;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconType;
import com.qpidnetwork.livemodule.view.DotsView;
import com.qpidnetwork.livemodule.view.MaterialProgressBar;

import java.util.ArrayList;
import java.util.List;


/**
 * @author Yanni
 * 
 * @version 2016-6-4
 */
public class MagicIconsFragment extends BaseFragment implements LiveChatManagerMagicIconListener,OnPageChangeListener{
	
	private static final int GET_MAGICICON_CALLBACK = 1;
	
	private ViewPager mViewPager;
	private MaterialProgressBar mProgress;
	private DotsView dvPoint;
	
	private LiveChatManager mLiveChatManager;
	private MagicIconConfig mMagicIconConfig;// 小高表配置
	
	private MagicIconVpAdapter mMagicIconVpAdapter;// 小高表ViewPagerAdapter
	

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		View view = inflater.inflate(R.layout.fragment_live_magicicon_lc, null);
		mViewPager = (ViewPager) view.findViewById(R.id.viewPager);
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
		mLiveChatManager.RegisterMagicIconListener(this);
		mMagicIconConfig = mLiveChatManager.GetMagicIconConfigItem();
		
		if (mMagicIconConfig == null) {
			// 本地无配置，调用接口获取或更新
			mProgress.setVisibility(View.VISIBLE);
			mLiveChatManager.GetMagicIconConfig();
		}else{
			updateView();
		}
	}
	
	private void updateView() {
		// TODO Auto-generated method stub
		MagicIconItem[] magicIconArray = getOrderByTypeIconArray();//获取排序后小高表数据
		if(magicIconArray != null && magicIconArray.length > 0){
			mMagicIconVpAdapter = new MagicIconVpAdapter(getChildFragmentManager(), getActivity(), magicIconArray);
			dvPoint.setDotCount(mMagicIconVpAdapter.getCount());
			mViewPager.setAdapter(mMagicIconVpAdapter);
		}
	}
	
	
	/**
	 * @return 根据类型排序
	 */
	private MagicIconItem[] getOrderByTypeIconArray(){
		
		MagicIconType[] magicIconType = mMagicIconConfig.magicTypeArray;//小高表type
		MagicIconItem[] magicIconItem = mMagicIconConfig.magicIconArray;//小高表item
		
		List<MagicIconItem> itemList = new ArrayList<MagicIconItem>();
		
		if(magicIconItem==null||magicIconItem.length==0){//item为空直接return
			return null;
		}
		
		//type不为空遍历typeItem
		if(magicIconType !=null && magicIconType.length > 0){
			for (MagicIconType type : magicIconType) {
				for (MagicIconItem item : magicIconItem) {
					if(item.typeId.equals(type.id)){
						itemList.add(item);
					}
				}
			}
		}
		
		
		if(itemList != null && itemList.size() > 0){
			int size = itemList.size();
			return (MagicIconItem[]) itemList.toArray(new MagicIconItem[size]);
		}else{//type为空 item不为空
			return magicIconItem;
		}
	}

	
	
	@Override
	public void onDetach() {
		// TODO Auto-generated method stub
		super.onDetach();
		mLiveChatManager.UnregisterMagicIconListener(this);
	}
	
	
	@Override
	protected void handleUiMessage(Message msg) {
		// TODO Auto-generated method stub
		super.handleUiMessage(msg);
		switch (msg.what) {
		case GET_MAGICICON_CALLBACK:
			mProgress.setVisibility(View.GONE);
			if (msg.arg1 == 1) {// 小高表请求成功
				MagicIconConfig item = (MagicIconConfig) msg.obj;
				if (item != null) {
					if (mMagicIconConfig == null) {
						// 本地无数据或者数据更新时，刷新界面
						mMagicIconConfig = mLiveChatManager.GetMagicIconConfigItem();
						updateView();
					}
				}
			}
			break;
		default:
			break;
		}
	}
	
	

	@Override
	public void OnGetMagicIconConfig(boolean success, String errno,
			String errmsg, MagicIconConfig item) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		msg.what = GET_MAGICICON_CALLBACK;
		msg.arg1 = success ? 1 : 0;
		msg.obj = item;
		sendUiMessage(msg);
		
	}

	@Override
	public void OnSendMagicIcon(LiveChatClientListener.LiveChatErrType errType, String errmsg,
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
		
	}

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

}
