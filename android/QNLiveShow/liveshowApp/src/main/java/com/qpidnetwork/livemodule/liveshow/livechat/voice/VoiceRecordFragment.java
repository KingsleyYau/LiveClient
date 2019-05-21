package com.qpidnetwork.livemodule.liveshow.livechat.voice;

import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.ScaleAnimation;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.liveshow.livechat.LiveChatTalkActivity;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.sysPermissions.manager.PermissionManager;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.io.File;

public class VoiceRecordFragment extends BaseFragment {
	
	//private final int RECORD_RELEASE_AREA_RADIUS = 96;//单位dp
	private final int ON_READY_SIZE = 96;
	private final int ON_RECORD_SIZE = 80;
	

	private RelativeLayout recordPane;
	private TextView tvRecordTitle;
	private TextView priceInfo;
	
	/* 录音动画View */
	private RecordView recordView;
	private ImageView backBtnBg;
	private View foreRecordBtn;
	private View foreCancelBtn;
	private TextView tvRecord;

	/* data 区 */
	private float availableTouchRadius = 0;// 有效触摸范围（release - record）
	private float minRadius = 0;// 根据pane大小，计算刚好覆盖pane的圆的最小半径
	private String saveFilePath = null;// 录音文件本地存放地址
	private RecordStatus recordStatus = RecordStatus.DEFAULT;
	private long mRecordTime = 0; // 记录当前已录音时间
	
