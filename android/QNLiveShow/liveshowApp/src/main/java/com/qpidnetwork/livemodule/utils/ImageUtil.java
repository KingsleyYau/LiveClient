package com.qpidnetwork.livemodule.utils;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.media.ExifInterface;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileLock;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/1.
 */

public class ImageUtil {

    /**
     * 图片压缩处理
     * @param image
     * @param sizeLimit 图片最大大小（单位K）
     * @return
     */
    public static Bitmap compressImage(Bitmap image, int sizeLimit) {

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        image.compress(Bitmap.CompressFormat.JPEG, 100, baos);//质量压缩方法，这里100表示不压缩，把压缩后的数据存放到baos中
        int options = 100;
        while ( baos.toByteArray().length / 1024 > sizeLimit) {  //循环判断如果压缩后图片是否大于100kb,大于继续压缩
            baos.reset();//重置baos即清空baos
            image.compress(Bitmap.CompressFormat.JPEG, options, baos);//这里压缩options%，把压缩后的数据存放到baos中
            options -= 10;//每次都减少10
        }
        ByteArrayInputStream isBm = new ByteArrayInputStream(baos.toByteArray());//把压缩后的数据baos存放到ByteArrayInputStream中
        Bitmap bitmap = BitmapFactory.decodeStream(isBm, null, null);//把ByteArrayInputStream数据生成图片

        return bitmap;
    }

    /**
     * 根据文件路径获取图片，并精确缩放
     * @param path		图片文件路径
     * @param scale		缩放比例
     * @return
     */
    public static Bitmap preciseScaleBitmap(String path, float scale)
    {
        Bitmap bitmap = null;

        // 确保参数正确且图片加载成功
        BitmapFactory.Options opts = getImageInfoWithFile(path);
        if (scale > 0
                && null != opts && opts.outWidth > 0 && opts.outHeight > 0)
        {
            if (scale < 1)
            {
                // ---- 缩小图片处理 ----
                // 找到最小加载图片(1/samplesSize)的比例(减少内存占用)
                int samplesSize = 1;
                float ratio = 1;
                while (true) {
                    float temp = ratio / 2;
                    if (temp > scale) {
                        ratio = temp;
                        samplesSize++;
                    }
                    else {
                        break;
                    }
                }

                // 加载图片缩小的图片(减少内存占用)
                BitmapFactory.Options newOpts = new BitmapFactory.Options();
                newOpts.inSampleSize = samplesSize;
                newOpts.inJustDecodeBounds = false;
                newOpts.inPurgeable = true;                 //设置内存不足，可回收
                newOpts.inInputShareable = true;            //设置共享内存
                newOpts.inPreferredConfig = Bitmap.Config.RGB_565;
                bitmap = BitmapFactory.decodeFile(path, newOpts);

                // 精确缩放
                if (scale != ratio)
                {
                    // 计算精度
                    float ratio2 = scale / ratio;
                    Bitmap tempBitmap = bitmap;

                    // 缩放并生成新bitmap
                    Matrix matrix = new Matrix();
                    matrix.postScale(ratio2, ratio2);
                    bitmap = Bitmap.createBitmap(
                            tempBitmap
                            , 0, 0
                            , tempBitmap.getWidth(), tempBitmap.getHeight()
                            , matrix ,true);

                    // 释放临时bitmap
                    tempBitmap.recycle();
                }
            }
            else if (scale > 1) {
                // ---- 放大图片处理 ----
                // 加载图片
                Bitmap tempBitmap = loadImageFile(path);

                // 放大并生成新bitmap
                Matrix matrix = new Matrix();
                matrix.postScale(scale, scale);
                bitmap = Bitmap.createBitmap(
                        tempBitmap
                        , 0, 0
                        , tempBitmap.getWidth(), tempBitmap.getHeight()
                        , matrix ,true);

                // 释放临时bitmap
                tempBitmap.recycle();
            }
            else {
                // ---- 不用缩放 ----
                bitmap = loadImageFile(path);
            }
        }
        return bitmap;
    }

