package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.liveshow.manager.SynConfigerManager;
import com.qpidnetwork.qnbridgemodule.datacache.LocalCorePreferenceManager;
import com.takwolf.android.hfrecyclerview.HeaderAndFooterRecyclerView;

/**
 * HangOut列表头
 * @author Jagger 2019-3-6
 */
public class HangOutHeaderViewHelper {

    //控件
    private HeaderAndFooterRecyclerView mRecyclerView;
    private View headerView;
    private TextView txt_des;
    private FrameLayout fl_operation, fl_toggle;
    private ImageView img_arrow;
    private Button btn_got;
    private CheckBox cb_dont_show;

    //变量
    private Context mContext;
    private boolean mIsExpan = false;   //是否展开
    private LocalCorePreferenceManager mLocalCorePreferenceManager;

    public HangOutHeaderViewHelper(@NonNull Context context, @NonNull HeaderAndFooterRecyclerView recyclerView) {
        this.mContext = context;
        this.mRecyclerView = recyclerView;
        this.mLocalCorePreferenceManager = new LocalCorePreferenceManager(context);

        headerView = LayoutInflater.from(context).inflate(R.layout.view_header_hang_out_list, recyclerView.getHeaderContainer(), false);

        txt_des = headerView.findViewById(R.id.txt_des);

        String hangoutCredit = "";
        ConfigItem configItem = SynConfigerManager.getInstance().getConfigItemCache();
        if(configItem != null && configItem.hangoutCreditPrice > 0){
            hangoutCredit = String.valueOf(configItem.hangoutCreditPrice);
        }
        txt_des.setText(String.format(mContext.getResources().getString(R.string.hand_out_list_header_tips_long), hangoutCredit));

        fl_operation = headerView.findViewById(R.id.fl_operation);
        img_arrow = headerView.findViewById(R.id.img_arrow);
        btn_got = headerView.findViewById(R.id.btn_got);
        btn_got.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(cb_dont_show.isChecked()){
                    mLocalCorePreferenceManager.saveHangOutListHeaderGone();
                    mRecyclerView.removeHeaderView(headerView);
                }else{
                    toggle();
                }
            }
        });
        cb_dont_show = headerView.findViewById(R.id.cb_dont_show);
        fl_toggle = headerView.findViewById(R.id.fl_toggle);
        fl_toggle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                toggle();
            }
        });

        reset();
    }

    /**
     * 隐藏列表头
     */
    public void hide(){
        if(mRecyclerView.getHeaderViewCount() > 0){
            mRecyclerView.removeHeaderView(headerView);
        }
    }

    /**
     * 根据设置重置列表头
     */
    public void reset(){
        if(mLocalCorePreferenceManager.getHangOutListHeaderStatus() && mRecyclerView.getHeaderViewCount() == 0){
            //配置可视则添加头
            mRecyclerView.addHeaderView(headerView);
            //展开
//            open();
            close();
        }
    }

    public void open(){
        mIsExpan = true;
        toggle();
    }

    public void close(){
        mIsExpan = false;
        toggle();
    }

    private void toggle(){
        setOperationVisibleState();
        setContentVisibleState();
        setShowIcon();
        //状态转变
        if(mIsExpan){
            mIsExpan = false;
        }else {
            mIsExpan = true;
        }
    }

    /**
     * 改变操作区可视状态
     */
    private void setOperationVisibleState(){
        if(mIsExpan){
            fl_operation.setVisibility(View.VISIBLE);
        }else {
            fl_operation.setVisibility(View.GONE);
        }
    }

    /**
     * 改变内容可视状态
     */
    private void setContentVisibleState(){
        if(mIsExpan){
            txt_des.setMaxLines(Integer.MAX_VALUE);//把TextView行数显示取消掉
        }else {
            txt_des.setMaxLines(2);
        }
    }

    /**
     * 改变展开图标
     */
    private void setShowIcon(){
        if(mIsExpan){
            img_arrow.setImageResource(R.drawable.ic_arrow_up_white);
        }else {
            img_arrow.setImageResource(R.drawable.ic_arrow_down_white);
        }
    }
}
