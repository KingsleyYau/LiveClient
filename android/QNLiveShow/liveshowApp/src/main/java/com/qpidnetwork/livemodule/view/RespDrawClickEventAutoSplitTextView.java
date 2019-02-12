package com.qpidnetwork.livemodule.view;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.support.annotation.Nullable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.util.AttributeSet;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;

/**
 * Description:可响应Drawable点击事件,且可控制文本是否宽度自适应的TextView
 * <p>
 * Created by Harry on 2017/5/22.
 */
public class RespDrawClickEventAutoSplitTextView extends TextView {
    private final String TAG = RespDrawClickEventAutoSplitTextView.class.getSimpleName();
    private OnDrawableLeftClickListener onDrawableLeftClickListener = null;
    private OnDrawableRightClickListener onDrawableRightClickListener = null;
    private OnDrawableTopClickListener onDrawableTopClickListener = null;
    private OnDrawableButtomClickListener onDrawableButtomClickListener = null;
    private long fingerDownTouchTime = 0l;
    private final int DRAWABLE_LEFT = 0;
    private final int DRAWABLE_TOP = 1;
    private final int DRAWABLE_RIGHT = 2;
    private final int DRAWABLE_BOTTOM = 3;

    private boolean isLeftDrawableTouched = false;
    private boolean isRightDrawableTouched = false;
    private boolean isTopDrawableTouched = false;
    private boolean isButtomDrawableTouched = false;

    private boolean autoSpliteTextEnable = false;

    public void setAutoSpliteTextEnable(boolean autoSpliteTextEnable){
        this.autoSpliteTextEnable = autoSpliteTextEnable;
    }

    public boolean isLeftDrawableTouched(){
        return isLeftDrawableTouched;
    }

    public void setLeftDrawableTouched(boolean isLeftDrawableClicked){
        this.isLeftDrawableTouched = isLeftDrawableClicked;
    }

    public boolean isRightDrawableTouched(){
        return isRightDrawableTouched;
    }

    public void setRightDrawableTouched(boolean isRightDrawableClicked){
        this.isRightDrawableTouched = isRightDrawableClicked;
    }

    public void setTopDrawableTouched(boolean isTopDrawableClicked){
        this.isTopDrawableTouched = isTopDrawableClicked;
    }

    public boolean isTopDrawableTouched(){
        return isTopDrawableTouched;
    }

    public void setButtomDrawableTouched(boolean isButtomDrawableClicked){
        this.isButtomDrawableTouched = isButtomDrawableClicked;
    }

    public boolean isButtomDrawableTouched(){
        return isButtomDrawableTouched;
    }

    public void setOnDrawableLeftClickListener(OnDrawableLeftClickListener onDrawableLeftClickListener){
        this.onDrawableLeftClickListener = onDrawableLeftClickListener;
    }

    public void setOnDrawableRightClickListener(OnDrawableRightClickListener onDrawableRightClickListener){
        this.onDrawableRightClickListener = onDrawableRightClickListener;
    }

    public void setOnDrawableTopClickListener(OnDrawableTopClickListener onDrawableTopClickListener){
        this.onDrawableTopClickListener = onDrawableTopClickListener;
    }

    public void setOnDrawableButtomClickListener(OnDrawableButtomClickListener onDrawableButtomClickListener){
        this.onDrawableButtomClickListener = onDrawableButtomClickListener;
    }