    /**
     * 加载图片
     * @param srcPath	文件路径
     * @return
     */
    public static Bitmap loadImageFile(String srcPath) {
        Bitmap bitmap = null;

        if (!TextUtils.isEmpty(srcPath))
        {
            BitmapFactory.Options newOpts = new BitmapFactory.Options();
            newOpts.inJustDecodeBounds = false;
            bitmap = BitmapFactory.decodeFile(srcPath, newOpts);
        }

        return bitmap;
    }

    /**
     * 获取图片信息
     * @param srcPath	文件路径
     * @return
     */
    public static BitmapFactory.Options getImageInfoWithFile(String srcPath) {
        BitmapFactory.Options newOpts = null;
        if (!TextUtils.isEmpty(srcPath))
        {
            newOpts = new BitmapFactory.Options();
            newOpts.inJustDecodeBounds = true;
            BitmapFactory.decodeFile(srcPath, newOpts);
        }
        return newOpts;
    }

    /**
     * 高效获取指定路径下图片文件Bitmap（压缩处理，防止过大导致内存溢出）
     *
     * @param filePath  源文件地址
     * @param reqWidth  目标文件宽度
     * @param reqHeight 目标文件高度
     * @return
     */
    public static Bitmap decodeSampledBitmapFromFile(String filePath, int reqWidth, int reqHeight) {

        // First decode with inJustDecodeBounds=true to check dimensions
        final BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(filePath, options);

        // Calculate inSampleSize
        options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight);

