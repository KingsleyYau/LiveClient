package com.qpidnetwork.livemodule.liveshow.flowergift.store;

import android.content.Context;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.view.BadgeHelper;

import q.rorbin.badgeview.Badge;
import q.rorbin.badgeview.QBadgeView;

/**
 * @author Jagger 2019-10-14
 */
public class DeliveryGiftsAdapter extends BaseRecyclerViewAdapter<LSFlowerGiftBaseInfoItem, DeliveryGiftsAdapter.ViewHolder> {
    private Context mContext;
    private OnDeliveryItemEventListener mListener;

    public DeliveryGiftsAdapter(Context context) {
        super(context);
        mContext = context;
    }

    public void setOnDeliveryItemEventListener(OnDeliveryItemEventListener eventListener){
        mListener = eventListener;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_delivery_gift_list;
    }

    @Override
    public ViewHolder getViewHolder(View itemView, int viewType) {
        return new ViewHolder(itemView);
    }

    @Override
    public void initViewHolder(final ViewHolder holder) {
        holder.img_gift.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mListener != null){
                    mListener.onGiftClicked(getItemBean(getPosition(holder)));
                }
            }
        });
    }

    @Override
    public void convertViewHolder(ViewHolder holder, LSFlowerGiftBaseInfoItem data, int position) {
        holder.setData(data, position);
    }

    /**
     * ViewHolder
     */
    protected class ViewHolder extends BaseViewHolder<LSFlowerGiftBaseInfoItem> {

        public FrameLayout fl_gift;
        public SimpleDraweeView img_gift;
        private Badge badge;
        private int picSize ;

        public ViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            fl_gift = f(R.id.fl_gift);
            img_gift = f(R.id.img_gift);
            FrescoLoadUtil.setHierarchy(mContext, img_gift, R.color.black4, false,6,6,6,6);
            picSize = mContext.getResources().getDimensionPixelSize(R.dimen.delivery_img_size);

            badge = new QBadgeView(mContext).bindTarget(fl_gift);
            badge.setBadgeNumber(0);
            badge.setBadgeGravity(Gravity.TOP | Gravity.END);
            BadgeHelper.setBaseStyle(mContext, badge, mContext.getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_badge_txt_size_max));
        }

        @Override
        public void setData(LSFlowerGiftBaseInfoItem data, int position) {
            FrescoLoadUtil.loadUrl(img_gift, data.giftImg, picSize);

            if(data.giftNumber == 1){
                //1个礼物时不显示红点
                badge.setBadgeNumber(0);
            }else{
                badge.setBadgeNumber(data.giftNumber);
            }
        }
    }
}
