package com.qpidnetwork.livemodule.liveshow.sayhi.adapter;

import android.content.Context;
import android.support.v4.content.ContextCompat;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.SayHiAllListItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiBaseListItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiResponseListItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;
import com.qpidnetwork.qnbridgemodule.util.TextViewUtil;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/**
 * Created by Hardy on 2019/5/29.
 * <p>
 * SayHi 列表的基类 Adapter
 */
public class SayHiBaseListAdapter extends BaseRecyclerViewAdapter<SayHiBaseListItem,
        SayHiBaseListAdapter.SayHiBaseListViewHolder> {

    // map
    private HashMap<String, SayHiBaseListItem> mItemMap;

    // color
    private int colorFontBlack;
    private int colorFontGrey;
    // dimen
    private int iconWh;
    private int iconRadius;

    public SayHiBaseListAdapter(Context context) {
        super(context);

        colorFontBlack = ContextCompat.getColor(context, R.color.live_text_color_black);
        colorFontGrey = ContextCompat.getColor(context, R.color.text_color_grey_light);

        iconWh = context.getResources().getDimensionPixelSize(R.dimen.live_size_50dp);
        iconRadius = context.getResources().getDimensionPixelSize(R.dimen.live_size_4dp);

        mItemMap = new HashMap<>();
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_say_hi_all_and_response_list;
    }

    @Override
    public SayHiBaseListViewHolder getViewHolder(View itemView, int viewType) {
        return new SayHiBaseListViewHolder(itemView);
    }

    @Override
    public void initViewHolder(final SayHiBaseListViewHolder holder) {
        // color 设置
        holder.setIconWh(iconWh);
        holder.setIconRadius(iconRadius);
        holder.setColors(colorFontBlack, colorFontGrey);

        // 点击事件
        holder.mRlItemRoot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onItemClick(v, getPosition(holder));
                }
            }
        });
    }

    @Override
    public void convertViewHolder(SayHiBaseListViewHolder holder, SayHiBaseListItem data, int position) {
        holder.setData(data, position);
    }


    @Override
    public void setData(List<SayHiBaseListItem> list) {
        // 清除已有的
        mItemMap.clear();

        // 存储
        saveItem2Map(list);

        super.setData(list);
    }

    @Override
    public void addData(List<SayHiBaseListItem> list) {
        // 2019/5/30 过滤
        removeSameItemFromMap(list);

        // 存储
        saveItem2Map(list);

        super.addData(list);
    }

    @Override
    public void updateData(List<SayHiBaseListItem> list, boolean isLoadMore) {
        super.updateData(list, isLoadMore);
    }

    /**
     * response item 数据的 map key
     */
    private String getResponseItemMapKey(SayHiResponseListItem item) {
        if (item == null) {
            return "";
        }

        return item.sayHiId + "&" + item.responseId;
    }

    /**
     * 存储列表的 item
     */
    private void saveItem2Map(List<SayHiBaseListItem> list) {
        if (ListUtils.isList(list)) {
            for (SayHiBaseListItem item : list) {
                if (item != null) {
                    if (item.getDataType() == SayHiBaseListItem.DATA_TYPE_ALL) {
                        SayHiAllListItem subItem = (SayHiAllListItem) item;
                        mItemMap.put(subItem.sayHiId, item);
                    } else {
                        SayHiResponseListItem subItem = (SayHiResponseListItem) item;
                        mItemMap.put(getResponseItemMapKey(subItem), item);
                    }
                }
            }
        }
    }

    /**
     * 移除列表中已有的相同 item
     *
     * @param list
     */
    private void removeSameItemFromMap(List<SayHiBaseListItem> list) {
        if (ListUtils.isList(list)) {

            Iterator<SayHiBaseListItem> itemIterator = list.iterator();

            while (itemIterator.hasNext()) {
                SayHiBaseListItem item = itemIterator.next();

                if (item != null) {
                    if (item.getDataType() == SayHiBaseListItem.DATA_TYPE_ALL) {
                        SayHiAllListItem subItem = (SayHiAllListItem) item;
                        if (mItemMap.get(subItem.sayHiId) != null) {
                            itemIterator.remove();
                        }
                    } else {
                        SayHiResponseListItem subItem = (SayHiResponseListItem) item;
                        if (mItemMap.get(getResponseItemMapKey(subItem)) != null) {
                            itemIterator.remove();
                        }
                    }
                }
            }
        }
    }

    /**
     * ViewHolder
     */
    static class SayHiBaseListViewHolder extends BaseViewHolder<SayHiBaseListItem> {

        private static final String NO_RESPONSE_STRING = "No responses yet.";

        public LinearLayout mRlItemRoot;
        private SimpleDraweeView mIvIcon;
        private TextView mTvName;
        private ImageView mIvImageTag;
        private TextView mTvFreeTag;
        private TextView mTvTimestamp;
        private TextView mTvDesc;
        private TextView mTvUnread;

        private int colorFontBlack;
        private int colorFontGrey;

        private int iconWh;
        private int iconRadius;

        public SayHiBaseListViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            mRlItemRoot = f(R.id.item_say_hi_all_and_response_rlItemRoot);
            mIvIcon = f(R.id.item_say_hi_all_and_response_iv_icon);
            mTvName = f(R.id.item_say_hi_all_and_response_tv_name);
            mIvImageTag = f(R.id.item_say_hi_all_and_response_iv_image_tag);
            mTvFreeTag = f(R.id.item_say_hi_all_and_response_tv_free_tag);
            mTvTimestamp = f(R.id.item_say_hi_all_and_response_tv_timestamp);
            mTvDesc = f(R.id.item_say_hi_all_and_response_tv_desc);
            mTvUnread = f(R.id.item_say_hi_all_and_response_tv_unread);
        }

        @Override
        public void setData(SayHiBaseListItem data, int position) {
            int dataType = data.getDataType();
            if (dataType == SayHiBaseListItem.DATA_TYPE_ALL) {
                // all 标签
                SayHiAllListItem item = (SayHiAllListItem) data;
                setTypeAllData(item);
            } else {
                // response 标签
                SayHiResponseListItem item = (SayHiResponseListItem) data;
                setTypeResponseData(item);
            }
        }

        /**
         * 设置 all 标签的数据
         *
         * @param item
         */
        private void setTypeAllData(SayHiAllListItem item) {
            showImageTag(false);

            loadIconUrl(item.avatar);
            mTvTimestamp.setText(item.sendTimeString);
            mTvName.setText(item.nickName);
            mTvDesc.setText(item.content);

            boolean hasResponseNum = item.responseNum > 0;
            boolean hasUnreadNum = item.unreadNum > 0;

            // 未读数
            if (hasUnreadNum) {
                showUnreadTag(true);
                mTvUnread.setText(item.unreadNum + " unread");
            } else {
                showUnreadTag(false);
                mTvUnread.setText("");
            }

            // UI 状态判断
            if (hasResponseNum && hasUnreadNum) {
                setBgColorStatus(true);
                showFreeTag(item.isFree);
                setDescTextColor(true);

                setTextViewBoldStyle(true);
            } else if (hasResponseNum && !hasUnreadNum) {
                setBgColorStatus(false);
                showFreeTag(false);
                setDescTextColor(true);

                setTextViewBoldStyle(false);
            } else {
                mTvDesc.setText(NO_RESPONSE_STRING);

                setBgColorStatus(false);
                showFreeTag(false);
                setDescTextColor(false);

                setTextViewItalicsStyle();
            }

        }

        /**
         * 设置 response 标签的数据
         *
         * @param item
         */
        private void setTypeResponseData(SayHiResponseListItem item) {
            showUnreadTag(false);
            showImageTag(item.hasImg);
            showFreeTag(item.isFree);

            loadIconUrl(item.avatar);
            mTvTimestamp.setText(item.responseTimeString);
            mTvName.setText(item.nickName);
            mTvDesc.setText(item.content);

            if (item.hasRead) {
                // 已读
                setBgColorStatus(false);

                setTextViewBoldStyle(false);
            } else {
                // 未读
                setBgColorStatus(true);

                setTextViewBoldStyle(true);
            }
        }

        public void setIconRadius(int iconRadius) {
            this.iconRadius = iconRadius;
        }

        public void setIconWh(int iconWh) {
            this.iconWh = iconWh;
        }

        public void setColors(int colorFontBlack, int colorFontGrey) {
            this.colorFontBlack = colorFontBlack;
            this.colorFontGrey = colorFontGrey;
        }

        private void loadIconUrl(String avatar) {
            FrescoLoadUtil.loadUrl(context, mIvIcon, avatar, iconWh, R.drawable.ic_default_photo_woman_rect,
                    false, iconRadius, iconRadius, iconRadius, iconRadius);
        }

        private void showImageTag(boolean isShow) {
            mIvImageTag.setVisibility(isShow ? View.VISIBLE : View.GONE);
        }

        private void showFreeTag(boolean isShow) {
            mTvFreeTag.setVisibility(isShow ? View.VISIBLE : View.GONE);
        }

        private void showUnreadTag(boolean isShow) {
            mTvUnread.setVisibility(isShow ? View.VISIBLE : View.GONE);
        }

        private void setBgColorStatus(boolean isUnreadBg) {
            itemView.setBackgroundResource(isUnreadBg ? R.color.color_FFFECD : R.color.white);
        }

        private void setDescTextColor(boolean isBlack) {
            mTvDesc.setTextColor(isBlack ? colorFontBlack : colorFontGrey);
        }

        private void setTextViewBoldStyle(boolean isBold) {
            TextViewUtil.setTextBold(mTvName, isBold);
            TextViewUtil.setTextBold(mTvDesc, isBold);
            TextViewUtil.setTextBold(mTvTimestamp, isBold);
        }

        private void setTextViewItalicsStyle() {
            TextViewUtil.setTextBold(mTvName, false);
            TextViewUtil.setTextBold(mTvTimestamp, false);
            TextViewUtil.setTextItalics(mTvDesc, true);     // 斜体
        }
    }
}
