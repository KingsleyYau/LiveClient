package com.qpidnetwork.liveshow.liveroom.gift.dialog;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.qpidnetwork.framework.canadapter.CanAdapter;
import com.qpidnetwork.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.httprequest.item.GiftItem;
import com.qpidnetwork.liveshow.LiveApplication;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.utils.DisplayUtil;
import com.squareup.picasso.Picasso;

import java.util.List;

import static com.qpidnetwork.utils.DisplayUtil.getResources;

/**
 * Description:礼物选择页,GridView的Adapter
 * <p>
 * Created by Harry on 2017/6/26.
 */

public class GiftAdapter extends CanAdapter {
    private final String TAG = GiftAdapter.class.getSimpleName();
    public static String selectedGiftId ="";
    private Drawable tranColorDrawable = null;
    private Drawable selectedYellowDrawable = null;
    private int itemWidth=0;
    private int giftIconWidth=0;
    private int giftFlagWidth = 0;

    public GiftAdapter(Context context, int itemLayoutId, List mList) {
        super(context, itemLayoutId, mList);
        itemWidth = DisplayUtil.getScreenWidth(context)/4;
        giftIconWidth = itemWidth/9*5;
        giftFlagWidth = itemWidth/9*2;
        tranColorDrawable = new ColorDrawable(getResources().getColor(android.R.color.transparent));
        selectedYellowDrawable = getResources().getDrawable(R.drawable.selector_live_buttom_gift_item);
    }

    @Override
    protected void setView(CanHolderHelper helper, int position, Object bean) {
        GiftItem item = (GiftItem)bean;
        helper.setText(R.id.tv_giftName,item.name);
        helper.setText(R.id.tv_giftCoins,String.valueOf(item.coins));

        View ll_giftItem = helper.getView(R.id.ll_giftItem);
        ViewGroup.LayoutParams itemLp = ll_giftItem.getLayoutParams();
        itemLp.width = itemWidth;
        itemLp.height = itemWidth;
        ll_giftItem.setLayoutParams(itemLp);
        boolean isSelected = ( !TextUtils.isEmpty(selectedGiftId)) && selectedGiftId.equals(item.id);
        Drawable drawalbe = isSelected? selectedYellowDrawable : tranColorDrawable;
        ll_giftItem.setBackgroundDrawable(drawalbe);

        ImageView iv_giftIcon = helper.getImageView(R.id.iv_giftIcon);
        if(!TextUtils.isEmpty(item.imgUrl)){
            Picasso.with(LiveApplication.getContext())
                    .load(item.imgUrl).fit()
                    .into(iv_giftIcon);
        }
        ViewGroup.LayoutParams giftIconLp = iv_giftIcon.getLayoutParams();
        giftIconLp.width = giftIconWidth;
        giftIconLp.height = giftIconWidth;
        iv_giftIcon.setLayoutParams(giftIconLp);

        ImageView iv_leftGiftFlag = helper.getImageView(R.id.iv_leftGiftFlag);
        iv_leftGiftFlag.setVisibility(View.INVISIBLE);
//        ViewGroup.LayoutParams leftGiftFlagLp = iv_giftIcon.getLayoutParams();
//        leftGiftFlagLp.width = giftFlagWidth;
//        leftGiftFlagLp.height = giftFlagWidth;
//        iv_leftGiftFlag.setLayoutParams(giftIconLp);

        ImageView iv_rightGiftFlag = helper.getImageView(R.id.iv_rightGiftFlag);
        iv_rightGiftFlag.setVisibility(item.giftType == GiftItem.GiftType.AdvancedAnimation ? View.VISIBLE : View.INVISIBLE);
//        ViewGroup.LayoutParams rightGiftFlagLp = iv_giftIcon.getLayoutParams();
//        rightGiftFlagLp.width = giftFlagWidth;
//        rightGiftFlagLp.height = giftFlagWidth;
//        iv_rightGiftFlag.setLayoutParams(giftIconLp);

    }

    @Override
    protected void setItemListener(CanHolderHelper helper) {
        helper.setItemChildClickListener(R.id.iv_leftGiftFlag);
        helper.setItemChildClickListener(R.id.iv_giftIcon);
        helper.setItemChildClickListener(R.id.iv_rightGiftFlag);
        helper.setItemChildClickListener(R.id.tv_giftName);
        helper.setItemChildClickListener(R.id.iv_coinIcon);
        helper.setItemChildClickListener(R.id.tv_giftCoins);
        helper.setItemChildClickListener(R.id.ll_giftItem);
    }


}
