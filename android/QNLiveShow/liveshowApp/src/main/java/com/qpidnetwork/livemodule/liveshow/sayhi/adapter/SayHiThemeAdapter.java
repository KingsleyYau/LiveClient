package com.qpidnetwork.livemodule.liveshow.sayhi.adapter;

import android.content.Context;
import android.view.View;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.SayHiThemeItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;

/**
 * SayHi编辑界面，主题列表
 * @author Jagger 2019-5-30
 */
public class SayHiThemeAdapter extends BaseRecyclerViewAdapter<SayHiThemeItem, SayHiThemeAdapter.ViewHolderSayHiTheme> {

    private int mSelectedNowIndex = 0;
    private OnThemeItemEventListener onThemeItemEventListener;

    public interface OnThemeItemEventListener {
        void onThemeClicked(SayHiThemeItem themeItem);
    }

    public SayHiThemeAdapter(Context context) {
        super(context);
        mContext = context;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.view_sayhi_theme_item;
    }

    @Override
    public ViewHolderSayHiTheme getViewHolder(View itemView, int viewType) {
        return new ViewHolderSayHiTheme(itemView);
    }

    @Override
    public void initViewHolder(ViewHolderSayHiTheme holder) {

    }

    @Override
    public void convertViewHolder(ViewHolderSayHiTheme holder, SayHiThemeItem data, int position) {
        holder.setData(data, position);
    }

    public void setOnThemeItemEventListener(OnThemeItemEventListener onThemeItemEventListener) {
        this.onThemeItemEventListener = onThemeItemEventListener;
    }

    public void setSelectedIndex(int index){
        if(-1 < index && index < mList.size()){
            mSelectedNowIndex = index;
        }else{
            mSelectedNowIndex = 0;
        }
        notifyItemChanged(mSelectedNowIndex);

        if(onThemeItemEventListener != null){
            onThemeItemEventListener.onThemeClicked(mList.get(mSelectedNowIndex));
        }
    }

    protected class ViewHolderSayHiTheme extends BaseViewHolder<SayHiThemeItem> {
        public SimpleDraweeView iv_theme;
        public View v_selected;
        public int position;

        public ViewHolderSayHiTheme(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            iv_theme = f(R.id.iv_theme);
            v_selected = f(R.id.v_selected);
        }

        @Override
        public void setData(final SayHiThemeItem data,final int position) {
            this.position = position;
            //取消不被选中
            if(mSelectedNowIndex != position){
                v_selected.setVisibility(View.GONE);
            }else{
                v_selected.setVisibility(View.VISIBLE);
            }

            FrescoLoadUtil.loadUrl(mContext, iv_theme, data.smallImg,
                    null,
                    mContext.getResources().getDimensionPixelSize(R.dimen.sayHi_edit_theme_item_width),
                    R.color.black4,
                    R.drawable.say_hi_theme_error_bg,
                    false,
                    mContext.getResources().getDimensionPixelSize(R.dimen.live_size_4dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.live_size_4dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.live_size_4dp),
                    mContext.getResources().getDimensionPixelSize(R.dimen.live_size_4dp));

            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    //选中 且 取消不被选中
                    if(mSelectedNowIndex != position){
                        notifyItemChanged(mSelectedNowIndex);
                        v_selected.setVisibility(View.VISIBLE);
                        mSelectedNowIndex = position;

                        if(onThemeItemEventListener != null){
                            onThemeItemEventListener.onThemeClicked(data);
                        }
                    }
                }
            });
        }
    }
}
