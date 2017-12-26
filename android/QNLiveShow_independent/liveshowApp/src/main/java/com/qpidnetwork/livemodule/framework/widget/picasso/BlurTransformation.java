package com.qpidnetwork.livemodule.framework.widget.picasso;


import android.content.Context;
import android.graphics.Bitmap;
import android.support.v8.renderscript.Allocation;
import android.support.v8.renderscript.Element;
import android.support.v8.renderscript.RenderScript;
import android.support.v8.renderscript.ScriptIntrinsicBlur;

import com.squareup.picasso.Transformation;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/10/13.
 */

public class BlurTransformation implements Transformation {

    private int radius = 0;
    private RenderScript rs;

    public BlurTransformation(int radius,Context context){
        this.radius = radius;
        rs = RenderScript.create(context);
    }

    @Override
    public Bitmap transform(Bitmap bitmap) {
        // Create another bitmap that will hold the results of the filter.
        Bitmap blurredBitmap = bitmap.copy(Bitmap.Config.ARGB_8888,true);
        // Allocate memory for Renderscript to work with
        Allocation input = Allocation.createFromBitmap(rs, blurredBitmap,
                Allocation.MipmapControl.MIPMAP_FULL, Allocation.USAGE_SHARED);
        Allocation output = Allocation.createTyped(rs, input.getType());
        // Load up an instance of the specific script that we want to use.
        ScriptIntrinsicBlur script = ScriptIntrinsicBlur.create(rs, Element.U8_4(rs));
        script.setInput(input);
        // Set the blur radius
        script.setRadius(radius);
        // Start the ScriptIntrinisicBlur
        script.forEach(output);
        // Copy the output to the blurred bitmap
        output.copyTo(blurredBitmap);
        bitmap.recycle();
        return blurredBitmap;
    }

    @Override
    public String key() {
        return "BlurTransformation-radius:"+radius;
    }
}
