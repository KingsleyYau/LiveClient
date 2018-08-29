package com.qpidnetwork.anchor.framework.filedownloader;

import com.liulishuo.filedownloader.connection.FileDownloadConnection;
import com.liulishuo.filedownloader.connection.FileDownloadUrlConnection;
import com.liulishuo.filedownloader.util.FileDownloadHelper;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.Proxy;
import java.net.URL;
import java.util.List;
import java.util.Map;

import javax.net.ssl.HttpsURLConnection;

/**
 * Description:
 * 参考:https://github.com/lingochamp/FileDownloader/issues/437#issuecomment-270825192
 * <p>
 * Created by Harry on 2018/5/30.
 */
public class SSLSupportsUrlConnection implements FileDownloadConnection{

    protected HttpsURLConnection mConnection;

    public SSLSupportsUrlConnection(String originUrl, Configuration configuration) throws IOException {
        this(new URL(originUrl), configuration);
    }

    public SSLSupportsUrlConnection(URL url, Configuration configuration) throws IOException {
        if (configuration != null && configuration.proxy != null) {
            this.mConnection = (HttpsURLConnection) url.openConnection(configuration.proxy);
        } else {
            this.mConnection = (HttpsURLConnection) url.openConnection();
        }

        if (configuration != null) {
            if (configuration.readTimeout != null) {
                this.mConnection.setReadTimeout(configuration.readTimeout);
            }

            if (configuration.connectTimeout != null) {
                this.mConnection.setConnectTimeout(configuration.connectTimeout);
            }
        }

    }

    public SSLSupportsUrlConnection(String originUrl) throws IOException {
        this((String)originUrl, (Configuration)null);
    }

    public void addHeader(String name, String value) {
        this.mConnection.addRequestProperty(name, value);
    }

    public boolean dispatchAddResumeOffset(String etag, long offset) {
        return false;
    }

    public InputStream getInputStream() throws IOException {
        return this.mConnection.getInputStream();
    }

    public Map<String, List<String>> getRequestHeaderFields() {
        return this.mConnection.getRequestProperties();
    }

    public Map<String, List<String>> getResponseHeaderFields() {
        return this.mConnection.getHeaderFields();
    }

    public String getResponseHeaderField(String name) {
        return this.mConnection.getHeaderField(name);
    }

    public void execute() throws IOException {
        this.mConnection.connect();
    }

    public int getResponseCode() throws IOException {
        return this.mConnection instanceof HttpURLConnection ? ((HttpURLConnection)this.mConnection).getResponseCode() : 0;
    }

    public void ending() {
    }

    public static class Configuration {
        private Proxy proxy;
        private Integer readTimeout;
        private Integer connectTimeout;

        public Configuration() {
        }

        public Configuration proxy(Proxy proxy) {
            this.proxy = proxy;
            return this;
        }

        public Configuration readTimeout(int readTimeout) {
            this.readTimeout = readTimeout;
            return this;
        }

        public Configuration connectTimeout(int connectTimeout) {
            this.connectTimeout = connectTimeout;
            return this;
        }
    }

    public static class Creator implements FileDownloadHelper.ConnectionCreator {
        private final FileDownloadUrlConnection.Configuration mConfiguration;

        public Creator() {
            this((FileDownloadUrlConnection.Configuration)null);
        }

        public Creator(FileDownloadUrlConnection.Configuration configuration) {
            this.mConfiguration = configuration;
        }

        FileDownloadConnection create(URL url) throws IOException {
            return new FileDownloadUrlConnection(url, this.mConfiguration);
        }

        public FileDownloadConnection create(String originUrl) throws IOException {
            return new FileDownloadUrlConnection(originUrl, this.mConfiguration);
        }
    }

}
