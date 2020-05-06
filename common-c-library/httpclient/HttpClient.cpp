/*
 * HttpClient.cpp
 *
 *  Created on: 2014-12-24
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "HttpClient.h"

#include <curl/curl.h>

#ifdef _HTTPS_SUPPORT
#include <openssl/ssl.h>
#endif

#ifndef _WIN32
#include <common/command.h>
#endif

#include <common/KLog.h>
#include <common/KMutex.h>
#include <common/CheckMemoryLeak.h>


#define DEVICE_ANDROID_TYPE "dev-type: 30"
#define DEVICE_IPHONE_TYPE "dev-type: 31"
#ifdef IOS  /* IOS */
#define DEVICE_TYPE DEVICE_IPHONE_TYPE
#else
#define DEVICE_TYPE DEVICE_ANDROID_TYPE
#endif
//
#define QN_DEVICE_ANDROID_TYPE "device_type: 30"
#define QN_DEVICE_IPHONE_TYPE  "device_type: 31"
#ifdef IOS  /* IOS */
#define QN_DEVICE_TYPE QN_DEVICE_IPHONE_TYPE
#else
#define QN_DEVICE_TYPE QN_DEVICE_ANDROID_TYPE
#endif

#define USER_AGENT	"Mozil1a/4.0 (compatible; MS1E 7.0; Windows NT 6.1; WOW64; )"

// 增加头是否时主播


#define INVALID_DOWNLOAD 0
#define INVALID_DOWNLOADLASTTIME 0
CURLSH *sh;
string COOKIES_FILE = "/sdcard/qpidnetwork/cookie";

static string gProxyUrl = "";


#ifdef _HTTPS_SUPPORT
//alextest ssl 多线程的锁, openssl 在多线程有时会crash（难重现， curl_easy_cleanup 或 curl_easy_perform）
#define NUMT 4

/* we have this global to let the callback get easy access to it */
static pthread_mutex_t *lockarray;

static bool isSSlLock = false;

static void lock_callback(int mode, int type, const char *file, int line)
{
    (void)file;
    (void)line;
    if(mode & CRYPTO_LOCK) {
        pthread_mutex_lock(&(lockarray[type]));
    }
    else {
        pthread_mutex_unlock(&(lockarray[type]));
    }
}

static unsigned long thread_id(void)
{
    unsigned long ret;
    
    ret=(unsigned long)pthread_self();
    return ret;
}

static void init_locks(void)
{
    if (isSSlLock == false) {
        int i;
        
        lockarray=(pthread_mutex_t *)OPENSSL_malloc(CRYPTO_num_locks() *
                                                    sizeof(pthread_mutex_t));
        for(i=0; i<CRYPTO_num_locks(); i++) {
            pthread_mutex_init(&(lockarray[i]), NULL);
        }
        
        CRYPTO_set_id_callback((unsigned long (*)())thread_id);
        CRYPTO_set_locking_callback(lock_callback);
        
        isSSlLock = true;
    }
    
}

static void kill_locks(void)
{
    if (isSSlLock == true) {
        int i;
        
        CRYPTO_set_locking_callback(NULL);
        for(i=0; i<CRYPTO_num_locks(); i++)
            pthread_mutex_destroy(&(lockarray[i]));
        
        OPENSSL_free(lockarray);
        
         isSSlLock = false;
    }
}

#endif

