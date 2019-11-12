package com.qpidnetwork.livemodule.view.dialog;

import android.content.Context;
import android.support.annotation.ColorRes;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;

import static android.util.TypedValue.COMPLEX_UNIT_SP;

/**
 * Created by Hardy on 2019/5/28.
 * <p>
 * 通用的带提示文案 + 3 个按钮事件的 dialog
 */
public class CommonMultipleBtnTipDialog extends BaseCommonDialog {


    public interface OnDialogItemClickListener {

        void onItemSelected(View v, int which);
    }

    private LinearLayout mllBg;
    private ImageView mTvTitleIcon;
    private TextView mTvTitle;
    private TextView mTvMessage;
    private TextView mTvSubTitle;
    private Button mBtnDone;
    private RecyclerView itemsView;
    private DialogItemAdapter itemAdapter;
    private OnDialogItemClickListener onDialogItemClickListener;

    public CommonMultipleBtnTipDialog(Context context) {
        super(context, R.layout.dialog_say_hi_tip_multiple_btn);
    }

    @Override
    public void initView(View v) {
        mllBg = v.findViewById(R.id.dialog_common_multiple_ll_bg);
        mTvTitleIcon = v.findViewById(R.id.dialog_common_multiple_btn_title_icon);
        mTvTitle = v.findViewById(R.id.dialog_common_multiple_btn_title);
        mTvMessage = v.findViewById(R.id.dialog_common_multiple_btn_message);
        mTvSubTitle = v.findViewById(R.id.dialog_common_multiple_btn_sub_title);
        itemsView = v.findViewById(R.id.dialog_common_multiple_btn_items);
        itemsView.setNestedScrollingEnabled(false);

        LinearLayoutManager manager = new LinearLayoutManager(mContext);
        manager.setOrientation(LinearLayoutManager.VERTICAL);
        itemsView.setLayoutManager(manager);

        mBtnDone = v.findViewById(R.id.dialog_common_multiple_btn_done);
        mBtnDone.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();

            }
        });

        itemAdapter = new DialogItemAdapter(mContext);
        itemAdapter.setOnItemClickListener(new BaseRecyclerViewAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View v, int position) {
                if (onDialogItemClickListener != null) {
                    onDialogItemClickListener.onItemSelected(v, position);
                }

                DialogItem dialogItem = itemAdapter.getItemBean(position);
                if(dialogItem != null && dialogItem.isDismiss){
                    dismiss();
                }
            }
        });
        itemsView.setAdapter(itemAdapter);
    }

    @Override
    public void initDialogAttributes(WindowManager.LayoutParams params) {
        params.gravity = Gravity.CENTER;
        params.width = getDialogNormalWidth();
        setDialogParams(params);
    }

    /**
     * 设置选项监听回调
     *
     * @param itemClickListener
     */
    public void setItemClickCallback(OnDialogItemClickListener itemClickListener) {
        this.onDialogItemClickListener = itemClickListener;
    }

    /**
     * 设置背景
     * @param resId
     */
    public void setBgDrawable(int resId){
        mllBg.setBackgroundResource(resId);
    }

    /**
     * 设置标题
     */
    public void setTitle(String title) {
        mTvTitle.setText(title);
    }

    /**
     * 设置内容
     */
    public void setMessage(String message) {
        mTvMessage.setVisibility(View.VISIBLE);
        mTvMessage.setText(message);
    }

    /**
     * 设置副标题
     */
    public void setSubTitle(String message) {
        mTvSubTitle.setVisibility(View.VISIBLE);
        mTvSubTitle.setText(message);
    }


    /**
     * 设置标题id
     *
     * @param resId
     */
    public void setTitleIcon(int resId) {

        mTvTitleIcon.setVisibility(View.VISIBLE);
        mTvTitleIcon.setImageResource(resId);
    }


    /**
     * 设置标题字体大小
     *
     * @param size
     */
    public void setTitleSize(float size) {

        mTvTitle.setTextSize(COMPLEX_UNIT_SP, size);

    }


    /**
     * 设置标题文字颜色
     */
    public void setTitleTextColor(@ColorRes int textColor) {
        mTvTitle.setTextColor(ContextCompat.getColor(mContext, textColor));
    }

    /**
     * 设置副标题字体大小
     *
     * @param size
     */
    public void setSubTitleSize(float size) {

        mTvSubTitle.setTextSize(COMPLEX_UNIT_SP, size);
    }


    /**
     * 设置副标题文字颜色
     */
    public void setSubTitleTextColor(@ColorRes int textColor) {

        mTvSubTitle.setTextColor(ContextCompat.getColor(mContext, textColor));
    }


    /**
     * 设置内容字体大小
     *
     * @param size
     */
    public void setMessageSize(float size) {


        mTvMessage.setTextSize(COMPLEX_UNIT_SP, size);
    }


    /**
     * 设置内容文字颜色
     */
    public void setMessageTextColor(@ColorRes int textColor) {

        mTvMessage.setTextColor(ContextCompat.getColor(mContext, textColor));
    }


    /**
     * 设置done按钮的文字颜色
     */
    public void setBtnDoneTextColor(@ColorRes int textColor) {

        mBtnDone.setTextColor(ContextCompat.getColor(mContext, textColor));
    }

    public void addItem(
            String title,
            int iconId) {
        addItem(title, iconId, -1);
    }

    public void addItem(
            String tag,
            String title,
            int iconId) {
        addItem(tag, title, iconId, -1, -1, true);
    }

    public void addItem(
            String tag,
            String title,
            int iconId,
            boolean isDismiss) {
        addItem(tag, title, iconId, -1, -1, isDismiss);
    }

    public void addItem(
            String title,
            int iconId,
            int titleColor) {
        addItem("", title, iconId, titleColor, -1, true);
    }


    public DialogItem getItem(String tag){
        DialogItem item = null;
        for(DialogItem dialogItem:itemAdapter.mList){
            if(dialogItem.tag.equals(tag)){
                item = dialogItem;
            }
        }
        return item;
    }

    public void refresh(){
        itemAdapter.notifyDataSetChanged();
    }


    /**
     * 添加选项
     *
     * @param title
     * @param iconId
     * @param titleColor
     * @param titleSize
     */
    public void addItem(
            String tag,
            String title,
            int iconId,
            int titleColor,
            float titleSize,
            boolean isDismiss) {

        DialogItem item = new DialogItem();
        item.tag = tag;
        item.itemIconId = iconId;
        item.itemTitle = title;
        item.itemTitleColor = titleColor;
        item.itemTitleSize = titleSize;
        item.isDismiss = isDismiss;
        itemAdapter.addData(item);
    }

    public static class DialogItem {
        private String tag = "";
        private int itemIconId = -1;
        private String itemTitle = "";
        private int itemTitleColor = -1;
        private float itemTitleSize = -1f;
        private boolean isDismiss = true;

        public void setItemIconId(int itemIconId) {
            this.itemIconId = itemIconId;
        }

        public void setItemTitle(String itemTitle) {
            this.itemTitle = itemTitle;
        }

        public void setItemTitleColor(int itemTitleColor) {
            this.itemTitleColor = itemTitleColor;
        }

        public void setItemTitleSize(float itemTitleSize) {
            this.itemTitleSize = itemTitleSize;
        }
    }

    private static class DialogItemAdapter extends BaseRecyclerViewAdapter<DialogItem, DialogItemAdapter.DialogItemHolder> {


        public DialogItemAdapter(Context context) {
            super(context);
        }

        @Override
        public int getLayoutId(int viewType) {
            return R.layout.adapter_dialog_item_view;
        }

        @Override
        public DialogItemHolder getViewHolder(View itemView, int viewType) {
            return new DialogItemHolder(itemView);
        }

        @Override
        public void initViewHolder(final DialogItemHolder holder) {

            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mOnItemClickListener != null) {
                        mOnItemClickListener.onItemClick(v, getPosition(holder));
                    }
                }
            });
        }

        @Override
        public void convertViewHolder(DialogItemHolder holder,
                                      DialogItem data,
                                      int position) {

            holder.setData(data, position);
        }

        private static class DialogItemHolder extends BaseViewHolder<DialogItem> {


            private ImageView itemIcon;
            private TextView itemTitle;

            public DialogItemHolder(View itemView) {
                super(itemView);
            }

            @Override
            public void bindItemView(View itemView) {

                itemIcon = f(R.id.item_icon);
                itemTitle = f(R.id.item_title);
            }

            @Override
            public void setData(DialogItem data,
                                int position) {

                itemView.setTag(data.tag);

                if (data.itemIconId > 0) {
                    itemIcon.setImageResource(data.itemIconId);
                }

                if (!TextUtils.isEmpty(data.itemTitle)) {
                    itemTitle.setText(data.itemTitle);
                }

                if (data.itemTitleColor > 0) {
                    itemTitle.setTextColor(ContextCompat.getColor(context, data.itemTitleColor));
                }

                if (data.itemTitleSize > 0) {
                    itemTitle.setTextSize(COMPLEX_UNIT_SP, data.itemTitleSize);
                }

            }
        }

    }
}
