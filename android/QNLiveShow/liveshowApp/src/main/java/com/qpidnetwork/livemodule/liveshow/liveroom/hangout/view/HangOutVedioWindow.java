package com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.PointF;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.opengl.GLSurfaceView;
import android.os.Handler;
import android.os.Message;
import android.support.constraint.ConstraintLayout;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.generic.RoundingParams;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.common.ResizeOptions;
import com.facebook.imagepipeline.image.ImageInfo;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.HangoutInvitationManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.LivePlayerManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.PublisherManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.ModuleGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.obj.HangOutBarGiftListItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.obj.HangoutVedioWindowObj;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.utils.StringUtil;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.qnbridgemodule.util.Log;

import net.qdating.LSPlayer;
import net.qdating.LSPublisher;
import net.qdating.player.LSPlayerRendererBinder;

import java.util.List;
import java.util.concurrent.TimeUnit;

import io.reactivex.Flowable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;


/**
 * Description:Hang Out直播间四宫格界面组件封装
 * <p>
 * Created by Harry on 2018/4/18.
 */
public class HangOutVedioWindow extends FrameLayout implements PublisherManager.ILSPublisherStatusListener, LivePlayerManager.ILSPlayerStatusListener, HangoutInvitationManager.OnHangoutInvitationEventListener {

    private final String TAG = HangOutVedioWindow.class.getSimpleName();
    private static final int STEP_PUSH_OPERA_COUNTDOWN = 3 * 1000;//男士操作层自动隐藏倒计时时间间隔

    private Activity mActivity;

    private View vedioWindow;
    private FrameLayout fl_right;
    private FrameLayout fl_gift;
    private FrameLayout fl_sfv_content;
    private GLSurfaceView sv_vedio;
    private ProgressBar pb_loading;
    private TextView tv_nickName;
    private ImageView iv_crown;
    private SimpleDraweeView iv_photo;  //男士头像
    private FrameLayout fl_push;        //男士操作区
    private Button btn_openVideo;       //男士打开上传视频
    private Button btn_closeVideo;       //男士停止上传视频
    private ImageView iv_switchCamera;   //男士摄像头转换
    private boolean isCanSwitchCamera = false;  //摄像头能否转换
    private Disposable mDisposableCountdown;  //本地倒计时
    private HangOutBarGiftListManager barGiftListManager;
    private ConstraintLayout cl_gift;   //礼物区
    private FrameLayout fl_head;        //人名区
    private FrameLayout fl_multiGift;
    private SimpleDraweeView sdv_advanceGiftAnim;
    private SimpleDraweeView sdv_barGiftAnim;
    private View ll_loading;
    private SimpleDraweeView img_photo;
    private ImageView iv_inviting;
    private TextView tv_invitingTips;
    private View fl_blank;
    private ImageView iv_inviteFriend;
    private TextView tv_inviteTips;
    private ButtonRaised btn_cancel;    //取消邀请

    private LivePlayerManager liveStreamPullManager;
    private PublisherManager liveStreamPushManager;
    private LSPlayerRendererBinder mRendererBinderPull; //拉流视频渲染器
    private ModuleGiftManager mModuleGiftManager;   //礼物管理器
    private HangoutVedioWindowObj obj;
    private int anchorComingExpires = 0;
    public HangoutVedioWindowObj getObj(){
        return obj;
    }
    private VideoStatus mPushVideoStatus = VideoStatus.stop;    //推流状态
    private VideoStatus mPullVideoStatus = VideoStatus.stop;    //拉流状态
    private VedioWindowStatus mVedioWindowStatus = VedioWindowStatus.WaitToInvite;  //窗口状态
    private RenderStatus mRenderStatus = RenderStatus.Interior; //渲染器状态
    private VideoWorkType mVideoWorkType = VideoWorkType.Pull;  //视频播放类型
    private boolean hasInitedView = false;

    public int index = 0;
    private String[] lastVideoUrls;

    //----- 缩放 start -----
    //控制视图是否可长按放大
    private boolean isViewCanScale = true;
    private WidowScaleStatus mWidowScaleStatus = WidowScaleStatus.Normal;
    private int mWidowNormalWidth, mWidowNormalHeight;
    //------ 缩放 end ------

    //----- 邀请 start -----
    private HangoutInvitationManager mHangoutInvitationManager;
    //------ 邀请 end ------

    //----- 状态类型定义 start -----
    /**
     * 窗口缩放状态
     */
    private enum WidowScaleStatus{
        Normal,
        Big,
        Small
    }

    /**
     * 视频播放状态
     */
    private enum VideoStatus{
        waiting,
        playing,
        stop
    }

