package com.qpidnetwork.livemodule.liveshow.home;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.PointF;
import android.net.Uri;
import android.support.constraint.ConstraintLayout;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
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
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;

/**
 * HangOut列表，每个item里的Friends横向头像
 * @author Jagger 2019-3-8
 */
public class HangOutListFriendsAdapter extends BaseRecyclerViewAdapter<HangoutAnchorInfoItem, HangOutListFriendsAdapter.ViewHolderHangOut> {

    private Context mContext;
    private OnHangOutListFriendsItemEventListener onHangOutListFriendsItemEventListener;

    public interface OnHangOutListFriendsItemEventListener{
        void onFriendClicked(HangoutAnchorInfoItem anchorInfoItem);
    }

    public HangOutListFriendsAdapter(Context context) {
        super(context);
        mContext = context;
    }

    public void setOnEventListener(OnHangOutListFriendsItemEventListener listener){
        onHangOutListFriendsItemEventListener = listener;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_live_hang_out_list_friends;
    }

    @Override
    public ViewHolderHangOut getViewHolder(View itemView, int viewType) {
        return new ViewHolderHangOut(itemView);
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public void initViewHolder(final ViewHolderHangOut holder) {
    }

    @Override
    public void convertViewHolder(final ViewHolderHangOut holder, HangoutAnchorInfoItem data, int position) {
        holder.setData(data, position);
    }

    /**
     *
     */
    protected class ViewHolderHangOut extends BaseViewHolder<HangoutAnchorInfoItem>{
        public Button btnFriend;
        public SimpleDraweeView imgFriend;

        public ViewHolderHangOut(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            imgFriend = f(R.id.img_friend);
            btnFriend = f(R.id.btn_friend);
        }

        @Override
        public void setData(final HangoutAnchorInfoItem data, int position) {
//            imgFriend.setImageURI(data.photoUrl);
            //压缩、裁剪图片
            int bgSize = mContext.getResources().getDimensionPixelSize(R.dimen.live_size_60dp);  //DisplayUtil.getScreenWidth(mContext);

            //对齐方式(中上对齐)
            PointF focusPoint = new PointF();
            focusPoint.x = 0.5f;
            focusPoint.y = 0f;

            //占位图，拉伸方式
            GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(context.getResources());
            GenericDraweeHierarchy hierarchy = builder
                    .setFadeDuration(300)
                    .setPlaceholderImage(R.drawable.ic_default_photo_woman)    //占位图
                    .setPlaceholderImageScaleType(ScalingUtils.ScaleType.FIT_XY)    //占位图拉伸
                    .setActualImageFocusPoint(focusPoint)
                    .setActualImageScaleType(ScalingUtils.ScaleType.FOCUS_CROP)     //图片拉伸（配合上面的focusPoint）
                    .build();
            imgFriend.setHierarchy(hierarchy);

            //下载
            Uri imageUri = Uri.parse(data.photoUrl);
            ImageRequest request = ImageRequestBuilder.newBuilderWithSource(imageUri)
                    .setResizeOptions(new ResizeOptions(bgSize,bgSize))
                    .build();
            DraweeController controller = Fresco.newDraweeControllerBuilder()
                    .setImageRequest(request)
                    .setOldController(imgFriend.getController())
                    .setControllerListener(new BaseControllerListener<ImageInfo>())
                    .build();
            imgFriend.setController(controller);

            //圆角
            RoundingParams roundingParams = RoundingParams.fromCornersRadius(5f);
            roundingParams.setRoundAsCircle(true);
            imgFriend.getHierarchy().setRoundingParams(roundingParams);

            btnFriend.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(onHangOutListFriendsItemEventListener != null){
                        onHangOutListFriendsItemEventListener.onFriendClicked(data);
                    }
                }
            });
        }

    }
}
