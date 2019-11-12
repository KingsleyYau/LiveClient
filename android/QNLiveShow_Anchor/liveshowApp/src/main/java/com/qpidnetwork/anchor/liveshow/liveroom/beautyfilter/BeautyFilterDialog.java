package com.qpidnetwork.anchor.liveshow.liveroom.beautyfilter;

import android.content.Context;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.SeekBar;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.liveshow.base.BaseRecyclerViewAdapter;
import com.qpidnetwork.anchor.liveshow.liveroom.LiveStreamPushManager;
import com.qpidnetwork.anchor.view.Dialogs.BaseCommonDialog;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;

/**
 * Created by Hardy on 2019/10/30.
 * 美颜滤镜的 dialog
 */
public class BeautyFilterDialog extends BaseCommonDialog {

    private SeekBar mSbSmooth;
    private TextView mTvSmooth;
    private SeekBar mSbWhiten;
    private TextView mTvWhiten;

    private RecyclerView mListView;
    private BeautyFilterAdapter mAdapter;

    private LiveStreamPushManager pushManager;

    public BeautyFilterDialog(Context context) {
        super(context, R.layout.dialog_beauty_filter, R.style.CustomTheme_LiveGiftDialog);
    }

    @Override
    public void initView(View v) {
        mSbSmooth = (SeekBar) v.findViewById(R.id.dialog_beauty_filer_sb_smooth);
        mTvSmooth = (TextView) v.findViewById(R.id.dialog_beauty_filer_tv_smooth);

        mSbWhiten = (SeekBar) v.findViewById(R.id.dialog_beauty_filer_sb_whiten);
        mTvWhiten = (TextView) v.findViewById(R.id.dialog_beauty_filer_tv_whiten);

        mSbSmooth.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                setSmoothProgressText(progress);
                pushManager.setBeautyLevel(progress);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        mSbWhiten.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                setWhitenProgressText(progress);
                pushManager.setStrength(progress);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        mListView = (RecyclerView) v.findViewById(R.id.dialog_beauty_filer_list_view);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(mContext, LinearLayoutManager.HORIZONTAL, false);
        mListView.setLayoutManager(linearLayoutManager);
        mListView.addItemDecoration(new HorizontalLineDecoration(DisplayUtil.dip2px(mContext, 10)));
        mAdapter = new BeautyFilterAdapter(mContext);
        mAdapter.setOnItemClickListener(new BaseRecyclerViewAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View v, int position) {
                BeautyFilterBean bean = mAdapter.getItemBean(position);
                if (bean != null) {
                    pushManager.setBeautyFilter(position, true);

                    handlerSelectStatus(position);
                }
            }
        });
        mListView.setAdapter(mAdapter);
    }

    @Override
    public void initDialogAttributes(WindowManager.LayoutParams params) {
        params.gravity = Gravity.BOTTOM;
        params.width = DisplayUtil.getScreenWidth(mContext);
        setDialogParams(params);
    }

    public void setPushManager(LiveStreamPushManager pushManager) {
        this.pushManager = pushManager;

        // set data
        mAdapter.setData(pushManager.getFilterBeanList());

        setSmoothProgress(pushManager.getLocalBeautyLevel());
        setSmoothProgressText(pushManager.getLocalBeautyLevel());

        setWhitenProgress(pushManager.getLocalBeautyStrength());
        setWhitenProgressText(pushManager.getLocalBeautyStrength());
    }

    private void setSmoothProgress(int progress) {
        mSbSmooth.setProgress(progress);
    }

    private void setSmoothProgressText(int progress) {
        mTvSmooth.setText(String.valueOf(progress));
    }

    private void setWhitenProgress(int progress) {
        mSbWhiten.setProgress(progress);
    }

    private void setWhitenProgressText(int progress) {
        mTvWhiten.setText(String.valueOf(progress));
    }

    private void handlerSelectStatus(int pos){
        int len = mAdapter.getItemCount();
        for (int i = 0; i < len; i++) {
            mAdapter.getItemBean(i).isSelect = pos == i;
        }
        mAdapter.notifyDataSetChanged();
    }

}