    public RespDrawClickEventAutoSplitTextView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.RespDrawClickEventAutoSplitTextView);
        autoSpliteTextEnable = a.getBoolean(R.styleable.RespDrawClickEventAutoSplitTextView_autoSpliteTextEnable, autoSpliteTextEnable);
    }
    public RespDrawClickEventAutoSplitTextView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs,0);
    }

    public RespDrawClickEventAutoSplitTextView(Context context){
        this(context,null);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {

        //计算焦点是否在该TextView的drawable的区域
        switch (event.getAction()){
            case MotionEvent.ACTION_UP:
                isLeftDrawableTouched = isRightDrawableTouched = isTopDrawableTouched = isButtomDrawableTouched = false;
                Log.d(TAG,"onTouchEvent-start isLeftDrawableTouched:" + isLeftDrawableTouched
                        +" isRightDrawableTouched:"+ isRightDrawableTouched
                        +" isTopDrawableTouched:"+ isTopDrawableTouched
                        +" isButtomDrawableTouched:"+ isButtomDrawableTouched);
                Drawable drawableLeft = getCompoundDrawables()[DRAWABLE_LEFT];
                Drawable drawableRight = getCompoundDrawables()[DRAWABLE_RIGHT];
                Drawable drawableTop = getCompoundDrawables()[DRAWABLE_TOP];
                Drawable drawableButtom = getCompoundDrawables()[DRAWABLE_BOTTOM];

                if(null != onDrawableLeftClickListener){
                    if(null != drawableLeft && event.getRawX()>getLeft()+getPaddingLeft()
                            && event.getRawX()<getLeft()+drawableLeft.getBounds().width()+getPaddingLeft()
                            && event.getRawY()>getTop()+getPaddingTop()+(null == drawableTop? 0 : drawableTop.getBounds().height())
                            && event.getRawY()<getBottom()-getPaddingBottom()-(null == drawableButtom? 0 : drawableButtom.getBounds().height())){
                        onDrawableLeftClickListener.onDrawableLeftClicked(this);
                        isLeftDrawableTouched = true;
                        //return之后就走不到onClick的流程了
                        //两种处理方式：1.touchen时触发回调；2.touched只做判断，具体的响应逻辑放到onClicked
                        return isLeftDrawableTouched;
                    }
                }

                if(null != onDrawableRightClickListener){
                    if(null != drawableRight && event.getRawX()>getRight()-drawableRight.getBounds().width() - getPaddingRight()
                            && event.getRawX()< getRight() - getPaddingRight()
                            && event.getRawY()>getTop()+getPaddingTop()+(null == drawableTop? 0 : drawableTop.getBounds().height())
                            && event.getRawY()<getBottom()-getPaddingBottom()-(null == drawableButtom? 0 : drawableButtom.getBounds().height())){
                        onDrawableRightClickListener.onDrawableRightClicked(this);
                        isRightDrawableTouched = true;
                        return isRightDrawableTouched;
                    }
                }

                if(null != onDrawableTopClickListener){
                    if(null != drawableTop && event.getRawY()>getTop()+getPaddingTop()
                            && event.getRawY()<getTop()+drawableTop.getBounds().height()+getPaddingTop()
                            && event.getRawX()>getLeft()+getPaddingLeft()+(null == drawableLeft ? 0 : drawableLeft.getBounds().width())
                            && event.getRawX()<getRight()-getPaddingRight()-(null == drawableRight ? 0 : drawableRight.getBounds().width())){
                        onDrawableTopClickListener.onDrawableTopClicked(this);
                        isTopDrawableTouched = true;
                        return isTopDrawableTouched;
                    }
                }

                if(null != onDrawableButtomClickListener){
                    if(null != drawableButtom && event.getRawY()>=getBottom()-getPaddingBottom()-drawableButtom.getBounds().height()
                            && event.getRawY()<getBottom()-getPaddingBottom()
                            && event.getRawX()>getLeft()-getPaddingLeft()-(null == drawableLeft ? 0 : drawableLeft.getBounds().width())
                            && event.getRawX()<getRight() - getPaddingRight() - (null == drawableRight ? 0 : drawableRight.getBounds().width())){
                        onDrawableButtomClickListener.onDrawableButtomClicked(this);
                        isButtomDrawableTouched = true;
                        return isButtomDrawableTouched;
                    }
                }
                Log.d(TAG,"onTouchEvent-end  isLeftDrawableTouched:" + isLeftDrawableTouched
                        +" isRightDrawableTouched:"+ isRightDrawableTouched
                        +" isTopDrawableTouched:"+ isTopDrawableTouched
                        +" isButtomDrawableTouched:"+ isButtomDrawableTouched);
                break;
        }

        return super.onTouchEvent(event);
    }

    public interface OnDrawableLeftClickListener{
        void onDrawableLeftClicked(View view);
    }

    public interface OnDrawableRightClickListener{
        void onDrawableRightClicked(View view);
    }

    public interface OnDrawableTopClickListener{
        void onDrawableTopClicked(View view);
    }

    public interface OnDrawableButtomClickListener{
        void onDrawableButtomClicked(View view);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        if((MeasureSpec.getMode(widthMeasureSpec) == MeasureSpec.EXACTLY
                || MeasureSpec.getMode(heightMeasureSpec) == MeasureSpec.EXACTLY)
                && autoSpliteTextEnable
                && getWidth() > 0
                && getHeight() > 0){
            String newText = autoSplitText();
            if (!TextUtils.isEmpty(newText)) {
                if(!TextUtils.isEmpty(changeColorKey)){
                    changeTxtColor(newText);
                }else{
                    setText(newText);
                }

            }
        }
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }

    private void changeTxtColor(String text){
        SpannableString spannableString = new SpannableString(text);
        int startIndex = text.indexOf(changeColorKey);
        spannableString.setSpan(new ForegroundColorSpan(changeColor),
                startIndex, startIndex+changeColorKey.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
        setText(spannableString);
    }

    public void setChangeColor(int colorRes){
        this.changeColor = colorRes;
    }

    public void setChangeColor(String colorStr){
        changeColor = Color.parseColor(colorStr);//#ffd205
    }

    private int changeColor = Color.parseColor("#ffd205");

    private String changeColorKey = "";

    public void setChangeColorKey(String changeColorKey){
        this.changeColorKey = changeColorKey;
    }

    /**
     * 文本长度拆分
     * 参考http://www.cnblogs.com/goagent/p/5159125.html
     * @return
     */
    public String autoSplitText() {
        final String rawText = this.getText().toString(); //原始文本
        final Paint tvPaint = this.getPaint(); //paint，包含字体等信息
        final float tvWidth = this.getWidth() - this.getPaddingLeft() - this.getPaddingRight(); //控件可用宽度

        //将原始文本按行拆分
        String [] rawTextLines = rawText.replaceAll("\r", "").split("\n");
        StringBuilder sbNewText = new StringBuilder();
        for (String rawTextLine : rawTextLines) {
            if (tvPaint.measureText(rawTextLine) <= tvWidth) {
                //如果整行宽度在控件可用宽度之内，就不处理了
                sbNewText.append(rawTextLine);
            } else {
                //如果整行宽度超过控件可用宽度，则按字符测量，在超过可用宽度的前一个字符处手动换行
                float lineWidth = 0;
                for (int chIndex = 0; chIndex != rawTextLine.length(); ++chIndex) {
                    char ch = rawTextLine.charAt(chIndex);
                    lineWidth += tvPaint.measureText(String.valueOf(ch));
                    if (lineWidth <= tvWidth) {
                        sbNewText.append(ch);
                    } else {
                        sbNewText.append("\n");
                        lineWidth = 0;
                        --chIndex;
                    }
                }
            }
            sbNewText.append("\n");
        }

        //把结尾多余的\n去掉
        if (!rawText.endsWith("\n")) {
            sbNewText.deleteCharAt(sbNewText.length() - 1);
        }

        return sbNewText.toString();
    }
}
