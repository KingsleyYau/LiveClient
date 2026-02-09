/*
 * HttpTester.h
 *
 *  Created on: 2019年3月4日
 *      Author: max
 */

#ifndef HTTP_TESTER_HTTPTESTER_H_
#define HTTP_TESTER_HTTPTESTER_H_

#include <httpclient/HttpClient.h>

namespace coollive {

class HttpTester : public IHttpClientCallback {
public:
	HttpTester();
	virtual ~HttpTester();

public:
	void Test();

	void OnReceiveBody(HttpClient* client, const char* buf, int size);
};

} /* namespace coollive */

#endif /* HTTP_TESTER_HTTPTESTER_H_ */
