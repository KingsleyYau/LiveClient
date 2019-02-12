package com.qpidnetwork.livemodule.liveshow.livechat.normalexp;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout.LayoutParams;
import android.widget.RelativeLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.livechat.LCMagicIconItem;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerMagicIconListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconConfig;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconItem;
import com.qpidnetwork.livemodule.liveshow.livechat.LiveChatTalkActivity;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.qnbridgemodule.util.BroadcastManager;

import java.io.File;
import java.util.List;

@SuppressLint("ValidFragment")
public class MagicIconsOtherFragment extends BaseFragment implements
		LiveChatManagerMagicIconListener {

	private static final int GET_MAGICICON_THUNMB_CALLBACK = 1;

	private GridView gvMagicIcon;

	private List<MagicIconItem> mIconItemList;
	private MagicIconGridviewAdapter mAdapter;
	private LiveChatManager mLiveChatManager;

	private int mVpHeight = 0;

	//add by Jagger 2018-2-11
	public MagicIconsOtherFragment(){}

	public MagicIconsOtherFragment(int vpHeight, List<MagicIconItem> iconItemList) {
		super();
		this.mIconItemList = iconItemList;
		this.mVpHeight = vpHeight;
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View view = inflater.inflate(R.layout.fragment_live_magic_gridview_lc, null);
		gvMagicIcon = (GridView) view.findViewById(R.id.gvMagicIcon);
		return view;
	}

	@Override
	public void onActivityCreated(@Nullable Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onActivityCreated(savedInstanceState);
		
		int gvHeight = (mVpHeight - DisplayUtil.dip2px(mContext, 40 + 10));
		
		if(gvHeight>0){
			gvMagicIcon.setLayoutParams(new RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, gvHeight));
		}
		
		mLiveChatManager = LiveChatManager.getInstance();
		if (mIconItemList.size() > 0) {
			mLiveChatManager.RegisterMagicIconListener(this);
			mAdapter = new MagicIconGridviewAdapter(getActivity(),(gvHeight-DisplayUtil.dip2px(mContext, 1))/2,mIconItemList);
			gvMagicIcon.setAdapter(mAdapter);
			gvMagicIcon.setOnItemClickListener(new OnItemClickListener() {
				@Override
				public void onItemClick(AdapterView<?> parent, View view,int position, long id) {
					MagicIconItem item = mIconItemList.get(position);
					Intent intent = new Intent(LiveChatTalkActivity.SEND_MAGICICON_ACTION);
					intent.putExtra(LiveChatTalkActivity.MAGICICON_ID, item.id);
//					mContext.sendBroadcast(intent);
					BroadcastManager.sendBroadcast(mContext,intent);
				}
			});
		}
	}


	@Override
	protected void handleUiMessage(Message msg) {
		// TODO Auto-generated method stub
		super.handleUiMessage(msg);
		switch (msg.what) {
		case GET_MAGICICON_THUNMB_CALLBACK: {
			LCMagicIconItem item = (LCMagicIconItem) msg.obj;
			if (item != null) {
				String localPath = item.getThumbPath();
				if (!TextUtils.isEmpty(localPath)
						&& (new File(localPath).exists())) {
					updateMagicThumbImage(item);
				}
			}
			mAdapter.notifyDataSetChanged();
		}
			break;

		default:
			break;
		}
	}

	private void updateMagicThumbImage(LCMagicIconItem item) {
		if (item != null) {
			int position = -1;
			if (mIconItemList != null) {
				for (int i = 0; i < mIconItemList.size(); i++) {
					if (mIconItemList.get(i).id.equals(item.getMagicIconId())) {
						position = i;
						break;
					}
				}
			}

			if (position >= 0) {
				/* 更新单个Item */
				View childAt = gvMagicIcon.getChildAt(position
						- gvMagicIcon.getFirstVisiblePosition());
				if (childAt != null) {
					ImageView magicIconImage = ((ImageView) childAt
							.findViewById(R.id.icon));
//					new ImageViewLoader(mContext).DisplayImage(magicIconImage,
//							null, item.getThumbPath(), null);
					PicassoLoadUtil.loadLocal(magicIconImage, R.drawable.ic_default_live_preminum_emotion_grey_56dp, item.getThumbPath());
				}
			}
		}
	}

	@Override
	public void onDetach() {
		// TODO Auto-generated method stub
		super.onDetach();
		mLiveChatManager.UnregisterMagicIconListener(this);
	}

	// ------------------ MagicIcon relative callback --------------------------
	@Override
	public void OnGetMagicIconConfig(boolean success, String errno,
			String errmsg, MagicIconConfig item) {

	}

	@Override
	public void OnSendMagicIcon(LiveChatClientListener.LiveChatErrType errType, String errmsg,
								LCMessageItem item) {

	}

	@Override
	public void OnRecvMagicIcon(LCMessageItem item) {

	}

	@Override
	public void OnGetMagicIconSrcImage(boolean success,
			LCMagicIconItem magicIconItem) {
	}

	@Override
	public void OnGetMagicIconThumbImage(boolean success,
			LCMagicIconItem magicIconItem) {
		if (success) {
			Message msg = Message.obtain();
			msg.what = GET_MAGICICON_THUNMB_CALLBACK;
			msg.obj = magicIconItem;
			sendUiMessage(msg);
		}
	}

}