    /**
     * 视频渲染器状态
     */
    private enum RenderStatus{
        External,   //外部
        Interior    //内部
    }

    /**
     * 视频播放类型
     */
    private enum VideoWorkType{
        Pull,   //拉流
        Push    //推流
    }

    /**
     * 窗口状态
     */
    public enum VedioWindowStatus{
        WaitToInvite,   //等待邀请/响应超时拒绝邀请
        Inviting,       //邀请中
        OpeningDoor,    //开门中
        VideoStreaming  //推拉流
    }

    //----- 状态类型定义 end -----

    //----------------- 接口定义 start -----------------
    /**
     * 推荐好友事件监听器
     */
    public interface VedioDisconnectListener{
        void onPullVedioConnect(int index, boolean hasConnected);
        void onPushVedioConnect(int index, boolean hasConnected);
    }

    /**
     * 推荐好友事件监听器
     */
    public interface OnAddInviteClickListener{
        void onAddInviteClick(int index);
        void onInvitationCancel(boolean isSuccess, int httpErrCode, String errMsg, String anchorId);
    }

    /**
     * 点击事件监听器
     */
    public interface VedioClickListener {
        void onVedioWindowLongClick(int index);
        void onVedioWindowClick(int index, HangoutVedioWindowObj obj, boolean isStreaming);
        void onOpenVideoClicked();
        void onCloseVideoClicked();
    }

    /**
     * 邀请事件监听器
     */
    public interface OnInviteEventListener{
        void onInvitationStart(IMUserBaseInfoItem userBaseInfoItem);
        void onInvitationResponse(boolean isSuccess, HangoutInvitationManager.HangoutInvationErrorType errorType, String errMsg, IMUserBaseInfoItem userBaseInfoItem, String roomId);
    }

    //------------------ 接口定义 end ------------------

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

    private OnInviteEventListener OnInviteEventListener;
    public void setOnInviteEventListener(HangOutVedioWindow.OnInviteEventListener onInviteEventListener) {
        OnInviteEventListener = onInviteEventListener;
    }


    /**
     * 设置索引
     * @param index
     */
    public void setIndex(int index){
        this.index = index;
    }

    /**
     * 设置是否可长按放大缩小窗口
     * @param isViewCanScale
     */
    public void setViewCanScale(boolean isViewCanScale){
        this.isViewCanScale = isViewCanScale;
    }

