package com.qpidnetwork.livemodule.liveshow.home;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.PointF;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

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
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetHangoutFriendsCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniHangout;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutOnlineAnchorItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;

/**
 * @author Jagger 2019-3-5
 */
public class HangOutAdapter extends BaseRecyclerViewAdapter<HangoutOnlineAnchorItem, HangOutAdapter.ViewHolderHangOut> {

    private final int FRIENDS_MAX_LENGHT = 5;
    private Context mContext;
    private OnHangOutListItemEventListener onHangOutListItemEventListener;

    public interface OnHangOutListItemEventListener{
        void onBgClicked(HangoutOnlineAnchorItem anchorInfoItem);
        void onFriendClicked(HangoutAnchorInfoItem anchorInfoItem);
        void onStartClicked(HangoutOnlineAnchorItem anchorInfoItem);
    }

    private class FriendsResult{
        boolean isSuccess;
        int errCode;
        String errMsg;
        List<HangoutAnchorInfoItem> audienceList = new ArrayList<>();
    }

    public HangOutAdapter(Context context) {
        super(context);
        mContext = context;
    }

    public void setOnEventListener(OnHangOutListItemEventListener listener){
        onHangOutListItemEventListener = listener;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_live_hang_out_list;
    }

    @Override
    public ViewHolderHangOut getViewHolder(View itemView, int viewType) {
        return new ViewHolderHangOut(itemView);
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public void initViewHolder(final ViewHolderHangOut holder) {

        //点击事件
        holder.setOnEventListener(onHangOutListItemEventListener);
    }

    @Override
    public void convertViewHolder(final ViewHolderHangOut holder, HangoutOnlineAnchorItem data, int position) {
        holder.setData(data, position);
    }

    @Override
    public void onViewDetachedFromWindow(@NonNull RecyclerView.ViewHolder holder) {
        if(holder instanceof ViewHolderHangOut){
            ((ViewHolderHangOut)holder).destroy();
        }
        super.onViewDetachedFromWindow(holder);
    }


    /**
     * 当图片不显示的时候自动释放，防止oom
     * @param holder
     */
    @Override
    public void onViewRecycled(RecyclerView.ViewHolder holder) {
        super.onViewRecycled(holder);

        if(holder instanceof ViewHolderHangOut) {
            ViewHolderHangOut viewHolder = (ViewHolderHangOut) holder;
            if (viewHolder.imgRoomBg.getController() != null) {
                viewHolder.imgRoomBg.getController().onDetach();
            }

            // 2018/12/29 Hardy
            // 该 callback 是 Drawable 内部接口，其 invalidateDrawable() 方法用于在需要重画的时候回调更新 view
            // Fresco 中有一些继承 Drawable 的子类，做该更新处理，若设置空，会导致不能更新，当前 ImageView 的图片会显示回
            // 该 item 的 position 的上一次的图片，即看起来图片错乱.
//            if (viewHolder.ivRoomBg.getTopLevelDrawable() != null) {
//                viewHolder.ivRoomBg.getTopLevelDrawable().setCallback(null);
//            }
        }
    }


    /**
     * ViewHolder
     */
    protected class ViewHolderHangOut extends BaseViewHolder<HangoutOnlineAnchorItem>{
        public SimpleDraweeView imgRoomBg;
        public TextView tvName;
        public TextView tvDes;
//        public LinearLayout lyStart;
        public RecyclerView rvFriends;
        public HangOutListFriendsAdapter mAdapterFriends;
        private Disposable mDisposable;
        public ButtonRaised btnStart;
//        private boolean isGetFriends = false;
        private OnHangOutListItemEventListener onEventListener;

        public ViewHolderHangOut(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            imgRoomBg = f(R.id.iv_roomBg);
            tvName = f(R.id.tv_name);
            tvDes = f(R.id.tv_des);
            btnStart = f(R.id.btn_start);
            rvFriends = f(R.id.rv_friends);

            LinearLayoutManager manager = new LinearLayoutManager(mContext, LinearLayoutManager.HORIZONTAL, false);
            mAdapterFriends = new HangOutListFriendsAdapter(mContext);
            mAdapterFriends.setOnEventListener(new HangOutListFriendsAdapter.OnHangOutListFriendsItemEventListener() {
                @Override
                public void onFriendClicked(HangoutAnchorInfoItem anchorInfoItem) {
                    if(onEventListener != null){
                        onEventListener.onFriendClicked(anchorInfoItem);
                    }
                }
            });

            rvFriends.setLayoutManager(manager);
            rvFriends.setAdapter(mAdapterFriends);


            // 2018/12/29 Hardy
            /*
                 不在 onBindViewHolder 中使用，有以下原因：
                 1、https://www.fresco-cn.org/docs/gotchas.html
                     不要复用 DraweeHierarchies
                     不要在多个 DraweeHierarchy 中使用同一个 Drawable

                 2、https://www.fresco-cn.org/docs/using-drawees-code.html
                     对于同一个View，请不要多次调用setHierarchy，即使这个 View 是可回收的。创建 DraweeHierarchy 的较为耗时的一个过程，应该多次利用。
             */

            FrescoLoadUtil.setHierarchy(mContext, imgRoomBg, R.drawable.bg_hotlist_item, false);
        }

        @Override
        public void setData(final HangoutOnlineAnchorItem data, int position) {
            tvName.setText(data.nickName);

            //邀请语
            if(!TextUtils.isEmpty(data.invitationMsg)){
                tvDes.setVisibility(View.VISIBLE);
                tvDes.setText(mContext.getResources().getString(R.string.hangout_list_invitationmsg_des, data.invitationMsg));
            }else {
                tvDes.setVisibility(View.GONE);
            }

            //封面图
            //封面图大小，因此时取不出控件大小, 暂时以屏幕宽为准
            int bgSize = (int)(DisplayUtil.getScreenWidth(mContext)*0.8);//屏幕宽 80% 尽量节省内存
            FrescoLoadUtil.loadUrl(imgRoomBg, data.coverImg, bgSize);


            //好友列表
//            if(!isGetFriends){
                //未取过才请求接口
//                doGetHangoutFriends(data.anchorId, new Consumer<FriendsResult>() {
//                    @Override
//                    public void accept(FriendsResult friendsResult) {
//                        if(friendsResult.isSuccess){
//                            isGetFriends = true;
//                            mAdapterFriends.setData(friendsResult.audienceList);
//                        }
//                    }
//                });
//                isGetFriends = true;
            if(data.friendsInfo.length > FRIENDS_MAX_LENGHT){
                mAdapterFriends.setData(Arrays.asList(Arrays.copyOf(data.friendsInfo, FRIENDS_MAX_LENGHT)));
            }else{
                mAdapterFriends.setData(Arrays.asList(data.friendsInfo));
            }


            //点击事件
            imgRoomBg.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(onEventListener != null){
                        onEventListener.onBgClicked(data);
                    }
                }
            });

