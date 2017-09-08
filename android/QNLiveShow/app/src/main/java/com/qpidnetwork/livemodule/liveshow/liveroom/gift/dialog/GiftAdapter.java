package com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftTab;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.PackageGiftManager;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.squareup.picasso.Picasso;

import java.util.List;

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
    private Context mContext;
    private GiftTab.GiftTabFlag giftTab;

    public GiftAdapter(Context context, int itemLayoutId, List<GiftItem> mList,GiftTab.GiftTabFlag giftTab) {
        super(context, itemLayoutId, mList);
        mContext = context.getApplicationContext();
        itemWidth = DisplayUtil.getScreenWidth(context)/4;
        giftIconWidth = itemWidth/9*5;
        giftFlagWidth = itemWidth/9*2;
        tranColorDrawable = new ColorDrawable(mContext.getResources().getColor(android.R.color.transparent));
        selectedYellowDrawable = mContext.getResources().getDrawable(R.drawable.selector_live_buttom_gift_item);
        this.giftTab = giftTab;
    }

    @Override
    protected void setView(CanHolderHelper helper, int position, Object bean) {
        Log.d(TAG,"setView-position:"+position);
        GiftItem item = (GiftItem) bean;
        View ll_giftItem = helper.getView(R.id.ll_giftItem);
        ViewGroup.LayoutParams itemLp = ll_giftItem.getLayoutParams();
        itemLp.width = itemWidth;
        itemLp.height = itemWidth;
        ll_giftItem.setLayoutParams(itemLp);
        boolean isSelected = ( !TextUtils.isEmpty(selectedGiftId)) && selectedGiftId.equals(item.id);
        Drawable drawalbe = isSelected? selectedYellowDrawable : tranColorDrawable;
        ll_giftItem.setBackgroundDrawable(drawalbe);

        ImageView iv_giftIcon = helper.getImageView(R.id.iv_giftIcon);
        TextView tv_giftName = helper.getTextView(R.id.tv_giftName);
        TextView tv_giftCoins = helper.getTextView(R.id.tv_giftCoins);


        ViewGroup.LayoutParams giftIconLp = iv_giftIcon.getLayoutParams();
        giftIconLp.width = giftIconWidth;
        giftIconLp.height = giftIconWidth;
        iv_giftIcon.setLayoutParams(giftIconLp);

        if(!TextUtils.isEmpty(item.middleImgUrl)){
            Picasso.with(LiveApplication.getContext())
                    .load(item.middleImgUrl).fit()
                    .into(iv_giftIcon);
        }

        ImageView iv_leftGiftFlag = helper.getImageView(R.id.iv_leftGiftFlag);
        ImageView iv_coinIcon = helper.getImageView(R.id.iv_coinIcon);
        iv_leftGiftFlag.setVisibility(View.INVISIBLE);

        TextView tv_rightGiftFlag = helper.getTextView(R.id.tv_rightGiftFlag);

        tv_giftName.setText(item.name);
        tv_giftName.setVisibility(View.VISIBLE);
        iv_coinIcon.setVisibility(giftTab == GiftTab.GiftTabFlag.BACKPACK ? View.INVISIBLE : View.VISIBLE);
        tv_giftCoins.setText(String.valueOf(item.credit));
        tv_giftCoins.setVisibility(giftTab == GiftTab.GiftTabFlag.BACKPACK ? View.INVISIBLE : View.VISIBLE);
        if(giftTab == GiftTab.GiftTabFlag.BACKPACK){
            int totalNum = PackageGiftManager.getInstance().getPackageGiftNumById(item.id);
            tv_rightGiftFlag.setVisibility(0 == totalNum ? View.INVISIBLE : View.VISIBLE);
            tv_rightGiftFlag.setText(String.valueOf(totalNum));
            tv_rightGiftFlag.measure(0,0);
            //可动态修改属性值的shape
            GradientDrawable digitalHintGD = new GradientDrawable();
            digitalHintGD.setCornerRadius(90f);
            digitalHintGD.setColor(Color.RED);
            digitalHintGD.setSize(tv_rightGiftFlag.getMeasuredHeight(),tv_rightGiftFlag.getMeasuredHeight());
            tv_rightGiftFlag.setBackgroundDrawable(digitalHintGD);

        }else{
            tv_rightGiftFlag.setVisibility(item.giftType == GiftItem.GiftType.Advanced ? View.VISIBLE : View.INVISIBLE);
            tv_rightGiftFlag.setBackgroundDrawable(mContext.getResources().getDrawable(R.drawable.ic_live_buttom_gift_advance));
            tv_rightGiftFlag.setText("");
        }
    }


    @Override
    protected void setItemListener(CanHolderHelper helper) {
        helper.setItemChildClickListener(R.id.iv_leftGiftFlag);
        helper.setItemChildClickListener(R.id.iv_giftIcon);
        helper.setItemChildClickListener(R.id.tv_rightGiftFlag);
        helper.setItemChildClickListener(R.id.tv_giftName);
        helper.setItemChildClickListener(R.id.iv_coinIcon);
        helper.setItemChildClickListener(R.id.tv_giftCoins);
        helper.setItemChildClickListener(R.id.ll_giftItem);
    }


}
