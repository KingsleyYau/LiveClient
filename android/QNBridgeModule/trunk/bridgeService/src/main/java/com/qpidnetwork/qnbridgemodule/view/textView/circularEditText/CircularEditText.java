package com.qpidnetwork.qnbridgemodule.view.textView.circularEditText;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.support.constraint.ConstraintLayout;
import android.support.v4.content.ContextCompat;
import android.text.InputType;
import android.text.method.PasswordTransformationMethod;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.LinearLayout;

import com.qpidnetwork.qnbridgemodule.R;

import java.util.ArrayList;
import java.util.List;

/**
 * 仿IOS可圆角EditText
 *
 * @author Jagger 2019-1-29
 */
public class CircularEditText extends ConstraintLayout {

    public enum Local {
        Top,
        Middle,
        Bottom,
        Single
    }

    private enum Status{
        Normal,
        Error
    }

    //
    private float txt_size = 16.00f;
    private int colorEditText, colorLine;
    //
    private Context mContext;
    private Local mLocal = Local.Middle;
    private int normalBgResId, errorBgResId;
    private ConstraintLayout mRoot;
    private EditText mEditText;
    private View mViewLine;
    private LinearLayout mLyLeft, mLyRight;
    private List<OnCircularEditTextEventListener> onCircularEditTextEventListeners = new ArrayList<>();
    private Status mStatus = Status.Normal;

    public interface OnCircularEditTextEventListener{
        /**
         * 点击使控件颜色还原事件
         */
        void onClickedToResetUI();

        /**
         * 控件显示错误提示颜色事件
         */
        void onShowError();

        /**
         * 控件还原正常状态颜色事件
         */
        void onShowNormal();
    }

    public CircularEditText(Context context) {
        super(context);
        init(context);
    }

    public CircularEditText(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
        setAttr(attrs);
    }

    public CircularEditText(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
        setAttr(attrs);
    }