static CURLcode Curl_SSL_Handle(CURL *curl, void *sslctx, void *param)
{
#ifdef _HTTPS_SUPPORT
	FileLog(LIVESHOW_HTTP_LOG, "HttpClient::Curl_SSL_Handle()");
	X509_STORE * store;
	X509 * cert=NULL;
	BIO * bio;
	const char *mypem = /* www.cacert.org */
			"-----BEGIN CERTIFICATE-----\n"\
			"MIIHPTCCBSWgAwIBAgIBADANBgkqhkiG9w0BAQQFADB5MRAwDgYDVQQKEwdSb290\n"\
		"IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNB\n"\
			"IENlcnQgU2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRA\n"\
			"Y2FjZXJ0Lm9yZzAeFw0wMzAzMzAxMjI5NDlaFw0zMzAzMjkxMjI5NDlaMHkxEDAO\n"\
			"BgNVBAoTB1Jvb3QgQ0ExHjAcBgNVBAsTFWh0dHA6Ly93d3cuY2FjZXJ0Lm9yZzEi\n"\
			"MCAGA1UEAxMZQ0EgQ2VydCBTaWduaW5nIEF1dGhvcml0eTEhMB8GCSqGSIb3DQEJ\n"\
			"ARYSc3VwcG9ydEBjYWNlcnQub3JnMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC\n"\
			"CgKCAgEAziLA4kZ97DYoB1CW8qAzQIxL8TtmPzHlawI229Z89vGIj053NgVBlfkJ\n"\
			"8BLPRoZzYLdufujAWGSuzbCtRRcMY/pnCujW0r8+55jE8Ez64AO7NV1sId6eINm6\n"\
			"zWYyN3L69wj1x81YyY7nDl7qPv4coRQKFWyGhFtkZip6qUtTefWIonvuLwphK42y\n"\
			"fk1WpRPs6tqSnqxEQR5YYGUFZvjARL3LlPdCfgv3ZWiYUQXw8wWRBB0bF4LsyFe7\n"\
			"w2t6iPGwcswlWyCR7BYCEo8y6RcYSNDHBS4CMEK4JZwFaz+qOqfrU0j36NK2B5jc\n"\
			"G8Y0f3/JHIJ6BVgrCFvzOKKrF11myZjXnhCLotLddJr3cQxyYN/Nb5gznZY0dj4k\n"\
			"epKwDpUeb+agRThHqtdB7Uq3EvbXG4OKDy7YCbZZ16oE/9KTfWgu3YtLq1i6L43q\n"\
			"laegw1SJpfvbi1EinbLDvhG+LJGGi5Z4rSDTii8aP8bQUWWHIbEZAWV/RRyH9XzQ\n"\
			"QUxPKZgh/TMfdQwEUfoZd9vUFBzugcMd9Zi3aQaRIt0AUMyBMawSB3s42mhb5ivU\n"\
			"fslfrejrckzzAeVLIL+aplfKkQABi6F1ITe1Yw1nPkZPcCBnzsXWWdsC4PDSy826\n"\
			"YreQQejdIOQpvGQpQsgi3Hia/0PsmBsJUUtaWsJx8cTLc6nloQsCAwEAAaOCAc4w\n"\
			"ggHKMB0GA1UdDgQWBBQWtTIb1Mfz4OaO873SsDrusjkY0TCBowYDVR0jBIGbMIGY\n"\
			"gBQWtTIb1Mfz4OaO873SsDrusjkY0aF9pHsweTEQMA4GA1UEChMHUm9vdCBDQTEe\n"\
			"MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0\n"\
			"IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy\n"\
			"dC5vcmeCAQAwDwYDVR0TAQH/BAUwAwEB/zAyBgNVHR8EKzApMCegJaAjhiFodHRw\n"\
			"czovL3d3dy5jYWNlcnQub3JnL3Jldm9rZS5jcmwwMAYJYIZIAYb4QgEEBCMWIWh0\n"\
			"dHBzOi8vd3d3LmNhY2VydC5vcmcvcmV2b2tlLmNybDA0BglghkgBhvhCAQgEJxYl\n"\
			"aHR0cDovL3d3dy5jYWNlcnQub3JnL2luZGV4LnBocD9pZD0xMDBWBglghkgBhvhC\n"\
			"AQ0ESRZHVG8gZ2V0IHlvdXIgb3duIGNlcnRpZmljYXRlIGZvciBGUkVFIGhlYWQg\n"\
			"b3ZlciB0byBodHRwOi8vd3d3LmNhY2VydC5vcmcwDQYJKoZIhvcNAQEEBQADggIB\n"\
			"ACjH7pyCArpcgBLKNQodgW+JapnM8mgPf6fhjViVPr3yBsOQWqy1YPaZQwGjiHCc\n"\
			"nWKdpIevZ1gNMDY75q1I08t0AoZxPuIrA2jxNGJARjtT6ij0rPtmlVOKTV39O9lg\n"\
			"18p5aTuxZZKmxoGCXJzN600BiqXfEVWqFcofN8CCmHBh22p8lqOOLlQ+TyGpkO/c\n"\
			"gr/c6EWtTZBzCDyUZbAEmXZ/4rzCahWqlwQ3JNgelE5tDlG+1sSPypZt90Pf6DBl\n"\
			"Jzt7u0NDY8RD97LsaMzhGY4i+5jhe1o+ATc7iwiwovOVThrLm82asduycPAtStvY\n"\
			"sONvRUgzEv/+PDIqVPfE94rwiCPCR/5kenHA0R6mY7AHfqQv0wGP3J8rtsYIqQ+T\n"\
			"SCX8Ev2fQtzzxD72V7DX3WnRBnc0CkvSyqD/HMaMyRa+xMwyN2hzXwj7UfdJUzYF\n"\
			"CpUCTPJ5GhD22Dp1nPMd8aINcGeGG7MW9S/lpOt5hvk9C8JzC6WZrG/8Z7jlLwum\n"\
			"GCSNe9FINSkYQKyTYOGWhlC0elnYjyELn8+CkcY7v2vcB5G5l1YjqrZslMZIBjzk\n"\
			"zk6q5PYvCdxTby78dOs6Y5nCpqyJvKeyRKANihDjbPIky/qbn3BHLt4Ui9SyIAmW\n"\
			"omTxJBzcoTWcFbLUvFUufQb1nA5V9FrWk9p2rSVzTMVD\n"\
			"-----END CERTIFICATE-----\n";

	  /* get a BIO */
	  bio = BIO_new_mem_buf((void*)mypem, -1);

	  /* use it to read the PEM formatted certificate from memory into an X509
	   * structure that SSL can use
	   */
	  PEM_read_bio_X509(bio, &cert, 0, NULL);
	  if (cert == NULL)
		printf("PEM_read_bio_X509 failed...\n");

	  /* get a pointer to the X509 certificate store (which may be empty!) */
	  store = SSL_CTX_get_cert_store((SSL_CTX *)sslctx);

	  /* add our certificate to this store */
	  if (X509_STORE_add_cert(store, cert)==0)
		printf("error adding certificate\n");

	  /* decrease reference counts */
	  X509_free(cert);
	  BIO_free(bio);
#endif

	  /* all set to go */
	  return CURLE_OK ;
}

