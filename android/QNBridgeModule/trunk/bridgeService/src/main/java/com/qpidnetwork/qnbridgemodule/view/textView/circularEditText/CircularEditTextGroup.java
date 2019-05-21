package com.qpidnetwork.qnbridgemodule.view.textView.circularEditText;

import android.annotation.SuppressLint;
import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * 仿IOS可圆角EditText控件组
 * @author Jagger 2019-1-29
 * https://www.cnblogs.com/bhlsheji/p/5089736.html
 */
public class CircularEditTextGroup extends LinearLayout implements CircularEditText.OnCircularEditTextEventListener {

    private PassThroughHierarchyChangeListener mPassThroughListener;
    private List<CircularEditText> editTextsAll = new ArrayList<>();
    private List<CircularEditText> editTextsVisable = new ArrayList<>();

    public CircularEditTextGroup(Context context) {
        super(context);
        init();
    }

    public CircularEditTextGroup(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }


    private void init() {
        setOrientation(VERTICAL);
        mPassThroughListener = new PassThroughHierarchyChangeListener();
        super.setOnHierarchyChangeListener(mPassThroughListener);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
//        Log.i("Jagger", "onFinishInflate=111==>>>>");
//        check(mCheckedId);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void setOnHierarchyChangeListener(OnHierarchyChangeListener listener) {
        // the user listener is delegated to our pass-through listener
        mPassThroughListener.mOnHierarchyChangeListener = listener;
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        super.onLayout(changed, l, t, r, b);
//        Log.i("Jagger", "onLayout:" + changed);

        if(changed){
            getVisableCircularEditText();
            resetEditTextBg();
        }
    }

    @Override
    public void addView(View child, int index, ViewGroup.LayoutParams params) {
//        Log.i("Jagger", "addView");
        getAllCircularEditText(child);
        resetEditTextBg();
        super.addView(child, index, params);
    }

    /**
     * 根据可视的CircularEditText列表,重新设置EditTextBg
     */
    private void resetEditTextBg(){
//        Log.i("Jagger", "resetEditTextBg");
        if(editTextsVisable != null ){
            if(editTextsVisable.size() == 1){
                //单独一个
                editTextsVisable.get(0).setLocal(CircularEditText.Local.Single);
            }else if(editTextsVisable.size() > 1){
                //多个
                for(int i = 0; i < editTextsVisable.size(); i++){
                    if (i == 0) {
                        editTextsVisable.get(i).setLocal(CircularEditText.Local.Top);
                    }else if(i == editTextsVisable.size() - 1) {
                        editTextsVisable.get(i).setLocal(CircularEditText.Local.Bottom);
                    }else {
                        editTextsVisable.get(i).setLocal(CircularEditText.Local.Middle);
                    }
                }
            }
        }
    }


    /**
     * 加入CircularEditText列表
     * @param child
     */
    private List<CircularEditText> getAllCircularEditText(View child){
        if (child instanceof CircularEditText) {
            CircularEditText circularEditText = (CircularEditText) child;
            circularEditText.addCircularEditTextEventListener(this);
            editTextsAll.add(circularEditText);
        }else if(child instanceof ViewGroup){
            int counts = ((ViewGroup) child).getChildCount();
            for(int i = 0; i < counts; i++){
                editTextsAll.addAll(getAllCircularEditText(((ViewGroup) child).getChildAt(i)));
            }
        }

//        Log.i("Jagger", "getAllCircularEditText:" + editTextsAll.size());
        return editTextsAll;
    }

    /**
     * 加入可视CircularEditText列表
     */
    private void getVisableCircularEditText(){
        editTextsVisable.clear();
        for(CircularEditText circularEditText:editTextsAll){
            if(circularEditText.getVisibility() == VISIBLE){
                editTextsVisable.add(circularEditText);
            }
        }
    }

    @Override
    public void onClickedToResetUI() {
//        Log.i("Jagger", "onClickedToResetUI" );
        for(CircularEditText circularEditText:editTextsAll){
            circularEditText.resetUI();
        }
    }

    @Override
    public void onShowError() {

    }

    @Override
    public void onShowNormal() {

    }

    /**
     * <p>A pass-through listener acts upon the events and dispatches them
     * to another listener. This allows the table layout to set its own internal
     * hierarchy change listener without preventing the user to setup his.</p>
     */
    private class PassThroughHierarchyChangeListener implements
            ViewGroup.OnHierarchyChangeListener {
        private ViewGroup.OnHierarchyChangeListener mOnHierarchyChangeListener;

        /**
         * {@inheritDoc}
         */
        @SuppressLint("NewApi")
        public void onChildViewAdded(View parent, View child) {
//            Log.i("Jagger", "onChildViewAdded===>>>>" + (parent == CircularEditTextGroup.this) + ",child:" + (child instanceof CircularEditText));
            if (parent == CircularEditTextGroup.this && child instanceof CircularEditText) {
                int id = child.getId();
                // generates an id if it's missing
                if (id == View.NO_ID) {
                    id = View.generateViewId();
                    child.setId(id);
                }
            }

            if (mOnHierarchyChangeListener != null) {
                mOnHierarchyChangeListener.onChildViewAdded(parent, child);
            }
        }

        /**
         * {@inheritDoc}
         */
        public void onChildViewRemoved(View parent, View child) {
//            Log.i("Jagger", "onChildViewRemoved===>>>>");

            if (mOnHierarchyChangeListener != null) {
                mOnHierarchyChangeListener.onChildViewRemoved(parent, child);
            }
        }
    }
}
