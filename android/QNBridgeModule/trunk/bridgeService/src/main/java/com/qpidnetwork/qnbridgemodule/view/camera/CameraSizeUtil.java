package com.qpidnetwork.qnbridgemodule.view.camera;

import android.hardware.Camera;
import android.hardware.Camera.Size;

import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Created by Hardy on 2019/4/23.
 * <p>
 * https://blog.csdn.net/zhoubin1992/article/details/47020071
 * https://blog.csdn.net/u012301841/article/details/50492324
 * https://blog.csdn.net/guluo2010/article/details/23664995
 * <p>
 * Camera 获取最佳预览宽高大小和图片宽高大小的工具类
 * <p>
 * 调用方式：
 * private static Size pictureSize,previewSize;
 * pictureSize= MyCamPara.getInstance().getPictureSize(parameter.getSupportedPictureSizes(), 800);
 * //预览大小
 * previewSize=MyCamPara.getInstance().getPreviewSize(parameter.getSupportedPreviewSizes(), display.getHeight());
 * if(previewSize!=null)
 * parameter.setPreviewSize(previewSize.width,previewSize.height);
 * if(pictureSize!=null)
 * parameter.setPictureSize(pictureSize.width,pictureSize.height);
 */
public class CameraSizeUtil {

    private final CameraSizeComparator sizeComparator = new CameraSizeComparator();
    private static CameraSizeUtil myCamPara = null;

    private CameraSizeUtil() {

    }

    public static CameraSizeUtil getInstance() {
        if (myCamPara == null) {
            myCamPara = new CameraSizeUtil();
        }
        return myCamPara;
    }

    public Size getPreviewSize(List<Camera.Size> list, int th) {
        Collections.sort(list, sizeComparator);
        Size size = null;
        for (int i = 0; i < list.size(); i++) {
            size = list.get(i);
            if ((size.width > th) && equalRate(size, 1.3f)) {
                break;
            }
        }
        return size;
    }

    public Size getPictureSize(List<Camera.Size> list, int th) {
        if (list == null) {
            return null;
        }

        Collections.sort(list, sizeComparator);
        Size size = null;
        for (int i = 0; i < list.size(); i++) {
            size = list.get(i);
            if ((size.width > th) && equalRate(size, 1.3f)) {
                break;
            }
        }
        return size;
    }

    public boolean equalRate(Size s, float rate) {
        float r = (float) (s.width) / (float) (s.height);
        if (Math.abs(r - rate) <= 0.2) {
            return true;
        } else {
            return false;
        }
    }


    /**
     * https://www.qoogifts.com.cn/zentaopms2/www/index.php?m=bug&f=view&bugID=17797
     * 需求：
     * 请在3.5.4版本上修复，照片尺寸要求如下：
     * <p>
     * 1. 选取长边小于1920px的最大尺寸（如有1024x768、1536x1152，则选1536x1152）
     * <p>
     * 2. 若没有长边小于1920px的选项，则选最小尺寸
     *
     * @param list
     * @param specifiedPx
     * @return
     */
    public Size getPictureSizeForSpecifiedPx(List<Camera.Size> list, int specifiedPx) {
        if (list == null) {
            return null;
        }

        Collections.sort(list, sizeComparator);

        Size resultSize = null;

        int tempDiffPx = -1;

        int len = list.size();
        for (int i = 0; i < len; i++) {
            Size size = list.get(i);
            Log.i("info", "size---width: " + size.width + "--- height: " + size.height);

            // 1.获取长边
            int maxPx = size.width > size.height ? size.width : size.height;

            // 2.指定的大小与长边进行比较，差值越小，则代表越接近指定大小的 index
            int diffPx = specifiedPx - maxPx;

            // 给定第一个默认值
            if (i == 0) {
                tempDiffPx = diffPx;
            }

            if (diffPx > 0) {
                // 比指定大小要小的宽高(选取长边小于1920px的最大尺寸)
                if (diffPx < tempDiffPx) {
                    tempDiffPx = diffPx;
                    resultSize = size;
                }
            } else {
                // 比指定大小要大的宽高(若没有长边小于1920px的选项，则选最小尺寸)
                if (resultSize == null) {
                    resultSize = size;
                }
                break;
            }
        }

        if (resultSize != null) {
            Log.i("info", "resultSize---width: " +
                    resultSize.width + "--- height: " + resultSize.height);
        }

        return resultSize;
    }


    /**
     * 宽度按升序排列，由小到大
     */
    public class CameraSizeComparator implements Comparator<Camera.Size> {
        @Override
        public int compare(Camera.Size lhs, Camera.Size rhs) {
            if (lhs.width == rhs.width) {
                return 0;
            } else if (lhs.width > rhs.width) {
                return 1;
            } else {
                return -1;
            }
        }
    }
}
