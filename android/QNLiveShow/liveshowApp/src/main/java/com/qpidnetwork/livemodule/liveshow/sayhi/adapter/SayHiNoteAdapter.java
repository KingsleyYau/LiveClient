package com.qpidnetwork.livemodule.liveshow.sayhi.adapter;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.SayHiTextItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;

/**
 * SayHi编辑界面，文字列表
 * @author Jagger 2019-5-30
 */
public class SayHiNoteAdapter extends BaseRecyclerViewAdapter<SayHiTextItem, SayHiNoteAdapter.ViewHolderSayHiNote> {
    private int mSelectedNowIndex = 0;
    private OnNoteItemEventListener onNoteItemEventListener;

    public interface OnNoteItemEventListener {
        void onNoteClicked(SayHiTextItem textItem);
    }

    public SayHiNoteAdapter(Context context) {
        super(context);
        mContext = context;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.view_sayhi_note_item;
    }

    @Override
    public ViewHolderSayHiNote getViewHolder(View itemView, int viewType) {
        return new ViewHolderSayHiNote(itemView);
    }

    @Override
    public void initViewHolder(ViewHolderSayHiNote holder) {

    }

    @Override
    public void convertViewHolder(ViewHolderSayHiNote holder, SayHiTextItem data, int position) {
        holder.setData(data, position);
    }

    public void setOnNoteItemEventListener(OnNoteItemEventListener onNoteItemEventListener) {
        this.onNoteItemEventListener = onNoteItemEventListener;
    }

    public void setSelectedIndex(int index){
        if(-1 < index && index < mList.size()){
            mSelectedNowIndex = index;
        }else{
            mSelectedNowIndex = 0;
        }
        notifyItemChanged(mSelectedNowIndex);

        if(onNoteItemEventListener != null){
            onNoteItemEventListener.onNoteClicked(mList.get(mSelectedNowIndex));
        }
    }

    protected class ViewHolderSayHiNote extends BaseViewHolder<SayHiTextItem> {
        public TextView tv_note;
        public View v_selected;
        public int position;

        public ViewHolderSayHiNote(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            tv_note = f(R.id.tv_note);
            v_selected = f(R.id.v_selected);
        }

        @Override
        public void setData(final SayHiTextItem data,final int position) {
            this.position = position;
            //取消不被选中
            if(mSelectedNowIndex != position){
                v_selected.setVisibility(View.GONE);
            }else{
                v_selected.setVisibility(View.VISIBLE);
            }

            tv_note.setText(data.text);

            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    //选中 且 取消不被选中
                    if(mSelectedNowIndex != position){
                        notifyItemChanged(mSelectedNowIndex);
                        v_selected.setVisibility(View.VISIBLE);
                        mSelectedNowIndex = position;

                        if(onNoteItemEventListener != null){
                            onNoteItemEventListener.onNoteClicked(data);
                        }
                    }
                }
            });
        }
    }
}