	private boolean isStartAnimationCancel = false;//判断开始动画是否被取消，防止取消后仍调用onAnimationEnd

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View view = inflater.inflate(R.layout.fragment_live_chat_voice_record_lc,
				null);
		initViews(view);
		return view;
	}
	
	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onActivityCreated(savedInstanceState);

		int paneHeight = DisplayUtil.dip2px(getActivity(), 300);
		int screenWidth = DisplayUtil.getScreenWidth(getActivity());
		minRadius = (float)Math.sqrt((screenWidth*screenWidth)/4 + (paneHeight * paneHeight)/4);
		availableTouchRadius = DisplayUtil.dip2px(getActivity(), ON_READY_SIZE)/2;
	
	}

	private void initViews(View view) {
		recordPane = (RelativeLayout) view.findViewById(R.id.recordPane);

		tvRecordTitle = (TextView) view.findViewById(R.id.tvRecordTitle);
		priceInfo = (TextView) view.findViewById(R.id.price_info);

		backBtnBg = (ImageView) view.findViewById(R.id.backBtnBg);
		recordView = (RecordView) view.findViewById(R.id.recordView);
		recordView.setOnRecordTimeChangeListener(new RecordView.OnRecordTimeChangeListener() {

					@Override
					public void onRecordTimeCallback(long recordTime) {
						// TODO Auto-generated method stub
						Log.i("Jagger" , "onRecordTimeCallback recordTime:" + recordTime);
						mRecordTime = recordTime;
						if (recordStatus == RecordStatus.RELEASE_TO_CANCEL) {
							tvRecord.setText(DateUtil.getTime(mRecordTime));
						} else {
							tvRecordTitle.setText(DateUtil.getTime(mRecordTime));
							tvRecordTitle.setTextColor(Color.RED);
						}
					}
				});
		foreRecordBtn =  view.findViewById(R.id.foreRecordBtn);
		foreCancelBtn = view.findViewById(R.id.foreCancelBtn);
		tvRecord = (TextView) view.findViewById(R.id.tvRecord);

		//先进行权限检测
		PermissionManager permissionManager = new PermissionManager(mContext, new PermissionManager.PermissionCallback() {
			@Override
			public void onSuccessful() {
				foreRecordBtn.setBackgroundResource(R.drawable.circle_solid_red);
				recordPane.setOnTouchListener(voiceRecordTouch);
			}

			@Override
			public void onFailure() {
				foreRecordBtn.setBackgroundResource(R.drawable.circle_grey_bg);
			}
		});
		permissionManager.requestAudio();

	}

	private OnTouchListener voiceRecordTouch = new OnTouchListener() {

		@Override
		public boolean onTouch(View v, MotionEvent event) {
			int x = (int) event.getX();
			int y = (int) event.getY();
			int width = v.getWidth();
			int height = v.getHeight();
			switch (event.getAction()) {
			case MotionEvent.ACTION_DOWN:
				if ((x > width / 2 - availableTouchRadius)
						&& (x < width / 2 + availableTouchRadius)
						&& (y > height / 2 - availableTouchRadius)
						&& (y < height / 2 + availableTouchRadius)) {
					if ((recordStatus != RecordStatus.DEFAULT)
							&& (recordStatus != RecordStatus.STOP_RECORD)) {
						// 上次录音未结束，点击无响应
						return true;
					}
					recordStatus = RecordStatus.DEFAULT;
					/*开始录音，关闭语音播放*/
					stopPlayVoice();
					playStartRecordAnimation();
				} else {
					// 未点击在有效范围内
					return true;
				}
				break;
			case MotionEvent.ACTION_MOVE:
				if (saveFilePath == null) {
					return true;
				}
				if ((x > width / 2 - availableTouchRadius)
						&& (x < width / 2 + availableTouchRadius)
						&& (y > height / 2 - availableTouchRadius)
						&& (y < height / 2 + availableTouchRadius)) {
					// record
					if ((recordStatus == RecordStatus.RELEASE_TO_CANCEL)
							&& (backBtnBg.getAnimation() != null)) {
						// 由cancel模式切换回start模式，且start转cancel模式动画未结束
						recordStatus = RecordStatus.START_RECORD;
						backBtnBg.getAnimation().cancel();
						backBtnBg.clearAnimation();

						tvRecordTitle.setText(DateUtil.getTime(mRecordTime));
						tvRecordTitle.setTextColor(Color.RED);
						priceInfo.setTextColor(getResources().getColor(R.color.text_color_grey));
						tvRecord.setText(getString(R.string.live_chat_voice_record_speak));
						tvRecord.setTextColor(Color.WHITE);
						foreRecordBtn.setVisibility(View.VISIBLE);
						foreCancelBtn.setVisibility(View.GONE);
					} else if (recordStatus == RecordStatus.RELEASE_TO_CANCEL) {
						// 由cancel模式切换回start模式，且start转cancel模式动画已结束
						recordStatus = RecordStatus.START_RECORD;
						playCancelToStartAnimation();
					}
				} else {
					// release to cancel record
					if ((recordStatus == RecordStatus.START_RECORD)
							&& (backBtnBg.getAnimation() != null)) {
						// 由start模式切换为cancel模式，切由于快速切换的原因，cancel转start动画未结束
						recordStatus = RecordStatus.RELEASE_TO_CANCEL;
						backBtnBg.getAnimation().cancel();
						backBtnBg.clearAnimation();

						tvRecordTitle.setText(getString(R.string.live_chat_voice_record_cancel));
						tvRecordTitle.setTextColor(getResources().getColor(R.color.white));
						priceInfo.setTextColor(getResources().getColor(R.color.white));
						tvRecord.setText(DateUtil.getTime(mRecordTime));
						tvRecord.setTextColor(Color.RED);
						foreRecordBtn.setVisibility(View.GONE);
						foreCancelBtn.setVisibility(View.VISIBLE);
					} else if (recordStatus == RecordStatus.START_RECORD) {
						// 由cancel模式切换回start模式，且start转cancel模式动画已结束
						recordStatus = RecordStatus.RELEASE_TO_CANCEL;
						playStartToCancelAnimation();
					}

				}
				break;
			case MotionEvent.ACTION_UP:
				mHandler.removeCallbacks(delayTask);
				if (saveFilePath == null) {
					return true;
				}
				if (recordStatus == RecordStatus.DEFAULT) {
					// 取消处理
					cancelStartRecord();
				} else if (recordStatus == RecordStatus.START_RECORD) {
					playPickUpToSend();
				} else if (recordStatus == RecordStatus.RELEASE_TO_CANCEL) {
					playPickUpToCancel(false);
				} else {
					saveFilePath = null;
				}
				// stopRecording();

				break;
			}
			return true;
		}
	};
	
	private Runnable delayTask = new Runnable() {
		@Override
		public void run() {
			if (null != getActivity()) {
				if(recordStatus == RecordStatus.START_RECORD){
					playPickUpToSend();
				}else if(recordStatus == RecordStatus.RELEASE_TO_CANCEL){
					playPickUpToCancel(true);
				}
			}
		}
	};

	private Handler mHandler = new Handler();

	/**
	 * tap，启动动画开始录音
	 */
	private void playStartRecordAnimation() {

		tvRecordTitle.setText(DateUtil.getTime(mRecordTime));
		saveFilePath = FileCacheManager.getInstance().GetLCVoicePath()
				+ File.separator + System.currentTimeMillis() + ".aac"; // aac
		
		Animation animation = getRecordStartAnimation();
		animation.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation animation) {
				isStartAnimationCancel = false;
			}

			@Override
			public void onAnimationRepeat(Animation animation) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onAnimationEnd(Animation animation) {
				if(!isStartAnimationCancel){
					// 开始录制
					recordStatus = RecordStatus.START_RECORD;
					tvRecord.setText(getString(R.string.live_chat_voice_record_speak));
					mHandler.postDelayed(delayTask, 31 * 1000);// 语音最长只能录制30秒 //edit by Jagger 2018-11-29:把30改为31,需要延迟多1秒,不然只会录29秒就结束
					if(recordView.startRecording(saveFilePath)){
						// startRecording(saveFilePath);
						RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) foreRecordBtn
								.getLayoutParams();
						params.width = DisplayUtil.dip2px(getActivity(),
								ON_RECORD_SIZE);
						params.height = DisplayUtil.dip2px(getActivity(),
								ON_RECORD_SIZE);
						foreRecordBtn.setLayoutParams(params);
						foreRecordBtn.clearAnimation();
					}else {
						//MIC被占用提示
						if(getActivity() != null){
							ToastUtil.showToast(mContext, R.string.live_chat_microphone_occupied);
						}
					}

				}
			}
		});
		foreRecordBtn.startAnimation(animation);
	}

	/**
	 * 由于tap时间过短，取消开始录音动画
	 */
	private void cancelStartRecord() {
		if (foreRecordBtn.getAnimation() != null) {
			foreRecordBtn.getAnimation().cancel();
			isStartAnimationCancel = true;
			foreRecordBtn.clearAnimation();
		}
		tvRecordTitle.setText(getString(R.string.live_chat_voice_record_tips));
		saveFilePath = null;
	}

	/**
	 * 由START_RECORD切换为RELEASE_TO_CANCEL状态时，播放切换动画
	 */
	private void playStartToCancelAnimation() {
		Animation bgAnimation = getBgZoomOutAnimation();
		bgAnimation.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation animation) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onAnimationRepeat(Animation animation) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onAnimationEnd(Animation animation) {
				// TODO Auto-generated method stub
				tvRecordTitle.setText(getString(R.string.live_chat_voice_record_cancel));
				tvRecordTitle.setTextColor(getResources().getColor(R.color.white));
				priceInfo.setTextColor(getResources().getColor(R.color.white));
				tvRecord.setText(DateUtil.getTime(mRecordTime));
				tvRecord.setTextColor(Color.RED);
				foreRecordBtn.setVisibility(View.GONE);
				foreCancelBtn.setVisibility(View.VISIBLE);
				/* 由于动画not fill after，修改背景颜色 */
				recordPane.setBackgroundColor(Color.RED);
				backBtnBg.clearAnimation();
			}
		});
		backBtnBg.startAnimation(bgAnimation);
	}

	/**
	 * 由RELEASE_TO_CANCEL切换为START_RECORD状态时，播放切换动画
	 */
	private void playCancelToStartAnimation() {
		Animation bgAnimation = getBgZoomInAnimation();
		bgAnimation.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation animation) {
				/* 重置背景颜色为白色 */
				recordPane.setBackgroundColor(getResources().getColor(R.color.thin_grey));
			}

			@Override
			public void onAnimationRepeat(Animation animation) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onAnimationEnd(Animation animation) {
				// TODO Auto-generated method stub
				tvRecordTitle.setText(DateUtil.getTime(mRecordTime));
				tvRecordTitle.setTextColor(getResources().getColor(R.color.text_color_grey));
				priceInfo.setTextColor(getResources().getColor(R.color.text_color_grey));
				tvRecord.setText(getString(R.string.live_chat_voice_record_speak));
				tvRecord.setTextColor(Color.WHITE);
				foreRecordBtn.setVisibility(View.VISIBLE);
				foreCancelBtn.setVisibility(View.GONE);
				backBtnBg.clearAnimation();
			}
		});
		backBtnBg.startAnimation(bgAnimation);
	}

	/**
	 * START_RECORD 状态下抬起手指发送语音
	 */
	private void playPickUpToSend() {
		Animation bgAnimation = getBgZoomOutAnimation();
		bgAnimation.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation animation) {
				// TODO Auto-generated method stub
			}

			@Override
			public void onAnimationRepeat(Animation animation) {
				// TODO Auto-generated method stub
			}

			@Override
			public void onAnimationEnd(Animation animation) {
				// TODO Auto-generated method stub
				/* 停止录音并发送 */
				// stopRecording();
				recordView.stopRecording(new RecordView.OnRecordStopListener() {
					
					@Override
					public void onRecordStop() {
						// TODO Auto-generated method stub
						sendVoice();
					}
				});
				recordStatus = RecordStatus.STOP_RECORD;

				RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) foreRecordBtn
						.getLayoutParams();
				params.width = DisplayUtil.dip2px(getActivity(),
						ON_READY_SIZE);
				params.height = DisplayUtil.dip2px(getActivity(),
						ON_READY_SIZE);
				foreRecordBtn.setLayoutParams(params);
				backBtnBg.clearAnimation();
