package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Typeface;
import android.util.AttributeSet;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

import java.util.HashMap;
import java.util.Map;

/**
 * 自定义的View，实现ListView A~Z快速索引效果
 *
 * @author Harry
 * 参考:http://blog.csdn.net/stoppig/article/details/23198809
 *
 */
public class SlideBar extends View {
    private Paint paint = new Paint();
    private Context context;
    private OnTouchLetterChangeListenner listenner;
    // 是否画出背景
    private boolean showBg = false;
    // 选中的项
    private int choose = -1;
    private float itemWidth = 0f;//条目的宽度
    private float itemHeight = 0f;//条目的高度dp2px(23)
    private float indexWidth = 0f;//dp2px(40)
    private float currentY = 0f;
    private float fontSize = 0f;
    private float height = 0f;
    private String[] letters = {"A", "B", "C", "D", "E", "F", "G",
            "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
            "U", "V", "W", "X", "Y", "Z" };
    private float leftJianTouWidth = 0f;
    public Map<String,Integer> indexMap = new HashMap<String,Integer>();
    private int actPotision = -1;
    private boolean showTipView = true;

    public void setMarginTop(float marginTop) {
        this.marginTop = marginTop;
    }

    public void setMarginButtom(float marginButtom){
        this.marginButtom = marginButtom;
    }

    private float marginTop = 0f;
    private float marginButtom= 0f;
    public void setShowType(int showType) {
        this.showType = showType;
    }

    private int showType = 0;
    //itemHeight是否为依据marginTop及marginButtom的设置高度自适应
    public static final int SHOWTYPE_ADAPTIVESIZE = 1;

    private TextView tv_selectedCodeIndex;

    public void setShowTipView(boolean showTipView){
        this.showTipView = showTipView;
    }

    public void setTipView(TextView tv_selectedCodeIndex){
        this.tv_selectedCodeIndex = tv_selectedCodeIndex;
    }

    public void setItemSize(float itemWidth, float itemHeight){
        this.itemWidth = itemWidth;
        this.itemHeight = itemHeight;
    }

    public void setIndexData(String[] letters, Map<String,Integer> indexMap){
        this.letters = letters;
        this.indexMap = indexMap;
    }

    public void setIndexTxtFont(float fontSize){
        this.fontSize = fontSize;
    }

    public void setIndexWidth(float indexWidth){
        this.indexWidth = indexWidth;
        this.leftJianTouWidth = itemWidth-indexWidth;
    }

    /**
     * 构造方法
     */

    public SlideBar(Context context) {
        super(context);
        this.context = context;
    }

    public SlideBar(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.context = context;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if(null == letters){
            return;
        }
        if(SHOWTYPE_ADAPTIVESIZE == showType){
            // 获取宽和高
             height = getMeasuredHeight();
             itemHeight = (height-marginTop-marginButtom)/26f;
        }

        currentY = marginTop;
        // 设置字体格式
        paint.setTypeface(Typeface.DEFAULT_BOLD);
        paint.setAntiAlias(true);
        paint.setTextSize(fontSize);
        Path path=new Path();
        // 画字母
        for (int i = 0; i < letters.length; i++) {
            // 如果这一项被选中，则换一种颜色画
            if (i == choose) {
              // 画出背景
                paint.setColor(Color.parseColor("#0098a5"));
                path=new Path();
                path.moveTo(leftJianTouWidth, currentY);
                path.lineTo(0, currentY+itemHeight/2);
                path.lineTo(leftJianTouWidth, currentY+itemHeight);
                path.lineTo(itemWidth, currentY+itemHeight);
                path.lineTo(itemWidth, currentY);
                path.lineTo(leftJianTouWidth, currentY);
                path.close();//封闭
                canvas.drawPath(path, paint);
                // 设置字体格式
                //选中就不画正常背景色改字体颜色
                paint.setColor(Color.parseColor("#007079"));
            }else{
//                //正常背景色
                paint.setColor(Color.parseColor("#43d2de"));
                path=new Path();
                path.moveTo(leftJianTouWidth, currentY);
                path.lineTo(itemWidth, currentY);
                path.lineTo(itemWidth, currentY+itemHeight);
                path.lineTo(leftJianTouWidth, currentY+itemHeight);
                path.lineTo(leftJianTouWidth, currentY);
                path.close();//封闭
                canvas.drawPath(path, paint);
                paint.setColor(Color.WHITE);
            }

            // 要画的字母的x,y坐标
            float posX = leftJianTouWidth + indexWidth/2 - paint.measureText(letters[i])/2;
            float posY = currentY + itemHeight/2 + paint.measureText(letters[i])/2;
            // 画出字母
            canvas.drawText(letters[i], posX, posY, paint);
            currentY += itemHeight;
        }
        // 重新设置画笔
        paint.reset();
    }

    /**
     * 处理SlideBar的状态
     */
    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        final float y = event.getY();
        // 算出点击的字母的索引
        int result = Float.valueOf((y - marginTop)/itemHeight).intValue();
        final int index = -1 == result ? 0 : result;
        // 保存上次点击的字母的索引到oldChoose
        final int oldChoose = choose;
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                showBg = true;
                if (oldChoose != index && listenner != null && index >-1
                        && index < letters.length) {
                    choose = index;
                    actPotision = indexMap.get(letters[index]);
                    if(-1 != actPotision){
                        listenner.onTouchLetterChange(event, letters[index], actPotision,itemHeight,false);
                    }

                    if (null != tv_selectedCodeIndex && showTipView) {
                        tv_selectedCodeIndex.setText(letters[index]);
                        tv_selectedCodeIndex.setVisibility(View.VISIBLE);
                    }

                    invalidate();
                }
                break;

            case MotionEvent.ACTION_MOVE:
                if (oldChoose != index && listenner != null && index > -1
                        && index < letters.length) {
                    choose = index;
                    actPotision = indexMap.get(letters[index]);
                    if(-1 != actPotision){
                        listenner.onTouchLetterChange(event, letters[index], actPotision,itemHeight,false);
                    }

                    if (null != tv_selectedCodeIndex && showTipView) {
                        tv_selectedCodeIndex.setText(letters[index]);
                        tv_selectedCodeIndex.setVisibility(View.VISIBLE);
                    }
                    invalidate();
                }
                break;
            case MotionEvent.ACTION_UP:
            default:
                if (null != tv_selectedCodeIndex && showTipView) {
                    tv_selectedCodeIndex.setVisibility(View.INVISIBLE);
                }
                showBg = false;
//                choose = -1;
                if (listenner != null && index > -1 && index < letters.length){
                    actPotision = indexMap.get(letters[index]);
                    if(-1 != actPotision){
                        listenner.onTouchLetterChange(event, letters[index], actPotision,itemHeight,true);
                    }
                    invalidate();
                    Log.e("SlideBar","ACTION_UP-LETTER:"+letters[index]);
                }
                break;
        }
        return true;
    }

    /**
     * 回调方法，注册监听器
     *
     * @param listenner
     */
    public void setOnTouchLetterChangeListenner(
            OnTouchLetterChangeListenner listenner) {
        this.listenner = listenner;
    }

    /**
     * SlideBar 的监听器接口
     *
     * @author Harry
     *
     */
    public interface OnTouchLetterChangeListenner {
        void onTouchLetterChange(MotionEvent event, String letter, int index, float itemHeight, boolean isFignUp);
    }
}
