package com.qpidnetwork.anchor.liveshow.liveroom.vedio;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewParent;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.liveshow.liveroom.LiveStreamPullManager;
import com.qpidnetwork.anchor.liveshow.liveroom.LiveStreamPushManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.ModuleGiftManager;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.utils.Log;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import net.qdating.LSPlayer;
import net.qdating.LSPublisher;

import java.util.List;

/**
 * Description:Hang Out直播间四宫格界面组件封装
 * <p>
 * Created by Harry on 2018/4/18.
 */
public class HangOutVedioWindow extends FrameLayout implements LiveStreamPushManager.ILSPublisherStatusListener, LiveStreamPullManager.ILSPlayerStatusListener {

    private final String TAG = HangOutVedioWindow.class.getSimpleName();

    private Activity mActivity;

    private View vedioWindow;
    private View fl_right;
    private GLSurfaceView sv_vedio;
    private ProgressBar pb_loading;
    private TextView tv_nickName;
    private ImageView iv_switchCamera;
    private ImageView iv_photo;
    private HangOutBarGiftListManager barGiftListManager;
    private FrameLayout fl_multiGift;
    private SimpleDraweeView sdv_advanceGiftAnim;
    private SimpleDraweeView sdv_barGiftAnim;
    private View ll_loading;
    private CircleImageView civ_photo;
    private ImageView iv_inviting;
    private TextView tv_invitingTips;
    private View fl_blank;
    private ImageView iv_inviteFriend;
    private TextView tv_inviteTips;

    private LiveStreamPullManager liveStreamPullManager;
    private LiveStreamPushManager liveStreamPushManager;
    private HangoutVedioWindowObj obj;
    private int anchorComingExpires = 0;
    public HangoutVedioWindowObj getObj(){
        return obj;
    }

    private boolean hasInitedView = false;

    public int index = 0;
    private String[] lastVideoUrls;
    //控制视图是否可长按放大
    private boolean isViewCanScale = true;

    /**
     * 设置是否可长按放大缩小窗口
     * @param isViewCanScale
     */
    public void setViewCanScale(boolean isViewCanScale){
        this.isViewCanScale = isViewCanScale;
    }

    /**
     * 窗口状态
     */
    public enum VedioWindowStatus{
        WaitToInvite,//等待邀请/响应超时拒绝邀请
        Inviting,//邀请中
        VideoStreaming//推拉流
    }


    public interface VedioClickListener {
        void onVedioWindowLongClick(int index);
        void onVedioWindowClick(int index, HangoutVedioWindowObj obj, boolean isStreaming);
    }

    public HangOutVedioWindow(Context context) {
        super(context);
        init(context);
    }

