package com.dou361.dialogui.bean;

import java.io.Serializable;

/**
 * ========================================
 * <p>
 * 版 权：dou361.com 版权所有 （C） 2015
 * <p>
 * 作 者：陈冠明
 * <p>
 * 个人网站：http://www.dou361.com
 * <p>
 * 版 本：1.0
 * <p>
 * 创建日期：2016/3/15 21:29
 * <p>
 * 描 述：下拉列表的Bean对象，条目名称和其对于的索引或者编码
 * <p>
 * <p>
 * 修订历史：
 * <p>
 * ========================================
 */
public class PopuBean implements Serializable {

    /**
     * 序列化id
     */
    private static final long serialVersionUID = -6482229637703795368L;
    /**
     * 下拉条目id
     */
    int id;
    /**
     * 下拉条目sid
     */
    String sid;
    /**
     * 下拉条目标题
     */
    String title;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getSid() {
        return sid;
    }

    public void setSid(String sid) {
        this.sid = sid;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

}