static KMutex gCurlShareMutex;
static void Curl_Lock(CURL *handle, curl_lock_data data, curl_lock_access access, void *useptr) {
    //FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_STAT, "HttpClient::Curl_Lock( access : %d )", access);
    gCurlShareMutex.lock();
}

static void Curl_Unlock(CURL *handle, curl_lock_data data, void *useptr) {
    //FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_STAT, "HttpClient::Curl_Unlock()");
    gCurlShareMutex.unlock();
}

void HttpClient::Init() {
	curl_global_init(CURL_GLOBAL_ALL);
	curl_version_info_data *data = curl_version_info(CURLVERSION_FIRST);

	if( data->version != NULL ) {
        FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_WARNING, "HttpClient::Init( curl_version : %s )", data->version);
	}

	if( data->ssl_version != NULL ) {
		FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_WARNING, "HttpClient::Init( ssl_version : %s )", data->ssl_version);
	}

	sh = curl_share_init();
    #ifdef _HTTPS_SUPPORT
    //alextest ssl 多线程的锁
    kill_locks();
    init_locks();
    #endif
	curl_share_setopt(sh, CURLSHOPT_SHARE, CURL_LOCK_DATA_COOKIE);
    curl_share_setopt(sh, CURLSHOPT_LOCKFUNC, Curl_Lock);
    curl_share_setopt(sh, CURLSHOPT_UNLOCKFUNC, Curl_Unlock);
    
}

void HttpClient::SetLogDirectory(string directory) {
	KLog::SetLogDirectory(directory);
	FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_MSG, "HttpClient::SetLogDirectory( directory : %s )", directory.c_str());

	curl_version_info_data *data = curl_version_info(CURLVERSION_FIRST);

	if( data->version != NULL ) {
		FileLog(LIVESHOW_HTTP_LOG, "HttpClient::SetLogDirectory( curl_version : %s )", data->version);
	}

	if( data->ssl_version != NULL ) {
		FileLog(LIVESHOW_HTTP_LOG, "HttpClient::SetLogDirectory( ssl_version : %s )", data->ssl_version);
	}
}

void HttpClient::SetLogEnable(bool enable) {
	KLog::SetLogEnable(enable);
}

void HttpClient::SetProxy(string proxyUrl) {
    gProxyUrl = proxyUrl;
}

HttpClient::HttpClient() {
	// TODO Auto-generated constructor stub
    FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_MSG, "HttpClient::HttpClient( this : %p )", this);
    
	mpIHttpClientCallback = NULL;
	mpCURL = NULL;
	mUrl = "";
	mContentType = "";
    
    mIsAborted = false;
}

HttpClient::~HttpClient() {
	// TODO Auto-generated destructor stub
    FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_MSG, "HttpClient::~HttpClient( this : %p )", this);
}

void HttpClient::SetCookiesDirectory(string directory) {
	COOKIES_FILE = directory;
	COOKIES_FILE += "/cookie";
}

void HttpClient::CleanCookies() {
	FileLog(LIVESHOW_HTTP_LOG, "HttpClient::CleanCookies()");
	remove(COOKIES_FILE.c_str());
	CURL *curl = curl_easy_init();
	curl_easy_setopt(curl, CURLOPT_SHARE, sh);
	curl_easy_setopt(curl, CURLOPT_COOKIELIST, "ALL");
	curl_easy_cleanup(curl);
}

void HttpClient::CleanCookies(string site) {

}

