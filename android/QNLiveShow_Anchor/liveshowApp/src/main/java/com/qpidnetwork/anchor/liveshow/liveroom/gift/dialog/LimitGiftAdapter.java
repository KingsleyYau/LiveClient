package com.qpidnetwork.anchor.liveshow.liveroom.gift.dialog;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.canadapter.CanAdapter;
import com.qpidnetwork.anchor.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.GiftLimitNumItem;
import com.qpidnetwork.anchor.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;
import com.squareup.picasso.Picasso;

import java.util.List;

import static com.qpidnetwork.anchor.R.id.iv_giftIcon;

/**
 * Description:礼物选择页,GridView的Adapter
 * <p>
 * Created by Harry on 2017/6/26.
 */

public class LimitGiftAdapter<T> extends CanAdapter {
    private final String TAG = LimitGiftAdapter.class.getSimpleName();
    private Drawable tranColorDrawable = null;
    private Drawable selectedYellowDrawable = null;
    private int itemWidth=0;
    private int giftIconWidth=0;
    private Context mContext;

    private ProgressBar pb_loadAdvanceAnimFile;

    private String selectedGiftId = "";

    public void setSelectedGiftId(String selectedGiftId){
        this.selectedGiftId = selectedGiftId;
    }

    public LimitGiftAdapter(Context context, int itemLayoutId, List<GiftLimitNumItem> giftItems) {
        super(context, itemLayoutId, giftItems);
        mContext = context.getApplicationContext();
        tranColorDrawable = new ColorDrawable(mContext.getResources().getColor(android.R.color.transparent));
        selectedYellowDrawable = mContext.getResources().getDrawable(R.drawable.selector_live_buttom_gift_item);
    }

    public void setItemWidth(int itemWidth){
        this.itemWidth = itemWidth;
        giftIconWidth = itemWidth/9*4;
    }

    @Override
    protected void setView(CanHolderHelper helper, int position, Object bean) {
        Log.d(TAG,"setView-position:"+position);
        GiftLimitNumItem item = (GiftLimitNumItem) bean;
        GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(item.giftId);
        View ll_giftItem = helper.getView(R.id.ll_giftItem);
        ViewGroup.LayoutParams itemLp = ll_giftItem.getLayoutParams();
        itemLp.width = itemWidth;
        itemLp.height = itemWidth;
        ll_giftItem.setLayoutParams(itemLp);
        //礼物选中状态
        boolean isSelected = (!TextUtils.isEmpty(selectedGiftId)) && selectedGiftId.equals(item.giftId);
        Drawable drawalbe = isSelected? selectedYellowDrawable : tranColorDrawable;
        ll_giftItem.setBackgroundDrawable(drawalbe);
        //大礼物图片本地是否存在
        pb_loadAdvanceAnimFile = (ProgressBar) helper.getView(R.id.pb_loadAdvanceAnimFile);
        boolean isAdvanceGiftFileExisted = true;
        if(null != giftItem){
            if(isSelected && giftItem.giftType == GiftItem.GiftType.Advanced){
                if(TextUtils.isEmpty(giftItem.srcWebpUrl)){
                    isAdvanceGiftFileExisted = false;
                }else{
                    String localPath = FileCacheManager.getInstance().getGiftLocalPath(giftItem.id, giftItem.srcWebpUrl);
                    isAdvanceGiftFileExisted = SystemUtils.fileExists(localPath);
                }
            }
            pb_loadAdvanceAnimFile.setVisibility(isAdvanceGiftFileExisted ? View.GONE : View.VISIBLE);
            //礼物图片显示
            final ImageView iv_giftIcon = helper.getImageView(R.id.iv_giftIcon);
            ViewGroup.LayoutParams giftIconLp = iv_giftIcon.getLayoutParams();
            giftIconLp.width = giftIconWidth;
            giftIconLp.height = giftIconWidth;
            iv_giftIcon.setLayoutParams(giftIconLp);
            Log.d(TAG,"setView-position:"+position+" giftItem.middleImgUrl:"+giftItem.middleImgUrl);
            if(!TextUtils.isEmpty(giftItem.middleImgUrl)){
                Picasso.with(mContext).load(giftItem.middleImgUrl).noPlaceholder().error(R.drawable.ic_default_gift).into(iv_giftIcon);
            }
            //礼物名称
            TextView tv_giftName = helper.getTextView(R.id.tv_giftName);
            tv_giftName.setText(giftItem.name);
            tv_giftName.setVisibility(View.VISIBLE);
            //礼物可发送数量
            TextView tv_giftCount = helper.getTextView(R.id.tv_giftCount);
            tv_giftCount.setText(mContext.getResources().getString(R.string.live_gift_count,String.valueOf(item.giftNum)));
            //是否大礼物
            TextView tv_rightGiftFlag = helper.getTextView(R.id.tv_rightGiftFlag);
            //判断是否是大礼物
            if(giftItem.giftType == GiftItem.GiftType.Advanced){
                tv_rightGiftFlag.setVisibility(View.VISIBLE);
                tv_rightGiftFlag.setBackgroundDrawable(mContext.getResources().getDrawable(R.drawable.ic_live_buttom_gift_advance));
                tv_rightGiftFlag.setText("");
            }
            tv_giftCount.setVisibility(View.VISIBLE);
        }

    }

    @Override
    protected void setItemListener(CanHolderHelper helper) {
        helper.setItemChildClickListener(iv_giftIcon);
        helper.setItemChildClickListener(R.id.tv_rightGiftFlag);
        helper.setItemChildClickListener(R.id.tv_giftName);
        helper.setItemChildClickListener(R.id.tv_giftCount);
        helper.setItemChildClickListener(R.id.ll_giftItem);
    }
}
