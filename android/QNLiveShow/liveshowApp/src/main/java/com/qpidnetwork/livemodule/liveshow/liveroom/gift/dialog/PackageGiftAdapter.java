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
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftTab;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.squareup.picasso.Picasso;

import java.util.List;

import static com.qpidnetwork.livemodule.R.id.iv_giftIcon;

/**
 * 背包GridView adapter
 * Created by Hunter on 18/7/5.
 */

public class PackageGiftAdapter <T> extends CanAdapter {

    private Context mContext;
    //选中框问题
    private Drawable tranColorDrawable = null;
    private Drawable selectedYellowDrawable = null;
    //item宽度及对应内部小图标宽度
    private int itemWidth=0;
    private int giftIconWidth=0;
    //房间礼物管理器
    private RoomGiftManager mRoomGiftManager;
    //dialog数据共享帮助类
    private LiveGiftDialogHelper mGiftDialogHelper;

    public PackageGiftAdapter(Context context, LiveGiftDialogHelper giftDialogHelper, RoomGiftManager roomGiftManager, List<PackageGiftItem> mList) {
        super(context, R.layout.item_girdview_gift, mList);
        mContext = context.getApplicationContext();
        this.mRoomGiftManager = roomGiftManager;
        this.mGiftDialogHelper = giftDialogHelper;
        tranColorDrawable = new ColorDrawable(mContext.getResources().getColor(android.R.color.transparent));
        selectedYellowDrawable = mContext.getResources().getDrawable(R.drawable.selector_live_buttom_gift_item);
    }

    public void setItemWidth(int itemWidth){
        this.itemWidth = itemWidth;
        giftIconWidth = itemWidth/9*4;
    }

    @Override
    protected void setView(CanHolderHelper helper, int position, Object bean) {
        PackageGiftItem packageItem = (PackageGiftItem) bean;
        GiftItem item = NormalGiftManager.getInstance().getLocalGiftDetail(packageItem.giftId);

        //设置单个item的宽高
        View ll_giftItem = helper.getView(R.id.ll_giftItem);
        ViewGroup.LayoutParams itemLp = ll_giftItem.getLayoutParams();
        itemLp.width = itemWidth;
        itemLp.height = itemWidth;
        ll_giftItem.setLayoutParams(itemLp);

        //处理选中效果
        String selectedGiftId = mGiftDialogHelper.getGiftTabSelectedGiftId(GiftTab.GiftTabFlag.BACKPACK);
        boolean isSelected = (!TextUtils.isEmpty(selectedGiftId)) && selectedGiftId.equals(item.id);
        Drawable drawalbe = isSelected? selectedYellowDrawable : tranColorDrawable;
        ll_giftItem.setBackgroundDrawable(drawalbe);

        //设置处理大礼物如果本地资源下载未成功，出现加载中状态
        ProgressBar pb_loadAdvanceAnimFile = (ProgressBar) helper.getView(R.id.pb_loadAdvanceAnimFile);
        if(isSelected && item.giftType == GiftItem.GiftType.Advanced){
            boolean isAdvanceGiftFileExisted = true;
            if(TextUtils.isEmpty(item.srcWebpUrl)){
                isAdvanceGiftFileExisted = false;
            }else{
                String localPath = FileCacheManager.getInstance().getGiftLocalPath(item.id, item.srcWebpUrl);
                isAdvanceGiftFileExisted = SystemUtils.fileExists(localPath);
            }

            pb_loadAdvanceAnimFile.setVisibility(isAdvanceGiftFileExisted ? View.GONE : View.VISIBLE);
        }else{
            pb_loadAdvanceAnimFile.setVisibility(View.GONE);
        }

        final ImageView iv_giftIcon = helper.getImageView(R.id.iv_giftIcon);
        ViewGroup.LayoutParams giftIconLp = iv_giftIcon.getLayoutParams();
        giftIconLp.width = giftIconWidth;
        giftIconLp.height = giftIconWidth;
        iv_giftIcon.setLayoutParams(giftIconLp);

        if(!TextUtils.isEmpty(item.middleImgUrl)){
            Picasso.with(mContext)
                    .load(item.middleImgUrl)
                    .placeholder(R.drawable.ic_default_gift)
                    .error(R.drawable.ic_default_gift)
                    .into(iv_giftIcon);
        }

        TextView tv_giftName = helper.getTextView(R.id.tv_giftName);
        tv_giftName.setText(item.name);
        tv_giftName.setVisibility(View.VISIBLE);

        TextView tv_giftCoins = helper.getTextView(R.id.tv_giftCoins);
        tv_giftCoins.setText(mContext.getResources().getString(R.string.live_gift_coins,
                ApplicationSettingUtil.formatCoinValue(item.credit)));

        TextView tv_rightGiftFlag = helper.getTextView(R.id.tv_rightGiftFlag);
        tv_rightGiftFlag.setVisibility(0 == packageItem.num ? View.INVISIBLE : View.VISIBLE);
        tv_rightGiftFlag.setText(packageItem.num > 99 ?mContext.getResources().getString(R.string.live_gift_maxnum)
                : String.valueOf(packageItem.num));
        tv_rightGiftFlag.measure(0,0);

        //可动态修改属性值的shape
        GradientDrawable digitalHintGD = new GradientDrawable();
        digitalHintGD.setCornerRadius(90f);
        digitalHintGD.setColor(Color.parseColor("#f7cd3a"));
        digitalHintGD.setSize(tv_rightGiftFlag.getMeasuredHeight(),tv_rightGiftFlag.getMeasuredHeight());
        tv_rightGiftFlag.setBackgroundDrawable(digitalHintGD);

        //房间是否可发送
        if(!mRoomGiftManager.checkGiftSendable(item.id)){
            tv_rightGiftFlag.setVisibility(View.VISIBLE);
            tv_rightGiftFlag.setBackgroundDrawable(
                    mContext.getResources().getDrawable(R.drawable.ic_liveroom_gift_block));
            tv_rightGiftFlag.setText("");
        }
        tv_giftCoins.setVisibility(View.INVISIBLE);

        //判断级别是否达标
        if(!mGiftDialogHelper.checkGiftSendable(item)){
            tv_rightGiftFlag.setVisibility(View.VISIBLE);
            tv_rightGiftFlag.setBackgroundDrawable(
                    mContext.getResources().getDrawable(R.drawable.ic_liveroom_gift_block));
            tv_rightGiftFlag.setText("");
        }
    }


    @Override
    protected void setItemListener(CanHolderHelper helper) {
        helper.setItemChildClickListener(iv_giftIcon);
        helper.setItemChildClickListener(R.id.tv_rightGiftFlag);
        helper.setItemChildClickListener(R.id.tv_giftName);
        helper.setItemChildClickListener(R.id.tv_giftCoins);
        helper.setItemChildClickListener(R.id.ll_giftItem);
    }
}

