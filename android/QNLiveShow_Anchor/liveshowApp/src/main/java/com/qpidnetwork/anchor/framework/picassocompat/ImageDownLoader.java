package com.qpidnetwork.anchor.framework.picassocompat;

import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;

import com.squareup.picasso.Downloader;
import com.squareup.picasso.NetworkPolicy;

import java.io.IOException;
import java.util.Iterator;

import okhttp3.Cache;
import okhttp3.CacheControl;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.ResponseBody;

/**
 * okhttp版本已经更新到okhttp3+，在3.0版本之后，
 * 它的包名和接口都有所改变，比如包名从com.squareup.okhttp变成了okhttp3，
 * 所以导致了如果你的项目用的是3.0之后的版本，那么Picasso也不会去用它来请求网络，
 * 所以我们要自己写OKhttp3.0+ 版本的DownLoader。
 * 代码基本和Picasso源码的okHttpDownLoader差不多，只不过是换了3.0的用法
 * @author Jagger
 * 2017-7-14
 */
public class ImageDownLoader implements Downloader {
	OkHttpClient client = null;

	public ImageDownLoader(OkHttpClient client) {
		this.client = client;
	}

	@Override
	public Response load(Uri uri, int networkPolicy) throws IOException {

		CacheControl cacheControl = null;
		if (networkPolicy != 0) {
			if (NetworkPolicy.isOfflineOnly(networkPolicy)) {
				cacheControl = CacheControl.FORCE_CACHE;
			} else {
				CacheControl.Builder builder = new CacheControl.Builder();
				
				if (!NetworkPolicy.shouldReadFromDiskCache(networkPolicy)) {
					builder.noCache();
				}
				if (!NetworkPolicy.shouldWriteToDiskCache(networkPolicy)) {
					builder.noStore();
				}
				
				cacheControl = builder.build();
			}
		}

		Request.Builder builder = new Request.Builder().url(uri.toString());
		if (cacheControl != null) {
			builder.cacheControl(cacheControl);
		}
		
		okhttp3.Response response = client.newCall(builder.build()).execute();
		int responseCode = response.code();

		if (responseCode >= 300) {
			response.body().close();
			//清除picasso本地缓存，防止下次由于磁盘缓存导致重复下载失败
			clearErrorDownloadDiskCache(uri);

			throw new ResponseException(
					responseCode + " " + response.message(), networkPolicy,
					responseCode);
		}

		boolean fromCache = response.cacheResponse() != null;

		ResponseBody responseBody = response.body();
		return new Response(responseBody.byteStream(), fromCache,
				responseBody.contentLength());

	}

	/**
	 * 清除okhttp磁盘缓存中下载失败的缓存（如404错误等），防止下次由于磁盘缓存导致重复下载失败（即时url可以下载成功）
	 * @param uri
	 */
	private void clearErrorDownloadDiskCache(Uri uri){
		if(client != null && uri != null && !TextUtils.isEmpty(uri.toString())){
			Cache cache = client.cache();
			Iterator<String> iterator = null;
			try {
				iterator = cache.urls();
				if(iterator != null) {
					while (iterator.hasNext()) {
						String url = iterator.next();
						if (uri.toString().equals(url)) {
							// remove disk cache
							iterator.remove();
							break;
						}
					}
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	@Override
	public void shutdown() {
		Cache cache = client.cache();
		if (cache != null) {
			try {
				cache.close();
			} catch (IOException ignored) {
			}
		}
	}
}