list<string> HttpClient::GetCookiesInfo()
{
	list<string> cookiesInfo;

	CURL *curl = curl_easy_init();
	if (NULL != curl)
	{
		curl_easy_setopt(curl, CURLOPT_SHARE, sh);

		struct curl_slist *cookies = NULL;
		CURLcode res = curl_easy_getinfo(curl, CURLINFO_COOKIELIST, &cookies);
		if (CURLE_OK == res)
		{
			int i = 0;
			curl_slist* cookies_item = NULL;
			for (i = 0, cookies_item = cookies;
				cookies_item != NULL;
				i++, cookies_item = cookies_item->next)
			{
				if (NULL != cookies_item->data
					&& strlen(cookies_item->data) > 0)
				{
					FileLog(LIVESHOW_HTTP_LOG, "HttpClient::GetCookiesInfo() cookies_item->data:%s", cookies_item->data);

					cookiesInfo.push_back(cookies_item->data);
				}
			}
		}

		if (NULL != cookies)
		{
			curl_slist_free_all(cookies);
		}

		curl_easy_cleanup(curl);
	}

	return cookiesInfo;
}

// 设置cookies
void HttpClient::SetCookiesInfo(const list<string>& cookies)
{
	CURL *curl = curl_easy_init();
	if (NULL != curl)
	{
		curl_easy_setopt(curl, CURLOPT_SHARE, sh);

		string cookiesInfo("");
		for (list<string>::const_iterator iter = cookies.begin();
			iter != cookies.end();
			iter++)
		{
			curl_easy_setopt(curl, CURLOPT_COOKIELIST, (*iter).c_str());
		}

		curl_easy_cleanup(curl);
	}
}

// 获取所有域名的cookieItem
list<CookiesItem> HttpClient::GetCookiesItem()
{
	list<CookiesItem> cookiesItem;

	CURL *curl = curl_easy_init();
	if (NULL != curl)
	{
		curl_easy_setopt(curl, CURLOPT_SHARE, sh);

		struct curl_slist *cookies = NULL;
		CURLcode res = curl_easy_getinfo(curl, CURLINFO_COOKIELIST, &cookies);
		if (CURLE_OK == res)
		{
			int i = 0;
			curl_slist* cookies_item = NULL;
			for (i = 0, cookies_item = cookies;
				cookies_item != NULL;
				i++, cookies_item = cookies_item->next)
			{

				int j = 0;
//				bool bFlag = false;
				char *p = strtok(cookies_item->data, "\t");
				CookiesItem item;
				while(p != NULL){
					switch(j){
						case 0:
                            if(strncmp(p, "#HttpOnly_", 10) == 0) {
                                p += 10;
                            }
							item.m_domain = p;
							break;
						case 1:
							item.m_accessOtherWeb = p;
							break;
						case 2:
							item.m_symbol = p;
							break;
						case 3:
							item.m_isSend = p;
							break;
						case 4:
							item.m_expiresTime = p;
							break;
						case 5:
							item.m_cName = p;
							break;
						 case 6:
							item.m_value = p;
							break;
						 default:break;
					}
	
					j++;
					p = strtok(NULL,"\t");
				}

				if (NULL != cookies_item->data
					&& strlen(cookies_item->data) > 0)
				{
					FileLog(LIVESHOW_HTTP_LOG,
                            "HttpClient::GetCookiesInfo( "
                            "cookies_item->data : %s "
                            ")",
                            cookies_item->data
                            );

					cookiesItem.push_back(item);

				}

			}
		}

		if (NULL != cookies)
		{
			curl_slist_free_all(cookies);
		}

		curl_easy_cleanup(curl);
	}

	return cookiesItem;
}

string HttpClient::GetCookies(string site) {
	string cookie = "";
	FileLog(LIVESHOW_HTTP_LOG, "HttpClient::GetCookies( site : %s )", site.c_str());

	CURL *curl = curl_easy_init();
	curl_easy_setopt(curl, CURLOPT_URL, site.c_str());
	curl_easy_setopt(curl, CURLOPT_SHARE, sh);

	CURLcode res;
	struct curl_slist *cookies = NULL;
	struct curl_slist *next = NULL;
	int i;

	res = curl_easy_getinfo(curl, CURLINFO_COOKIELIST, &cookies);
	if (res == CURLE_OK) {
		next = cookies, i = 0;
		while ( next != NULL ) {
			FileLog(LIVESHOW_HTTP_LOG, "HttpClient::GetCookies( cookies[%d] : %s )", i++, next->data);

			/**
			 *
			 * www.example.com :	The domain that the cookie applies to
    		 * FALSE :				can other webservers within www.someURL.com access this cookie?
    		 * 						If there was a webserver at xxx.www.someURL.com, could it see this cookie?
    		 * 						If the domain begin with \u201c.\u201d, this value is TRUE
			 * / :					more restrictions on what paths on www.someURL.com can see this cookie.
			 * 						Anything here and under can see the cookie. / is the least restrictive,
			 * 						meaning that any (and all) requests from www.someURL.com get the cookie header sent.
    		 * FALSE :				Do we have to be coming in on https to send the cookie?
    		 * 0 :					expiration time. zero probably means that it never expires,
    		 * 						or that it is good for as long as this session lasts.
    		 * 						A number like 1420092061 would correspond to a number of seconds since the epoch (Jan 1, 1970).
    		 * 						If this value equal to 0, cookie don\u2019t expire
    		 * CNAME :				The name of the cookie variable that will be send to the server.
    		 * value :				cookie value that will be sent. Might be comma separated list of terms,
    		 * 						or could just be a word.. Hard to say. Depends on the server.
			 *
			 */
			int j = 0;
			bool bFlag = false;
			char *p = strtok(next->data, "\t");
			while(p != NULL) {
//				FileLog(LIVESHOW_HTTP_LOG, "HttpClient::GetCookies( p[%d] : %s )", j, p);
				switch(j) {
				case 0:{
                    if(strncmp(p, "#HttpOnly_", 10) == 0) {
                        p += 10;
                    }
                    
					if( strcmp(p, site.c_str()) != 0 ) {
						// not current site
						bFlag = true;
					}
				}break;
				case 5:{
					cookie += p;
					cookie += "=";
				}break;
				case 6:{
					cookie += p;
					cookie += ";";
				}break;
				default:break;
				}

				if( bFlag ) {
					break;
				}

				j++;
				p = strtok(NULL, "\t");
			}

			next = next->next;
		}

		if( cookies != NULL ) {
			curl_slist_free_all(cookies);
		}
	}
	curl_easy_cleanup(curl);

	FileLog(LIVESHOW_HTTP_LOG, "HttpClient::GetCookies( cookie : %s )", cookie.c_str());

	return cookie;
}