    public HangOutVedioWindow(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public HangOutVedioWindow(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private OnAddInviteClickListener onAddInviteClickListener;

    public void setOnAddInviteClickListener(OnAddInviteClickListener onAddInviteClickListener){
        this.onAddInviteClickListener = onAddInviteClickListener;
    }

    private VedioClickListener vedioClickListener;

    public void setVedioClickListener(VedioClickListener vedioClickListener){
        this.vedioClickListener = vedioClickListener;
    }

    /**
     * 设置索引
     * @param index
     */
    public void setIndex(int index){
        this.index = index;
    }

    /**
     * 缩放回1:1比例
     * @return
     */
    public boolean change2Normal(){
        boolean result = false;
        if(vedioWindow.getScaleX() > 1.0f || vedioWindow.getScaleY() > 1.0f){
            setPivoXY();
            vedioWindow.setScaleX(1.0f);
            vedioWindow.setScaleY(1.0f);
            result = true;
        }
        return result;
    }

    /**
     * 视频窗格放大，比例设置为1.5倍
     * @return
     */
    public boolean change2Large(){
        boolean result = false;
        if(vedioWindow.getScaleX() == 1.0f && vedioWindow.getScaleY() == 1.0f){
            vedioWindow.bringToFront();
            if (Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.KITKAT) {
                ViewParent viewParent = vedioWindow.getParent();
                if(null != viewParent && viewParent instanceof  View){
                    View parentView = (View)viewParent;
                    parentView.requestLayout();
                    parentView.invalidate();
                }

            }
            setPivoXY();
            vedioWindow.setScaleX(1.5f);
            vedioWindow.setScaleY(1.5f);
            result = true;
        }
        return result;
    }


    /**
     * 初始化界面布局
     */
    private void init(Context context){
        Log.d(TAG,"init-index:"+index);
        // 加载布局
        vedioWindow = LayoutInflater.from(context).inflate(R.layout.view_live_hangout_vedio, this);
        fl_right = vedioWindow.findViewById(R.id.fl_right);
        View.OnClickListener listener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(null != vedioClickListener){
                    vedioClickListener.onVedioWindowClick(index,obj,true);
                }
            }
        };
        fl_right.setOnClickListener(listener);
        fl_right.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if(isViewCanScale && null != lastVideoUrls && lastVideoUrls.length>0){
                    if(null != vedioClickListener){
                        vedioClickListener.onVedioWindowLongClick(index);
                    }
                }
                return isViewCanScale;
            }
        });

        sv_vedio = (GLSurfaceView)vedioWindow.findViewById(R.id.sv_vedio);
        pb_loading = (ProgressBar) vedioWindow.findViewById(R.id.pb_loading);
        pb_loading.setVisibility(View.GONE);
        tv_nickName = (TextView)vedioWindow.findViewById(R.id.tv_nickName);
        tv_nickName.setOnClickListener(listener);
        tv_nickName.setVisibility(View.GONE);
        iv_switchCamera = (ImageView)vedioWindow.findViewById(R.id.iv_switchCamera);
        iv_photo = (ImageView)vedioWindow.findViewById(R.id.iv_photo);
        iv_photo.setOnClickListener(listener);
        iv_photo.setVisibility(View.GONE);
        iv_switchCamera.setVisibility(View.GONE);
        iv_switchCamera.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(null != obj && obj.isUserSelf && null != liveStreamPushManager && liveStreamPushManager.isInited()){
                    liveStreamPushManager.switchCamera();
                    iv_switchCamera.setVisibility(View.GONE);
                }
            }
        });
        barGiftListManager = new HangOutBarGiftListManager(context,(RecyclerView) vedioWindow.findViewById(R.id.rlv_barGiftList));
        fl_multiGift = (FrameLayout)vedioWindow.findViewById(R.id.fl_multiGift);
        sdv_advanceGiftAnim = (SimpleDraweeView)vedioWindow.findViewById(R.id.sdv_advanceGiftAnim);
        sdv_barGiftAnim = (SimpleDraweeView)vedioWindow.findViewById(R.id.sdv_barGiftAnim);
        FrameLayout.LayoutParams barGiftAnimLP = (FrameLayout.LayoutParams)sdv_barGiftAnim.getLayoutParams();
        int barGiftAnimWidth = DisplayUtil.getScreenWidth(context)/4;
        barGiftAnimLP.height = barGiftAnimWidth;
        barGiftAnimLP.width = barGiftAnimWidth;
        fl_right.setVisibility(View.GONE);

        ll_loading = vedioWindow.findViewById(R.id.ll_loading);
        ll_loading.setOnClickListener(listener);
        civ_photo = (CircleImageView) vedioWindow.findViewById(R.id.civ_photo);
        iv_inviting = (ImageView)vedioWindow.findViewById(R.id.iv_inviting);
        iv_inviting.setImageResource(R.drawable.anim_public_inviting_tips);
        iv_inviting.setVisibility(View.GONE);
        tv_invitingTips = (TextView)vedioWindow.findViewById(R.id.tv_invitingTips);
        ll_loading.setVisibility(View.GONE);

        tv_inviteTips = (TextView) vedioWindow.findViewById(R.id.tv_inviteTips);
        tv_inviteTips.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if(null !=onAddInviteClickListener){
                    onAddInviteClickListener.onAddInviteClick(index);
                }
            }
        });
        iv_inviteFriend = (ImageView) vedioWindow.findViewById(R.id.iv_inviteFriend);
        iv_inviteFriend.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if(null !=onAddInviteClickListener){
                    onAddInviteClickListener.onAddInviteClick(index);
                }
            }
        });
        fl_blank = vedioWindow.findViewById(R.id.fl_blank);
        fl_blank.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(null !=onAddInviteClickListener){
                    onAddInviteClickListener.onAddInviteClick(index);
                }
            }
        });
        //默认都显示添加邀请界面
        fl_blank.setVisibility(View.VISIBLE);
        hasInitedView = true;
    }

    private static final int EVENT_ANCHOR_COMING_COUNT_DOWN = 0521;

    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what){
                case EVENT_ANCHOR_COMING_COUNT_DOWN:
                    if(anchorComingExpires>0){
                        if(null != obj){
                            tv_invitingTips.setText(mActivity.getString(R.string.hangout_enter_tips,obj.nickName,String.valueOf(anchorComingExpires)));
                        }
                        anchorComingExpires-=1;
                        handler.sendEmptyMessageDelayed(EVENT_ANCHOR_COMING_COUNT_DOWN,1000l);
                    }else if(0 == anchorComingExpires){
                        if(null != obj && !obj.isOnLine && null != mActivity){
                            obj.isOnLine = true;
                            showVedioStreamView(mActivity,obj);
                        }
                    }
                    break;
                default:
                    super.handleMessage(msg);
                    break;
            }

        }
    };

    /**
     * 初始化吧台礼物列表数据
     * @param hangOutBarGiftItems
     */
    public void setBarGiftList(List<HangOutBarGiftListItem> hangOutBarGiftItems){
        if(null != barGiftListManager){
            barGiftListManager.setBarGiftList(hangOutBarGiftItems);
        }
    }

    /**
     * 更新吧台礼物列表条目
     * @param hangOutBarGiftItem
     */
    public void updateBarGiftList(HangOutBarGiftListItem hangOutBarGiftItem){
        Log.d(TAG,"updateBarGiftList-hangOutBarGiftItem:"+hangOutBarGiftItem);
        if(null != barGiftListManager){
            barGiftListManager.updateBarGiftList(hangOutBarGiftItem);
        }
    }

    /**
     * 显示摄像头前后切换开关
     */
    public void changeCameraSwitchVisibility() {
        Log.d(TAG,"changeCameraSwitchVisibility");
        if(null != obj && obj.isUserSelf){
            iv_switchCamera.setVisibility(View.GONE == iv_switchCamera.getVisibility() ? View.VISIBLE : View.GONE);
        }
    }

    /**
     * 推荐好友事件监听器
     */
    public interface OnAddInviteClickListener{
        void onAddInviteClick(int index);
    }

    private VedioDisconnectListener vedioDisconnectListener;

    public void setVedioDisconnectListener(VedioDisconnectListener vedioDisconnectListener){
        this.vedioDisconnectListener = vedioDisconnectListener;
    }

    /**
     * 推荐好友事件监听器
     */
    public interface VedioDisconnectListener{
        void onVedioDisconnect(int index, boolean hasConnected);
    }

    /**
     * 设置起点坐标
     */
    private void setPivoXY(){
        Log.d(TAG,"setPivoXY-index:"+index);
        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) vedioWindow.getLayoutParams();
        switch (index){
            case 1://左上角
                vedioWindow.setPivotX(0f);
                vedioWindow.setPivotY(0f);
                break;
            case 2://右上角
                vedioWindow.setPivotX(lp.width);
                vedioWindow.setPivotY(0f);
                break;
            case 3://左下角
                vedioWindow.setPivotX(0f);
                vedioWindow.setPivotY(lp.height);
                break;
            case 4://右下角
                vedioWindow.setPivotX(lp.width);
                vedioWindow.setPivotY(lp.height);
                break;
        }
    }

    /**
     * 窗口状态切换
     * @param status
     */
    private void changeVedioWindowStatus(VedioWindowStatus status){
        Log.d(TAG,"changeVedioWindowStatus-status:"+status+" obj:"+obj);
        fl_right.setVisibility(status == VedioWindowStatus.VideoStreaming ? View.VISIBLE : View.GONE);
        ll_loading.setVisibility(status == VedioWindowStatus.Inviting ? View.VISIBLE : View.GONE);
        fl_blank.setVisibility(status == VedioWindowStatus.WaitToInvite ? View.VISIBLE : View.GONE);
    }

    /**
     * 切换到待邀请状态
     */
    public void showWaitToInviteView(){
        obj = null;
        if(barGiftListManager != null){
            barGiftListManager.clear();
        }
        dimissInvitingAnim();
        stopGiftAnim();
        stopPushOrPullVedioStream();
        changeVedioWindowStatus(VedioWindowStatus.WaitToInvite);
    }

    /**
     * 主播进入hangout直播间的途径枚举类
     */
    public enum AnchorComingType{
        Man_Inviting,//男士主动邀请
        Man_Accepted_Anchor_Knock, // 男士接受主播敲门请求
        Anchor_Coming_After_Expires // 主播在公开/私密直播间接受邀请，倒计时结束后进入直播间
    }

    /**
     * 切换主播正在进入hangout直播间的状态
     * @param activity
     * @param hangoutVedioWindowObj
     * @param type
     * @param expires
     */
    public void showAnchorComingView(Activity activity, HangoutVedioWindowObj hangoutVedioWindowObj,
                                     AnchorComingType type, int expires){
        Log.d(TAG,"showAnchorComingView-hangoutVedioWindowObj:"+hangoutVedioWindowObj+" type:"+type+" expires:"+expires);
        if(null == hangoutVedioWindowObj){
           return;
        }
        this.mActivity = activity;
        this.obj = hangoutVedioWindowObj;
        //更改界面状态展示
        changeVedioWindowStatus(VedioWindowStatus.Inviting);
        if(type!=AnchorComingType.Anchor_Coming_After_Expires){
            showInvitingAnim();
        }else{
            dimissInvitingAnim();
        }
        stopGiftAnim();
        stopPushOrPullVedioStream();
        String comingTips = null;
        if(!TextUtils.isEmpty(obj.nickName)){
            if(type==AnchorComingType.Man_Inviting){
                comingTips = activity.getString(R.string.hangout_inviting_tips,obj.nickName);
                tv_invitingTips.setText(comingTips);
                Log.d(TAG,"showAnchorComingView-comingTips:"+comingTips);
            }else if(type==AnchorComingType.Man_Accepted_Anchor_Knock){
                comingTips = activity.getString(R.string.hangout_coming_tips,obj.nickName);
                tv_invitingTips.setText(activity.getString(R.string.hangout_coming_tips,obj.nickName));
                Log.d(TAG,"showAnchorComingView-comingTips:"+comingTips);
            }else if(type==AnchorComingType.Anchor_Coming_After_Expires){
                anchorComingExpires = expires;
                tv_invitingTips.setText(mActivity.getString(R.string.hangout_enter_tips,obj.nickName,String.valueOf(anchorComingExpires)));
                handler.sendEmptyMessage(EVENT_ANCHOR_COMING_COUNT_DOWN);
            }
        }
        if(!TextUtils.isEmpty(obj.photoUrl)){
            Picasso.with(activity)
                    .load(obj.photoUrl)
                    .placeholder(R.drawable.ic_default_photo_man)
                    .error(R.drawable.ic_default_photo_man)
                    .memoryPolicy(MemoryPolicy.NO_CACHE)
                    .into(civ_photo);
        }
    }

    /**
     * 显示邀请动画
     */
    private void showInvitingAnim(){
        Log.d(TAG,"showInvitingAnim");
        if(!hasInitedView){
            throw new RuntimeException("请先调用initView()方法初始化界面布局");
        }
        iv_inviting.setVisibility(View.VISIBLE);
        iv_inviting.setImageResource(R.drawable.anim_public_inviting_tips);
        Drawable tempDrawable = iv_inviting.getDrawable();
        if((tempDrawable != null) && (tempDrawable instanceof AnimationDrawable)){
            ((AnimationDrawable)tempDrawable).start();
        }
    }

    /**
     * 隐藏邀请动画
     */
    private void dimissInvitingAnim(){
        Log.d(TAG,"dimissInvitingAnim");
        if(!hasInitedView){
            throw new RuntimeException("请先调用initView()方法初始化界面布局");
        }
        Drawable tempDrawable = iv_inviting.getDrawable();
        if((tempDrawable != null) && (tempDrawable instanceof AnimationDrawable)){
            ((AnimationDrawable)tempDrawable).stop();
        }
        iv_inviting.setVisibility(View.GONE);
    }

    /**
     * 初始化流媒体组件
     */
    private void initVSManager(){
        if(null == obj){
            return;
        }

        Log.d(TAG,"initVSManager-isUserSelf:"+obj.isUserSelf +" hasInitedView:"+hasInitedView);
        if(!hasInitedView){
            throw new RuntimeException("请先调用initView()方法初始化界面布局");
        }
        //如果是主播自己就是推流器
        if(obj.isUserSelf){
            if(null==liveStreamPushManager && null != mActivity){
                liveStreamPushManager = new LiveStreamPushManager(mActivity);
                liveStreamPushManager.init(sv_vedio);
                hasCoolLiveInited = true;
            }
            liveStreamPushManager.setILSPublisherStatusListener(this);
        }else{
            if(null == liveStreamPullManager && null != mActivity){
                //否则就是拉流器
                liveStreamPullManager = new LiveStreamPullManager(mActivity);
                liveStreamPullManager.init(sv_vedio);
                hasCoolLiveInited = true;
            }
            liveStreamPullManager.setILSPlayerStatusListener(this);
        }
        sv_vedio.setVisibility(View.VISIBLE);
    }

    public void onActivityStop(){
        Log.d(TAG,"onActivityStop");
        stopGiftAnim();
    }

    /**
     * 显示视频加载动画
     * @param activity
     */
    private void showVedioLoadingAnim(Activity activity){
        Log.d(TAG,"showVedioLoadingAnim");
        if(null == obj || null == pb_loading){
            return;
        }
        //主播则显示头像的同时显示loading
        if(obj.isUserSelf){
            pb_loading.setVisibility(View.VISIBLE);
        }else{
            //不是主播则全部替换为默认图
            Picasso.with(activity)
                    .load(R.drawable.ic_hangout_vedio_loading)
                    .noPlaceholder()
                    .into(iv_photo);
        }
    }

    /**
     * 隐藏视频加载动画
     */
    private void dimissVedioLoadingAnim(){
        Log.d(TAG,"dimissVedioLoadingAnim-obj:"+obj);
        if(null == obj || null == pb_loading){
            return;
        }
        if(obj.isUserSelf){
            pb_loading.setVisibility(View.GONE);
        }
        iv_photo.setVisibility(View.GONE);
        Log.d(TAG,"dimissVedioLoadingAnim-isUserSelf:"+obj.isUserSelf+" targetUserId:"+obj.targetUserId+" iv_photo.visib:"+iv_photo.getVisibility());
    }

    /**
     * 显示主播/男士个人头像或封面
     * @param activity
     */
    private void showVedioCover(Activity activity){
        Log.d(TAG,"showVedioCover-obj.isUserSelf:"+obj.isUserSelf+" obj.isManUser:"+obj.isManUser+" iv_photo.visib:"+iv_photo.getVisibility());
        if(null == obj){
            return;
        }
        //男士会员显示头像，主播自己显示视频预览，其他主播则显示默认视频加载状态图
        if(obj.isManUser){
            if(!TextUtils.isEmpty(obj.photoUrl)){
                Picasso.with(activity)
                    .load(obj.photoUrl)
                    .placeholder(R.drawable.ic_default_photo_man_hangout)
                    .error(R.drawable.ic_default_photo_man_hangout)
                    .memoryPolicy(MemoryPolicy.NO_CACHE)
                    .into(iv_photo);
            }
            iv_photo.setVisibility(View.VISIBLE);
        }else if(obj.isUserSelf){
            iv_photo.setVisibility(View.GONE);
        }else{
            //其他主播进来默认就会推流，所以不存在仅加载头像无推流的情况
            iv_photo.setImageDrawable(activity.getResources().getDrawable(R.drawable.ic_hangout_vedio_loading));
            iv_photo.setVisibility(View.VISIBLE);
        }
        Log.d(TAG,"showVedioCover-iv_photo.visib:"+iv_photo.getVisibility());
    }

    /**
     * 切换到视频推拉流
     * @param activity
     * @param obj
     */
    public void showVedioStreamView(Activity activity, HangoutVedioWindowObj obj){
        if(null == obj){
            return;
        }
        Log.d(TAG,"showVedioStreamView-obj:"+obj);
        this.obj = obj;
        this.mActivity = activity;
        if(null != handler){
            handler.removeMessages(EVENT_ANCHOR_COMING_COUNT_DOWN);
        }
        dimissInvitingAnim();
        changeVedioWindowStatus(VedioWindowStatus.VideoStreaming);
        showVedioCover(activity);
        //展示昵称
        if(!obj.isUserSelf && !TextUtils.isEmpty(obj.nickName)){
            tv_nickName.setVisibility(View.VISIBLE);
            tv_nickName.setText(obj.nickName);
        }
    }

    /**
     * 开始推拉流工作
     */
    public void startPushOrPullVedioStream(Activity activity,String[] videoUrls){
        if(null == obj){
            return;
        }
        this.mActivity = activity;
        showVedioLoadingAnim(activity);
        boolean videoUrlsUsuable = null != videoUrls && videoUrls.length > 0;
        Log.d(TAG,"startPushOrPullVedioStream-videoUrlsUsuable:"+videoUrlsUsuable+" obj:"+obj);
        initVSManager();
        //开始推拉流处理
        if(videoUrlsUsuable){
            if(obj.isUserSelf && null != liveStreamPushManager){
                liveStreamPushManager.setOrChangeManUploadUrls(videoUrls, "", "");
            }else if(null != liveStreamPullManager){
                liveStreamPullManager.setOrChangeVideoUrls(videoUrls, "", "",null);
            }
            lastVideoUrls = videoUrls;
        }

    }

    /**
     * 停止推流
     */
    public void stopPushOrPullVedioStream(){
        if(null == obj){
            return;
        }
        lastVideoUrls = null;
        Log.d(TAG,"stopVedioStreamPusher-isUserSelf:"+obj.isUserSelf);
        if(obj.isUserSelf && null != liveStreamPushManager){
            liveStreamPushManager.setILSPublisherStatusListener(null);
            liveStreamPushManager.stop();
        }else if(null != liveStreamPullManager){
            liveStreamPullManager.setILSPlayerStatusListener(null);
            liveStreamPullManager.stopPlayInternal();
        }
    }

    /**
     * 推流器切换音频的输入与否
     * @param isMute
     */
    public void setPushStreamMute(boolean isMute){
        Log.d(TAG,"setPushStreamMute-isMute:"+isMute);
        if(null != obj && obj.isUserSelf && null != liveStreamPushManager){
            liveStreamPushManager.setPushStreamMute(isMute);
        }
    }

    /**
     * 设置拉流器是否静音播流
     * @param isSilent
     */
    public void setPullStreamSilent(boolean isSilent){
        Log.d(TAG,"setPullStreamSilent-isSilent:"+isSilent);
        if(null != liveStreamPullManager){
            liveStreamPullManager.setPullStreamSilent(isSilent);
        }
    }

    /**
     * 资源释放
     */
    public void release(){
        if(barGiftListManager != null){
            barGiftListManager.release();
        }
        dimissInvitingAnim();
        stopGiftAnim();
        releaseVSManager();
        obj = null;
        onAddInviteClickListener = null;
        vedioClickListener = null;
        vedioDisconnectListener = null;
        if(null != handler){
            handler.removeMessages(EVENT_ANCHOR_COMING_COUNT_DOWN);
            handler.removeCallbacks(null);
            handler = null;
        }
    }

    //liveStreamPushManager或者liveStreamPullManager未调用init方法初始化时，sv_vedio不可设置为可见，
    // 否则会抛异常Attempt to invoke virtual method 'void android.opengl.GLSurfaceView$GLThread.surfaceCreated()' on a null object reference
    private boolean hasCoolLiveInited = false;

    //对应与Activity的onPause
    public void onPause(){
        Log.d(TAG,"onPause");
        if(null != sv_vedio){
            sv_vedio.setVisibility(View.INVISIBLE);
        }
    }

    /**
     * 释放流媒体资源占用
     */
    private void releaseVSManager(){
        Log.d(TAG,"releaseVSManager");
        if(null != obj){
            Log.d(TAG,"releaseVSManager-isUserSelf:"+obj.isUserSelf);
        }
        if(null != liveStreamPushManager){
            liveStreamPushManager.setILSPublisherStatusListener(null);
            liveStreamPushManager.release();
            hasCoolLiveInited = false;
            liveStreamPushManager = null;
        }
        if(null != liveStreamPullManager){
            liveStreamPullManager.setILSPlayerStatusListener(null);
            liveStreamPullManager.release();
            hasCoolLiveInited = false;
            liveStreamPullManager = null;
        }
        sv_vedio.setVisibility(View.INVISIBLE);
    }

    private ModuleGiftManager mModuleGiftManager;

    public void initGiftManager(final Activity activity){
        Log.d(TAG,"initGiftManager-hasInitedView:"+hasInitedView);
        if(!hasInitedView){
            throw new RuntimeException("请先调用initView()方法初始化界面布局");
        }
        this.mActivity = activity;
        mModuleGiftManager = new ModuleGiftManager(activity);
        mModuleGiftManager.initAdvanceGift(sdv_advanceGiftAnim);
        mModuleGiftManager.setBarGiftAnimView(sdv_barGiftAnim);
        mModuleGiftManager.setGiftAnimShowedInHangOutRoom(true);
        mModuleGiftManager.initMultiGift(fl_multiGift);
        mModuleGiftManager.showMultiGiftAs(fl_multiGift);
    }

    public void addIMMessageItem(IMMessageItem msgItem){
        Log.d(TAG,"playGiftAnim-msgItem:"+msgItem);

        if(null != mModuleGiftManager){
            mModuleGiftManager.dispatchIMMessage(msgItem);
        }

    }

    private void stopGiftAnim(){
        Log.d(TAG,"stopGiftAnim");
        if(null != mModuleGiftManager){
            mModuleGiftManager.onMultiGiftDestroy();
        }
    }

    @Override
    public void onPushStreamConnect(LSPublisher lsPublisher) {
        Log.d(TAG,"onPushStreamConnect");
        if(null != mActivity){
            mActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    dimissVedioLoadingAnim();
                    if(null != vedioDisconnectListener){
                        vedioDisconnectListener.onVedioDisconnect(index,true);
                    }
                }
            });
        }
    }

    @Override
    public void onPushStreamDisconnect(LSPublisher lsPublisher) {
        Log.d(TAG,"onPushStreamDisconnect");
        if(null != mActivity){
            mActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //主播断流
                    showVedioLoadingAnim(mActivity);
                    // 但是如果app断线重连这段时间web端男士end了hangout直播间，就会出现视频流一直连上断开提示的情况
                    if(null != vedioDisconnectListener){
                        vedioDisconnectListener.onVedioDisconnect(index, false);
                    }
                }
            });
        }
    }

    @Override
    public void onPullStreamConnect(LSPlayer var1) {
        Log.d(TAG,"onPullStreamConnect");
        if(null != mActivity){
            mActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //其他主播或者用户连上视频流
                    dimissVedioLoadingAnim();
                    if(null != vedioDisconnectListener){
                        vedioDisconnectListener.onVedioDisconnect(index,true);
                    }
                }
            });
        }
    }

    @Override
    public void onPullStreamDisconnect(LSPlayer var1) {
        Log.d(TAG,"onPullStreamDisconnect");
        if(null != mActivity){
            mActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //其他主播或者用户视频流断开
                    showVedioLoadingAnim(mActivity);
                    if(null != vedioDisconnectListener){
                        vedioDisconnectListener.onVedioDisconnect(index,false);
                    }
                }
            });
        }
    }
    
    public void onLogout(){
        if(null == obj){
            return;
        }
        Log.d(TAG,"onLogout");
        if(obj.isUserSelf && null != liveStreamPushManager){
            liveStreamPushManager.onLogout();
        }else if(null != liveStreamPullManager){
            liveStreamPullManager.onLogout();
        }
    }
}