        // Decode bitmap with inSampleSize set
        options.inJustDecodeBounds = false;
        return BitmapFactory.decodeFile(filePath, options);
    }

    /**
     * 计算缩放比例
     *
     * @param options
     * @param reqWidth
     * @param reqHeight
     * @return
     */
    private static int calculateInSampleSize(BitmapFactory.Options options, int reqWidth, int reqHeight) {
        // Raw height and width of image
        final int height = options.outHeight;
        final int width = options.outWidth;
        int inSampleSize = 1;

        if (reqHeight == -1) {
            if (width > reqWidth) {
                // Calculate the largest inSampleSize value that is a power of 2 and keeps both
                // height and width larger than the requested height and width.
                while ((width / inSampleSize) > reqWidth) {
                    inSampleSize *= 2;
                }
            }
        } else if (reqWidth == -1) {
            if (height > reqHeight) {
                // Calculate the largest inSampleSize value that is a power of 2 and keeps both
                // height and width larger than the requested height and width.
                while ((height / inSampleSize) > reqHeight) {
                    inSampleSize *= 2;
                }
            }
        } else {
            if (height > reqHeight || width > reqWidth) {
                // Calculate the largest inSampleSize value that is a power of 2 and keeps both
                // height and width larger than the requested height and width.
                while ((height / inSampleSize) > reqHeight
                        || (width / inSampleSize) > reqWidth) {
                    inSampleSize *= 2;
                }
            }
        }


        return inSampleSize;
    }

    /**
     * Gets the content:// URI  from the given corresponding path to a file
     *
     * @param context
     * @param filePath
     * @return content Uri
     */
    public static Uri getContentUriFromFile(Context context, String filePath) {
        File imageFile = new File(filePath);
        Uri resultUri = null;
        ContentResolver resolver = context.getContentResolver();
        Cursor cursor = resolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                new String[]{MediaStore.Images.Media._ID},
                MediaStore.Images.Media.DATA + "=? ",
                new String[]{filePath}, null);
        if (cursor != null && cursor.moveToFirst()) {
            int id = cursor.getInt(cursor.getColumnIndex(MediaStore.MediaColumns._ID));
            Uri baseUri = Uri.parse("content://media/external/images/media");
            resultUri = Uri.withAppendedPath(baseUri, "" + id);
            cursor.close();
        } else if (imageFile.exists()) {
            ContentValues values = new ContentValues();
            values.put(MediaStore.Images.Media.DATA, filePath);
            resultUri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
        }

        return resultUri;
    }

    /**
     * 测底删除文件
     *
     * @param context
     * @param filePath
     * @return
     */
    public static boolean realDeleteFile(Context context, String filePath) {
        File deleteFile = new File(filePath);
        ContentResolver mContentResolver = context.getContentResolver();
        if (null != deleteFile && deleteFile.exists()) {
            String where = MediaStore.Images.Media.DATA + "='" + filePath + "'";
            Uri uri = getContentUriFromFile(context, filePath);
            return mContentResolver.delete(uri, where, null) != 0;
        }
        return false;
    }

    /**
     * Gets the corresponding path to a file from the given content:// URI
     *
     * @param selectedVideoUri The content:// URI to find the file path from
     * @param contentResolver  The content resolver to use to perform the query.
     * @return the file path as a string
     */
    public static String getFilePathFromContentUri(Context context
            , Uri selectedVideoUri, ContentResolver contentResolver) {
        String filePath;
        String[] filePathColumn = {MediaStore.MediaColumns.DATA};
        Cursor cursor = contentResolver.query(selectedVideoUri, filePathColumn, null, null, null);
        //      \u4e5f\u53ef\u7528\u4e0b\u9762\u7684\u65b9\u6cd5\u62ff\u5230cursor
        //      Cursor cursor = this.context.managedQuery(selectedVideoUri, filePathColumn, null, null, null);
        cursor.moveToFirst();
        int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
        filePath = cursor.getString(columnIndex);
        cursor.close();
        return filePath;
    }

    //4.4之前是file:///，4.4之后是content:///
    @SuppressLint("NewApi")
    public static String getFilePathFromUri(final Context context, final Uri uri) {
        final boolean isKitKat = Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;
        // DocumentProvider
        if (isKitKat && DocumentsContract.isDocumentUri(context, uri)) {
            if (isExternalStorageDocument(uri)) {// ExternalStorageProvider
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];
                if ("primary".equalsIgnoreCase(type)) {
                    return Environment.getExternalStorageDirectory() + "/" + split[1];
                }
            } else if (isDownloadsDocument(uri)) {// DownloadsProvider
                final String id = DocumentsContract.getDocumentId(uri);
                final Uri contentUri = ContentUris.withAppendedId(
                        Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));
                return getDataColumn(context, contentUri, null, null);
            } else if (isMediaDocument(uri)) {// MediaProvider
                final String docId = DocumentsContract.getDocumentId(uri);
                final String[] split = docId.split(":");
                final String type = split[0];
                Uri contentUri = null;
                if ("image".equals(type)) {
                    contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                } else if ("video".equals(type)) {
                    contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                } else if ("audio".equals(type)) {
                    contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                }
                final String selection = "_id=?";
                final String[] selectionArgs = new String[]{
                        split[1]
                };

                return getDataColumn(context, contentUri, selection, selectionArgs);
            }
        } else if ("content".equalsIgnoreCase(uri.getScheme())) {// MediaStore (and general)
            // Return the remote address
            if (isGooglePhotosUri(uri)) {
                return uri.getLastPathSegment();
            }
            return getDataColumn(context, uri, null, null);
        } else if ("file".equalsIgnoreCase(uri.getScheme())) {// File
            return uri.getPath();
        }

        return null;
    }

    /**
     * Get the value of the data column for this Uri. This is useful for
     * MediaStore Uris, and other file-based ContentProviders.
     *
     * @param context       The context.
     * @param uri           The Uri to query.
     * @param selection     (Optional) Filter used in the query.
     * @param selectionArgs (Optional) Selection arguments used in the query.
     * @return The value of the _data column, which is typically a file path.
     */
    public static String getDataColumn(Context context, Uri uri, String selection,
                                       String[] selectionArgs) {

        Cursor cursor = null;
        final String column = "_data";
        final String[] projection = {
                column
        };

        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs,
                    null);
            if (cursor != null && cursor.moveToFirst()) {
                final int index = cursor.getColumnIndexOrThrow(column);
                return cursor.getString(index);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return null;
    }


    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is ExternalStorageProvider.
     */
    public static boolean isExternalStorageDocument(Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is DownloadsProvider.
     */
    public static boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is MediaProvider.
     */
    public static boolean isMediaDocument(Uri uri) {
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is Google Photos.
     */
    public static boolean isGooglePhotosUri(Uri uri) {
        return "com.google.android.apps.photos.content".equals(uri.getAuthority());
    }

    public static void adjustImageDegree(String filePath) {
        adjustImageDegree(filePath, filePath);
    }
    /**
     * 获取图片的旋转角度，有些系统把拍照的图片旋转了，有的没有旋转
     * https://stackoverflow.com/questions/14066038/why-does-an-image-captured-using-camera-intent-gets-rotated-on-some-devices-on-a
     */
    public static void adjustImageDegree(String filePath, String saveFilePath) {
        try {
            int degree = readImageDegree(filePath);
            if (degree != 0) {
                BitmapFactory.Options opts = new BitmapFactory.Options();//获取缩略图显示到屏幕上
                opts.inJustDecodeBounds = true;
                BitmapFactory.decodeFile(filePath, opts);
                opts.inSampleSize = 2;
                opts.inJustDecodeBounds = false;
                Bitmap cbitmap = BitmapFactory.decodeFile(filePath, opts);
                /**
                 * 把图片旋转为正的方向
                 */
                Bitmap newbitmap = rotaingImageView(degree, cbitmap);
                cbitmap.recycle();
                // 覆盖保存新图片
                FileCacheManager.getInstance().saveImage(saveFilePath, newbitmap, Bitmap.CompressFormat.JPEG, 100);
                newbitmap.recycle();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } catch (OutOfMemoryError e) {
            e.printStackTrace();
        }
    }

    /**
     * 读取图片属性：旋转的角度
     *
     * @param filePath 图片绝对路径
     * @return degree旋转的角度
     */
    public static int readImageDegree(String filePath) {
        int degree = 0;
        if (TextUtils.isEmpty(filePath)) {
            return degree;
        }
        try {
            ExifInterface exifInterface = new ExifInterface(filePath);
            int orientation = exifInterface.getAttributeInt(ExifInterface.TAG_ORIENTATION,
                    ExifInterface.ORIENTATION_NORMAL);
            switch (orientation) {
                case ExifInterface.ORIENTATION_ROTATE_90:
                    degree = 90;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_180:
                    degree = 180;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_270:
                    degree = 270;
                    break;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return degree;
    }


    /* 旋转图片
     * @param angle
     * @param bitmap
     * @return Bitmap
     */
    public static Bitmap rotaingImageView(int angle, Bitmap bitmap) {
        //旋转图片 动作
        Matrix matrix = new Matrix();
        matrix.postRotate(angle);
//        System.out.println("angle2=" + angle);
        // 创建新的图片
        Bitmap resizedBitmap = null;
        try {
            resizedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
        } catch (OutOfMemoryError e) {
            e.printStackTrace();
        }

        // 2019/5/14 Hardy 回收旧的 Bitmap
        if (bitmap != null && bitmap != resizedBitmap) {
            bitmap.recycle();
        }

        return resizedBitmap;
    }

    public static Bitmap getBitmapFromUri(Uri uri, Context mContext) {
        try {
            // 读取uri所在的图片
            Bitmap bitmap = MediaStore.Images.Media.getBitmap(mContext.getContentResolver(), uri);
            return bitmap;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * 根据图片名称获取资源ID
     *
     * @param resName
     * @return
     */
    public static int getImageResoursceByName(String resName) {
        int imgId = 0;
        try {
            imgId = R.drawable.class.getField(resName).getInt(null); // 图片的对应为R.drawable.e5
        } catch (Exception e) {
            e.printStackTrace();
        }
        return imgId;
    }

    /**
     * 转换图片成圆形
     *
     * @param bitmap 　传入Bitmap对象
     * @return
     */
    public static Bitmap toRoundBitmap(Bitmap bitmap) {
        if (bitmap == null)
            return null;
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        float roundPx;
        float left, top, right, bottom, dst_left, dst_top, dst_right, dst_bottom;
        if (width <= height) {
            roundPx = width / 2;
            top = 0;
            bottom = width;
            left = 0;
            right = width;
            height = width;
            dst_left = 0;
            dst_top = 0;
            dst_right = width;
            dst_bottom = width;
        } else {
            roundPx = height / 2;
            float clip = (width - height) / 2;
            left = clip;
            right = width - clip;
            top = 0;
            bottom = height;
            width = height;
            dst_left = 0;
            dst_top = 0;
            dst_right = height;
            dst_bottom = height;
        }

        Bitmap output = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(output);

        final int color = 0xff424242;
        final Paint paint = new Paint();
        final Rect src = new Rect((int) left, (int) top, (int) right,
                (int) bottom);
        final Rect dst = new Rect((int) dst_left, (int) dst_top,
                (int) dst_right, (int) dst_bottom);
        final RectF rectF = new RectF(dst);

        paint.setAntiAlias(true);

        canvas.drawARGB(0, 0, 0, 0);
        paint.setColor(color);
        canvas.drawRoundRect(rectF, roundPx, roundPx, paint);

        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        canvas.drawBitmap(bitmap, src, dst, paint);
        return output;
    }

    /**
     * 把Bitmap保存为文件
     *
     * @param filePath 文件路径
     * @param bitmap   Bitmap
     * @param format   图片格式
     * @param quality  图片压缩质量
     * @return
     */
    public static boolean saveBitmapToFile(String filePath, Bitmap bitmap, Bitmap.CompressFormat format, int quality) {
        if (filePath.isEmpty()
                || bitmap == null
                || quality <= 0) {
            return false;
        }

        boolean result = false;

        try {
            File file = new File(filePath);

            // 删除已存在的文件
            if (file.exists() && file.isFile()) {
                file.delete();
            }

            // 写入压纹图片数据
            FileOutputStream fOut = null;
            fOut = new FileOutputStream(file);
            FileLock fl = ((FileOutputStream) fOut).getChannel().tryLock();
            if (fl != null) {
                bitmap.compress(format, quality, fOut);
                fl.release();
            }
            fOut.close();

            // 标记成功
            result = true;
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return result;
    }

    public static Bitmap decodeHeightDependedBitmapFromFile(String filePath, int reqHeight) {
        /*初步使用inSampleSize方式缩放，防止读取大图直接导致溢出*/
        Bitmap resizeBitmap = null;
        Bitmap tempBitmap = decodeSampledBitmapFromFile(filePath, reqHeight, reqHeight);
        if (null != tempBitmap) {
            /*使用Matrix再处理生成图片，以长边缩放*/
            int bmpWidth = tempBitmap.getWidth();
            int bmpHeight = tempBitmap.getHeight();
            Matrix matrix = new Matrix();
            float scaleHeight = (float) reqHeight / bmpHeight;
            matrix.postScale(scaleHeight, scaleHeight);
            resizeBitmap = Bitmap.createBitmap(tempBitmap, 0, 0, bmpWidth, bmpHeight, matrix, false);
            if (resizeBitmap != tempBitmap) {
                //解决createBitmap 与原图一样，回收导致recycled异常
                tempBitmap.recycle();
            }
        }
        return resizeBitmap;
    }

    public static Bitmap decodeHeightDependedBitmapFromFile(Bitmap inBmp, int reqHeight) {

        /*使用Matrix再处理生成图片，以长边缩放*/
        int bmpWidth = inBmp.getWidth();
        int bmpHeight = inBmp.getHeight();
        Matrix matrix = new Matrix();
        float scaleHeight = (float) reqHeight / bmpHeight;
        matrix.postScale(scaleHeight, scaleHeight);
        Bitmap resizeBitmap = Bitmap.createBitmap(inBmp, 0, 0, bmpWidth, bmpHeight, matrix, false);
        if (resizeBitmap != inBmp) {
            //解决createBitmap 与原图一样，回收导致recycled异常
            inBmp.recycle();
        }
        return resizeBitmap;
    }

    public static Bitmap get2DpRoundedImage(Context context, Bitmap inBmp) {
        if (inBmp == null) {
            return null;
        }

        final float roundPx = 2.0f * context.getResources().getDisplayMetrics().density;

        if (inBmp.getWidth() <= roundPx || inBmp.getHeight() <= roundPx) {
            return inBmp;
        }

        Bitmap output = Bitmap.createBitmap(inBmp.getWidth(), inBmp
                .getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(output);

        final int color = 0xff424242;
        final Paint paint = new Paint();
        final Rect rect = new Rect(0, 0, inBmp.getWidth(), inBmp.getHeight());
        final RectF rectF = new RectF(rect);

        paint.setAntiAlias(true);
        paint.setColor(color);
        canvas.drawRoundRect(rectF, roundPx, roundPx, paint);

        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        canvas.drawBitmap(inBmp, rect, rect, paint);
        inBmp.recycle();
        return output;
    }


    /**
     * 2018/11/27 Hardy
     * 参考 QN 的 ImageUtil.SaveImageToGallery()
     * 并参考以下链接资料，稍微改造整理
     * https://stackoverflow.com/questions/9414955/trigger-mediascanner-on-specific-path-folder-how-to/25086535#25086535
     * @param activity
     * @param filePath
     * @return
     */
    public static boolean SaveImageToGallery(Activity activity,String filePath){
        if (null == activity
                || TextUtils.isEmpty(filePath)) {
            return false;
        }

        boolean result = false;

        // 插入图片文件
//        ContentResolver cr = activity.getContentResolver();
        try {
            // 2019/6/19 Hardy 注释掉，避免在系统里生成多一张同样的图片.
//            String path = MediaStore.Images.Media.insertImage(cr, filePath, "", "");

////            // 获取插入后的文件路径
//            Uri uri = Uri.parse(path);
//            String[] proj = {MediaStore.Images.Media.DATA};
//            Cursor actualimagecursor = activity.managedQuery(uri, proj, null, null, null);
//            int actual_image_column_index = actualimagecursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
//            actualimagecursor.moveToFirst();
//            String img_path = actualimagecursor.getString(actual_image_column_index);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
//                MediaScannerConnection.scanFile(activity, new String[]{img_path}, null, null);
                
                // 2019/6/19 Hardy  刷新当前路径下的图片即可
                MediaScannerConnection.scanFile(activity, new String[]{filePath}, null, null);
            } else {
                activity.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + filePath)));
            }

            // 完成
            result = true;

        } catch (Throwable e) {
            /*添加OOM捕捉，防止异常死机问题*/
            e.printStackTrace();
        }


        return result;
    }

    /**
     * 给 ImageView 盖上一层灰影
     *
     * @param isShow
     * @param imageView
     */
    public static void showImageColorFilter(boolean isShow, ImageView imageView) {
        showImageColorFilter(isShow, imageView, -1);
    }

    public static void showImageColorFilter(boolean isShow, ImageView imageView, int color) {
        if (color == -1) {
            color = Color.GRAY;
        }
        if (isShow) {
            imageView.setColorFilter(color, PorterDuff.Mode.MULTIPLY);    // 阴影
        } else {
            imageView.clearColorFilter();
        }
    }

    public static Bitmap createRotatedBitmap(Context context, Bitmap bitmap, int rotation){

        if (bitmap == null) {
            return null;
        }

        int w = bitmap.getWidth();
        int h = bitmap.getHeight();
        Matrix mtx = new Matrix();
        mtx.preRotate(rotation);
        bitmap = Bitmap.createBitmap(bitmap, 0, 0, w, h, mtx, false);

        return bitmap;
    }

    public static boolean writeBitmapToFile(Bitmap bitmap, String desFileUrl){
        FileOutputStream outStream = null;

        try{
            outStream = new FileOutputStream(desFileUrl);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outStream);
            outStream.close();
            return true;
        }catch(Exception e){
            return false;
        }
    }

    /**
     *
     * @param path 本地路径,如："/mnt/sdcard/names.jpg"
     * @param wh 长度为2的int数组，存放宽高
     */
    public static void getLocalPicSize(String path , int[] wh){
        if(wh != null && wh.length >= 2){
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            //bitmap.options类为bitmap的裁剪类，通过他可以实现bitmap的裁剪；如果不设置裁剪后的宽高和裁剪比例，返回的bitmap对象将为空，但是这个对象存储了原bitmap的宽高信息，bitmap对象为空不会引发OOM。
            BitmapFactory.decodeFile(path, options);

            wh[0] = options.outWidth;
            wh[1] = options.outHeight;
        }
    }
}