void HttpClient::SetCallback(IHttpClientCallback *callback){
	mpIHttpClientCallback = callback;
}

string HttpClient::GetUrl() const {
	return mUrl;
}
string HttpClient::GetContentType() const
{
	return mContentType;
}

// 获取上传ContentLength
double HttpClient::GetUploadContentLength() const
{
//	double dContentLength = 0.0;
//	CURLcode res = curl_easy_getinfo(mpCURL, CURLINFO_CONTENT_LENGTH_UPLOAD, &dContentLength);
//	if (res != CURLE_OK) {
//		dContentLength = 0.0;
//	}
	return mdUploadTotal;
}

// 获取已上传的数据长度
double HttpClient::GetUploadDataLength() const
{
//	double dUploadDataLength = 0.0;
//	CURLcode res = curl_easy_getinfo(mpCURL, CURLINFO_SIZE_UPLOAD, &dUploadDataLength);
//	if (res != CURLE_OK) {
//		dUploadDataLength = 0.0;
//	}
	return mdUploadLast;
}

// 获取下载ContentLength
double HttpClient::GetDownloadContentLength() const
{
//	double dContentLength = 0.0;
//	CURLcode res = curl_easy_getinfo(mpCURL, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &dContentLength);
//	if (res != CURLE_OK) {
//		dContentLength = 0.0;
//	}
	return mdDownloadTotal;
}

// 获取已下载的数据长度
double HttpClient::GetDownloadDataLength() const
{
//	double dDownloadDataLength = 0.0;
//	CURLcode res = curl_easy_getinfo(mpCURL, CURLINFO_SIZE_DOWNLOAD, &dDownloadDataLength);
//	if (res != CURLE_OK) {
//		dDownloadDataLength = 0.0;
//	}
	return mdDownloadLast;
}

void HttpClient::Stop() {
	FileLog(LIVESHOW_HTTP_LOG, "HttpClient::Stop()");

	mUrl = "";
	mbStop = true;
}

void HttpClient::Init(string url) {
    FileLog(LIVESHOW_HTTP_LOG, "HttpClient::Init( url : %s this：%s) ", url.c_str(), this);
	mUrl = url;
}

