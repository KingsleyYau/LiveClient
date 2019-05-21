package com.qpidnetwork.livemodule.view;

import android.animation.ObjectAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RadialGradient;
import android.graphics.Shader;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.view.animation.LinearInterpolator;

/**
 * Created by Hardy on 2019/3/7.
 * <p>
 * 在布局中的宽高，一定要给定具体的值，而且宽高一致。
 * 因为这里没做 onMeasure 方法的宽高测量
 * <p>
 * 作为某个展示 View 的底层 View，比展示 View 的宽高多出 10dp，用来显示出光晕
 */
public class CircleHaloView extends View {

    //画阴影
    private Paint paint;
    private Shader mShader;

    private int whiteColorHalf;
    private int widthHalf;

    private ObjectAnimator oj;

    public CircleHaloView(Context context) {
        this(context, null);
    }

    public CircleHaloView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CircleHaloView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        // 半透明
        whiteColorHalf = Color.parseColor("#80FFFFFF");

        paint = new Paint();
        paint.setAntiAlias(true);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        Log.i("info", "onSizeChanged----> " + "w: " + w + " h: " + h + " oldw:" + oldw + " oldh:" + oldh);

        widthHalf = w / 2;

        // 圆形渐变的 Gradient
        mShader = new RadialGradient(widthHalf, widthHalf, widthHalf,
                new int[]{Color.WHITE, Color.WHITE, Color.WHITE,
                        Color.WHITE, whiteColorHalf, Color.TRANSPARENT},
                null, Shader.TileMode.CLAMP);

        //画阴影
        paint.setShader(mShader);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        if (isInEditMode()) {
            return;
        }

        Log.i("info", "onDraw---> width: " + getWidth());

        //画圆
        canvas.drawCircle(widthHalf, widthHalf, widthHalf, paint);
    }


    /**
     * 开启闪烁 2 次的动画
     */
    public void startAnim() {
        if (oj != null && oj.isRunning()) {
            return;
        }

        oj = ObjectAnimator.ofFloat(this, "alpha", 1, 0, 1, 0, 1);  // 1,0 为 1 次有效闪烁
        oj.setDuration(1500);
        oj.setInterpolator(new LinearInterpolator());   // 均匀闪烁变化
        oj.start();
    }
}
