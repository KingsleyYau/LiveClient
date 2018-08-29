package com.qpidnetwork.livemodule.liveshow.message;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.httprequest.item.EmotionItem;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.EmojiTabScrollLayout;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * @author Yanni
 * 
 * @version 2016-6-4
 */
public class LiveEmojiListFragment extends BaseFragment {

	public static final String EMOJIPANELHEIGHT = "emojiPanelHeight";
	private int emojiPanelHeight;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		View view = inflater.inflate(R.layout.fragment_private_msg_emoji, null);
		EmojiTabScrollLayout etsl_emojiContainer = (EmojiTabScrollLayout) view.findViewById(R.id.etsl_emojiContainer);
		etsl_emojiContainer.setTabTitles(ChatEmojiManager.getInstance().getEmotionTagNames());
		etsl_emojiContainer.setItemMap(ChatEmojiManager.getInstance().getTagEmotionMap());
		//xml来控制
		etsl_emojiContainer.setViewStatusChangedListener(
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
			emojiPanelHeight =bundle.getInt(EMOJIPANELHEIGHT);
			if(emojiPanelHeight>0){
				etsl_emojiContainer.getLayoutParams().height = emojiPanelHeight;
				etsl_emojiContainer.setEmojiPanelHeight(emojiPanelHeight);
			}
		}
		etsl_emojiContainer.setEmojiIndicBgResId(R.drawable.selector_emoji_indicator_message);
		etsl_emojiContainer.notifyDataChanged();
		return view;
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		TAG = LiveEmojiListFragment.class.getSimpleName();
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
}