bool HttpClient::Request(const HttpEntiy* entiy) {
    FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_MSG, "HttpClient::Request( this : %p, url : %s )", this, mUrl.c_str());
	bool bFlag = true;

	CURLcode res;

	mContentType = "";
	mContentLength = -1;

	mbStop = false;
	mdUploadTotal = -1;
	mdUploadLast = -1;
	mdUploadLastTime = -1;
	mdDownloadTotal = -1;
	mdDownloadLast = INVALID_DOWNLOAD;
	mdDownloadLastTime = INVALID_DOWNLOADLASTTIME;
    mdDownloadTimeout = entiy->mDownloadTimeout;

	if( mpCURL == NULL ) {
		mpCURL = curl_easy_init();
	}


	curl_easy_setopt(mpCURL, CURLOPT_URL, mUrl.c_str());
	curl_easy_setopt(mpCURL, CURLOPT_SHARE, sh);

    if( gProxyUrl.length() > 0 ) {
        curl_easy_setopt(mpCURL, CURLOPT_PROXY, gProxyUrl.c_str());
    }
    
    // 支持重定向
    curl_easy_setopt(mpCURL, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(mpCURL, CURLOPT_POSTREDIR, CURL_REDIR_POST_ALL);
    curl_easy_setopt(mpCURL, CURLOPT_REDIR_PROTOCOLS, CURLPROTO_ALL);
    
	// 处理http body函数
	curl_easy_setopt(mpCURL, CURLOPT_WRITEFUNCTION, CurlHandle);
	curl_easy_setopt(mpCURL, CURLOPT_WRITEDATA, this);

	// deal with progress
	curl_easy_setopt(mpCURL, CURLOPT_NOPROGRESS, 0L);
	curl_easy_setopt(mpCURL, CURLOPT_PROGRESSFUNCTION, CurlProgress);
	curl_easy_setopt(mpCURL, CURLOPT_PROGRESSDATA, this);

	string host = mUrl;
	std::size_t index = mUrl.find("http://");
	if( index != string::npos ) {
		host = host.substr(strlen("http://"), host.length() - strlen("http://"));
		index = host.find("/");
		if( index != string::npos ) {
			host = host.substr(0, index);
		}
	}

	string cookie = GetCookies(host);
	FileLog(LIVESHOW_HTTP_LOG, "HttpClient::Request( Cookie Send : %s )", cookie.c_str());
	// Send cookies
//    curl_easy_setopt(mpCURL, CURLOPT_COOKIEFILE, COOKIES_FILE.c_str());

    /*
     * May be cause crash when call curl_easy_cleanup
     * Add by Max 2018/02/08
     * @description
     * https://curl.haxx.se/libcurl/c/CURLOPT_CONNECTTIMEOUT.html
     * https://curl.haxx.se/libcurl/c/CURLOPT_NOSIGNAL.html
     */
    // 设置连接超时(如果是上传文件需要设置时间，默认是20秒)
	curl_easy_setopt(mpCURL, CURLOPT_CONNECTTIMEOUT, entiy->mConnectTimeout);
//	// 设置执行超时
//	curl_easy_setopt(mpCURL, CURLOPT_TIMEOUT, 30L);
	// 设置不抛退出信号量
	curl_easy_setopt(mpCURL, CURLOPT_NOSIGNAL, 1L);

	// add by samson 2015-03-18 增加公共http User-Agent
	curl_easy_setopt(mpCURL, CURLOPT_USERAGENT, USER_AGENT);
     curl_easy_setopt(mpCURL, CURLOPT_FOLLOWLOCATION, 1);

	if( entiy != NULL ) {
		if( !entiy->mIsGetMethod ) {
			curl_easy_setopt(mpCURL, CURLOPT_POST, 1);
		}

//        if( entiy->mbSaveCookie ) {
//            // Save cookies
//            curl_easy_setopt(mpCURL, CURLOPT_COOKIEJAR, COOKIES_FILE.c_str());
//        }
//
//		FileLog(LIVESHOW_HTTP_LOG, "HttpClient::Request( mIsGetMethod : %s, mbSaveCookie : %s)",
//				entiy->mIsGetMethod?"true":"false", entiy->mbSaveCookie?"true":"false");

	}
	// 处理https
    // 不检查服务器证书
    curl_easy_setopt(mpCURL, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(mpCURL, CURLOPT_SSL_VERIFYHOST, 0);

    if( mUrl.find("https") != string::npos ) {
		FileLog(LIVESHOW_HTTP_LOG, "HttpClient::Request( Try to connect with ssl )");
//		// 不检查服务器证书
//		curl_easy_setopt(mpCURL, CURLOPT_SSL_VERIFYPEER, 0L);
//		curl_easy_setopt(mpCURL, CURLOPT_SSL_VERIFYHOST, 0);
		// 不设置客户端证书和私钥
//		curl_easy_setopt(mpCURL, CURLOPT_SSLCERTTYPE, "PEM");
//		curl_easy_setopt(mpCURL , CURLOPT_SSL_CTX_FUNCTION, Curl_SSL_Handle);
//		curl_easy_setopt(mpCURL , CURLOPT_SSL_CTX_DATA, this);
	}

	struct curl_slist* pList = NULL;
	struct curl_httppost* pPost = NULL;
	struct curl_httppost* pLast = NULL;
    string postData("");

	if( entiy != NULL ) {
		/* Basic Authentication */
		if( entiy->mAuthorization.length() > 0 ) {
			curl_easy_setopt(mpCURL, CURLOPT_USERPWD, entiy->mAuthorization.c_str());
			FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_MSG, "HttpClient::Request( this : %p, Add authentication header : [%s] )", this, entiy->mAuthorization.c_str());
		}

		/* Headers */
		for( HttpMap::const_iterator itr = entiy->mHeaderMap.begin(); itr != entiy->mHeaderMap.end(); itr++ ) {
			string header = itr->first + ": " + itr->second;
			pList = curl_slist_append(pList, header.c_str());
			FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_MSG, "HttpClient::Request( this : %p, Add header : [%s] )", this, header.c_str());
		}
        
        if( !entiy->mNoHeader ) {
            // add by Samson 2015-04-23, add "device_type" to http header
            pList = curl_slist_append(pList, DEVICE_TYPE);
            pList = curl_slist_append(pList, QN_DEVICE_TYPE);
        }

        if( entiy->mRawData.length() > 0 && !entiy->mIsGetMethod ) {
            curl_easy_setopt(mpCURL, CURLOPT_POSTFIELDS, entiy->mRawData.c_str());
        } else if (entiy->mFileMap.empty() && !entiy->mContentMap.empty() && !entiy->mIsGetMethod) {
            /* Contents */
            for( HttpMap::const_iterator itr = entiy->mContentMap.begin(); itr != entiy->mContentMap.end(); itr++ ) {
                if (!postData.empty()) {
                    postData += "&";
                }
                char* tempBuffer = curl_easy_escape(mpCURL, itr->second.c_str(), itr->second.length());
                if (NULL != tempBuffer) {
                    postData += itr->first;
                    postData += "=";
                    postData += tempBuffer;
                    
                    curl_free(tempBuffer);
                }

                FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_MSG, "HttpClient::Request( this : %p, Add content : [%s : %s] )", this, itr->first.c_str(), itr->second.c_str());
            }
            
            curl_easy_setopt(mpCURL, CURLOPT_POSTFIELDS, postData.c_str());
        } else {
            /* Contents */
            for( HttpMap::const_iterator itr = entiy->mContentMap.begin(); itr != entiy->mContentMap.end(); itr++ ) {
                curl_formadd(&pPost, &pLast, CURLFORM_COPYNAME, itr->first.c_str(),
                        CURLFORM_COPYCONTENTS, itr->second.c_str(), CURLFORM_END);
                FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_MSG, "HttpClient::Request( this : %p, Add content : [%s : %s] )", this, itr->first.c_str(), itr->second.c_str());
            }

            /* Files */
            for( FileMap::const_iterator itr = entiy->mFileMap.begin(); itr != entiy->mFileMap.end(); itr++ ) {
                curl_formadd(&pPost, &pLast, CURLFORM_COPYNAME, "filename",
                        CURLFORM_COPYCONTENTS, itr->first.c_str(), CURLFORM_END);

                curl_formadd(&pPost, &pLast,
                        CURLFORM_COPYNAME, itr->first.c_str(),
                        CURLFORM_FILE, itr->second.fileName.c_str(),
                        CURLFORM_CONTENTTYPE, itr->second.mimeType.c_str(),
                        CURLFORM_END);

                FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_MSG, "HttpClient::Request( this : %p, Add file filename : [%s], content [%s : %s,%s] )"
                        , this, itr->first.c_str(), itr->first.c_str(), itr->second.fileName.c_str(), itr->second.mimeType.c_str());
            }
            
            if( pPost != NULL ) {
                curl_easy_setopt(mpCURL, CURLOPT_HTTPPOST, pPost);
            }
        }

		if( pList != NULL ) {
			curl_easy_setopt(mpCURL, CURLOPT_HTTPHEADER, pList);
		}
	}

	FileLog(LIVESHOW_HTTP_LOG, "HttpClient::Request( curl_easy_perform )");
	res = curl_easy_perform(mpCURL);

	double totalTime = 0;
	curl_easy_getinfo(mpCURL, CURLINFO_TOTAL_TIME, &totalTime);
	FileLog(LIVESHOW_HTTP_LOG, "HttpClient::Request( this : %p, totalTime : %f second )", this, totalTime);

    char *urlp = NULL;
    curl_easy_getinfo(mpCURL, CURLINFO_REDIRECT_URL, &urlp);
    long count;
    curl_easy_getinfo(mpCURL, CURLINFO_REDIRECT_COUNT, &count);
    FileLog(LIVESHOW_HTTP_LOG, "HttpClient::Request( this : %p, Redirect url : %s, count : %ld )", this, urlp, count);
    
    long http_code;
    curl_easy_getinfo(mpCURL, CURLINFO_HTTP_CODE, &http_code);
    FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_STAT, "HttpClient::Request( this : %p, mpCURL : %p, http_code : %ld )", this, mpCURL, http_code);
    
	if( mpCURL != NULL ) {
		curl_easy_cleanup(mpCURL);
		mpCURL = NULL;
	}

	if( pList != NULL ) {
		curl_slist_free_all(pList);
	}
    
	if( pPost != NULL ) {
		curl_formfree(pPost);
	}

	cookie = GetCookies(host);
	FileLog(LIVESHOW_HTTP_LOG, "HttpClient::Request( this : %p, Cookie Recv : %s )", this, cookie.c_str());

    // alex, 2019-09-21, 当res = CURLE_ABORTED_BY_CALLBACK 和不是下载文件时，都算http成功了
    if (res == CURLE_ABORTED_BY_CALLBACK && !entiy->mIsDownloadFile) {
        mIsAborted = true;
    }
    bFlag = (res == CURLE_OK) || (res == CURLE_ABORTED_BY_CALLBACK && !entiy->mIsDownloadFile);
    FileLevelLog(LIVESHOW_HTTP_LOG, KLog::LOG_MSG, "HttpClient::Request( this : %p, bFlag : %s , res : %d )", this, bFlag?"true":"false", res);

	return bFlag;
}

