package com.qpidnetwork.livemodule.liveshow.livechat.normalexp;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.FrameLayout.LayoutParams;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.utils.DisplayUtil;

/**
 * @author Yanni
 * 
 * @version 2016-4-12
 */
public class NormalExprssionFragment extends BaseFragment {
	
//	private LinearLayout llTab;//底部导航

	private FragmentManager mFragmentManager;
	private FragmentTransaction transaction;
	private MagicIconsFragment mMagicIconsFragment;//小高表
	private EmotionsFragment mEmotionsFragment;//高表

	public enum NormalType {
		MaigicIcon, Emotion
	}
	
	
	@Override
	public void onAttach(Activity activity) {
		// TODO Auto-generated method stub
		super.onAttach(activity);
		mFragmentManager = getChildFragmentManager();
	}
	

	@SuppressLint("InflateParams")
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View view = inflater.inflate(R.layout.view_live_stub_expression_lc, null);
//		llTab = (LinearLayout) view.findViewById(R.id.llTab);
//		addBottomTab();// 生成底部导航
		return view;
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onActivityCreated(savedInstanceState);
		updateView(NormalType.MaigicIcon);
	}

	/**
	 * @param type
	 * 替换fragmetn
	 */
	private void updateView(NormalType type) {
		// TODO Auto-generated method stub
		transaction = mFragmentManager.beginTransaction();
		if (type.equals(NormalType.MaigicIcon)) {
			mMagicIconsFragment = new MagicIconsFragment();
			transaction.replace(R.id.flNormalPane, mMagicIconsFragment);
//			updateSelectTabBg(0);
		} else if (type.equals(NormalType.Emotion)) {
			mEmotionsFragment = new EmotionsFragment();
			transaction.replace(R.id.flNormalPane, mEmotionsFragment);
//			updateSelectTabBg(1);
		}
		transaction.commit();
	}

	//del by Jagger 2018-11-23 注释掉大高表相关
	/**
	 * @param position 
	 * 
	 * 更新选中tab背景
	 */
//	protected void updateSelectTabBg(int position) {
//		// TODO Auto-generated method stub
//		for (int i = 0; i < llTab.getChildCount(); i++) {
//			llTab.getChildAt(i).setBackgroundColor(getActivity().getResources().getColor(R.color.white));
//		}
//		llTab.getChildAt(position).setBackgroundColor(getActivity().getResources().getColor(R.color.light_gray));
//	}


//	private void addBottomTab() {
//		// TODO Auto-generated method stub
//		llTab.removeAllViews();
//
//		int itemWidth = DisplayUtil.getScreenWidth(mContext) / 8;
//		llTab.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, itemWidth));
//
//		LinearLayout llMagic = new LinearLayout(getActivity());
//		llMagic.setLayoutParams(new LinearLayout.LayoutParams(itemWidth,itemWidth));
//		llMagic.setGravity(Gravity.CENTER_VERTICAL);
//		llMagic.setOnClickListener(new OnClickListener() {
//			@Override
//			public void onClick(View v) {
//				// TODO Auto-generated method stub
//				updateView(NormalType.MaigicIcon);
//			}
//		});
//
//		ImageView ivMagic = new ImageView(getActivity());
//		ivMagic.setImageResource(R.drawable.ic_live_chat_emoji_default);
//		ivMagic.setLayoutParams(new LayoutParams(itemWidth,ViewGroup.LayoutParams.WRAP_CONTENT));
//
//		llMagic.addView(ivMagic);
//		llTab.addView(llMagic);
//
//		LinearLayout llEmotion = new LinearLayout(getActivity());
//		llEmotion.setLayoutParams(new LinearLayout.LayoutParams(itemWidth,itemWidth));
//		llEmotion.setGravity(Gravity.CENTER_VERTICAL);
//		llEmotion.setOnClickListener(new OnClickListener() {
//			@Override
//			public void onClick(View v) {
//				// TODO Auto-generated method stub
//				updateView(NormalType.Emotion);
//			}
//		});
//
//		ImageView ivEmotion = new ImageView(getActivity());
//		ivEmotion.setImageResource(R.drawable.ic_live_chat_emoji_default);
//		ivEmotion.setLayoutParams(new LayoutParams(itemWidth,ViewGroup.LayoutParams.WRAP_CONTENT));
//
//		llEmotion.addView(ivEmotion);
//		llTab.addView(llEmotion);
//	}
}
