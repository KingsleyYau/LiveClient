package com.qpidnetwork.qnbridgemodule.view.textView.circularEditText;

import android.content.Context;
import android.graphics.Color;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

/**
 * @author Jagger 2019-8-16
 * AutoCompleteTextView自动补全Adapter
 */
public class AutoCompleteAdapter extends BaseAdapter implements Filterable {
    private List<String> mList;
    private Context mContext;
    private MyFilter mFilter;
    private int textColor;
    private int textSize;

    public AutoCompleteAdapter(Context context, List<String> data) {
        mContext = context;
        mList = data;

        textColor = Color.rgb(65, 65, 65);
        textSize = 16;
    }

    public void setTextColor(int textColor){
        this.textColor = textColor;
    }

    public void setTextSize(int textSize){
        this.textSize = textSize;
    }

    @Override
    public int getCount() {
        return mList == null ? 0 : mList.size();
    }

    @Override
    public Object getItem(int position) {
        return mList == null ? null : mList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        if (convertView == null) {
            TextView tv = new TextView(mContext);
            tv.setTextColor(textColor);
            tv.setTextSize(TypedValue.COMPLEX_UNIT_PX, textSize);
            tv.setPadding(10, 20, 10, 20);
            convertView = tv;
        }
        TextView txt = (TextView) convertView;
        txt.setText(mList.get(position));
        return txt;
    }

    @Override
    public Filter getFilter() {
        if (mFilter == null) {
            mFilter = new MyFilter();
        }
        return mFilter;
    }

    private class MyFilter extends Filter {

        @Override
        protected FilterResults performFiltering(CharSequence constraint) {
            FilterResults results = new FilterResults();
            if (mList == null) {
                mList = new ArrayList<String>();
            }
            results.values = mList;
            results.count = mList.size();
            return results;
        }

        @Override
        protected void publishResults(CharSequence constraint, FilterResults results) {
            if (results.count > 0) {
                notifyDataSetChanged();
            } else {
                notifyDataSetInvalidated();
            }
        }
    }
}
