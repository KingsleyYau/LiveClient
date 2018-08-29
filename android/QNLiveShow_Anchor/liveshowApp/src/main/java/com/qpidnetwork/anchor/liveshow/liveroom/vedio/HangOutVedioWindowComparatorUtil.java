package com.qpidnetwork.anchor.liveshow.liveroom.vedio;

import java.util.Comparator;

/**
 * Description:
 * <p>
 * Created by Harry on 2018/5/3.
 */
public class HangOutVedioWindowComparatorUtil implements Comparator<HangOutVedioWindow> {
    public int compare(HangOutVedioWindow o1, HangOutVedioWindow o2) {
        int index1 = o1.index;
        double index2 = o2.index;
        if (index1 > index2) {
            return 1;
        } else if (index1 < index2) {
            return -1;
        } else {
            return 0;
        }
    }
}
