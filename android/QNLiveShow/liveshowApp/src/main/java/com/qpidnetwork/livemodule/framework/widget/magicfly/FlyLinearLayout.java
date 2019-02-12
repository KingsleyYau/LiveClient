/**
 * MIT License
 *
 * Copyright (c) 2016 yanbo
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package com.qpidnetwork.livemodule.framework.widget.magicfly;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ValueAnimator;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Point;
import android.graphics.PointF;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.SparseArray;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.LinearInterpolator;
import android.widget.LinearLayout;

import com.qpidnetwork.livemodule.R;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * A magic flying view, support various type flying anim and customer anim.
 */

public class FlyLinearLayout extends LinearLayout {
    private SparseArray<ValueState> mSparseArray = new SparseArray<>();
    private List<FlyElement> mFlyElementList = new ArrayList<>();

    private int mMeasureH, mMeasureW;
    private Rect mSrcRect, mDestRect;
    private Paint mPaint;
    private Matrix matrix = new Matrix();


    private int mAnimatorType;
    private int mFlyDuration;

    public FlyLinearLayout(Context context) {
        this(context, null);
    }

    public FlyLinearLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public FlyLinearLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.MagicFlyLinearLayout);
        mAnimatorType = array.getInt(R.styleable.MagicFlyLinearLayout_flyAnimatorType, AnimatorCreater.TYPE_B2T_SCATTER);
        mFlyDuration = array.getInt(R.styleable.MagicFlyLinearLayout_flyDuration, 4000);
        array.recycle();

        mSrcRect = new Rect();
        mDestRect = new Rect();

        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mPaint.setStyle(Paint.Style.STROKE);
    }

    public void clean() {
        mFlyElementList.clear();
        postInvalidate();
    }

    public void addFlyElement(FlyElement flyElement) {
        mFlyElementList.add(flyElement);
    }

    public void addFlyElement(int resId , FlyElement.Type type) {
        Bitmap bitmap = BitmapFactory.decodeResource(getContext().getResources(), resId);
        mFlyElementList.add(new FlyElement(bitmap , type));
    }

    public void flying() {
        PlayRunnable runnable = new PlayRunnable();
        if (mMeasureH > 0 || mMeasureW > 0) {
            runnable.run();
        } else {
            this.post(runnable);
        }
    }

    private class PlayRunnable implements Runnable {
        @Override
        public void run() {
            //随机找一个ITEM
            int randomIndex = new Random(System.currentTimeMillis()).nextInt(mFlyElementList.size());
            FlyElement flyElement = mFlyElementList.get(randomIndex);
            PointF enterPointF = getEnterAnimationStartPoint(mMeasureW, mMeasureH, flyElement.mBitmap);
            PointF transitionPointF = getTransitionPoint(mMeasureW, mMeasureH, flyElement.mBitmap);
            PointF endPointF = getOutEndAnimation(mMeasureW, mMeasureH, flyElement.mBitmap);

            //动画监听绘制
            FlyLinearLayout.MagicAnimatorListener listener = new FlyLinearLayout.MagicAnimatorListener();

            //飞入动画
            FlyEnterEvaluator enterEvaluator = new FlyEnterEvaluator(flyElement.mBitmap);

            ValueAnimator enterAnimator = ValueAnimator.ofObject(enterEvaluator, createValueState(flyElement.mBitmap, 255, 0.2f, 0f, enterPointF),
                            createValueState(flyElement.mBitmap, 255, 1.0f, 0f, transitionPointF));
            enterAnimator.setDuration(500);
            enterAnimator.addUpdateListener(listener);

            //飞出动画（贝塞尔曲线）
            AbsAnimatorEvaluator outEvaluator = AnimatorCreater.create(flyElement.mAnimType, mMeasureW, (mMeasureH * 4)/5, flyElement.mBitmap);
            ValueAnimator outAnimator = ValueAnimator.ofObject(outEvaluator, createValueState(flyElement.mBitmap, 255, 1.0f, 0f, transitionPointF),
                                    createValueState(flyElement.mBitmap, 0, 1.0f, 0f, endPointF));
            outAnimator.setDuration(2500);
            outAnimator.addUpdateListener(listener);

            //合成动画
            AnimatorSet animationSet = new AnimatorSet();
            animationSet.playSequentially(enterAnimator);
            animationSet.playSequentially(enterAnimator, outAnimator);
            animationSet.setInterpolator(new LinearInterpolator());
            animationSet.addListener(new FlyLinearLayout.MagicListener(listener.hashCode()));
            animationSet.start();

            //生成动画
//            AbsAnimatorEvaluator evaluator = AnimatorCreater.create(mFlyElementList.get(randomIndex).mAnimType, mMeasureW, mMeasureH, mFlyElementList.get(randomIndex).mBitmap);
//            ValueAnimator animator = ValueAnimator.ofObject(evaluator, evaluator.createAnimatorStart(), evaluator.createAnimatorEnd());
//            animator.setDuration(mFlyDuration);
//            animator.setInterpolator(new LinearInterpolator());
//
//            animator.addUpdateListener(listener);
//            animator.addListener(new FlyLinearLayout.MagicListener(listener.hashCode()));
//            animator.start();
        }
    }

    private ValueState createValueState(Bitmap bitmap, int alpha, float scale, float rotate, PointF pointF){
        ValueState valueState = new ValueState();
        valueState.bitmap = bitmap;
        valueState.alpha = alpha;
        valueState.scale = scale;
        valueState.rotate = rotate;
        valueState.pointF = pointF;
        return valueState;
    }

    /**
     * 获取动画起点
     * @param width
     * @param height
     * @return
     */
    private PointF getEnterAnimationStartPoint(int width, int height, Bitmap bitmap){
        return new PointF(mMeasureW / 2, mMeasureH - bitmap.getHeight() / 2);
    }

    /***
     * 获取两次动画的衔接点
     * @param width
     * @param height
     * @return
     */
    private PointF getTransitionPoint(int width, int height, Bitmap bitmap){
        PointF pointF = new PointF();
        pointF.x = new Random().nextFloat() * (width - bitmap.getWidth());
        pointF.y = ((float)height * 4)/5;
        return pointF;
    }

    /**
     * 生成飞出动画终点
     * @param width
     * @param height
     * @return
     */
    private PointF getOutEndAnimation(int width, int height, Bitmap bitmap){
        PointF pointF = new PointF();
        pointF.x = new Random().nextFloat()*width;
        pointF.y = 0f;
        return  pointF;
    }




    private class MagicAnimatorListener implements ValueAnimator.AnimatorUpdateListener {
        @Override
        public void onAnimationUpdate(ValueAnimator animation) {
            mSparseArray.put(this.hashCode(), (ValueState) animation.getAnimatedValue());
            postInvalidate();
        }
    }

    private class MagicListener extends AnimatorListenerAdapter {
        private int key;

        public MagicListener(int key) {
            this.key = key;
        }

        @Override
        public void onAnimationEnd(Animator animation) {
//            mSparseArray.get(key).bitmap.recycle();   //加了不行
            //动画结束 ， 释放内存
            mSparseArray.get(key).bitmap = null;
            mSparseArray.remove(key);
        }

        @Override
        public void onAnimationCancel(Animator animation) {
//            mSparseArray.get(key).bitmap.recycle();   //加了不行
            //动画结束 ， 释放内存
            mSparseArray.get(key).bitmap = null;
            mSparseArray.remove(key);
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        mMeasureH = this.getMeasuredHeight();
        mMeasureW = this.getMeasuredWidth();
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(canvas);
        for (int index = 0; index< mSparseArray.size(); index++) {
            ValueState valueState = mSparseArray.valueAt(index);
            if (valueState != null && valueState.bitmap != null) {
                matrix.setTranslate((int) valueState.pointF.x, (int) valueState.pointF.y);
                matrix.preScale(valueState.scale,valueState.scale);
                matrix.preRotate(valueState.rotate,valueState.bitmap.getWidth()/2 ,valueState.bitmap.getHeight()/2);// 这是旋转多少度

                mPaint.setAlpha(valueState.alpha);
                canvas.drawBitmap(valueState.bitmap, matrix, mPaint);

            }
        }
    }
}
