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
package com.qpidnetwork.anchor.framework.widget.magicfly;

import android.graphics.Bitmap;
import android.graphics.PointF;

import java.util.Random;

/**
 * Animator from View's bottom to top, and scattered all the time.
 */

public class B2TScatterEvaluatorScale extends B2TScatterEvaluator {
    private PointF pointF1, pointF2;
    private float mScaleSize = 0.00f;
    double xX;

    public B2TScatterEvaluatorScale(int width, int heigh, Bitmap bitmap) {
        super(width, heigh, bitmap);
        int realH = getMeasuredHeigh() - getBitmap().getHeight();
        pointF1 = getBezierP01PointF(realH / 2, realH);
        pointF2 = getBezierP01PointF(0, realH / 2);

        xX = new Random().nextInt(15)+1;//随机乘方
    }

    @Override
    public ValueState evaluate(float fraction, ValueState startValue, ValueState endValue) {
        float timeStart = 1.0f - fraction;

        //过程中缩放
        if(fraction < 0.2){
            mScaleSize = mScaleSize + 0.015f;
            if(mScaleSize >= 1f){
                mScaleSize = 1f;
            }
        }else if(fraction > 0.2 && fraction < 0.4){
            mScaleSize = mScaleSize - 0.01f;
            if(mScaleSize <= 0.2f){
                mScaleSize = 0.2f;
            }
        }else if(fraction > 0.4){
            mScaleSize = mScaleSize + 0.02f;
            if(mScaleSize >= 1f){
                mScaleSize = 1f;
            }
        }

        ValueState valueState = new ValueState();
        PointF point = new PointF();
        //路线
        float xR = (float)Math.pow( timeStart , xX); //越大越向左，越小越向右
        float yR = (float)Math.pow( timeStart , 8); //越大 冲得越快越远
        //改版
        point.x = xR * (startValue.pointF.x)//越大，范围更随机 timeStart * timeStart * timeStart * timeStart *
                + 3 * timeStart * timeStart * fraction * (pointF1.x)
                + fraction * (endValue.pointF.x);   //越大，越向右

        point.y = yR * (startValue.pointF.y)
                + 3.5f  * timeStart * timeStart  * fraction  *(pointF1.y)  // ? * (?越大越近起点,会在一半停留一下再飞)
                + 3 * timeStart * fraction * fraction * (pointF2.y) //控制在一半停留一下再飞
                + fraction * fraction * fraction * (endValue.pointF.y);

        valueState.pointF = point;
        valueState.scale = mScaleSize;// Math.abs((float)(1.0f - Math.pow((1.0f - fraction), 2 * 4)));    //2 * ?决定图缩放速率
        valueState.alpha = (int) (timeStart * 255);
        valueState.bitmap = getBitmap();
        return valueState;
    }

    @Override
    public ValueState createAnimatorStart() {
        return super.createAnimatorStart();
    }

    @Override
    public ValueState createAnimatorEnd() {
        return super.createAnimatorEnd();
    }
}
