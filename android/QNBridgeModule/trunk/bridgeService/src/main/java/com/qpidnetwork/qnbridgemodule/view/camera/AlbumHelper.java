package com.qpidnetwork.qnbridgemodule.view.camera;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.provider.MediaStore;
import android.provider.MediaStore.Images.Media;
import android.provider.MediaStore.Images.Thumbnails;
import android.text.TextUtils;

import com.qpidnetwork.qnbridgemodule.util.FileUtil;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * 系统图库工具类,获取系统图片列表
 *
 * @author Hunter
 * @since 2015.5.6
 */
public class AlbumHelper {

    final String TAG = getClass().getSimpleName();

    Context context;
    ContentResolver cr;
    // 缩略图列表
    HashMap<String, String> thumbnailList = new HashMap<String, String>();


    public AlbumHelper(Context context) {
        this.context = context;
        cr = context.getContentResolver();
    }

    public List<ImageBean> getAlbumImageList() {
        List<ImageBean> albumList = new ArrayList<ImageBean>();

        // 构造缩略图索引
//        getThumbnail();   // 2018/12/25 Hardy 在系统相机拍照完成后，由于某些手机系统，不会马上生成缩略图，故获取不到缩略图，应该以原图数据为准

        // 构造相册索引
        String columns[] = new String[]{Media._ID, Media.BUCKET_ID,
                Media.PICASA_ID, Media.DATA, Media.DISPLAY_NAME, Media.TITLE,
                Media.SIZE, Media.BUCKET_DISPLAY_NAME};
        // 得到一个游标
//        Cursor cur = cr.query(Media.EXTERNAL_CONTENT_URI, columns, null, null,
//                MediaStore.Images.Media.DATE_MODIFIED + " desc"); //edit by Jagger 2018-12-25 sortOrder改为递减

        // 2019/5/20 Hardy  只要 jpg 和 png 图片
        Cursor cur = cr.query(Media.EXTERNAL_CONTENT_URI, columns,
                MediaStore.Images.Media.MIME_TYPE + "=? or "
                        + MediaStore.Images.Media.MIME_TYPE + "=?",
                        new String[] {"image/jpeg","image/png"},
                MediaStore.Images.Media.DATE_MODIFIED + " desc"); //edit by Jagger 2018-12-25 sortOrder改为递减

        if (cur != null) {
            if (cur.moveToFirst()) {
                // 获取指定列的索引
                int photoIDIndex = cur.getColumnIndexOrThrow(Media._ID);
                int photoPathIndex = cur.getColumnIndexOrThrow(Media.DATA);

                int photoNameIndex = cur.getColumnIndexOrThrow(Media.DISPLAY_NAME);
//                int photoTitleIndex = cur.getColumnIndexOrThrow(Media.TITLE);

                do {
                    String _id = cur.getString(photoIDIndex);
                    String path = cur.getString(photoPathIndex);

                    // /storage/emulated/0/Pictures/1557814957403.jpg
                    String photoName = cur.getString(photoNameIndex);   //  1557814957403.jpg
//                    String photoTitle = cur.getString(photoTitleIndex); //  1557814957403

                    // 2018/12/25 Hardy
                    // 在系统相机拍照完成后，由于某些手机系统，不会马上生成缩略图，故获取不到缩略图，应该以原图数据为准
                    // 在外层使用时，thumbnailPath 没有用到，只是用原图进行压缩等操作
                    if (!TextUtils.isEmpty(path) && FileUtil.isFileExists(path)) {  // 需要判断该图片文件是否还存在
                        ImageBean item = new ImageBean();
                        item.imageId = _id;
                        item.imagePath = path;
                        item.imageFileName = photoName;

                        albumList.add(item);
                    }

                    // old
//                    ImageBean item = new ImageBean();
//                    item.imageId = _id;
//                    item.imagePath = path;
//
//                    item.thumbnailPath = thumbnailList.get(_id);
//                    /*无thumb图片，不加入可显示列表*/
//                    if (!StringUtil.isEmpty(item.thumbnailPath)) {
//                        /*加入图片列表前清除图片thumb，每次使用src显示，防止图片不清晰*/
//                        item.thumbnailPath = "";
//                        albumList.add(item);
//                    }

                } while (cur.moveToNext());
            }

            // 2018/12/25 Hardy
            if (!cur.isClosed()) {
                cur.close();
            }
        }
        return albumList;
    }

    /**
     * 得到缩略图
     */
    private void getThumbnail() {
        String[] projection = {Thumbnails._ID, Thumbnails.IMAGE_ID,
                Thumbnails.DATA};
        Cursor cursor = cr.query(Thumbnails.EXTERNAL_CONTENT_URI, projection,
                null, null, null);
        if (cursor != null) {
            getThumbnailColumnData(cursor);
        }

        // 2018/12/25 Hardy
        if (cursor != null && !cursor.isClosed()) {
            cursor.close();
        }
    }

    /**
     * 从数据库中得到缩略图
     *
     * @param cur
     */
    @SuppressWarnings("unused")
    private void getThumbnailColumnData(Cursor cur) {
        if (cur.moveToFirst()) {
            int _id;
            int image_id;
            String image_path;
            int _idColumn = cur.getColumnIndex(Thumbnails._ID);
            int image_idColumn = cur.getColumnIndex(Thumbnails.IMAGE_ID);
            int dataColumn = cur.getColumnIndex(Thumbnails.DATA);

            do {
                _id = cur.getInt(_idColumn);
                image_id = cur.getInt(image_idColumn);
                image_path = cur.getString(dataColumn);
                thumbnailList.put("" + image_id, image_path);
            } while (cur.moveToNext());
        }
    }

    /**
     * 过滤掉 png 图片
     * @param list
     * @return
     */
    public List<ImageBean> sortNotPngImagePath(List<ImageBean> list){
        if (!ListUtils.isList(list)) {
            return list;
        }

        List<ImageBean> newList = new ArrayList<>();
        for (ImageBean bean : list) {
            if (bean != null && !TextUtils.isEmpty(bean.imagePath) && !bean.imagePath.endsWith(".png")) {
                newList.add(bean);
            }
        }

        return newList;
    }
}
