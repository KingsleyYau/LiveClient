package com.qpidnetwork.livemodule.liveshow.livechat.normalexp;

import android.annotation.SuppressLint;
import android.content.Context;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconItem;
import com.qpidnetwork.livemodule.liveshow.model.MagicIconHomeParamBean;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.KeyBoardManager;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * @author Yanni
 * 
 * @version 2016-6-2
 * 
 * ViewPager小高表Adatper
 */
public class MagicIconVpAdapter extends FragmentPagerAdapter {

	private Context mContext;
	private int mVpHeight;//ViewPager高度
	private MagicIconItem[] mMagicIconArray;// 小高表列表
	private int count = 1;
	private int mHomeItemCount = 5;//首页显示5个item
	private int mPageItemCount = 10;//其他页显示10个item
	private List<MagicIconItem> mHomeMagicItems;//保存首页显示的item
	private List<MagicIconItem> mTempMagicItems;//其他页临时存放的item
	private HashMap<Integer, WeakReference<Fragment>> mPageReference;

	@SuppressLint("UseSparseArrays")
	public MagicIconVpAdapter(FragmentManager fm, Context context, MagicIconItem[] magicIconArray) {
		super(fm);
		this.mContext = context;
		this.mMagicIconArray = magicIconArray;
		this.count = getFragmentCount();
		mPageReference = new HashMap<Integer, WeakReference<Fragment>>();
		getVpHeigth();
	}

	private void getVpHeigth() {
		// TODO Auto-generated method stub
		int itemWidth = DisplayUtil.getScreenWidth(mContext) / 8;
		//计算整个ViewPager显示高度   keyBoardHeight-底部导航Height-分割线height
		mVpHeight = KeyBoardManager.getKeyboardHeight(mContext) - itemWidth - DisplayUtil.dip2px(mContext, 20+1);
	}

	private int getFragmentCount() {
		// TODO Auto-generated method stub
		int lenth = mMagicIconArray.length;
		if(lenth>0){
			float f = (float)(lenth-mHomeItemCount)/mPageItemCount;
			count+= (int) Math.ceil(f);//向上取整
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
		Fragment fragment = null;
		if (mPageReference.containsKey(position)) {
			fragment = mPageReference.get(position).get();
		}
		if (fragment == null) {
			if (position == 0) {
				mHomeMagicItems = getHomeMagicItems(mMagicIconArray);//获取首页item数据
				fragment = MagicIconHomeFragment.newInstance(new MagicIconHomeParamBean(mVpHeight, mHomeMagicItems));//首页
			} else {
				mTempMagicItems = getPageMagicItems(mMagicIconArray,position);//获取指定页的item数据
				fragment = new MagicIconsOtherFragment(mVpHeight,mTempMagicItems);//其他页
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
	public List<MagicIconItem> getPageMagicItems(MagicIconItem[] item, int position) {
		List<MagicIconItem> itemList = new ArrayList<>();
		int startIndex = mHomeItemCount + mPageItemCount * (position-1);
		int endIndex = mPageItemCount * position + mHomeItemCount;
		if(item.length<=endIndex){
			endIndex = item.length;
		}
		for (int i = startIndex; i < endIndex; i++) {
			itemList.add(item[i]);
		}
		
		return itemList;
	}

	/**
	 * @param item
	 * @return 获取首页显示小高表数据
	 */
	public List<MagicIconItem> getHomeMagicItems(MagicIconItem[] item) {
		// TODO Auto-generated method stub
		List<MagicIconItem> itemList = new ArrayList<>();
		if(item!=null&&item.length>0){
			if(item.length <= mHomeItemCount){
				mHomeItemCount = item.length;
			}
			for (int i = 0; i < mHomeItemCount; i++) {
				itemList.add(item[i]);
			}
		}
		return itemList;
	}

}
