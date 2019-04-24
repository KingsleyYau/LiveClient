/*
 * HttpTester.cpp
 *
 *  Created on: 2019年3月4日
 *      Author: max
 */

#include "HttpTester.h"

#include <common/KLog.h>

namespace coollive {

HttpTester::HttpTester() {
	// TODO Auto-generated constructor stub
}

HttpTester::~HttpTester() {
	// TODO Auto-generated destructor stub
}

void HttpTester::Test() {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"HttpTester::Test( "
			")"
			);

	HttpClient client;
	HttpEntiy entiy;

	client.Init("https://www.baidu.com");
	client.SetCallback(this);
	client.Request(&entiy);
}

void HttpTester::OnReceiveBody(HttpClient* client, const char* buf, int size) {
	FileLevelLog(
			"rtmpdump",
			KLog::LOG_WARNING,
			"HttpTester::OnReceiveBody( "
			"buf(%d) : %s "
			")",
			size,
			buf
			);
}

} /* namespace coollive */
