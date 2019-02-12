package com.qpidnetwork.livemodule.liveshow.livechat.normalexp;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridView;
import android.widget.LinearLayout.LayoutParams;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigEmotionItem;
import com.qpidnetwork.livemodule.utils.DisplayUtil;

import java.util.List;

/**
 * @author Yanni
 * 
 * @version 2016-6-3
 */
@SuppressLint("ValidFragment")
public class EmotionsItemFragment extends BaseFragment {

	private TextView tvEmotionPrice;// 价格
	private GridView gvEmotion;
	public OnItemClickCallback itemClickCallback;

	private List<OtherEmotionConfigEmotionItem> mEmotionItemList;
	private EmotionGridviewAdapter mAdapter;

	private int mVpHeight = 0;

	public EmotionsItemFragment(int vpHeight,
			List<OtherEmotionConfigEmotionItem> emotionItemList) {
		super();
		this.mEmotionItemList = emotionItemList;
		this.mVpHeight = vpHeight;
	}

	public interface OnItemClickCallback {
		public void onItemClick();

		public void onItemLongClick();

		public void onItemLongClickUp();
	}

	public void setOnItemClickCallback(OnItemClickCallback callback) {
		this.itemClickCallback = callback;
	};

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View view = inflater.inflate(R.layout.fragment_live_emotion_vp_gridview_lc, null);
		tvEmotionPrice = (TextView) view.findViewById(R.id.tvEmtionPrice);
		gvEmotion = (GridView) view.findViewById(R.id.gvEmotion);
		return view;
	}

	@Override
	public void onActivityCreated(@Nullable Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onActivityCreated(savedInstanceState);

		int gvHeight = (mVpHeight - DisplayUtil.dip2px(mContext, 35 + 10));

		if(gvHeight>0){
			gvEmotion.setLayoutParams(new RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, gvHeight));
		}

		if (mEmotionItemList.size() > 0) {
			tvEmotionPrice.setText(getMagicPrice(mEmotionItemList));// 获取价格最大最小值
			mAdapter = new EmotionGridviewAdapter(mContext, gvHeight,mEmotionItemList, gvEmotion, itemClickCallback);
			gvEmotion.setAdapter(mAdapter);
		}
	}

	/**
	 * 获取价格
	 */
	private String getMagicPrice(List<OtherEmotionConfigEmotionItem> item) {
		// TODO Auto-generated method stub
		String priceDesc = "";
		Double minPrice = item.get(0).price;
		Double maxPrice = item.get(0).price;
		for (int i = 0; i < item.size(); i++) {
			if (minPrice > item.get(i).price) {
				minPrice = item.get(i).price;
			}
			if (maxPrice < item.get(i).price) {
				maxPrice = item.get(i).price;
			}
		}
		String tips = getActivity().getResources().getString(R.string.live_chat_magicIcon_price_desc);
		if (minPrice.equals(maxPrice)){
			priceDesc = String.format(tips, maxPrice.toString());
		}else{
			priceDesc = String.format(tips, minPrice.toString()+ " - " +maxPrice.toString());
		}
		//priceDesc = String.format(tips, minPrice.toString(),maxPrice.toString());
		return priceDesc;
	}

}
