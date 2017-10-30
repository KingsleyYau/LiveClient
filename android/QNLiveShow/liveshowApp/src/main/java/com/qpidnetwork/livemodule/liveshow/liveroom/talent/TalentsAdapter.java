package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.List;

/**
 * 才艺列表Adapter
 * Created by Jagger on 2017/9/20.
 */

public class TalentsAdapter extends RecyclerView.Adapter<TalentsAdapter.ViewHolder> {
    private Context mContext;
    private List<TalentInfoItem> mDatas;
    private onRequestClickedListener mOnRequestClickedListener;
    private final String TAG = TalentsAdapter.class.getSimpleName();

    /**
     * 点击发送才艺要求事件
     * Created by Jagger on 2017/9/20.
     */

    public interface onRequestClickedListener {
        void onRequestClicked(TalentInfoItem talent);
    }

    public TalentsAdapter(List<TalentInfoItem> datas) {
        this.mDatas = datas;
    }

    public void setOnRequestClickedListener(onRequestClickedListener l){
        mOnRequestClickedListener = l;
    }

    //创建新View，被LayoutManager所调用
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        mContext = viewGroup.getContext();
        View view = LayoutInflater.from(mContext).inflate(R.layout.item_live_talent,viewGroup,false);
        ViewHolder vh = new ViewHolder(view);
        return vh;
    }

    //将数据与界面进行绑定的操作
    @Override
    public void onBindViewHolder(ViewHolder viewHolder, final int position) {
        final TalentInfoItem item = mDatas.get(position);
        viewHolder.mBtnRequest.setBackgroundResource(R.drawable.rectangle_rounded_angle_talent_yellow_bg);
        viewHolder.mBtnRequest.setEnabled(true);

        viewHolder.mTextViewName.setText(item.talentName);
        viewHolder.mTextViewCredits.setText(mContext.getString(R.string.live_talent_credits, String.valueOf(item.talentCredit)));
        viewHolder.mBtnRequest.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mOnRequestClickedListener != null){
                    Log.d(TAG,"onBindViewHolder-onClick position:"+position+" item:"+item);
                    mOnRequestClickedListener.onRequestClicked(item);
                }
            }
        });
    }

    //获取数据的数量
    @Override
    public int getItemCount() {
        if(mDatas == null){
            return 0;
        }else{
            return mDatas.size();
        }

    }

    //自定义的ViewHolder，持有每个Item的的所有界面元素
    public static class ViewHolder extends RecyclerView.ViewHolder {
        public TextView mTextViewName;
        public TextView mTextViewCredits;
        public Button mBtnRequest;

        public ViewHolder(View view){
            super(view);
            mTextViewName = (TextView) view.findViewById(R.id.tv_talentName);
            mTextViewCredits = (TextView) view.findViewById(R.id.tv_talentCredits);
            mBtnRequest = (Button) view.findViewById(R.id.btn_talentRequest);
        }
    }
}