void HttpClient::HttpHandle(void *buffer, size_t size, size_t nmemb) {
	FileLog(LIVESHOW_HTTP_LOG, "HttpClient::HttpHandle( size : %d , nmemb : %d )", size, nmemb);
	if( mContentType.length() == 0 ) {
		char *ct = NULL;
		CURLcode res = curl_easy_getinfo(mpCURL, CURLINFO_CONTENT_TYPE, &ct);

		if( res == CURLE_OK ) {
			if (NULL != ct) {
				mContentType = ct;
			}
			FileLog(LIVESHOW_HTTP_LOG, "HttpClient::HttpHandle( Content-Type : %s )", mContentType.c_str());
		}

		res = curl_easy_getinfo(mpCURL, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &mContentLength);
		if (res != CURLE_OK) {
			mContentLength = -1;
		}
		FileLog(LIVESHOW_HTTP_LOG, "HttpClient::HttpHandle( Content-Length : %.0f )", mContentLength);
	}

	int len = size * nmemb;
	if( mpIHttpClientCallback ) {
		mpIHttpClientCallback->OnReceiveBody(this, (const char*)buffer, len);
	}
}

size_t HttpClient::CurlHandle(void *buffer, size_t size, size_t nmemb, void *data) {
	HttpClient *client = (HttpClient *)data;
	client->HttpHandle(buffer, size, nmemb);
	return size * nmemb;
}