            btnStart.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(onEventListener != null){
                        onEventListener.onStartClicked(data);
                    }
                }
            });
        }

        public void setOnEventListener(OnHangOutListItemEventListener listener){
            onEventListener = listener;
        }

        /**
         * 取好友列表
         * @param anchorId
         * @param observerResult
         */
        private void doGetHangoutFriends(final String anchorId, Consumer<FriendsResult> observerResult){
            //rxjava
            Observable<FriendsResult> observerable = Observable.create(new ObservableOnSubscribe<FriendsResult>() {

                @Override
                public void subscribe(final ObservableEmitter<FriendsResult> emitter) {
                LiveRequestOperator.getInstance().GetHangoutFriends(anchorId, new OnGetHangoutFriendsCallback() {
                    @Override
                    public void onGetHangoutFriends(boolean isSuccess, int errCode, String errMsg, HangoutAnchorInfoItem[] audienceList) {
                        FriendsResult friendsResult = new FriendsResult();
                        friendsResult.isSuccess = isSuccess;
                        friendsResult.errCode = errCode;
                        friendsResult.errMsg = errMsg;
                        if (audienceList != null) {
                            friendsResult.audienceList.addAll(Arrays.asList(audienceList));
                        }

                        //发射
                        emitter.onNext(friendsResult);
                    }
                });
                }
            });

            mDisposable = observerable
                    .observeOn(AndroidSchedulers.mainThread())    //转由主线程处理结果
                    .subscribe(observerResult);
        }

        public void destroy(){
            if(mDisposable != null && !mDisposable.isDisposed()){
                mDisposable.dispose();
            }
        }

    }
}
