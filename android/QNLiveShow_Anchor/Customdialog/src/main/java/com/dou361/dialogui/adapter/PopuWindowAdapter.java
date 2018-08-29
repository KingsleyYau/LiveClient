package com.dou361.dialogui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.dou361.dialogui.R;
import com.dou361.dialogui.bean.PopuBean;

import java.util.ArrayList;
import java.util.List;

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
 * 创建日期：2016/3/15 21:27
 * <p>
 * 描 述：PopuWindow适配器，结合PopuWindowView使用
 * <p>
 * <p>
 * 修订历史：
 * <p>
 * ========================================
 */
public class PopuWindowAdapter extends BaseAdapter {

    /**
     * 上下文
     */
    private Context mContext;
    /**
     * 供下拉的集合包括id
     */
    List<PopuBean> list;
    private LayoutInflater inflater;

    public PopuWindowAdapter(Context mContext, List<PopuBean> lists) {
        this.mContext = mContext;
        this.list = lists;
        if (list == null) {
            list = new ArrayList<PopuBean>();
        }
        inflater = LayoutInflater.from(mContext);
    }

    @Override
    public int getCount() {
        return list.size();
    }

    @Override
    public Object getItem(int position) {
        return list.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        ViewHolder holder = null;
        if (convertView == null) {

            holder = new ViewHolder();
            convertView = inflater.inflate(R.layout.dialogui_popu_option_item, null);

            holder.textView = (TextView) convertView
                    .findViewById(R.id.customui_item_text);

            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        holder.textView.setText(list.get(position).getTitle());


        return convertView;
    }

    class ViewHolder {
        TextView textView;
    }

}
