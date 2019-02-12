package com.qpidnetwork.livemodule.liveshow.message;

import android.os.Bundle;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.httprequest.OnGetEmotionListCallback;
import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory;
import com.qpidnetwork.livemodule.httprequest.item.EmotionItem;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.EmojiTabScrollLayout;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * @author Yanni
 * 
 * @version 2016-6-4
 */
public class LiveEmojiListFragment extends BaseFragment {

	public static final int LIVE_EMOJI_LIST_UPDATE = 1;

	public static final String EMOJIPANELHEIGHT = "emojiPanelHeight";
	private EmojiTabScrollLayout mEmojiTabScrollLayout;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		View view = inflater.inflate(R.layout.fragment_private_msg_emoji, null);
		mEmojiTabScrollLayout = (EmojiTabScrollLayout) view.findViewById(R.id.etsl_emojiContainer);
		mEmojiTabScrollLayout.setTabTitles(ChatEmojiManager.getInstance().getEmotionTagNames());
		mEmojiTabScrollLayout.setItemMap(ChatEmojiManager.getInstance().getTagEmotionMap());
		//xml来控制
		mEmojiTabScrollLayout.setViewStatusChangedListener(
				new EmojiTabScrollLayout.ViewStatusChangeListener() {
					@Override
					public void onTabClick(int position, String title) {
					}

					@Override
					public void onGridViewItemClick(View itemChildView, int position, String title, Object obj) {
						onEmojiChoosed((EmotionItem) obj);
					}
				});
		Bundle bundle = getArguments();
		if(null != bundle && bundle.containsKey(EMOJIPANELHEIGHT)){
			int emojiPanelHeight = bundle.getInt(EMOJIPANELHEIGHT);
			if(emojiPanelHeight > 0){
				ViewGroup.LayoutParams layoutParams = mEmojiTabScrollLayout.getLayoutParams();
				layoutParams.height = emojiPanelHeight;
				mEmojiTabScrollLayout.setLayoutParams(layoutParams);

				mEmojiTabScrollLayout.setEmojiPanelHeight(emojiPanelHeight);
			}
		}
		mEmojiTabScrollLayout.setEmojiIndicBgResId(R.drawable.selector_emoji_indicator_message);
		mEmojiTabScrollLayout.notifyDataChanged();
		return view;
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		TAG = LiveEmojiListFragment.class.getSimpleName();
		getEmojiList();
	}

	public void onEmojiChoosed(EmotionItem emotionItem){
		Log.d(TAG,"onEmojiChoosed-emotionItem:"+emotionItem);
		if(null != getActivity() && getActivity() instanceof  OnEmojiSelectListener){
			((OnEmojiSelectListener) getActivity()).onEmojiSelect(emotionItem);
		}
	}

	@Override
	public void onDetach() {
		super.onDetach();
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
	}

	public interface OnEmojiSelectListener{
		public void onEmojiSelect(EmotionItem emotionItem);
	}

	@Override
	protected void handleUiMessage(Message msg) {
		super.handleUiMessage(msg);
		switch (msg.what){
			case LIVE_EMOJI_LIST_UPDATE:{
				if(mEmojiTabScrollLayout != null){
					mEmojiTabScrollLayout.setTabTitles(ChatEmojiManager.getInstance().getEmotionTagNames());
					mEmojiTabScrollLayout.setItemMap(ChatEmojiManager.getInstance().getTagEmotionMap());
					mEmojiTabScrollLayout.notifyDataChanged();
				}
			}break;
		}
	}

	/**
	 * 获取Emoji  list
	 */
	private void getEmojiList(){
		ChatEmojiManager.getInstance().getEmojiList(new OnGetEmotionListCallback() {
			@Override
			public void onGetEmotionList(boolean isSuccess, int errCode, String errMsg, EmotionCategory[] emotionCategoryList) {
				sendEmptyUiMessage(LIVE_EMOJI_LIST_UPDATE);
			}
		});
	}
}
