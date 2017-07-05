package com.qpidnetwork.view;

import android.content.Context;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.PopupWindow;

import com.qpidnetwork.liveshow.R;

import java.util.List;


public class SimpleListPopupWindow extends PopupWindow {

    private final String TAG = SimpleListPopupWindow.class.getSimpleName();
    private Context context;
    private ListView lv_popupWindowItems;
    private View rootView;
    private int width = ViewGroup.LayoutParams.FILL_PARENT,height = ViewGroup.LayoutParams.WRAP_CONTENT;
    private int listviewWidth =ViewGroup.LayoutParams.FILL_PARENT;

    private ArrayAdapter adapter;

    public SimpleListPopupWindow(Context context, int viewId,int width, int height, int listviewWidth){
        Log.d(TAG,"SimpleListPopupWindow");
        this.width = width;
        this.height = height;
        this.listviewWidth = listviewWidth;
        this.context = context;
        initView(viewId);
        initPopupWindow();
    }

    private void initPopupWindow(){
        // 设置SelectPicPopupWindow弹出窗体的宽
        this.setWidth(width);
        // 设置SelectPicPopupWindow弹出窗体的高
        this.setHeight(height);
        // 设置SelectPicPopupWindow弹出窗体可点击
        this.setFocusable(true);
        // 设置弹出窗体动画效果
         this.setAnimationStyle(android.R.style.Animation_Dialog);
        // 实例化一个ColorDrawable颜色为半透明
//        ColorDrawable dw = new ColorDrawable(0x30000000);
        // 设置SelectPicPopupWindow弹出窗体的背景
//        this.setBackgroundDrawable(dw);
        // mMenuView添加OnTouchListener监听判断获取触屏位置如果在选择框外面则销毁弹出框
        rootView.setOnTouchListener(new View.OnTouchListener() {
            public boolean onTouch(View v, MotionEvent event) {
                int height = rootView.findViewById(R.id.ll_popupWindowContainer).getTop();
                int y = (int) event.getY();
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    if (y < height) {
                        dismiss();
                    }
                }
                return true;
            }
        });
    }

    private void initView(int viewId){
        rootView = View.inflate(context,viewId == 0 ? R.layout.view_popupwindow_simple_list_1 : viewId,null);
        lv_popupWindowItems = (ListView) rootView.findViewById(R.id.lv_popupWindowItems);
        ViewGroup.LayoutParams lp = lv_popupWindowItems.getLayoutParams();
        lp.width = listviewWidth;
        lv_popupWindowItems.setLayoutParams(lp);
        this.setContentView(rootView);
    }

    public int getRawHeight(){
        int totalHeight = 0;
        for (int i = 0; i < adapter.getCount(); i++) {
            View listItem = adapter.getView(i, null, lv_popupWindowItems);
            listItem.measure(0, 0);
            totalHeight += listItem.getMeasuredHeight();
        }
        totalHeight += (lv_popupWindowItems.getDividerHeight() * (adapter.getCount()-1));
        return totalHeight;
    }

    public void setViewData(List<String> items, int adapterView){
        adapter = new ArrayAdapter<String>(context,adapterView == 0? R.layout.item_simple_list_1 : adapterView,items);
        lv_popupWindowItems.setAdapter(adapter);
    }

    public void setViewData(String[] items, int adapterView){
        adapter = new ArrayAdapter<String>(context,adapterView == 0? R.layout.item_simple_list_1 : adapterView,items);
        lv_popupWindowItems.setAdapter(adapter);
    }

    public void setItemClickListener(AdapterView.OnItemClickListener onItemClickListener){
        lv_popupWindowItems.setOnItemClickListener(onItemClickListener);
    }
}
