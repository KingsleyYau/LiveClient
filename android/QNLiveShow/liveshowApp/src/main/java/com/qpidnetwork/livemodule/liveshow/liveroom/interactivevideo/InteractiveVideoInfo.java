package com.qpidnetwork.livemodule.liveshow.liveroom.interactivevideo;

import java.io.Serializable;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/10/17.
 */

public class InteractiveVideoInfo implements Serializable{

    public boolean isVideoPositionChanged = false;

    public boolean neverShowOpenTipsAgained = false;

    public int lastVideoLeft=0;
    public int lastVideoTop=0;
    public int lastVideoRight=0;
    public int lastVideoButtom=0;

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("InteractiveVideoInfo[");
        sb.append("isVideoPositionChanged:");
        sb.append(isVideoPositionChanged);
        sb.append(" neverShowOpenTipsAgained:");
        sb.append(neverShowOpenTipsAgained);
        sb.append(" lastVideoLeft:");
        sb.append(lastVideoLeft);
        sb.append(" lastVideoTop:");
        sb.append(lastVideoTop);
        sb.append(" lastVideoRight:");
        sb.append(lastVideoRight);
        sb.append(" lastVideoButtom:");
        sb.append(lastVideoButtom);
        sb.append("]");
        return sb.toString();
    }
}
