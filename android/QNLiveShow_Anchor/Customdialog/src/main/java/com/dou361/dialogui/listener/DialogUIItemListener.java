package com.dou361.dialogui.listener;

/**
 * Created by Administrator on 2016/7/24.
 */
public abstract class DialogUIItemListener {

    /**
     * item点击事件
     */
    public abstract void onItemClick(CharSequence text, int position);

    /**
     * 底部点击事件
     */
    public void onBottomBtnClick() {
    }

}
