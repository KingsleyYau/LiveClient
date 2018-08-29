package com.qpidnetwork.anchor.liveshow.liveroom.gift.dialog;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.canadapter.CanAdapter;
import com.qpidnetwork.anchor.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.GiftLimitNumItem;
import com.qpidnetwork.anchor.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.anchor.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.GiftImageType;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;
import com.squareup.picasso.Picasso;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.qpidnetwork.anchor.R.id.iv_giftIcon;

/**
 * Description:礼物选择页,GridView的Adapter
 * <p>
 * Created by Harry on 2017/6/26.
 */

public class HangOutGiftAdapter<T> extends CanAdapter {
    private final String TAG = HangOutGiftAdapter.class.getSimpleName();
    public static GiftItem selectedGiftItem =null;
    private Drawable tranColorDrawable = null;
    private Drawable selectedBgDrawable = null;
    private Context mContext;
    public static Map<String,GiftLimitNumItem> giftLimitNumItemMap = new HashMap<>();
    private ProgressBar pb_loadAdvanceAnimFile;

    public HangOutGiftAdapter(Context context, int itemLayoutId, List<GiftItem> giftItems) {
        super(context, itemLayoutId, giftItems);
        mContext = context.getApplicationContext();
        tranColorDrawable = new ColorDrawable(mContext.getResources().getColor(android.R.color.transparent));
        selectedBgDrawable = mContext.getResources().getDrawable(R.drawable.bg_hangout_gift_item_selected);
    }

    @Override
    protected void setView(CanHolderHelper helper, int position, Object bean) {
        Log.d(TAG,"setView-position:"+position);
        GiftItem item = (GiftItem) bean;

        //礼物选中状态
        boolean isSelected = (null != selectedGiftItem && !TextUtils.isEmpty(selectedGiftItem.id)) && selectedGiftItem.id.equals(item.id);
        Drawable drawalbe = isSelected? selectedBgDrawable : tranColorDrawable;
        View ll_giftItem = helper.getView(R.id.ll_giftItem);
        ll_giftItem.setBackgroundDrawable(tranColorDrawable);
        if(item.giftType == GiftItem.GiftType.Celebrate){
            View fl_giftIcon = helper.getView(R.id.fl_giftIcon);
            fl_giftIcon.setBackgroundDrawable(drawalbe);
        }else{
            ll_giftItem.setBackgroundDrawable(drawalbe);
        }

        //大礼物图片本地是否存在
        if(null != selectedGiftItem && (selectedGiftItem.giftType == GiftItem.GiftType.Advanced
                || selectedGiftItem.giftType == GiftItem.GiftType.Celebrate)){
            //大礼物或者庆祝礼物 判断本地webp文件是否存在
            pb_loadAdvanceAnimFile = (ProgressBar) helper.getView(R.id.pb_loadAdvanceAnimFile);
            boolean isAdvanceGiftFileExisted = true;
            if(isSelected){
                if(TextUtils.isEmpty(item.srcWebpUrl)){
                    isAdvanceGiftFileExisted = false;
                }else{
                    String localPath = FileCacheManager.getInstance().getGiftLocalPath(item.id, item.srcWebpUrl);
                    isAdvanceGiftFileExisted = SystemUtils.fileExists(localPath);
                }
            }
            pb_loadAdvanceAnimFile.setVisibility(isAdvanceGiftFileExisted ? View.GONE : View.VISIBLE);
            //不存在，下载，通知界面
            if(!isAdvanceGiftFileExisted){
                NormalGiftManager.getInstance().getGiftImage(
                                    item.id, GiftImageType.BigAnimSrc, new IFileDownloadedListener() {
                                @Override
                                public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl) {
                                    notifyDataSetChanged();
                                }
                        });
            }
        }

        //礼物图片显示
        final ImageView iv_giftIcon = helper.getImageView(R.id.iv_giftIcon);
        Log.d(TAG,"setView-position:"+position+" item.middleImgUrl:"+item.middleImgUrl);
        if(!TextUtils.isEmpty(item.middleImgUrl)){
            Picasso.with(mContext)
                    .load(item.middleImgUrl)
                    .noPlaceholder()
                    .error(R.drawable.ic_default_gift)
                    .into(iv_giftIcon);
        }
        //礼物可发送数量
        TextView tv_giftCount = helper.getTextView(R.id.tv_giftCount);
        int  totalNum= (null!=giftLimitNumItemMap&&giftLimitNumItemMap.containsKey(item.id)) ? giftLimitNumItemMap.get(item.id).giftNum : 0;
        if(item.giftType == GiftItem.GiftType.Celebrate){
            tv_giftCount.setText(String.valueOf(totalNum));
        }else{
            tv_giftCount.setText(mContext.getResources().getString(R.string.hangout_gift_count,String.valueOf(totalNum)));
        }
        //是否大礼物
        if(item.giftType != GiftItem.GiftType.Celebrate){
            ImageView iv_rightGiftFlag = helper.getImageView(R.id.iv_rightGiftFlag);
            //判断是否是大礼物
            if(item.giftType == GiftItem.GiftType.Advanced){
                iv_rightGiftFlag.setVisibility(View.VISIBLE);
            }else{
                iv_rightGiftFlag.setVisibility(View.GONE);
            }
        }
    }

    @Override
    protected void setItemListener(CanHolderHelper helper) {
        helper.setItemChildClickListener(iv_giftIcon);
        helper.setItemChildClickListener(R.id.tv_giftCount);
        helper.setItemChildClickListener(R.id.ll_giftItem);
    }
}
