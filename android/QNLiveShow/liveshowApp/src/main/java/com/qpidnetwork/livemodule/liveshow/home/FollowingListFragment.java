package com.qpidnetwork.livemodule.liveshow.home;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.PointF;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Message;
import android.text.TextPaint;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.AbsListView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.common.ResizeOptions;
import com.facebook.imagepipeline.image.ImageInfo;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseListFragment;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.livemodule.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnBannerCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetFollowingListCallback;
import com.qpidnetwork.livemodule.httprequest.item.AnchorLevelType;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.FollowingListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.utils.ButtonUtils;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.HotItemStyleManager;
import com.qpidnetwork.livemodule.utils.IPConfigUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.PicassoRoundTransform;
import com.qpidnetwork.livemodule.utils.StringUtil;
import com.qpidnetwork.livemodule.view.ViewSmartHelper;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Hunter Mun on 2017/9/6.
 */

public class FollowingListFragment extends BaseListFragment{

    private static final int GET_FOLLOWING_CALLBACK = 1;
    private static final int GET_BANNER_CALLBACK = 2;
    private static final int GET_VOUCHER_CALLBACK = 3;

    private CanAdapter<FollowingListItem> mAdapter;
    private List<FollowingListItem> mFollowingList = new ArrayList<FollowingListItem>();
    private BannerItem bannerItem;
    private ImageView headerView = null;
    private HotListVoucherHelper hotListVoucherHelper = new HotListVoucherHelper();
    private boolean isNeedRefresh = true;   //是否需要刷新列表 刷新逻辑可看BUG#13060

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        initListHeaderView();
        mAdapter = createAdapter();
        TAG = FollowingListFragment.class.getSimpleName();
        setContentBackground(R.color.hotlist_item_default_bg_color);
        getPullToRefreshListView().addHeaderView(headerView);
        //隐藏滚动条
        getPullToRefreshListView().setVerticalScrollBarEnabled(false);
        getPullToRefreshListView().setFastScrollEnabled(false);
        getPullToRefreshListView().setAdapter(mAdapter);
//        getPullToRefreshListView().setHeaderDividersEnabled(true);
//        getPullToRefreshListView().setDivider(new ColorDrawable(getResources().getColor(R.color.hotlist_divider_color)));
//        getPullToRefreshListView().setDividerHeight(DisplayUtil.dip2px(getActivity(), 2));
        onDefaultErrorRetryClick();
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.d(TAG,"onResume");
        //刷新试用券信息
        updateVoucherAvailableInfo();
    }

    /**
     * 刷新试用券信息
     */
    private void updateVoucherAvailableInfo(){
        Log.d(TAG,"updateVoucherAvailableInfo");
        //add by Jagger 2018-2-6 列表为空不刷新,减少请求次数
        if((mFollowingList ==  null) || mFollowingList.size() == 0){
            Log.d(TAG,"**** cancel ****");
            return;
        }

        hotListVoucherHelper.updateVoucherAvailableInfo(new HotListVoucherHelper.OnGetVoucherAvailableInfoListener() {
            @Override
            public void onVoucherInfoUpdated(boolean isSuccess) {
                Log.d(TAG,"onGetVoucherInfo-isSuccess:"+isSuccess);
                sendEmptyUiMessage(GET_VOUCHER_CALLBACK);
            }
        });
    }

    @Override
    protected void onReVisible() {
        super.onReVisible();
        if(isNeedRefresh){
            //列表为空，切换刷一次
            onDefaultErrorRetryClick();
        }else{
            //刷新试用券信息
            updateVoucherAvailableInfo();
        }
    }

    @Override
    protected void onBackFromHomeInTimeInterval() {
        super.onBackFromHomeInTimeInterval();
        onDefaultErrorRetryClick();
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what) {
            case GET_BANNER_CALLBACK:{
                BannerItem bannerItem = (BannerItem) msg.obj;
                if (null != bannerItem) {
                    updateBannerImg(bannerItem);
                }
            }break;
            case GET_VOUCHER_CALLBACK:{
                mAdapter.notifyDataSetChanged();
            }break;
            case GET_FOLLOWING_CALLBACK:{
                //Ps:msg.arg1 == 1 取更多; ==0 刷新
                hideLoadingProcess();
                HttpRespObject response = (HttpRespObject)msg.obj;
                if(response.isSuccess) {
                    //del by Jagger 2018-2-6 != 1 不就是0吗? 移下去了
//                    if(!(msg.arg1 == 1)){
//                        mFollowingList.clear();
//                    }

                    if (0 == msg.arg1) {
                        //add by Jagger 2018-2-6
                        mFollowingList.clear();
                        //add by Jagger 2018-2-6 取Banner. 因为把所有请求放在一起, 耗时太长有时会引起ARN错误, 所以改为分步请求
                        updateBannerData();
                    }

                    FollowingListItem[] followingArray = (FollowingListItem[]) response.data;
                    if (followingArray != null) {
                        mFollowingList.addAll(Arrays.asList(followingArray));
                    }
                    mAdapter.setList(mFollowingList);

                    //无数据
                    if (mFollowingList == null || mFollowingList.size() == 0) {
                        showEmptyView();
                    } else {
                        //防止无数据下拉刷新后，无数据页仍然存在
                        hideNodataPage();
                        hideErrorPage();
                    }

                    //刷新试用券信息
                    if(0 == msg.arg1) {
                        updateVoucherAvailableInfo();
                    }

                    //
                    isNeedRefresh = false;
                }else{
                    if(mFollowingList.size()>0){
                        if(getActivity() != null){
                            Toast.makeText(getActivity(), response.errMsg, Toast.LENGTH_LONG).show();
                        }
                        isNeedRefresh = false;
                    }else{
                        //无数据显示错误页，引导用户
                        showErrorPage();
                        isNeedRefresh = true;
                    }
                }
            }break;
        }
        onRefreshComplete();
    }

    public void updateBannerImg(BannerItem bannerItem){
        this.bannerItem = bannerItem;
        if(null != headerView && null != bannerItem && !TextUtils.isEmpty(bannerItem.bannerImgUrl)
                && !TextUtils.isEmpty(bannerItem.bannerLinkUrl) && getActivity() != null){
            Picasso.with(getActivity()).load(bannerItem.bannerImgUrl)
                    .placeholder(getActivity().getResources().getDrawable(R.drawable.hotlist_default_header))
                    .error(getActivity().getResources().getDrawable(R.drawable.hotlist_default_header))
                    .fit()
                    .into(headerView);
        }
    }

    /**
     * 生成列表头
     * @return
     */
    private void initListHeaderView(){
        headerView = new ImageView(getActivity());
        headerView.setAdjustViewBounds(true);
        if(null != bannerItem && !TextUtils.isEmpty(bannerItem.bannerImgUrl) && !TextUtils.isEmpty(bannerItem.bannerLinkUrl)){
            Picasso.with(getActivity()).load(bannerItem.bannerImgUrl)
                    .placeholder(getActivity().getResources().getDrawable(R.drawable.hotlist_default_header))
                    .error(getActivity().getResources().getDrawable(R.drawable.hotlist_default_header))
                    .config(Bitmap.Config.RGB_565)
                    .into(headerView);
        }else{
            headerView.setImageResource(R.drawable.hotlist_default_header);
        }
        headerView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(null != bannerItem && !TextUtils.isEmpty(bannerItem.bannerLinkUrl)){
                    startActivity(WebViewActivity.getIntent(getActivity(),
                            bannerItem.bannerName,
                            IPConfigUtil.addCommonParamsToH5Url(bannerItem.bannerLinkUrl),
                            true));
                }

            }
        });
    }

    private void queryFollowingList(final boolean isLoadMore){
        int start = 0;
        if(isLoadMore){
            start = mFollowingList.size();
        }
        LiveRequestOperator.getInstance().GetFollowingLiveList(start, Default_Step, new OnGetFollowingListCallback() {
            @Override
            public void onGetFollowingList(boolean isSuccess, int errCode, String errMsg, FollowingListItem[] followingList) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, followingList);
                Message msg = Message.obtain();
                msg.what = GET_FOLLOWING_CALLBACK;
                msg.arg1 = isLoadMore?1:0;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(){
        if(null != getActivity()){
            setDefaultEmptyMessage(getActivity().getResources().getString(R.string.followinglist_empty_text));
            setDefaultEmptyButtonText(getActivity().getResources().getString(R.string.anchor_list_empty));
        }
        showNodataPage();
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        showLoadingProcess();
        queryFollowingList(false);
//        Log.d(TAG,"onDefaultErrorRetryClick-updateBannerData");
//        updateBannerData();
    }

    @Override
    protected void onDefaultEmptyGuide() {
        super.onDefaultEmptyGuide();
        if(getActivity() != null && getActivity() instanceof  MainFragmentActivity){
            ((MainFragmentActivity)getActivity()).setCurrentPager(0);
            //add by Jagger 2018-8-10 BUG#13276 只是跳转到hotList,但这个无数据页不能消失
            showEmptyView();
        }
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        queryFollowingList(false);
//        updateBannerData();
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        queryFollowingList(true);
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        queryFollowingList(false);
    }

    @Override
    public void onRefreshComplete() {
        super.onRefreshComplete();
    }

    private CanAdapter<FollowingListItem> createAdapter(){
        final CanAdapter<FollowingListItem> adapter = new CanAdapter<FollowingListItem>(getActivity(), R.layout.item_hot_list, mFollowingList) {
            @Override
            protected void setView(CanHolderHelper helper, int position, FollowingListItem bean) {
                //处理item大小（宽高相同）
                int itemHeight = DisplayUtil.getScreenWidth(mContext);
                AbsListView.LayoutParams params = (AbsListView.LayoutParams)helper.getConvertView().getLayoutParams();
                params.height = itemHeight;

//                helper.setImageResource(R.id.ivOnlineStatus,
//                        bean.onlineStatus == AnchorOnlineStatus.Online ? R.drawable.anchor_status_online :
//                        R.drawable.anchor_status_offline);

                //兴趣爱好区域
                helper.setVisibility(R.id.ivInterest1, View.GONE);
                helper.setVisibility(R.id.ivInterest2, View.GONE);
                helper.setVisibility(R.id.ivInterest3, View.GONE);
//                if(bean.interests != null && bean.interests.size() > 0){
//                    if(bean.interests.size() >= 3){
//                        helper.setVisibility(R.id.ivInterest1, View.VISIBLE);
//                        helper.setVisibility(R.id.ivInterest2, View.VISIBLE);
//                        helper.setVisibility(R.id.ivInterest3, View.VISIBLE);
//                        helper.setImageResource(R.id.ivInterest1, ImageUtil.getImageResoursceByName(bean.interests.get(0).name()));
//                        helper.setImageResource(R.id.ivInterest2, ImageUtil.getImageResoursceByName(bean.interests.get(1).name()));
//                        helper.setImageResource(R.id.ivInterest3, ImageUtil.getImageResoursceByName(bean.interests.get(2).name()));
//                    }else if(bean.interests.size() == 2){
//                        helper.setVisibility(R.id.ivInterest1, View.VISIBLE);
//                        helper.setVisibility(R.id.ivInterest2, View.VISIBLE);
//                        helper.setImageResource(R.id.ivInterest1, ImageUtil.getImageResoursceByName(bean.interests.get(0).name()));
//                        helper.setImageResource(R.id.ivInterest2, ImageUtil.getImageResoursceByName(bean.interests.get(1).name()));
//                    }else{
//                        helper.setVisibility(R.id.ivInterest1, View.VISIBLE);
//                        helper.setImageResource(R.id.ivInterest1, ImageUtil.getImageResoursceByName(bean.interests.get(0).name()));
//                    }
//                }

//                //回收停止动画
//                final ImageView btnPrivate = helper.getView(R.id.btnPrivate);
//                //edit by Jagger 2018-1-8 控件看不到时, 停止动画
//                ViewSmartHelper viewSmartHelperPrivate = new ViewSmartHelper(btnPrivate);
//                viewSmartHelperPrivate.setOnVisibilityChangedListener(new ViewSmartHelper.onVisibilityChangedListener() {
//                    @Override
//                    public void onVisibilityChanged(boolean isVisible) {
//                        if(!isVisible){
//                            Drawable privateDrawable = btnPrivate.getDrawable();
//                            if ((privateDrawable != null)
//                                    && (privateDrawable instanceof AnimationDrawable)) {
//                                if(((AnimationDrawable) privateDrawable).isRunning()){
//                                    ((AnimationDrawable) privateDrawable).stop();
//                                }
//                            }
//                        }
//                    }
//                });


                //房间状态
                final ImageView ivLiveType = helper.getView(R.id.ivLiveType);
                //edit by Jagger 2018-1-8 控件看不到时, 停止动画
                ViewSmartHelper viewSmartHelperLiveType = new ViewSmartHelper(ivLiveType);
                viewSmartHelperLiveType.setOnVisibilityChangedListener(new ViewSmartHelper.onVisibilityChangedListener() {
                    @Override
                    public void onVisibilityChanged(boolean isVisible) {
                        Drawable liveTypeDrawable = ivLiveType.getDrawable();
                        if(!isVisible){
                            if ((liveTypeDrawable != null)
                                    && (liveTypeDrawable instanceof AnimationDrawable)) {
                                if(((AnimationDrawable) liveTypeDrawable).isRunning()) {
                                    ((AnimationDrawable) liveTypeDrawable).stop();
                                }
                            }
                        }else{
                            if ((liveTypeDrawable != null)
                                    && (liveTypeDrawable instanceof AnimationDrawable)) {
                                if(!((AnimationDrawable) liveTypeDrawable).isRunning()) {
                                    ((AnimationDrawable) liveTypeDrawable).start();
                                }
                            }
                        }
                    }
                });
                //统一先隐藏，只有公开直播间时才显示
                helper.setVisibility(R.id.ivLiveType, View.GONE);
                helper.setVisibility(R.id.ivPremium, View.GONE);

                //统一先隐藏操作按钮，根据需要打开
                helper.setVisibility(R.id.btnPrivate, View.GONE);
                helper.setVisibility(R.id.btnPublic, View.GONE);
                helper.setVisibility(R.id.btnSchedule, View.GONE);

                //区别处理节目和普通直播间
                boolean isProgram = false;
                helper.setText(R.id.tvName,bean.nickName);
                if(bean.showInfo != null && !TextUtils.isEmpty(bean.showInfo.showLiveId)){
                    isProgram = true;
                }

                //节目描述
                if(isProgram) {
                    List<Integer> returnDrawableWidths = new ArrayList<>();
                    helper.setVisibility(R.id.tvProgramDesc, View.VISIBLE);
                    helper.getTextView(R.id.tvProgramDesc).setText(StringUtil.parseHotFollowProgramDesc(mContext, bean.showInfo.showTitle , returnDrawableWidths));

                    //计算文字宽
                    TextPaint paint = helper.getTextView(R.id.tvProgramDesc).getPaint();
                    String showTitleText = helper.getTextView(R.id.tvProgramDesc).getText().toString();
                    int textLength = (int)paint.measureText(showTitleText);
                    for (Integer drawableWidth:returnDrawableWidths ) {
                        textLength += drawableWidth;
                    }
                    //重设TextView宽度
                    helper.getTextView(R.id.tvProgramDesc).setLayoutParams(new LinearLayout.LayoutParams(textLength , ViewGroup.LayoutParams.WRAP_CONTENT));

                    //Speed 根据字长计算滚动速度 (每秒显示3个字符)
                    float speed = 8;
                    if(!TextUtils.isEmpty(showTitleText)){
                        speed = showTitleText.length()/3;
                    }

                    //设置动画（Ps:花这么多功夫做个滚动， 是因为需求要求文字短也能滚， 所以用不了跑马灯）
                    Animation animation = AnimationUtils.loadAnimation(mContext, R.anim.anim_hotlist_grogramme_des);
                    animation.setDuration((int)(speed * 1000));
                    helper.getTextView(R.id.tvProgramDesc).startAnimation(animation);
                }else{
                    helper.setVisibility(R.id.tvProgramDesc, View.GONE);
                }


                //按钮区域
                if(bean.onlineStatus == AnchorOnlineStatus.Online){

                    //统一处理右上角图标（节目和付费公开直播间时显示）
                    if(isProgram){
                        helper.setVisibility(R.id.ivPremium, View.VISIBLE);
                        helper.setImageResource(R.id.ivPremium, R.drawable.list_program_indicator);
                    }else if(bean.roomType == LiveRoomType.PaidPublicRoom){
                        helper.setVisibility(R.id.ivPremium, View.VISIBLE);
                        helper.setImageResource(R.id.ivPremium, R.drawable.list_premium_public);
                    }

                    if(bean.roomType != LiveRoomType.Unknown) {
                        //房间类型
//                        helper.setVisibility(R.id.btnSchedule, View.GONE);
//                        helper.setVisibility(R.id.llStartContent, View.VISIBLE);
//                        helper.setVisibility(R.id.ivLiveType, View.VISIBLE);
                        if (bean.roomType == LiveRoomType.FreePublicRoom
                                || bean.roomType == LiveRoomType.PaidPublicRoom) {
//                            helper.setImageResource(R.id.ivLiveType, R.drawable.room_type_public);
                            helper.setVisibility(R.id.ivLiveType, View.VISIBLE);
                            setAndStartRoomTypeAnimation(bean.roomType, ivLiveType);
//                            helper.setVisibility(R.id.btnPrivate, View.VISIBLE);
//                            helper.setVisibility(R.id.btnPublic, View.VISIBLE);
                        }
//                        else {
//                            helper.setImageResource(R.id.ivLiveType, R.drawable.anchor_status_online);
//                            helper.setVisibility(R.id.btnPrivate, View.VISIBLE);
//                            helper.setVisibility(R.id.btnPublic, View.GONE);
//                        }

                        switch (bean.roomType) {
                            case FreePublicRoom: {
//                                helper.setImageResource(R.id.btnPrivate, R.drawable.list_button_start_normal_private_broadcast);
//                                setAndStartAdvancePrivateAnimation(btnPrivate);
                                helper.setVisibility(R.id.btnPublic, View.VISIBLE);
                                //根据是否free更换图标，调整间距
                                HotItemStyleManager.resetHotItemButtomStyle(getActivity(),
                                        helper.getImageView(R.id.btnPublic),
                                        hotListVoucherHelper.checkVoucherFree(bean.userId,true),true);
                            }
                            break;
                            case PaidPublicRoom: {
//                                setAndStartAdvancePrivateAnimation(btnPrivate);
                                helper.setVisibility(R.id.btnPublic, View.VISIBLE);
                                //根据是否free更换图标，调整间距
                                HotItemStyleManager.resetHotItemButtomStyle(getActivity(),
                                        helper.getImageView(R.id.btnPublic),
                                        hotListVoucherHelper.checkVoucherFree(bean.userId,true),true);
                            }
                            break;
                            case AdvancedPrivateRoom: {
//                                setAndStartAdvancePrivateAnimation(btnPrivate);
                                helper.setVisibility(R.id.btnPrivate, View.VISIBLE);
                                //根据是否free更换图标，调整间距
                                HotItemStyleManager.resetHotItemButtomStyle(getActivity(),
                                        helper.getImageView(R.id.btnPrivate),
                                        hotListVoucherHelper.checkVoucherFree(bean.userId,false),false);
                            }
                            break;
                            case NormalPrivateRoom: {
//                                helper.setImageResource(R.id.btnPrivate, R.drawable.list_button_start_normal_private_broadcast);
//                                setAndStartAdvancePrivateAnimation(btnPrivate);
                                helper.setVisibility(R.id.btnPrivate, View.VISIBLE);
                                //根据是否free更换图标，调整间距
                                HotItemStyleManager.resetHotItemButtomStyle(getActivity(),
                                        helper.getImageView(R.id.btnPrivate),
                                        hotListVoucherHelper.checkVoucherFree(bean.userId,false),false);
                            }
                            break;
                        }
                    }else{
                        //在线未直播
//                        helper.setVisibility(R.id.btnSchedule, View.GONE);
//                        helper.setVisibility(R.id.llStartContent, View.VISIBLE);
                        helper.setVisibility(R.id.btnPrivate, View.VISIBLE);
                        //根据是否free更换图标，调整间距
                        HotItemStyleManager.resetHotItemButtomStyle(getActivity(),
                                helper.getImageView(R.id.btnPrivate),
                                hotListVoucherHelper.checkVoucherFree(bean.userId,false),false);
//                        helper.setVisibility(R.id.btnPrivate, View.VISIBLE);
//                        helper.setVisibility(R.id.btnPublic, View.GONE);
//                        if(bean.anchorType == AnchorLevelType.gold){
//                            setAndStartAdvancePrivateAnimation(btnPrivate);
//                        }else{
////                            helper.setImageResource(R.id.btnPrivate, R.drawable.list_button_start_normal_private_broadcast);
//                            setAndStartAdvancePrivateAnimation(btnPrivate);
//                        }
                        //add by Jagger 2018-3-8
                        helper.setVisibility(R.id.ivLiveType, View.VISIBLE);
                        helper.setImageResource(R.id.ivLiveType , R.drawable.ic_livetype_room_online);
                    }
                }else{
//                    helper.setImageResource(R.id.ivLiveType, R.drawable.anchor_status_offline);
//                    helper.setVisibility(R.id.llStartContent, View.GONE);
//                    helper.setVisibility(R.id.btnSchedule, View.VISIBLE);
                    helper.setVisibility(R.id.btnSchedule, View.VISIBLE);
                    helper.setImageResource(R.id.btnSchedule, R.drawable.list_button_send_schedule);
                }

                //背景图
//                helper.setImageResource(R.id.iv_roomBg, R.drawable.rectangle_transparent_drawable);
//                if(!TextUtils.isEmpty(bean.roomPhotoUrl) && getActivity() != null){
//                    ImageView imgView = helper.getImageView(R.id.iv_roomBg);
//                    Picasso.with(getActivity())
//                            .load(bean.roomPhotoUrl)
//                            .transform(new PicassoRoundTransform(
//                                    params.height,   //宽    //因为这个Item宽高都一样,以屏幕宽为准.
//                                    params.height, //高
//                                    0))//弧度
//                            .placeholder(R.drawable.rectangle_transparent_drawable)
//                            .error(R.drawable.rectangle_transparent_drawable)
//                            .config(Bitmap.Config.RGB_565)
//                            .into(imgView);
//                }
                if(!TextUtils.isEmpty(bean.roomPhotoUrl) && mContext!= null){
                    //edit by Jagger 2018-6-29:picasso不会从本地取缓存，每次下载，初始化时图片显示得太慢，所以改用fresco
                    SimpleDraweeView ivRoomBg = helper.getView(R.id.iv_roomBg);

                    //对齐方式(左上角对齐)
                    PointF focusPoint = new PointF();
                    focusPoint.x = 0f;
                    focusPoint.y = 0f;

                    //占位图，拉伸方式
                    GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(mContext.getResources());
                    GenericDraweeHierarchy hierarchy = builder
                            .setFadeDuration(300)
                            .setPlaceholderImage(R.drawable.bg_hotlist_item)    //占位图
                            .setPlaceholderImageScaleType(ScalingUtils.ScaleType.FIT_XY)    //占位图拉伸
                            .setActualImageFocusPoint(focusPoint)
                            .setActualImageScaleType(ScalingUtils.ScaleType.FOCUS_CROP)     //图片拉伸（配合上面的focusPoint）
                            .build();
                    ivRoomBg.setHierarchy(hierarchy);

                    //压缩、裁剪图片
                    Uri imageUri = Uri.parse(bean.roomPhotoUrl);
                    ImageRequest request = ImageRequestBuilder.newBuilderWithSource(imageUri)
                            .setResizeOptions(new ResizeOptions(itemHeight, itemHeight))
                            .build();
                    DraweeController controller = Fresco.newDraweeControllerBuilder()
                            .setImageRequest(request)
                            .setOldController(ivRoomBg.getController())
                            .setControllerListener(new BaseControllerListener<ImageInfo>())
                            .build();
                    ivRoomBg.setController(controller);
                }
            }

            /**
             * 设置启动帧动画
             * @param view
             */
            private void setAndStartAdvancePrivateAnimation(final ImageView view){
                view.setImageResource(R.drawable.anim_private_broadcast_button);
                postUiDelayed(new Runnable() {
                    @Override
                    public void run() {
                        Drawable tempDrawable = view.getDrawable();
                        if((tempDrawable != null)
                                && (tempDrawable instanceof AnimationDrawable)){
                            ((AnimationDrawable)tempDrawable).start();
                        }
                    }
                }, 200);
            }

            /**
             * 设置启动房间直播间状态
             * @param roomType
             * @param view
             */
            private void setAndStartRoomTypeAnimation(LiveRoomType roomType, final ImageView view){
                if(roomType == LiveRoomType.FreePublicRoom){
                    view.setImageResource(R.drawable.anim_room_broadcasting);
                }else if(roomType == LiveRoomType.PaidPublicRoom){
                    view.setImageResource(R.drawable.anim_room_broadcasting);
                }
                postUiDelayed(new Runnable() {
                    @Override
                    public void run() {
                        Drawable tempDrawable = view.getDrawable();
                        if((tempDrawable != null)
                                && (tempDrawable instanceof AnimationDrawable)){
                            ((AnimationDrawable)tempDrawable).start();
                        }
                    }
                }, 200);
            }

            @Override
            protected void setItemListener(CanHolderHelper helper) {
                //只有这里设置了setItemChildClickListener,对adapter的setOnItemListener才会有效
                helper.setItemChildClickListener(R.id.btnPrivate);
                helper.setItemChildClickListener(R.id.btnPublic);
                helper.setItemChildClickListener(R.id.btnSchedule);
                helper.setItemChildClickListener(R.id.iv_roomBg);
            }

        };
        adapter.setOnItemListener(new CanOnItemListener(){
            @Override
            public void onItemChildClick(View view, int position) {
                String action = "";
                String label = "";
                FollowingListItem item = adapter.getItem(position);
                int i = view.getId();
                if(!ButtonUtils.isFastDoubleClick(i)) {
                    if (i == R.id.iv_roomBg) {
                        AnchorProfileActivity.launchAnchorInfoActivty(getActivity(), getResources().getString(R.string.live_webview_anchor_profile_title),
                                item.userId, false, AnchorProfileActivity.TagType.Album);
                    } else if (i == R.id.btnPrivate) {
                        startActivity(LiveRoomTransitionActivity.getIntent(mContext,
                                LiveRoomTransitionActivity.CategoryType.Audience_Invite_Enter_Room,
                                item.userId, item.nickName, item.photoUrl, "", item.roomPhotoUrl));
                        //GA统计
                        if (item.anchorType == AnchorLevelType.gold) {
                            action = getResources().getString(R.string.Live_EnterBroadcast_Action_VIPPrivateBroadcast);
                            label = getResources().getString(R.string.Live_EnterBroadcast_Label_VIPPrivateBroadcast);
                        } else {
                            action = getResources().getString(R.string.Live_EnterBroadcast_Action_PrivateBroadcast);
                            label = getResources().getString(R.string.Live_EnterBroadcast_Label_PrivateBroadcast);
                        }
                    } else if (i == R.id.btnPublic) {
                        startActivity(LiveRoomTransitionActivity.getIntent(mContext,
                                LiveRoomTransitionActivity.CategoryType.Enter_Public_Room,
                                item.userId, item.nickName, item.photoUrl, "", item.roomPhotoUrl));
                        //GA统计
                        if (item.showInfo != null && !TextUtils.isEmpty(item.showInfo.showLiveId)) {
                            //节目
                            action = getResources().getString(R.string.Live_EnterBroadcast_Action_ShowBroadcast);
                            label = getResources().getString(R.string.Live_EnterBroadcast_Label_ShowBroadcast);
                        } else if (item.anchorType == AnchorLevelType.gold) {
                            action = getResources().getString(R.string.Live_EnterBroadcast_Action_VIPPublicBroadcast);
                            label = getResources().getString(R.string.Live_EnterBroadcast_Label_VIPPublicBroadcast);
                        } else {
                            action = getResources().getString(R.string.Live_EnterBroadcast_Action_PublicBroadcast);
                            label = getResources().getString(R.string.Live_EnterBroadcast_Label_PublicBroadcast);
                        }
                    } else if (i == R.id.btnSchedule) {
                        startActivity(BookPrivateActivity.getIntent(mContext, item.userId, item.nickName));
                        //GA统计
                        action = getResources().getString(R.string.Live_EnterBroadcast_Action_RequestBooking);
                        label = getResources().getString(R.string.Live_EnterBroadcast_Label_RequestBooking);
                    }
                }

                //GA统计
                Activity activity = getActivity();
                if(!TextUtils.isEmpty(action) && activity != null
                        && activity instanceof AnalyticsFragmentActivity){
                    ((AnalyticsFragmentActivity)activity).onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category), action, label);
                }
            }
        });
        return adapter;
    }

    /**
     * 刷新banner
     */
    private void updateBannerData(){
        LiveRequestOperator.getInstance().Banner(new OnBannerCallback() {
            @Override
            public void onBanner(boolean isSuccess, int errCode, String errMsg,
                                 String bannerImg, String bannerLink, String bannerName) {
                Log.d(TAG,"onBanner-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" bannerImg:"+bannerImg+" bannerLink:"+bannerLink
                        +" bannerName:"+bannerName);
                if(isSuccess){
                    BannerItem bannerItem = new BannerItem(bannerImg,bannerLink,bannerName);
                    Message msg = Message.obtain();
                    msg.what = GET_BANNER_CALLBACK;
                    msg.obj = bannerItem;
                    sendUiMessage(msg);

                }
            }
        });
    }
}
