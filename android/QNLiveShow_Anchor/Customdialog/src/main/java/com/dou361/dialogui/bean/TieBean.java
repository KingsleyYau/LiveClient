package com.dou361.dialogui.bean;

import android.graphics.Color;
import android.support.annotation.ColorInt;
import android.view.Gravity;

import java.io.Serializable;

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
 * 创建日期：2016/11/18 18:55
 * <p/>
 * 描 述：
 * <p/>
 * <p/>
 * 修订历史：
 * <p/>
 * ========================================
 */
public class TieBean implements Serializable {

    private int id;
    private String title;
    private boolean isSelect;
    private int textColor = Color.BLACK;
    private int textGravity = Gravity.LEFT;

    public TieBean(String title) {
        this.title = title;
    }

    public TieBean(String title, int id) {
        this.title = title;
        this.id = id;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public boolean isSelect() {
        return isSelect;
    }

    public void setSelect(boolean select) {
        isSelect = select;
    }

    public void setColor(@ColorInt int color) {
        textColor = color;
    }

    public int getColor() {
        return textColor;
    }

    public void setGravity(int gravity){
        textGravity = gravity;
    }

    public int getGravity() {
        return textGravity;
    }
}