//				sendVoice();	//del by Jagger 2017-8-24 移到回调里
			}
		});

		// recordView.stopRecording();
		tvRecordTitle.setText(getString(R.string.live_chat_voice_record_tips));
		tvRecord.setText(getString(R.string.live_chat_voice_record));
		backBtnBg.startAnimation(bgAnimation);

	}

	/**
	 * RELEASE_TO_CANCEL 状态下抬起手指 或 30秒录音时间到执行发送
	 */
	private void playPickUpToCancel(boolean isSend) {
		Animation bgAnimation = getBgZoomInAnimation();
		bgAnimation.setAnimationListener(new AnimationListener() {

			@Override
			public void onAnimationStart(Animation animation) {
				/* 重置背景颜色为白色 */
				recordPane.setBackgroundColor(getResources().getColor(R.color.thin_grey));
			}

			@Override
			public void onAnimationRepeat(Animation animation) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onAnimationEnd(Animation animation) {
				// TODO Auto-generated method stub
				/* 停止录音并发送 */
				recordView.stopRecording(null);
				// stopRecording();
				recordStatus = RecordStatus.STOP_RECORD;
				RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams) foreRecordBtn
						.getLayoutParams();
				params.width = DisplayUtil.dip2px(getActivity(),
						ON_READY_SIZE);
				params.height = DisplayUtil.dip2px(getActivity(),
						ON_READY_SIZE);
				foreRecordBtn.setLayoutParams(params);
				foreRecordBtn.setVisibility(View.VISIBLE);
				foreCancelBtn.setVisibility(View.GONE);
				backBtnBg.clearAnimation();
//				sendVoice();
				/*取消发送清除数据*/
				tvRecordTitle.setTextColor(getResources().getColor(R.color.text_color_grey));
				mRecordTime = 0;
				saveFilePath = null;
			}
		});
		// recordView.stopRecording();
		tvRecordTitle.setTextColor(getResources().getColor(R.color.text_color_grey));
		tvRecordTitle.setText(getString(R.string.live_chat_voice_record_tips));
		priceInfo.setTextColor(getResources().getColor(R.color.text_color_grey));
		tvRecord.setTextColor(Color.WHITE);
		tvRecord.setText(getString(R.string.live_chat_voice_record));
		backBtnBg.startAnimation(bgAnimation);
	}

	/**
	 * record 按钮缩放动画
	 * 
	 * @return
	 */
	private Animation getRecordStartAnimation() {
		float scale = (float) ON_RECORD_SIZE / (float)ON_READY_SIZE;
		ScaleAnimation animation = new ScaleAnimation(1, scale, 1, scale,
				Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF,
				0.5f);
		animation.setFillAfter(false);
		animation.setDuration(100);
		return animation;
	}

	/**
	 * 发送语音
	 */
	private void sendVoice() {
		if(!TextUtils.isEmpty(saveFilePath)){
			
			if(getActivity() != null){
				if(getActivity() instanceof LiveChatTalkActivity){
                    ((LiveChatTalkActivity)getActivity()).sendVoiceItem(saveFilePath, mRecordTime);
                }
			}
		}
		tvRecordTitle.setTextColor(getResources().getColor(R.color.text_color_grey));
		mRecordTime = 0;
		saveFilePath = null;
	}

	private Animation getBgZoomInAnimation() {
		float scale = ((float) minRadius) / DisplayUtil.dip2px(getActivity(), 16);
		ScaleAnimation animation = new ScaleAnimation(scale, 1, scale, 1,
				Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF,
				0.5f);
		animation.setFillAfter(false);
		animation.setDuration(100);
		return animation;
	}

	private Animation getBgZoomOutAnimation() {
		float scale = ((float) minRadius) / DisplayUtil.dip2px(getActivity(), 16);
		ScaleAnimation animation = new ScaleAnimation(1, scale, 1, scale,
				Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF,
				0.5f);
		animation.setFillAfter(false);
		animation.setDuration(100);
		return animation;
	}

	public enum RecordStatus {
		DEFAULT, START_RECORD, RELEASE_TO_CANCEL, STOP_RECORD
	}
	
	@Override
	public void onDetach() {
		// TODO Auto-generated method stub
		super.onDetach();
		if(mHandler != null){
			/*fragment detach 时去调异步处理*/
			mHandler.removeCallbacks(delayTask);
		}
	}
	
	private void stopPlayVoice(){
		if(getActivity() != null){
			if(getActivity() instanceof LiveChatTalkActivity){
				((LiveChatTalkActivity)getActivity()).stopAllVoicePlaying();
			}
//			else if(getActivity() instanceof CamShareActivity){
//				((CamShareActivity)getActivity()).stopAllVoicePlaying();
//			}
		}
		
	}

}