    //--------------- 处理放大缩小 start ---------------
    /**
     * 缩放回1:1比例
     * @return
     */
    public boolean change2Normal(){
        boolean result = false;
        if(mWidowScaleStatus == WidowScaleStatus.Big || mWidowScaleStatus == WidowScaleStatus.Small){
            mWidowScaleStatus = WidowScaleStatus.Normal;

            setPivoXY();
            ViewGroup.LayoutParams params  = vedioWindow.getLayoutParams();
            params.width = mWidowNormalWidth;
            params.height = mWidowNormalHeight;
            vedioWindow.setLayoutParams(params);
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
        if(mWidowScaleStatus == WidowScaleStatus.Normal){
            mWidowScaleStatus = WidowScaleStatus.Big;

            vedioWindow.bringToFront();
//            sv_vedio.setZOrderOnTop(true);
            sv_vedio.setZOrderMediaOverlay(true);
//            sv_vedio.getHolder().setFormat(PixelFormat.TRANSPARENT);
            setPivoXY();

            mWidowNormalWidth = vedioWindow.getWidth();
            mWidowNormalHeight = vedioWindow.getWidth();

            ViewGroup.LayoutParams params  = vedioWindow.getLayoutParams();
            params.width = (int)(mWidowNormalWidth*1.5);
            params.height = (int)(mWidowNormalHeight*1.5);
            vedioWindow.setLayoutParams(params);
            result = true;
        }

        return result;
    }

    /**
     * 视频窗格缩小，比例设置为0.5倍，对应变大的1.5倍
     */
    public void change2Small(){
        if(mWidowScaleStatus == WidowScaleStatus.Normal) {
            mWidowScaleStatus = WidowScaleStatus.Small;
            setPivoXY();

            mWidowNormalWidth = vedioWindow.getWidth();
            mWidowNormalHeight = vedioWindow.getWidth();

            ViewGroup.LayoutParams params = vedioWindow.getLayoutParams();
            params.width = (int) (mWidowNormalWidth * 0.5);
            params.height = (int) (mWidowNormalHeight * 0.5);
            vedioWindow.setLayoutParams(params);
        }
    }

    /**
     * 改变视频播放渲染器
     * (只对拉流状态处理)
     * @param view
     */
    public void changeRenderBinder(GLSurfaceView view, FrameLayout frameLayout){
        if(mVideoWorkType == VideoWorkType.Pull && mRenderStatus == RenderStatus.Interior){
            mRenderStatus = RenderStatus.External;
            liveStreamPullManager.changePlayerRenderBinder(LivePlayerManager.createPlayerRenderBinder(view));


            changeViewParent(fl_head, frameLayout);
            changeViewParent(cl_gift, frameLayout);

//            ViewParent viewParent = cl_gift.getParent();
//            if(viewParent != null){
//                ViewGroup v = (ViewGroup)viewParent;
//                v.removeView(cl_gift);
//            }
//            frameLayout.addView(cl_gift);
        }
    }

    /**
     * 还原视频播放渲染器
     * (只对拉流状态处理)
     */
    public void resetRenderBinder(){
        if(mVideoWorkType == VideoWorkType.Pull && mRenderStatus == RenderStatus.External && mRendererBinderPull != null) {
            mRenderStatus = RenderStatus.Interior;
            liveStreamPullManager.changePlayerRenderBinder(mRendererBinderPull);

            changeViewParent(fl_head, fl_right);
            changeViewParent(cl_gift, fl_right);

//            ViewParent viewParent = cl_gift.getParent();
//            if(viewParent != null){
//                ViewGroup v = (ViewGroup)viewParent;
//                v.removeView(cl_gift);
//            }
//            fl_gift.addView(cl_gift);
        }
    }

    private void changeViewParent(View targetView, ViewGroup newParentView){
        ViewParent viewParent = targetView.getParent();
        if(viewParent != null){
            ViewGroup v = (ViewGroup)viewParent;
            v.removeView(targetView);
        }
        newParentView.addView(targetView);
    }

    //--------------- 处理放大缩小 end ---------------

    /**
     * 取窗口状态
     * @return
     */
    public VedioWindowStatus getWindowStatus(){
        return mVedioWindowStatus;
    }

    /**
     * 初始化界面布局
     */
    private void init(Context context){
        Log.d(TAG,"init-index:"+index);
        // 加载布局
        vedioWindow = LayoutInflater.from(context).inflate(R.layout.view_live_hangout_vedio, this);

        fl_right = vedioWindow.findViewById(R.id.fl_right);
        OnClickListener listener = new OnClickListener() {
            @Override
            public void onClick(View v) {
                doShowPushOpera();
                if(null != vedioClickListener){
                    vedioClickListener.onVedioWindowClick(index,obj,true);
                }
            }
        };
        fl_right.setOnClickListener(listener);
        fl_right.setOnLongClickListener(new OnLongClickListener() {
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
        fl_gift = vedioWindow.findViewById(R.id.fl_gift);

        fl_sfv_content = vedioWindow.findViewById(R.id.fl_sfv_content);
        sv_vedio = (GLSurfaceView)vedioWindow.findViewById(R.id.sv_vedio);
        pb_loading = (ProgressBar) vedioWindow.findViewById(R.id.pb_loading);
        pb_loading.setVisibility(View.GONE);
        tv_nickName = (TextView)vedioWindow.findViewById(R.id.tv_nickName);
        tv_nickName.setOnClickListener(listener);
        tv_nickName.setVisibility(View.GONE);
        iv_switchCamera = (ImageView)vedioWindow.findViewById(R.id.iv_switchCamera);
        iv_switchCamera.setVisibility(GONE);
        iv_crown = vedioWindow.findViewById(R.id.iv_crown);
        iv_crown.setVisibility(GONE);
        iv_photo = vedioWindow.findViewById(R.id.iv_photo);
        iv_photo.setOnClickListener(listener);
        iv_photo.setVisibility(View.GONE);
        fl_push = vedioWindow.findViewById(R.id.fl_push);
        fl_push.setVisibility(GONE);
        fl_push.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                doHidePushOpera();
            }
        });
        btn_openVideo = vedioWindow.findViewById(R.id.btn_openVideo);
        btn_openVideo.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                doHidePushOpera();
                if(null != vedioClickListener){
                    vedioClickListener.onOpenVideoClicked();
                }
            }
        });
        btn_openVideo.setVisibility(GONE);
        btn_closeVideo = vedioWindow.findViewById(R.id.btn_closeVideo);
        btn_closeVideo.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                mPushVideoStatus = VideoStatus.waiting;
                doHidePushOpera();
                if(null != vedioClickListener){
                    vedioClickListener.onCloseVideoClicked();
                }
            }
        });
        iv_switchCamera.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                doHidePushOpera();
                if(null != obj && obj.isUserSelf && null != liveStreamPushManager && liveStreamPushManager.isInited()){
                    liveStreamPushManager.switchCamera();
//                    iv_switchCamera.setVisibility(View.GONE);
                }
            }
        });
        barGiftListManager = new HangOutBarGiftListManager(context,(RecyclerView) vedioWindow.findViewById(R.id.rlv_barGiftList));
        cl_gift = vedioWindow.findViewById(R.id.cl_gift);
        fl_head = vedioWindow.findViewById(R.id.fl_head);
        fl_multiGift = (FrameLayout)vedioWindow.findViewById(R.id.fl_multiGift);
        sdv_advanceGiftAnim = (SimpleDraweeView)vedioWindow.findViewById(R.id.sdv_advanceGiftAnim);
        sdv_barGiftAnim = (SimpleDraweeView)vedioWindow.findViewById(R.id.sdv_barGiftAnim);
        ConstraintLayout.LayoutParams barGiftAnimLP = (ConstraintLayout.LayoutParams)sdv_barGiftAnim.getLayoutParams();
        int barGiftAnimWidth = DisplayUtil.getScreenWidth(context)/4;
        barGiftAnimLP.height = barGiftAnimWidth;
        barGiftAnimLP.width = barGiftAnimWidth;
        fl_right.setVisibility(View.GONE);

        ll_loading = vedioWindow.findViewById(R.id.ll_loading);
        ll_loading.setOnClickListener(listener);
        img_photo = vedioWindow.findViewById(R.id.img_photo);
        iv_inviting = (ImageView)vedioWindow.findViewById(R.id.iv_inviting);
        iv_inviting.setImageResource(R.drawable.anim_public_inviting_tips);
        iv_inviting.setVisibility(View.GONE);
        tv_invitingTips = (TextView)vedioWindow.findViewById(R.id.tv_invitingTips);
        btn_cancel = (ButtonRaised) vedioWindow.findViewById(R.id.btn_cancel);
        btn_cancel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                onCancelInvitationClicked();
            }
        });
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
        fl_blank.setOnClickListener(new OnClickListener() {
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

    @SuppressLint("HandlerLeak")
    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what){
                case EVENT_ANCHOR_COMING_COUNT_DOWN:
                    if(anchorComingExpires>0){
                        if(null != obj){
                            String anchorName = StringUtil.truncateName(obj.nickName);
                            tv_invitingTips.setText(mActivity.getString(R.string.hangout_enter_tips, anchorName, String.valueOf(anchorComingExpires)));
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
     * 摄像头能否转换
     * @param cameraCanSwitch
     */
    public void setCameraCanSwitch(boolean cameraCanSwitch){
        Log.d(TAG,"setCameraCanSwitch-cameraCanSwitch:"+cameraCanSwitch);
        isCanSwitchCamera = cameraCanSwitch;
    }

    private VedioDisconnectListener vedioDisconnectListener;

    public void setVedioDisconnectListener(VedioDisconnectListener vedioDisconnectListener){
        this.vedioDisconnectListener = vedioDisconnectListener;
    }

    /**
     * 设置起点坐标
     */
    private void setPivoXY(){
        Log.d(TAG,"setPivoXY-index:"+index);
        LayoutParams lp = (LayoutParams) vedioWindow.getLayoutParams();
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
        mVedioWindowStatus = status;
        fl_right.setVisibility(status == VedioWindowStatus.VideoStreaming ? View.VISIBLE : View.GONE);
        ll_loading.setVisibility(status == VedioWindowStatus.Inviting || status == VedioWindowStatus.OpeningDoor ? View.VISIBLE : View.GONE);
        fl_blank.setVisibility(status == VedioWindowStatus.WaitToInvite ? View.VISIBLE : View.GONE);
    }

    /**
     * 显示主播名
     */
    private void doShowAnchorName(){
        //展示昵称
        if(obj != null && !obj.isUserSelf && !TextUtils.isEmpty(obj.nickName)){
            tv_nickName.setVisibility(View.VISIBLE);
            tv_nickName.setText(StringUtil.truncateName(obj.nickName));

            if(index == 1){
                iv_crown.setVisibility(VISIBLE);
            }else {
                iv_crown.setVisibility(GONE);
            }
        }
    }

    /**
     * 切换到待邀请状态
     */
    public void showWaitToInviteView(){
        if(barGiftListManager != null){
            barGiftListManager.clear();
        }
        dimissInvitingAnim();
        stopGiftAnim();
        stopPushOrPullVedioStream();
        changeVedioWindowStatus(VedioWindowStatus.WaitToInvite);
        obj = null;
    }

    /**
     * 主播进入hangout状态
     */
    public enum AnchorComingType{
        Man_Inviting,//男士主动邀请中
        Man_Accepted_Anchor_Knock, // 男士接受主播敲门请求
        Anchor_Invite_Confirm,      //主播已进入直播间
        Anchor_Coming_After_Expires // 主播在公开/私密直播间接受邀请，倒计时结束后进入直播间
    }

    /**
     * 切换主播正在进入hangout直播间的状态
     * (单元格不得自己改变窗口状态，要通过HangOutVedioWindowManager更新)
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
        if(type!= AnchorComingType.Anchor_Coming_After_Expires){
            showInvitingAnim();
        }else{
            dimissInvitingAnim();
        }
        stopGiftAnim();
        stopPushOrPullVedioStream();
        String comingTips = null;
        if(!TextUtils.isEmpty(obj.nickName)){
            String anchorName = StringUtil.truncateName(obj.nickName);
            if(type== AnchorComingType.Man_Inviting){
                comingTips = activity.getString(R.string.hangout_inviting_tips, anchorName);
                tv_invitingTips.setText(comingTips);
                btn_cancel.setVisibility(VISIBLE);
                //更改界面状态展示
                changeVedioWindowStatus(VedioWindowStatus.Inviting);

                Log.d(TAG,"showAnchorComingView-comingTips:"+comingTips);
            }else if(type== AnchorComingType.Man_Accepted_Anchor_Knock){
                comingTips = activity.getString(R.string.hangout_coming_tips,obj.nickName);
                tv_invitingTips.setText(activity.getString(R.string.hangout_coming_tips, anchorName));
                btn_cancel.setVisibility(GONE);
                //更改界面状态展示
                changeVedioWindowStatus(VedioWindowStatus.OpeningDoor);

                Log.d(TAG,"showAnchorComingView-comingTips:"+comingTips);
            }else if(type== AnchorComingType.Anchor_Invite_Confirm){
//                anchorComingExpires = expires;
//                tv_invitingTips.setText(mActivity.getString(R.string.hangout_enter_tips,obj.nickName,String.valueOf(anchorComingExpires)));
//                handler.sendEmptyMessage(EVENT_ANCHOR_COMING_COUNT_DOWN);
                showVedioStreamView(activity, hangoutVedioWindowObj);
            }else if(type== AnchorComingType.Anchor_Coming_After_Expires){
                anchorComingExpires = expires;
                tv_invitingTips.setText(mActivity.getString(R.string.hangout_enter_tips, anchorName, String.valueOf(anchorComingExpires)));
                btn_cancel.setVisibility(GONE);
                handler.sendEmptyMessage(EVENT_ANCHOR_COMING_COUNT_DOWN);
                //更改界面状态展示
                changeVedioWindowStatus(VedioWindowStatus.Inviting);
            }
        }
        if(!TextUtils.isEmpty(obj.photoUrl)){
            //头像
            //压缩、裁剪图片
            int bgSize = getContext().getResources().getDimensionPixelSize(R.dimen.live_size_60dp);  //DisplayUtil.getScreenWidth(mContext);

            //对齐方式(中上对齐)
            PointF focusPoint = new PointF();
            focusPoint.x = 0.5f;
            focusPoint.y = 0f;

            //占位图，拉伸方式
            GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(getContext().getResources());
            GenericDraweeHierarchy hierarchy = builder
                    .setFadeDuration(300)
                    .setPlaceholderImage(R.drawable.ic_default_photo_woman)    //占位图
                    .setPlaceholderImageScaleType(ScalingUtils.ScaleType.FIT_XY)    //占位图拉伸
                    .setActualImageFocusPoint(focusPoint)
                    .setActualImageScaleType(ScalingUtils.ScaleType.FOCUS_CROP)     //图片拉伸（配合上面的focusPoint）
                    .build();
            img_photo.setHierarchy(hierarchy);

            //下载
            Uri imageUri = Uri.parse(obj.photoUrl);
            ImageRequest request = ImageRequestBuilder.newBuilderWithSource(imageUri)
                    .setResizeOptions(new ResizeOptions(bgSize, bgSize))
                    .build();
            DraweeController controller = Fresco.newDraweeControllerBuilder()
                    .setImageRequest(request)
                    .setOldController(img_photo.getController())
                    .setControllerListener(new BaseControllerListener<ImageInfo>())
                    .build();
            img_photo.setController(controller);

            //圆
            RoundingParams roundingParams = RoundingParams.fromCornersRadius(5f);
            roundingParams.setRoundAsCircle(true);
            img_photo.getHierarchy().setRoundingParams(roundingParams);
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
                liveStreamPushManager = new PublisherManager(mActivity);
                liveStreamPushManager.init(sv_vedio);
                mVideoWorkType = VideoWorkType.Push;
                hasCoolLiveInited = true;
            }
            liveStreamPushManager.setILSPublisherStatusListener(this);
        }else{
            if(null == liveStreamPullManager && null != mActivity){
                //否则就是拉流器
                liveStreamPullManager = new LivePlayerManager(mActivity);
                mVideoWorkType = VideoWorkType.Pull;
                if(mRendererBinderPull == null){
                    mRendererBinderPull = LivePlayerManager.createPlayerRenderBinder(sv_vedio);
                }
                liveStreamPullManager.init(mRendererBinderPull);
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
     */
    private void doShowVideoLoadingAnim(){
        Log.d(TAG,"doShowVideoLoadingAnim");
        if(null == obj || null == pb_loading){
            return;
        }
        //男士则显示头像的同时显示loading
        if(obj.isUserSelf){
            mPushVideoStatus = VideoStatus.waiting;
            pb_loading.setVisibility(View.VISIBLE);
            doHidePushOpera();
        }
    }

    /**
     * 隐藏视频加载动画
     */
    private void doHideVideoLoadingAnim(){
        Log.d(TAG,"doHideVideoLoadingAnim-obj:"+obj);
        if(null == obj || null == pb_loading){
            return;
        }
        if(obj.isUserSelf){
            pb_loading.setVisibility(View.GONE);
        }
        iv_photo.setVisibility(View.GONE);
        doHidePushOpera();
        Log.d(TAG,"doHideVideoLoadingAnim-isUserSelf:"+obj.isUserSelf+" targetUserId:"+obj.targetUserId+" iv_photo.visib:"+iv_photo.getVisibility());
    }

    /**
     * 显示上传视频操作区
     */
    private void doShowPushOpera(){
        if(obj != null && obj.isUserSelf){
            if(mPushVideoStatus == VideoStatus.waiting){
                return;
            }else if(mPushVideoStatus == VideoStatus.playing){
                //显示暂停
                fl_push.setVisibility(VISIBLE);
                btn_openVideo.setVisibility(GONE);
                btn_closeVideo.setVisibility(VISIBLE);

                //视频中， 操作层3秒后隐藏
                doUpdatePushOperaTime();
            }else{
                //显示播放
                fl_push.setVisibility(VISIBLE);
                btn_openVideo.setVisibility(VISIBLE);
                btn_closeVideo.setVisibility(GONE);
            }
        }

        if(isCanSwitchCamera){
            iv_switchCamera.setVisibility(VISIBLE);
        }
    }

    /**
     * 隐藏上传视频操作区
     */
    private void doHidePushOpera(){
        fl_push.setVisibility(GONE);
        if (mDisposableCountdown != null && !mDisposableCountdown.isDisposed()) {
            mDisposableCountdown.dispose();
        }
    }

    /**
     * 本地自动倒计时
     */
    private void doUpdatePushOperaTime() {
        if (mDisposableCountdown != null && !mDisposableCountdown.isDisposed()) {
            return;
        }
        mDisposableCountdown = Flowable.interval(STEP_PUSH_OPERA_COUNTDOWN, TimeUnit.MILLISECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<Long>() {
                    @Override
                    public void accept(Long aLong) throws Exception {
                        doHidePushOpera();
                    }
                });
    }

    /**
     * 显示主播/男士个人头像或封面
     */
    private void showVedioCover(){
        if(null == obj){
            return;
        }
        Log.d(TAG,"showVedioCover-obj.isUserSelf:"+obj.isUserSelf+" iv_photo.visib:"+iv_photo.getVisibility());

        //男士会员显示头像，主播自己显示视频预览，其他主播则显示默认视频加载状态图
        if(obj.isUserSelf){
            if(!TextUtils.isEmpty(obj.photoUrl)){
                FrescoLoadUtil.loadUrl(mActivity, iv_photo, obj.photoUrl, getResources().getDimensionPixelSize(R.dimen.live_size_80dp), R.drawable.ic_default_photo_man, false);
            }
            iv_photo.setVisibility(View.VISIBLE);

            //显示操作区（仅男士有效）
            doShowPushOpera();
        }
        else{
            //其他主播进来默认就会推流，所以不存在仅加载头像无推流的情况
            iv_photo.setImageResource(R.drawable.ic_hangout_vedio_loading);
            iv_photo.setVisibility(View.VISIBLE);
        }
        Log.d(TAG,"showVedioCover-iv_photo.visib:"+iv_photo.getVisibility());
    }

    /**
     * 切换到视频推拉流
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
        showVedioCover();
        //展示昵称
        if(!obj.isUserSelf && !TextUtils.isEmpty(obj.nickName)){
            tv_nickName.setVisibility(View.VISIBLE);
            tv_nickName.setText(StringUtil.truncateName(obj.nickName));
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
        doShowVideoLoadingAnim();
        doHidePushOpera();
        boolean videoUrlsUsuable = null != videoUrls && videoUrls.length > 0;
        Log.d(TAG,"startPushOrPullVedioStream-videoUrlsUsuable:"+videoUrlsUsuable+" obj:"+obj);
        initVSManager();
        //开始推拉流处理
        if(videoUrlsUsuable){
            if(obj.isUserSelf && null != liveStreamPushManager){
                mVideoWorkType = VideoWorkType.Push;
                liveStreamPushManager.setOrChangeManUploadUrls(videoUrls, "", "");
                Log.i(TAG , "startPushOrPullVedioStream 男士推流URL:" + videoUrls);
            }else if(null != liveStreamPullManager){
                mVideoWorkType = VideoWorkType.Pull;
                liveStreamPullManager.setOrChangeVideoUrls(videoUrls, "", "",null);
                Log.i(TAG , "startPushOrPullVedioStream 女士拉流URL:" + videoUrls);
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
            //男士主动断开，并不会回调到 onPushStreamDisconnect,所以在这要更新一下状态
            mPushVideoStatus = VideoStatus.stop;
        }else if(null != liveStreamPullManager){
            liveStreamPullManager.removeILSPlayerStatusListener();// .setILSPlayerStatusListener(null);
//            liveStreamPullManager.stopPlayInternal();
            liveStreamPullManager.onLogout();
            mPullVideoStatus = VideoStatus.stop;
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
        if(mHangoutInvitationManager != null) {
            mHangoutInvitationManager.release();
        }

        if (mDisposableCountdown != null && !mDisposableCountdown.isDisposed()) {
            mDisposableCountdown.dispose();
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

    public void initGiftManager(final Activity activity){
        Log.d(TAG,"initGiftManager-hasInitedView:"+hasInitedView);
        if(!hasInitedView){
            throw new RuntimeException("请先调用initView()方法初始化界面布局");
        }
        this.mActivity = activity;

        mModuleGiftManager = new ModuleGiftManager(activity);
        mModuleGiftManager.initAdvanceGift(sdv_advanceGiftAnim);
        mModuleGiftManager.initAdvancePngGift(sdv_barGiftAnim);
//        mModuleGiftManager.setGiftAnimShowedInHangOutRoom(true);
        mModuleGiftManager.initMultiGift(fl_multiGift,1);
//        mModuleGiftManager.showMultiGiftAs(fl_multiGift);
    }

    public void addIMMessageItem(IMMessageItem msgItem){
        Log.d(TAG,"playGiftAnim-msgItem:"+msgItem);

        if(null != mModuleGiftManager){
            mModuleGiftManager.dispatchIMMessage(msgItem, IMRoomInItem.IMLiveRoomType.HangoutRoom);
        }

    }

    private void stopGiftAnim(){
        Log.d(TAG,"stopGiftAnim");
        if(null != mModuleGiftManager){
            mModuleGiftManager.onMultiGiftStop();
            mModuleGiftManager.onAdvanceGiftOnStop();
        }
    }

    @Override
    public void onPushStreamConnect(LSPublisher lsPublisher) {
        Log.d(TAG,"onPushStreamConnect");
        if(null != mActivity){
//            runOnUiThread(new Runnable() {
//                @Override
//                public void run() {
//                    doHideVideoLoadingAnim();
//                    if(null != vedioDisconnectListener){
//                        vedioDisconnectListener.onVedioDisconnect(index,true);
//                    }
//                }
//            });
            mPushVideoStatus = VideoStatus.playing;
            this.post(new Runnable() {
                @Override
                public void run() {
                    doHideVideoLoadingAnim();
                    if(null != vedioDisconnectListener){
                        vedioDisconnectListener.onPushVedioConnect(index,true);
                    }
                }
            });
        }
    }

    /**
     * 男士主动断开，并不会回调到 onPushStreamDisconnect
     * @param lsPublisher
     */
    @Override
    public void onPushStreamDisconnect(LSPublisher lsPublisher) {
        Log.d(TAG,"onPushStreamDisconnect");
        if(null != mActivity){
            this.post(new Runnable() {
                @Override
                public void run() {
                    mPushVideoStatus = VideoStatus.stop;
                    //男士断流
                    showVedioCover();
                    // 但是如果app断线重连这段时间web端男士end了hangout直播间，就会出现视频流一直连上断开提示的情况
                    if(null != vedioDisconnectListener){
                        vedioDisconnectListener.onPushVedioConnect(index, false);
                    }
                }
            });
        }
    }

    @Override
    public void onPullStreamConnect(LSPlayer var1) {
        Log.d(TAG,"onPullStreamConnect");
        if(null != mActivity){
            this.post(new Runnable() {
                @Override
                public void run() {
                    //主播连上视频流
                    mPullVideoStatus = VideoStatus.playing;
                    doHideVideoLoadingAnim();
                    changeVedioWindowStatus(VedioWindowStatus.VideoStreaming);
                    doShowAnchorName();
                    if(null != vedioDisconnectListener){
                        vedioDisconnectListener.onPullVedioConnect(index,true);
                    }
                }
            });
        }
    }

    @Override
    public void onPullStreamDisconnect(LSPlayer var1) {
        Log.d(TAG,"onPushStreamDisconnect");
        if(null != mActivity){
            this.post(new Runnable() {
                @Override
                public void run() {
                    //主播视频流断开
                    mPullVideoStatus = VideoStatus.stop;
                    showVedioCover();
                    if(null != vedioDisconnectListener){
                        vedioDisconnectListener.onPullVedioConnect(index,false);
                    }
                }
            });
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if(null != mModuleGiftManager){
            mModuleGiftManager.destroy();
        }
    }

    //--------------------- 邀请 start --------------------

    /**
     * 发出邀请
     * @param hangoutVedioWindowObj
     * @param roomId
     */
    public boolean sendInvitation(HangoutVedioWindowObj hangoutVedioWindowObj, String roomId){
        if(obj != null){
            //如果座位上有人
            return false;
        }

        //发送邀请
        IMUserBaseInfoItem imUserBaseInfoItem = new IMUserBaseInfoItem();
        imUserBaseInfoItem.userId = hangoutVedioWindowObj.targetUserId;
        // 2019/4/1 Hardy 补全信息，回调外层时，需要用到 nickName
        imUserBaseInfoItem.nickName = hangoutVedioWindowObj.nickName;
        imUserBaseInfoItem.photoUrl = hangoutVedioWindowObj.photoUrl;
        startInvitationInternal(imUserBaseInfoItem, roomId, "", false);
        return true;
    }

    private void startInvitationInternal(IMUserBaseInfoItem anchorInfo, String roomId, String recommandId, boolean createOnly){
        if(mHangoutInvitationManager != null){
            //清除旧的
            mHangoutInvitationManager.release();
        }
        //互斥关系创建新的邀请client
        mHangoutInvitationManager = HangoutInvitationManager.createInvitationClient(getContext());
        mHangoutInvitationManager.setClientEventListener(this);
        mHangoutInvitationManager.startInvitationSession(anchorInfo, roomId, recommandId, createOnly, false);
    }


    @Override
    public void onHangoutInvitationStart(IMUserBaseInfoItem userBaseInfoItem) {

        if(OnInviteEventListener != null){
            OnInviteEventListener.onInvitationStart(userBaseInfoItem);
        }
    }

    @Override
    public void onHangoutInvitationFinish(boolean isSuccess, HangoutInvitationManager.HangoutInvationErrorType errorType, String errMsg, IMUserBaseInfoItem userBaseInfoItem, String roomId) {

        if(OnInviteEventListener != null){
            OnInviteEventListener.onInvitationResponse(isSuccess, errorType, errMsg, userBaseInfoItem, roomId);
        }
    }

    @Override
    public void onHangoutCancel(boolean isSuccess, int httpErrCode, String errMsg, IMUserBaseInfoItem userBaseInfoItem) {

        if(onAddInviteClickListener != null){
            String anchorId = "";
            if(userBaseInfoItem != null){
                anchorId = userBaseInfoItem.userId;
            }else{
                if(obj != null && obj.imHangoutAnchorItem != null){
                    anchorId = obj.imHangoutAnchorItem.anchorId;
                }
            }

            onAddInviteClickListener.onInvitationCancel(isSuccess, httpErrCode, errMsg, anchorId);
        }
    }

    /**
     * 点击取消邀请
     */
    private void onCancelInvitationClicked(){
        if(mHangoutInvitationManager != null) {
            mHangoutInvitationManager.stopInvite();
        }else{
            //解决邀请中杀掉App,重新进入后，更新状态为邀请中时，缺少取消邀请相关业务问题
            if(obj != null && obj.imHangoutAnchorItem != null && !TextUtils.isEmpty(obj.imHangoutAnchorItem.inviteId)){
                mHangoutInvitationManager = HangoutInvitationManager.createInvitationClient(getContext());
                mHangoutInvitationManager.setClientEventListener(this);
                mHangoutInvitationManager.startInvitationByInvitationStatus(new IMUserBaseInfoItem(obj.imHangoutAnchorItem.anchorId, obj.imHangoutAnchorItem.nickName, obj.imHangoutAnchorItem.photoUrl), obj.imHangoutAnchorItem.inviteId);
                mHangoutInvitationManager.stopInvite();
            }
        }
    }

    //---------------------- 邀请 end ---------------------

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