size_t HttpClient::CurlProgress(void *data, double downloadTotal, double downloadNow, double uploadTotal, double uploadNow) {
	HttpClient *client = (HttpClient *)data;
	return client->HttpProgress(downloadTotal, downloadNow, uploadTotal, uploadNow);
}

size_t HttpClient::HttpProgress(double downloadTotal, double downloadNow, double uploadTotal, double uploadNow) {
//    FileLog(LIVESHOW_HTTP_LOG, "HttpClient::HttpProgress( "
//            "downloadTotal: %.0f, "
//            "downloadNow : %.0f, "
//            "uploadTotal : %.0f, "
//            "uploadNow : %.0f, "
//            "mbStop : %s "
//            ")",
//            downloadTotal,
//            downloadNow,
//            uploadTotal,
//            uploadNow,
//            mbStop?"true":"false"
//            );
 //   FileLog(LIVESHOW_HTTP_LOG, "HttpClient::HttpProgress()");

	double totalTime = 0;
	curl_easy_getinfo(mpCURL, CURLINFO_TOTAL_TIME, &totalTime);
//	FileLog(LIVESHOW_HTTP_LOG, "HttpClient::HttpProgress( totalTime : %f second )", totalTime);

	// mark the upload progress
	mdUploadTotal = uploadTotal;
	mdUploadLast = uploadNow;

	// waiting for upload finish, no upload timeout
    // 解决有回调但是没有数据到会进入死循环
	if( uploadNow == uploadTotal ) {
//        if( mdDownloadLast == downloadNow ) {
//            if( totalTime - mdDownloadLastTime > DWONLOAD_TIMEOUT ) {
//                // DWONLOAD_TIMEOUT no receive data, download timeout
//                FileLog(LIVESHOW_HTTP_LOG, "HttpClient::HttpProgress( download timeout )");
//                mbStop = true;
//            }
//        } else {
//            // mark the download progress
//            mdDownloadLast = downloadNow;
//            mdDownloadLastTime = totalTime;
//
//        }
    
        
//		if( downloadTotal != downloadNow && mdDownloadLast != -1 &&  mdDownloadLast == downloadNow ) {
            if (downloadTotal == 0 || downloadTotal != downloadNow) {
                if (mdDownloadLast != 0     && mdDownloadLast == downloadNow) {
                    if( totalTime - mdDownloadLastTime > mdDownloadTimeout ) {
                        // DWONLOAD_TIMEOUT no receive data, download timeout
                        FileLog(LIVESHOW_HTTP_LOG, "HttpClient::HttpProgress( download timeout )");
                        mbStop = true;
                    }
                }else {
                    // mark the download progress
                    mdDownloadLast = downloadNow;
                    mdDownloadLastTime = totalTime;
                }
                //            }

        }
    }

	return mbStop;
}
