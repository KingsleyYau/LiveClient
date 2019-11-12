package com.qpidnetwork.livemodule.liveshow.sayhi.adapter;

import android.content.Context;
import android.graphics.Color;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.SayHiDetailResponseListItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;

import static com.qpidnetwork.livemodule.utils.DateUtil.FORMAT_SHOW_MONTH_YEAR_DATE;

/**
 * Created  by Oscar
 * 2019-5-13
 */
public class SayHiResponseAdapter
        extends BaseRecyclerViewAdapter<SayHiDetailResponseListItem, SayHiResponseAdapter.SayHiResponseHolder> {

    /**
     * 回复列表头像
     */
    private String responseAvatar = "";
    /**
     * 选中标识
     */
    private String responseId = "";

    public SayHiResponseAdapter(Context context) {
        super(context);
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.adapter_say_hi_response_item;
    }

    @Override
    public SayHiResponseHolder getViewHolder(View itemView, int viewType) {
        return new SayHiResponseHolder(itemView, this);
    }


    @Override
    public void initViewHolder(final SayHiResponseHolder holder) {

        holder.ll_body.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onItemClick(v, getPosition(holder));
                }
            }
        });
    }

    @Override
    public void convertViewHolder(SayHiResponseHolder holder,
                                  SayHiDetailResponseListItem data,
                                  int position) {
        holder.setData(data, position);
    }

    public void notifyReplaceItem(SayHiDetailResponseListItem item) {

        for (SayHiDetailResponseListItem i : mList) {
            if (i.responseId.equals(item.responseId)) {
                i.update(item);
                break;
            }
        }
        notifyDataSetChanged();
    }


    public void setResponseAvatar(String responseAvatar) {
        this.responseAvatar = responseAvatar;
    }

    public void setSelected(String selected) {
        this.responseId = selected;
    }

    public String getResponseAvatar() {
        return responseAvatar;
    }

    public String getSelected() {
        return responseId;
    }

    class SayHiResponseHolder extends BaseViewHolder<SayHiDetailResponseListItem> {

        private LinearLayout ll_body;
        private View listBg;
        private TextView responseInfo;
        private TextView simpleContentTx;
        private TextView unReadFlag;
        private TextView freeTip;
        private ImageView imgFlag;
        private ImageView selectIcon;
        private SimpleDraweeView ladyAvatar;

        public SayHiResponseHolder(View itemView,
                                   SayHiResponseAdapter adapter) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {

            ll_body = f(R.id.ll_body);
            listBg = f(R.id.response_list_bg);
            responseInfo = f(R.id.responseInfo);
            simpleContentTx = f(R.id.simpleContentTx);
            imgFlag = f(R.id.imgFlag);
            selectIcon = f(R.id.selectIcon);
            unReadFlag = f(R.id.unReadFlag);
            ladyAvatar = f(R.id.ladyAvatar);
            freeTip = f(R.id.freeTip);
        }

        @Override
        public void setData(SayHiDetailResponseListItem data, int position) {

            int iconWh = DisplayUtil.dip2px(context, 45);
            FrescoLoadUtil.loadUrl(context, ladyAvatar, getResponseAvatar(), iconWh, R.drawable.ic_default_photo_woman_rect,
                    true, 0, 0, 0, 0);

            String responseDate = DateUtil.getDateStr(data.responseTime * 1000L, FORMAT_SHOW_MONTH_YEAR_DATE);
            String respInfo = context.getString(R.string.say_hi_detail_response_info, data.responseId, responseDate);
            responseInfo.setText(respInfo);

            int imgVis = data.hasImg ? View.VISIBLE : View.GONE;
            imgFlag.setVisibility(imgVis);

            simpleContentTx.setText(data.simpleContent);

            int freeVis = data.isFree ? View.VISIBLE : View.GONE;
            freeTip.setVisibility(freeVis);

            int unReadVis = (data.hasRead || freeVis == View.VISIBLE) ? View.GONE : View.VISIBLE;
            unReadFlag.setVisibility(unReadVis);

            if (data.responseId.equals(getSelected())) {
                selectIcon.setVisibility(View.VISIBLE);
                listBg.setBackgroundResource(R.drawable.say_hi_response_list_selected_bg);
            } else {
                selectIcon.setVisibility(View.GONE);
                if (data.hasRead) {
                    listBg.setBackgroundColor(Color.WHITE);
                } else {
                    listBg.setBackgroundResource(R.color.color_FFFECD);
                }

            }

        }


    }
}