    @SuppressLint("ClickableViewAccessibility")
    private void init(Context context){
        mContext = context;
        // 加载布局
        LayoutInflater.from(context).inflate(R.layout.circular_edittext_layout, this);
        mRoot = findViewById(R.id.cy_root);
        mEditText = findViewById(R.id.edt);
        mViewLine = findViewById(R.id.line);
        mLyLeft = findViewById(R.id.ly_left);
        mLyRight = findViewById(R.id.ly_right);

        mEditText.setOnFocusChangeListener(new OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (onFocuseChangedCallback != null) {
                    onFocuseChangedCallback.onFocuseChanged(v, hasFocus);
                }
            }
        });

        normalBgResId = R.drawable.circle_edittext_middle_bg_white;
        errorBgResId = R.drawable.circle_edittext_middle_bg_red;

        mEditText.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                if(motionEvent.getAction() == MotionEvent.ACTION_UP){
                    if(mStatus == Status.Error)
                    {
                        resetUI();
                        for (OnCircularEditTextEventListener listener:onCircularEditTextEventListeners){
                            listener.onClickedToResetUI();
                        }
                    }
                }
                return false;
            }
        });
    }

    private void setAttr(AttributeSet attrs){
        if (attrs != null){
            TypedArray a = this.getContext().obtainStyledAttributes(attrs, R.styleable.CircularEditText);
            if(a.hasValue(R.styleable.CircularEditText_hint)){
                mEditText.setHint(a.getString(R.styleable.CircularEditText_hint));
            }

            if(a.hasValue(R.styleable.CircularEditText_text_size)){
                mEditText.setTextSize(px2sp(a.getDimension(R.styleable.CircularEditText_text_size, (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, txt_size, getResources().getDisplayMetrics()))));
            }

            if(a.hasValue(R.styleable.CircularEditText_text_color)) {
                colorEditText = a.getColor(R.styleable.CircularEditText_text_color, Color.BLACK);
            }else{
                colorEditText = ContextCompat.getColor(getContext(), R.color.circle_edittext_normal_text);
            }
            mEditText.setTextColor(colorEditText);

            if(a.hasValue(R.styleable.CircularEditText_line_default_color)){
                colorLine = a.getColor(R.styleable.CircularEditText_line_default_color, Color.DKGRAY);
            }else{
                colorLine = ContextCompat.getColor(getContext(), R.color.circle_edittext_normal_line);
            }
            mViewLine.setBackgroundColor(colorLine);

            a.recycle();
        }
    }

    public void setLocal(Local local){
        mLocal = local;
        setResByLocal();
    }

    private void setResByLocal() {
        if (mLocal == Local.Top) {
            normalBgResId = R.drawable.circle_edittext_top_bg_white;
            errorBgResId = R.drawable.circle_edittext_top_bg_red;
            mViewLine.setVisibility(VISIBLE);
        } else if (mLocal == Local.Middle) {
            normalBgResId = R.drawable.circle_edittext_middle_bg_white;
            errorBgResId = R.drawable.circle_edittext_middle_bg_red;
            mViewLine.setVisibility(VISIBLE);
        } else if (mLocal == Local.Bottom) {
            normalBgResId = R.drawable.circle_edittext_bottom_bg_white;
            errorBgResId = R.drawable.circle_edittext_bottom_bg_red;
            mViewLine.setVisibility(INVISIBLE);
        } else if (mLocal == Local.Single) {
            normalBgResId = R.drawable.circle_edittext_single_bg_white;
            errorBgResId = R.drawable.circle_edittext_single_bg_red;
            mViewLine.setVisibility(INVISIBLE);
        }

        mRoot.setBackgroundResource(normalBgResId);
        mEditText.setTextColor(colorEditText);
        mEditText.setHintTextColor(ContextCompat.getColor(getContext(),R.color.circle_edittext_hint));
        mViewLine.setBackgroundColor(colorLine);
    }

    private int px2sp(float pxValue) {
        final float fontScale = getContext().getResources().getDisplayMetrics().scaledDensity;
        return (int) (pxValue / fontScale + 0.5f);
    }

    public void addCircularEditTextEventListener(OnCircularEditTextEventListener listener){
        if(!onCircularEditTextEventListeners.contains(listener)){
            onCircularEditTextEventListeners.add(listener);
        }
    }

    //------------------- 对用户使用方法 -----------------
    public void resetUI(){
        mStatus = Status.Normal;
        setResByLocal();

        for (OnCircularEditTextEventListener listener:onCircularEditTextEventListeners){
            listener.onShowNormal();
        }
    }

    public void showError(){
        mStatus = Status.Error;
        mRoot.setBackgroundResource(errorBgResId);
        mEditText.setTextColor(ContextCompat.getColor(getContext(),R.color.circle_edittext_error_text));
        mEditText.setHintTextColor(ContextCompat.getColor(getContext(),R.color.circle_edittext_error_text));
        mViewLine.setBackgroundResource(R.color.circle_edittext_error_line);

        for (OnCircularEditTextEventListener listener:onCircularEditTextEventListeners){
            listener.onShowError();
        }
    }

    public EditText getEditor(){
        return mEditText;
    }

    public void setHint(String hint){
        mEditText.setHint(hint);
    }

    public void setText(String val){
        mEditText.setText(val);
    }

    public String getText(){
        return mEditText.getText().toString();
    }

    public void setInputActionDone(){
        getEditor().setImeOptions(EditorInfo.IME_ACTION_DONE);
    }

    public void setPassword(){
//		getEditor().setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        //解决红米和华硕手机HINT字体显示变成全角字符问题
        getEditor().setTransformationMethod(PasswordTransformationMethod.getInstance());
    }

    public void setEmail(){
        getEditor().setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
    }

    public void setNoPredition(){
        getEditor().setInputType(InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
    }

    public void setOnFocusChangedCallback(OnFocuseChangedCallback l) {
        this.onFocuseChangedCallback = l;
    }

    private OnFocuseChangedCallback onFocuseChangedCallback;

    public interface OnFocuseChangedCallback {
        public void onFocuseChanged(View v, boolean hasFocus);
    }

    public void addLeftView(View v){
        mLyLeft.addView(v);
    }

    public void addRightView(View v){
        mLyRight.addView(v);
    }

    public void addRightView(View v, int width, int height){
        LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams)v.getLayoutParams();
        if(layoutParams != null){
            layoutParams.width = width;
            layoutParams.height = height;
        }else{
            layoutParams = new LinearLayout.LayoutParams(width, height);
        }

        v.setLayoutParams(layoutParams);
        mLyRight.addView(v);
    }

    public String getTextString(){
        return mEditText.getText().toString();
    }

    //----------------- 对用户使用方法 end -----------------
}
