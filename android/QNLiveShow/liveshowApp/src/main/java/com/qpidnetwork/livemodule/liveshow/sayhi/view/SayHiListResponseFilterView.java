package com.qpidnetwork.livemodule.liveshow.sayhi.view;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.PopupWindow;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.RequestJniSayHi;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.view.ButtonRaised;

/**
 * Created by Hardy on 2019/5/31.
 * SayHi response 列表底部的浮层 View
 */
public class SayHiListResponseFilterView extends FrameLayout implements View.OnClickListener {

    private String UNREAD_STRING;
    private String LATEST_STRING;

    private ButtonRaised mBtn;
    private LocalPreferenceManager localPreferenceManager;

    private PopupWindow mPopWindow;
    private View mPopUnread;
    private View mPopNewest;

    private int mPopX;
    private int mPopY;

    public SayHiListResponseFilterView(@NonNull Context context) {
        this(context, null);
    }

    public SayHiListResponseFilterView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public SayHiListResponseFilterView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        init(context);
    }

    private void init(Context context) {
        UNREAD_STRING = context.getString(R.string.Unread_First);
        LATEST_STRING = context.getString(R.string.Newest_First);

        // pop view
        View mPopView = LayoutInflater.from(context).inflate(R.layout.layout_say_hi_response_filter_pop, this, false);
        mPopUnread = mPopView.findViewById(R.id.layout_say_hi_response_filter_pop_ll_unread);
        mPopNewest = mPopView.findViewById(R.id.layout_say_hi_response_filter_pop_ll_newest);
        mPopUnread.setOnClickListener(this);
        mPopNewest.setOnClickListener(this);

        int w = context.getResources().getDimensionPixelSize(R.dimen.sayHi_list_response_filter_width);
        mPopWindow = new PopupWindow(mPopView, w, ViewGroup.LayoutParams.WRAP_CONTENT, true);
        // 设置PopupWindow是否能响应外部点击事件
        mPopWindow.setOutsideTouchable(true);
        mPopWindow.setTouchable(true);
        mPopWindow.setBackgroundDrawable(new ColorDrawable());
//        mPopWindow.setAnimationStyle(R.style.CustomTheme_SimpleDialog_Anim);
        // 偏移量
        mPopX = context.getResources().getDimensionPixelSize(R.dimen.live_size_20dp);           // 距离右边的边距
        mPopY = mPopX + context.getResources().getDimensionPixelSize(R.dimen.btn_height_46dp);  // 距离底部的边距,要加上浮层按钮的高度
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mBtn = findViewById(R.id.layout_say_hi_response_filter_btn);
        mBtn.setOnClickListener(this);

        // 初始化上次记录的数据
        RequestJniSayHi.SayHiListOperateType type = getResponseFilterType();
        setBtnText(type);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();

        if (id == R.id.layout_say_hi_response_filter_btn) {
            // 设置 pop 的过滤方式选中样式
            setPopSelectUI();

            mPopWindow.showAtLocation(mBtn, Gravity.BOTTOM | Gravity.END, mPopX, mPopY);

        } else if (id == R.id.layout_say_hi_response_filter_pop_ll_unread ||
                id == R.id.layout_say_hi_response_filter_pop_ll_newest) {
            mPopWindow.dismiss();

            RequestJniSayHi.SayHiListOperateType type = RequestJniSayHi.SayHiListOperateType.UnRead;
            if (id == R.id.layout_say_hi_response_filter_pop_ll_newest) {
                type = RequestJniSayHi.SayHiListOperateType.Latest;
            }

            // 保存记录在本地
            saveResponseFilterType(type);

            // 设置按钮文本
            setBtnText(type);

            if (mOnResponseListFilterListener != null) {
                mOnResponseListFilterListener.onFilterChange(type);
            }
        }
    }

    private void setBtnText(RequestJniSayHi.SayHiListOperateType type) {
        if (type == RequestJniSayHi.SayHiListOperateType.UnRead) {
            mBtn.setButtonTitle(UNREAD_STRING);
        } else {
            mBtn.setButtonTitle(LATEST_STRING);
        }
    }

    private void setPopSelectUI() {
        RequestJniSayHi.SayHiListOperateType type = getResponseFilterType();

        if (type == RequestJniSayHi.SayHiListOperateType.UnRead) {
            mPopUnread.setSelected(true);
            mPopNewest.setSelected(false);
        } else {
            mPopUnread.setSelected(false);
            mPopNewest.setSelected(true);
        }
    }

    public RequestJniSayHi.SayHiListOperateType getResponseFilterType() {
        return getLocalPreferenceManager().getSayHiResponseListFilterType();
    }

    private void saveResponseFilterType(RequestJniSayHi.SayHiListOperateType type) {
        getLocalPreferenceManager().saveSayHiResponseListFilterType(type);
    }

    private LocalPreferenceManager getLocalPreferenceManager() {
        if (localPreferenceManager == null) {
            localPreferenceManager = new LocalPreferenceManager(getContext());
        }

        return localPreferenceManager;
    }

    //========================  interface   ====================================
    private OnResponseListFilterListener mOnResponseListFilterListener;

    public void setOnResponseListFilterListener(OnResponseListFilterListener mOnResponseListFilterListener) {
        this.mOnResponseListFilterListener = mOnResponseListFilterListener;
    }

    public interface OnResponseListFilterListener {
        void onFilterChange(RequestJniSayHi.SayHiListOperateType type);
    }
}
