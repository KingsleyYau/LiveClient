/*
 * config.h
 *
 *  Created on: 2014/10/27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef COMMON_CONFIG_H_
#define COMMON_CONFIG_H_

 /*
  * TCP_KEEPIDLE for Android in <linux/tcp.h>
  * TCP_KEEPALIVE for iOS in <netinet/tcp.h>
  */
#if !defined(TCP_KEEPIDLE) && defined(TCP_KEEPALIVE)
#define TCP_KEEPIDLE TCP_KEEPALIVE
#endif

#endif /* COMMON_CONFIG_H_ */
