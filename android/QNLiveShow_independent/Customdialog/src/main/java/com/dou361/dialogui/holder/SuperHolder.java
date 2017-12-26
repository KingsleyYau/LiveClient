package com.dou361.dialogui.holder;

import android.content.Context;
import android.support.annotation.LayoutRes;
import android.view.View;

import com.dou361.dialogui.bean.BuildBean;


/**
 * ========================================
 * <p/>
 * 版 权：dou361.com 版权所有 （C） 2015
 * <p/>
 * 作 者：陈冠明
 * <p/>
 * 个人网站：http://www.dou361.com
 * <p/>
 * 版 本：1.0
 * <p/>
 * 创建日期：2016/11/28 11:54
 * <p/>
 * 描 述：holder
 * <p/>
 * <p/>
 * 修订历史：
 * <p/>
 * ========================================
 */
public abstract class SuperHolder {
    public View rootView;

    public SuperHolder(Context context) {
        rootView = View.inflate(context, setLayoutRes(), null);
        findViews();
    }

    protected abstract void findViews();

    protected abstract
    @LayoutRes
    int setLayoutRes();

    /**
     * 一般情况下，实现这个方法就足够了
     *
     * @param context
     * @param bean
     */
    public abstract void assingDatasAndEvents(Context context, BuildBean bean);


}
