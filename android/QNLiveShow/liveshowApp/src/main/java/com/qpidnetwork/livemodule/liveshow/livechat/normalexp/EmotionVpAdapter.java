package com.qpidnetwork.livemodule.liveshow.livechat.normalexp;

import android.annotation.SuppressLint;
import android.content.Context;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigEmotionItem;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.KeyBoardManager;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * @author Yanni
 * 
 * @version 2016-6-3
 */
public class EmotionVpAdapter extends FragmentPagerAdapter {

	private Context mContext;
	private int mVpHeight = 0;
	private int count = 1;
	private OtherEmotionConfigEmotionItem[] mEmotionArray;
	private int mPageItemCount = 10;// 每页显示item数量
	private List<OtherEmotionConfigEmotionItem> mTempEmotionItems;// 临时存放的item
	private HashMap<Integer, WeakReference<Fragment>> mPageReference;
	private EmotionsItemFragment.OnItemClickCallback mOnItemClickCallBack;

	@SuppressLint("UseSparseArrays")
	public EmotionVpAdapter(FragmentManager fm, Context context,
			OtherEmotionConfigEmotionItem[] emotionArray) {
		super(fm);
		this.mContext = context;
		this.mEmotionArray = emotionArray;
		this.count = getFragmentCount();
		mPageReference = new HashMap<Integer, WeakReference<Fragment>>();
		getVpHeigth();
	}
	
	public void setOnItemClickCallback(EmotionsItemFragment.OnItemClickCallback onItemClickCallBack){
		this.mOnItemClickCallBack = onItemClickCallBack;
	}

	private void getVpHeigth() {
		// TODO Auto-generated method stub
		int itemWidth = DisplayUtil.getScreenWidth(mContext) / 8;
		mVpHeight = KeyBoardManager.getKeyboardHeight(mContext) - itemWidth- DisplayUtil.dip2px(mContext, 20+1);
	}

	private int getFragmentCount() {
		// TODO Auto-generated method stub
		int lenth = mEmotionArray.length;
		if (lenth > 0) {
			float f = (float) lenth / mPageItemCount;
			count = (int) Math.ceil(f);// 向上取整
		}
		return count;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return count;
	}

	@Override
	public Fragment getItem(int position) {
		// TODO Auto-generated method stub
		Fragment fragment = null;
		if (mPageReference.containsKey(position)) {
			fragment = mPageReference.get(position).get();
		}
		if (fragment == null) {
			mTempEmotionItems = getPageEmotionItems(mEmotionArray, position);// 获取指定页的item数据
			fragment = new EmotionsItemFragment(mVpHeight, mTempEmotionItems);
			if(mOnItemClickCallBack!=null){
				((EmotionsItemFragment)fragment).setOnItemClickCallback(mOnItemClickCallBack);
			}
			mPageReference.put(position, new WeakReference<Fragment>(fragment));
		}
		return fragment;
	}

	/**
	 * @param item
	 * @param position
	 * @return 获取指定页显示小高表数据
	 */
	public List<OtherEmotionConfigEmotionItem> getPageEmotionItems(
			OtherEmotionConfigEmotionItem[] item, int position) {
		List<OtherEmotionConfigEmotionItem> itemList = new ArrayList<>();
		int startIndex = mPageItemCount * position;
		int endIndex = mPageItemCount * (position + 1);
		if (item.length <= endIndex) {
			endIndex = item.length;
		}
		for (int i = startIndex; i < endIndex; i++) {
			itemList.add(item[i]);
		}

		return itemList;
	}

}
