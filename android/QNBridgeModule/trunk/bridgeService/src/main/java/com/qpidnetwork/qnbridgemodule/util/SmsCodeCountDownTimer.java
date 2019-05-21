package com.qpidnetwork.qnbridgemodule.util;

import android.os.CountDownTimer;
import android.widget.TextView;

/**
 * Created by Hardy on 2019/1/31.
 */
public class SmsCodeCountDownTimer extends CountDownTimer {

    private static final int MILLIS_COUNT = 60;
    private static final long countDownInterval = 1000;
    private static final long millisInFuture = MILLIS_COUNT * countDownInterval;

    private TextView mEt;
    private String mResetVal;
    private long mCurMillisInFuture;

    public SmsCodeCountDownTimer(TextView mEt) {
        super(millisInFuture, countDownInterval);
        this.mEt = mEt;
        this.mCurMillisInFuture = millisInFuture;
    }

    public SmsCodeCountDownTimer(TextView mEt, int msCount) {
        super(msCount * countDownInterval, countDownInterval);
        this.mEt = mEt;
        this.mCurMillisInFuture = msCount * countDownInterval;
    }

    @Override
    public void onTick(long millisUntilFinished) {
        formatEditText(millisUntilFinished);
    }

    @Override
    public void onFinish() {
        resetEditText();
    }

    private void formatEditText(long millisUntilFinished) {
        String val = (millisUntilFinished / countDownInterval) + "";
        onChangeUI(val);
    }

    public void resetEditText() {
        resetEditText(mResetVal);
    }

    public void resetEditText(String val) {
        this.cancel();

        this.mResetVal = val;

        mEt.setEnabled(true);
        mEt.setText(val);
    }

    public void onDestroy() {
        this.cancel();
    }

    public void onStart() {
        this.start();

        formatEditText(mCurMillisInFuture);
        mEt.setEnabled(false);
    }

    public void onChangeUI(String val) {

    }
}
