package com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog;

import android.content.Context;
import android.graphics.Bitmap;
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
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftTab;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.qpidnetwork.livemodule.R.id.iv_giftIcon;

/**
 * Description:礼物选择页,GridView的Adapter
 * <p>
 * Created by Harry on 2017/6/26.
 */

public class GiftAdapter <T> extends CanAdapter {
    private final String TAG = GiftAdapter.class.getSimpleName();
    public static String selectedGiftId ="";
    private Drawable tranColorDrawable = null;
    private Drawable selectedYellowDrawable = null;
    private int itemWidth=0;
    private int giftIconWidth=0;
    private Context mContext;
    private GiftTab.GiftTabFlag giftTab;
    private static Map<String,Integer> packageGiftNums;
    private Map<String,SendableGiftItem> sendableGiftItemMap = new HashMap<>();
    public static IMRoomInItem currIMRoomInItem;
    private boolean isFirstAdapterNotify = false;
    private ProgressBar pb_loadAdvanceAnimFile;

    public GiftAdapter(Context context, int itemLayoutId, List<GiftItem> mList,
                       GiftTab.GiftTabFlag giftTab) {
        super(context, itemLayoutId, mList);
        mContext = context.getApplicationContext();
        tranColorDrawable = new ColorDrawable(mContext.getResources().getColor(android.R.color.transparent));
        selectedYellowDrawable = mContext.getResources().getDrawable(R.drawable.selector_live_buttom_gift_item);
        if(null != currIMRoomInItem){
            sendableGiftItemMap = NormalGiftManager.getInstance().getLocalRoomSendableGiftMap(currIMRoomInItem.roomId);
        }
        this.giftTab = giftTab;
        isFirstAdapterNotify = true;
    }

    //引用赋值
    public void setPackageGiftNums(Map<String,Integer> packageGiftNums){
        this.packageGiftNums = packageGiftNums;
    }

    public void setItemWidth(int itemWidth){
        this.itemWidth = itemWidth;
        giftIconWidth = itemWidth/9*4;
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

        boolean isSelected = (!TextUtils.isEmpty(selectedGiftId)) && selectedGiftId.equals(item.id);
        Drawable drawalbe = isSelected? selectedYellowDrawable : tranColorDrawable;
        ll_giftItem.setBackgroundDrawable(drawalbe);

        pb_loadAdvanceAnimFile = (ProgressBar) helper.getView(R.id.pb_loadAdvanceAnimFile);
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
        Log.d(TAG,"setView-position:"+position+" item.middleImgUrl:"+item.middleImgUrl);
        if(!TextUtils.isEmpty(item.middleImgUrl) && isFirstAdapterNotify){
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
        if(giftTab == GiftTab.GiftTabFlag.BACKPACK){
            int totalNum = (null!=packageGiftNums&&packageGiftNums.containsKey(item.id)) ? packageGiftNums.get(item.id) : 0;
            tv_rightGiftFlag.setVisibility(0 == totalNum ? View.INVISIBLE : View.VISIBLE);
            tv_rightGiftFlag.setText(totalNum > 99 ?mContext.getResources().getString(R.string.live_gift_maxnum)
                    : String.valueOf(totalNum));
            tv_rightGiftFlag.measure(0,0);
            //可动态修改属性值的shape
            GradientDrawable digitalHintGD = new GradientDrawable();
            digitalHintGD.setCornerRadius(90f);
            digitalHintGD.setColor(Color.parseColor("#f7cd3a"));
            digitalHintGD.setSize(tv_rightGiftFlag.getMeasuredHeight(),tv_rightGiftFlag.getMeasuredHeight());
            tv_rightGiftFlag.setBackgroundDrawable(digitalHintGD);

            //房间是否可发送
            if(null != sendableGiftItemMap && !sendableGiftItemMap.containsKey(item.id)){
                tv_rightGiftFlag.setVisibility(View.VISIBLE);
                tv_rightGiftFlag.setBackgroundDrawable(
                        mContext.getResources().getDrawable(R.drawable.ic_liveroom_gift_block));
                tv_rightGiftFlag.setText("");
            }
            tv_giftCoins.setVisibility(View.INVISIBLE);
        }else{
            tv_rightGiftFlag.setVisibility(View.GONE);
            if(item.giftType == GiftItem.GiftType.Advanced){
                tv_rightGiftFlag.setVisibility(View.VISIBLE);
                tv_rightGiftFlag.setBackgroundDrawable(
                        mContext.getResources().getDrawable(R.drawable.ic_live_buttom_gift_advance));
                tv_rightGiftFlag.setText("");
            }
            tv_giftCoins.setVisibility(View.VISIBLE);
        }
        //判断级别是否达标
        if(item.lovelevelLimit > currIMRoomInItem.loveLevel || item.levelLimit > currIMRoomInItem.manLevel){
            tv_rightGiftFlag.setVisibility(View.VISIBLE);
            tv_rightGiftFlag.setBackgroundDrawable(
                    mContext.getResources().getDrawable(R.drawable.ic_liveroom_gift_block));
            tv_rightGiftFlag.setText("");
        }
        if(mList.indexOf(bean) == getCount()-1 && isFirstAdapterNotify){
            isFirstAdapterNotify = false;
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


    private class GiftIconTarget implements Target {

        private ImageView imageView;

        public GiftIconTarget(ImageView imageView){
            this.imageView = imageView;
        }

        @Override
        public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom loadedFrom) {
            Log.d(TAG,"onBitmapLoaded");
            this.imageView.setImageBitmap(bitmap);
        }

        @Override
        public void onBitmapFailed(Drawable drawable) {
            Log.d(TAG,"onBitmapFailed");
            this.imageView.setImageDrawable(drawable);
        }

        @Override
        public void onPrepareLoad(Drawable drawable) {
            Log.d(TAG,"onPrepareLoad");
            this.imageView.setImageDrawable(drawable);
        }
    }

}
