package com.qpidnetwork.livemodule.framework.widget.magicfly;

import android.graphics.Bitmap;

/**
 * Created by Jagger on 2017/6/7.
 */

public class FlyElement {
    public enum Type{
        Normal,
        Scale,
        Shake
    }

    public Bitmap mBitmap;
    public int mAnimType;

    public FlyElement(Bitmap bitmap , FlyElement.Type type){
        mBitmap = bitmap;
        if(type == Type.Normal){
            mAnimType = AnimatorCreater.TYPE_B2T_SCATTER;
        }else if(type == Type.Scale){
            mAnimType = AnimatorCreater.TYPE_B2T_SCATTER_SCALE;
        }else if(type == Type.Shake){
            mAnimType = AnimatorCreater.TYPE_B2T_SCATTER_SHAKE;
        }else {
            mAnimType = AnimatorCreater.TYPE_B2T_SCATTER;
        }
    }
}
