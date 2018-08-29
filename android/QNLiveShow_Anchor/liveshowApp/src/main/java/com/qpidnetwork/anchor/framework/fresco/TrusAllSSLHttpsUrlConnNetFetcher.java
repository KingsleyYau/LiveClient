package com.qpidnetwork.anchor.framework.fresco;

import android.net.Uri;

import com.facebook.common.internal.VisibleForTesting;
import com.facebook.imagepipeline.image.EncodedImage;
import com.facebook.imagepipeline.producers.BaseNetworkFetcher;
import com.facebook.imagepipeline.producers.BaseProducerContextCallbacks;
import com.facebook.imagepipeline.producers.Consumer;
import com.facebook.imagepipeline.producers.FetchState;
import com.facebook.imagepipeline.producers.NetworkFetcher;
import com.facebook.imagepipeline.producers.ProducerContext;
import com.qpidnetwork.anchor.utils.Log;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

/**
 * Description:Fresco支持非正式https证书
 * 参考:http://www.jacpy.com/2017/09/28/fresco-used-httpurlconnection-support-https-image-loader.html
 * <p>
 * Created by Harry on 2018/5/30.
 */
public class TrusAllSSLHttpsUrlConnNetFetcher  extends BaseNetworkFetcher<FetchState> {
    private static final int NUM_NETWORK_THREADS = 3;
    private static final int MAX_REDIRECTS = 5;
    public static final int HTTP_TEMPORARY_REDIRECT = 307;
    public static final int HTTP_PERMANENT_REDIRECT = 308;
    private final ExecutorService mExecutorService;

    public TrusAllSSLHttpsUrlConnNetFetcher() {
        this(Executors.newFixedThreadPool(3));
    }

    @VisibleForTesting
    TrusAllSSLHttpsUrlConnNetFetcher(ExecutorService executorService) {
        this.mExecutorService = executorService;
    }

    public FetchState createFetchState(Consumer<EncodedImage> consumer, ProducerContext context) {
        return new FetchState(consumer, context);
    }

    public void fetch(final FetchState fetchState, final NetworkFetcher.Callback callback) {
        final Future<?> future = this.mExecutorService.submit(new Runnable() {
            public void run() {
                TrusAllSSLHttpsUrlConnNetFetcher.this.fetchSync(fetchState, callback);
            }
        });
        fetchState.getContext().addCallbacks(new BaseProducerContextCallbacks() {
            public void onCancellationRequested() {
                if (future.cancel(false)) {
                    callback.onCancellation();
                }

            }
        });
    }

    @VisibleForTesting
    void fetchSync(FetchState fetchState, NetworkFetcher.Callback callback) {
        HttpURLConnection connection = null;
        InputStream is = null;

        try {
            connection = this.downloadFrom(fetchState.getUri(), 5);
            if (connection != null) {
                is = connection.getInputStream();
                callback.onResponse(is, -1);
            }
        } catch (IOException var14) {
            callback.onFailure(var14);
        } finally {
            if (is != null) {
                try {
                    is.close();
                } catch (IOException var13) {
                    ;
                }
            }

            if (connection != null) {
                connection.disconnect();
            }

        }

    }

    private HttpURLConnection downloadFrom(Uri uri, int maxRedirects) throws IOException {
        HttpURLConnection connection = openConnectionTo(uri);
        // 增加https支持
        String scheme = uri.getScheme();
        if ("https".equals(scheme)) {
            HttpsURLConnection httpsURLConnection = (HttpsURLConnection) connection;
            SSLContext sslContext = null;
            try {
                sslContext = SSLContext.getInstance("TLS");
                sslContext.init(null, new TrustManager[]{new X509TrustManager() {
                    @Override
                    public void checkClientTrusted(X509Certificate[] chain, String authType)  {}

                    @Override
                    public void checkServerTrusted(X509Certificate[] chain, String authType) {}

                    @Override
                    public X509Certificate[] getAcceptedIssuers() {
                        return new X509Certificate[0];
                    }
                }}, new SecureRandom());
            } catch (Exception e) {
                Log.e("TrusAllSSLHttpsUrlConnNetFetcher", e.getMessage(), e);
            }

            if (sslContext != null) {
                SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();
                httpsURLConnection.setSSLSocketFactory(sslSocketFactory);
                httpsURLConnection.setHostnameVerifier(new HostnameVerifier() {
                   @Override
                   public boolean verify(String hostname, SSLSession session) {
                       return true;
                   }
               });
            }
        }

        int responseCode = connection.getResponseCode();
        if (isHttpSuccess(responseCode)) {
            return connection;
        } else if (isHttpRedirect(responseCode)) {
            String nextUriString = connection.getHeaderField("Location");
            connection.disconnect();
            Uri nextUri = nextUriString == null ? null : Uri.parse(nextUriString);
            String originalScheme = uri.getScheme();
            if (maxRedirects > 0 && nextUri != null && !nextUri.getScheme().equals(originalScheme)) {
                return this.downloadFrom(nextUri, maxRedirects - 1);
            } else {
                String message = maxRedirects == 0 ? error("URL %s follows too many redirects", uri.toString()) : error("URL %s returned %d without a valid redirect", uri.toString(), responseCode);
                throw new IOException(message);
            }
        } else {
            connection.disconnect();
            throw new IOException(String.format("Image URL %s returned HTTP code %d", uri.toString(), responseCode));
        }
    }

    @VisibleForTesting
    static HttpURLConnection openConnectionTo(Uri uri) throws IOException {
        URL url = new URL(uri.toString());
        return (HttpURLConnection)url.openConnection();
    }

    private static boolean isHttpSuccess(int responseCode) {
        return responseCode >= 200 && responseCode < 300;
    }

    private static boolean isHttpRedirect(int responseCode) {
        switch(responseCode) {
            case 300:
            case 301:
            case 302:
            case 303:
            case 307:
            case 308:
                return true;
            case 304:
            case 305:
            case 306:
            default:
                return false;
        }
    }

    private static String error(String format, Object... args) {
        return String.format(Locale.getDefault(), format, args);
    }
}
