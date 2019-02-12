package com.qpidnetwork.livemodule.liveshow.livechat.downloader;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livechat.LCMagicIconItem;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerMagicIconListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconConfig;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;
import com.qpidnetwork.livemodule.view.MaterialProgressBar;

import java.io.File;

/**
 * 仅用于列表显示的下载器
 * 
 * @author Hunter
 * 
 */
public class MagicIconImageDownloader implements LiveChatManagerMagicIconListener {
	
	private static final int DOWNLOAD_MAGICICON_THUMB_SUCCESS = 1;
	
	private LiveChatManager mLiveChatManager;
	private ImageView magicIconPhoto;
	private MaterialProgressBar pbDownload;
	private ImageButton btnError;
	private LCMessageItem msgBean;
	
	private Context mContext;
	
	public MagicIconImageDownloader(Context context) {
		mLiveChatManager = LiveChatManager.getInstance();
		mContext = context;
	}

	public void displayMagicIconPhoto(ImageView magicIconPhoto,
			MaterialProgressBar pbDownload, LCMessageItem msgBean,
			ImageButton btnError) {
		this.magicIconPhoto = magicIconPhoto;
		this.pbDownload = pbDownload;
		this.msgBean = msgBean;
		this.btnError = btnError;
		Bitmap bitmap = ImageUtil.decodeHeightDependedBitmapFromFile((BitmapFactory.decodeResource(mContext.getResources(), R.drawable.ic_default_live_preminum_emotion_grey_56dp)), mContext.getResources().getDimensionPixelSize(R.dimen.live_chat_magic_icon_height));
		magicIconPhoto.setImageBitmap(ImageUtil.get2DpRoundedImage(mContext, bitmap));
		
		if(!loadLocalFile()){
			if(reloadPhoto()){
				//add by Jagger 2018-11-22
				//下载成功,再从本地取,并显示
				loadLocalFile();
			}
		}
	}
	
	/**
	 *  如果本地文件有，加载本地文件
	 * @return 是否加载成功
	 */
	private boolean loadLocalFile(){
		
		boolean isLoad = false;
		if (btnError != null) {
			btnError.setVisibility(View.GONE);
		}
		String filePath = "";
		if(msgBean.getMagicIconItem()!= null){
			filePath = msgBean.getMagicIconItem().getThumbPath();
		}

		if ((!TextUtils.isEmpty(filePath)) && (new File(filePath).exists())) {
			/* 本地已存在图片 */
			if (pbDownload != null) {
				pbDownload.setVisibility(View.GONE);
			}
			/* 有缩略图，直接使用 */
			Bitmap thumb = BitmapFactory.decodeFile(msgBean.getMagicIconItem().getThumbPath());
			if(magicIconPhoto != null){
				magicIconPhoto.setImageBitmap(thumb);
			}
			isLoad = true;
		}
		return isLoad;
	}
	
	/**
	 * 本地没有或下载失败，重新下载
	 */
	private boolean reloadPhoto(){
		boolean success = false;
		if(btnError != null){
			btnError.setVisibility(View.GONE);
		}
		if (pbDownload != null) {
			pbDownload.setVisibility(View.VISIBLE);
		}
		mLiveChatManager.RegisterMagicIconListener(this);
		success = mLiveChatManager.GetMagicIconThumbImage(msgBean.getMagicIconItem().getMagicIconId());
		Log.i("Jagger" , "MagicIconImageDownloader reloadPhoto success:" + success);
		if (!success) {
			if (pbDownload != null) {
				pbDownload.setVisibility(View.GONE);
			}
			mLiveChatManager.UnregisterMagicIconListener(this);
			onDownloadPrivatePhotoFailed();
		}
		return success;
	}

	/**
	 * 下载私密照失败公共处理
	 */
	private void onDownloadPrivatePhotoFailed() {
		if (btnError != null) {
			btnError.setVisibility(View.VISIBLE);
			btnError.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					/* 下载失败，提示及重新下载 */
					MaterialDialogAlert dialog = new MaterialDialogAlert(
							mContext);
					dialog.setMessage(mContext
							.getString(R.string.live_chat_download_magicicon_fail));
					dialog.addButton(dialog.createButton(
							mContext.getString(R.string.live_common_btn_retry),
							new OnClickListener() {

								@Override
								public void onClick(View v) {
									/* 文件不存在，下载文件 */
									reloadPhoto();
								}
							}));
					dialog.addButton(dialog.createButton(
							mContext.getString(R.string.common_btn_cancel),
							null));

					dialog.show();
				}
			});
		}
	}

	private Handler handler = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case DOWNLOAD_MAGICICON_THUMB_SUCCESS:{
				mLiveChatManager.UnregisterMagicIconListener(MagicIconImageDownloader.this);
				if (pbDownload != null) {
					pbDownload.setVisibility(View.GONE);
				}
				if(msg.arg1 == 1){
					//success callback
					if(loadLocalFile()){
						return;
					}
				}

				onDownloadPrivatePhotoFailed();
			}break;

			default:
				break;
			}
		}
	};

	// ---------------  MagicIcon callback ----------------------
	@Override
	public void OnGetMagicIconConfig(boolean success, String errno,
			String errmsg, MagicIconConfig item) {
		// TODO Auto-generated method stub
		
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
		if(magicIconItem != null && 
				magicIconItem.getMagicIconId().equals(msgBean.getMagicIconItem().getMagicIconId())){
			Message msg = Message.obtain();
			msg.what = DOWNLOAD_MAGICICON_THUMB_SUCCESS;
			msg.arg1 = success?1:0;
			msg.obj = magicIconItem;
			handler.sendMessage(msg);
		}
		
	}
	
	/**
	 * 重置下载器
	 */
	public void reset(){
		if(mLiveChatManager != null){
			mLiveChatManager.UnregisterMagicIconListener(this);
		}
		magicIconPhoto = null;
		pbDownload = null;
		btnError = null;
	}

}
