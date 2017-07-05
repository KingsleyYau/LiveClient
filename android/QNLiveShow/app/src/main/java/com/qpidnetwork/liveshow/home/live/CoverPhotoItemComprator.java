package com.qpidnetwork.liveshow.home.live;

/**
 * Description: 自定义排序比较器，对审核中或者审核通过的CoverPhotoItem进行排序
 * 排序规则，使用中>审核通过>审核中>Unknow
 * <p>
 * Created by Harry on 2017/6/30.
 */

import com.qpidnetwork.httprequest.item.CoverPhotoItem;

import java.util.Comparator;

public class CoverPhotoItemComprator implements Comparator {
    @Override
    public int compare(Object o1, Object o2) {
        CoverPhotoItem item1 = (CoverPhotoItem) o1;
        CoverPhotoItem item2 = (CoverPhotoItem) o2;
        if(item1.isInUse){
            return -1;
        }else if(item2.isInUse){
            return 1;
        }else if(item1.photoStatus == item2.photoStatus){
            return 0;
        }else if(item1.photoStatus == CoverPhotoItem.PhotoStatus.Approval && item2.photoStatus != CoverPhotoItem.PhotoStatus.Approval){
            return -1;
        }else if(item1.photoStatus == CoverPhotoItem.PhotoStatus.Pending && item2.photoStatus == CoverPhotoItem.PhotoStatus.Unknown){
            return -1;
        }else if(item1.photoStatus == CoverPhotoItem.PhotoStatus.Pending && item2.photoStatus == CoverPhotoItem.PhotoStatus.Approval){
            return 1;
        }else if(item1.photoStatus == CoverPhotoItem.PhotoStatus.Unknown && item2.photoStatus != CoverPhotoItem.PhotoStatus.Unknown){
            return 1;
        }else {//其他情况保持默认顺序
            return 0;
        }

    }
}
