package com.qpidnetwork.livemodule.liveshow.personal.mypackage;

import android.content.Context;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.VoucherItem;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import static com.qpidnetwork.livemodule.httprequest.item.VoucherItem.VoucherUseRoleType.SpecialAnchor;

/**
 * Created by Hunter on 17/9/28.
 */

public class VoucherListAdapter extends BaseAdapter {

    private Context mContext;
    private List<VoucherItem> mVoucherList;

    public VoucherListAdapter(Context context, List<VoucherItem> dataList){
        this.mContext = context;
        this.mVoucherList = dataList;
    }

    @Override
    public int getCount() {
        return mVoucherList.size();
    }

    @Override
    public Object getItem(int position) {
        return mVoucherList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        VoucherViewHolder holder;
        if(convertView == null){
            convertView = LayoutInflater.from(mContext).inflate(R.layout.adapter_package_voucher, parent, false);    //android:layout_above 无效的解决办法:不能使用 不能使用
            holder = new VoucherViewHolder(convertView);
        }else{
            holder = (VoucherViewHolder)convertView.getTag();
        }

        final VoucherItem item = mVoucherList.get(position);

        //已读／未读
        if(item.isRead){
            holder.ivUnread.setVisibility(View.GONE);
        }else{
            holder.ivUnread.setVisibility(View.VISIBLE);
        }

        holder.tvDuration.setText(String.valueOf(item.offsetMin));

        //有效期
        ExpireType expireType = checkExpireTime(item.startValidDate, item.expDate);
        String validDurationDesc = "";
        switch (expireType){
            case Active:{
              holder.llSoon.setVisibility(View.GONE);
              validDurationDesc = String.format(mContext.getResources().getString(R.string.my_package_voucher_expired_desc),
                      new SimpleDateFormat("MMM dd, yyyy" , Locale.ENGLISH).format(new Date(((long)item.expDate) * 1000)));
            }break;
            case NotActive:{
               holder.llSoon.setVisibility(View.GONE);
               validDurationDesc = String.format(mContext.getResources().getString(R.string.my_package_voucher_valid_time_duration),
                        new SimpleDateFormat("MMM dd, yyyy" , Locale.ENGLISH).format(new Date(((long)item.startValidDate) * 1000)),
                        new SimpleDateFormat("MMM dd, yyyy" , Locale.ENGLISH).format(new Date(((long)item.expDate) * 1000)));
            }break;
            case ComingSoon:{
               holder.llSoon.setVisibility(View.VISIBLE);
                validDurationDesc = String.format(mContext.getResources().getString(R.string.my_package_voucher_expired_desc),
                        new SimpleDateFormat("MMM dd, yyyy" , Locale.ENGLISH).format(new Date(((long)item.expDate) * 1000)));
            }break;
            default:{
                 holder.llSoon.setVisibility(View.GONE);
                validDurationDesc = String.format(mContext.getResources().getString(R.string.my_package_voucher_expired_desc),
                        new SimpleDateFormat("MMM dd, yyyy" , Locale.ENGLISH).format(new Date(((long)item.expDate) * 1000)));
            }break;
        }
        holder.tvExp.setText(validDurationDesc);

        //适用主播类型
        String useRoleDesc = "";
        if(item.voucherType == VoucherItem.VoucherType.Livechat){
            //LiveChat试聊券
            holder.llDuration.setBackgroundResource(R.drawable.ic_package_livechat_voucher_bg);
            holder.tvVoucherType.setText(R.string.my_package_voucher_livechat_type_normal);
            //适用主播类型
            switch (item.useRole){
                case Any:{
                    useRoleDesc = mContext.getResources().getString(R.string.my_package_voucher_livechat_use_forall);
                }break;
                case NeverLive:{
                    useRoleDesc = mContext.getResources().getString(R.string.my_package_voucher_livechat_use_nochat);
                }break;
                case SpecialAnchor:{
                    useRoleDesc = mContext.getResources().getString(R.string.my_package_voucher_livechat_use_forsomeone) + item.anchorId.toUpperCase();
                }break;
            }
        }else{
            //直播试聊券
            holder.llDuration.setBackgroundResource(R.drawable.ic_package_live_voucher_bg);
            //适用直播类型
            String schemeDesc = "";
            switch (item.useScheme){
                case Any:{
                    schemeDesc = mContext.getResources().getString(R.string.my_package_voucher_live_type_normal);
                }break;
                case Private:{
                    schemeDesc = mContext.getResources().getString(R.string.my_package_voucher_live_type_private);
                }break;
                case Public:{
                    schemeDesc = mContext.getResources().getString(R.string.my_package_voucher_live_type_public);
                }break;
            }
            holder.tvVoucherType.setText(schemeDesc);
            //适用主播类型
            switch (item.useRole){
                case Any:{
                    useRoleDesc = mContext.getResources().getString(R.string.my_package_voucher_live_use_forall);
                }break;
                case NeverLive:{
                    useRoleDesc = mContext.getResources().getString(R.string.my_package_voucher_live_use_nowatch);
                }break;
                case SpecialAnchor:{
                    useRoleDesc = mContext.getResources().getString(R.string.my_package_voucher_live_use_forsomeone) + item.anchorId.toUpperCase();
                }break;
            }
        }

        //统一处理指定直播使用时点击跳转资料
        if(item.useRole == SpecialAnchor){
            SpannableString spanText = new SpannableString(useRoleDesc);
            String specialString = "";
            if(item.voucherType == VoucherItem.VoucherType.Livechat){
                specialString = mContext.getResources().getString(R.string.my_package_voucher_livechat_use_forsomeone);
            }else{
                specialString = mContext.getResources().getString(R.string.my_package_voucher_live_use_forsomeone);
            }
            if(useRoleDesc.length() > specialString.length()){
                spanText.setSpan(new ClickableSpan() {
                    @Override
                    public void updateDrawState(TextPaint ds) {
                        super.updateDrawState(ds);
                        ds.setColor(mContext.getResources().getColor(R.color.voucher_anchor_id_color));
                        ds.setUnderlineText(true);
                    }

                    @Override
                    public void onClick(View widget) {
                        //跳转主播资料页
                        AnchorProfileActivity.launchAnchorInfoActivty(mContext, mContext.getResources().getString(R.string.live_webview_anchor_profile_title),
                                item.anchorId, false, AnchorProfileActivity.TagType.Album);
                    }
                }, useRoleDesc.indexOf(specialString) + specialString.length(), useRoleDesc.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
            }
            holder.tvVoucherDesc.setText(spanText);
            holder.tvVoucherDesc.setMovementMethod(LinkMovementMethod.getInstance());
        }else{
            holder.tvVoucherDesc.setText(useRoleDesc);
        }

        return convertView;
    }

    /***************************************************   处理有效期相关   ********************************************************/
    private enum ExpireType{
        NotActive, //未生效
        Active,    //生效，有效周期大于48小时
        ComingSoon, //生效即将失效
    }

    /**
     * 处理试聊券有效期
     * @param startTime
     * @param expDate
     * @return
     */
    private ExpireType checkExpireTime(long startTime, long expDate){
        ExpireType  expireType = ExpireType.NotActive;
        long currentTime = System.currentTimeMillis();
        if(currentTime >= startTime * 1000 && currentTime <= expDate *1000){
            //试聊券有效期内
            if(expDate * 1000 - currentTime < 48 * 60 * 60 * 1000){
                //48小时以内失效
                expireType = ExpireType.ComingSoon;
            }else{
                 expireType = ExpireType.Active;
            }
        }else{
            expireType = ExpireType.NotActive;
        }
        return expireType;
    }

    private class VoucherViewHolder{

        public VoucherViewHolder(){

        }

        public VoucherViewHolder(View convertView){
            llDuration = (LinearLayout)convertView.findViewById(R.id.llDuration);
            tvDuration = (TextView)convertView.findViewById(R.id.tvDuration);
            tvVoucherType = (TextView)convertView.findViewById(R.id.tvVoucherType);
            tvVoucherDesc = (TextView)convertView.findViewById(R.id.tvVoucherDesc);
            tvExp = (TextView)convertView.findViewById(R.id.tvExp);
            llSoon = (LinearLayout)convertView.findViewById(R.id.llSoon);
            ivUnread = (ImageView)convertView.findViewById(R.id.ivUnread);
            convertView.setTag(this);
        }

        public LinearLayout llDuration;
        public TextView tvDuration;
        public TextView tvVoucherType;
        public TextView tvVoucherDesc;
        public TextView tvExp;
        public LinearLayout llSoon;
        public ImageView ivUnread;
    }
}
