/*
 * author: Samson.Fan
 *   date: 2015-03-30
 *   file: ZBCounter.cpp
 *   desc: 计数器（带锁）
 */

#include <stdio.h>
#include "ZBCounter.h"
#include <common/IAutoLock.h>
#include <common/CheckMemoryLeak.h>

ZBCounter::ZBCounter(void)
{
	m_begin = 0;
	m_count = m_begin;
	m_lock = NULL;
	m_bInit = false;
}

ZBCounter::~ZBCounter(void)
{
	Uninit();
}

// 初始化
bool ZBCounter::Init(int begin, int step)
{
	if (!m_bInit) {
		m_lock = IAutoLock::CreateAutoLock();
		if (NULL != m_lock) {
			m_bInit = m_lock->Init();
		}

		if (m_bInit) {
			m_begin = begin;
			// 设置步长
			SetStep(step);
			// 重置计数器
			Reset();
		}
	}
	return m_bInit;
}

void ZBCounter::Uninit()
{
	IAutoLock::ReleaseAutoLock(m_lock);
	m_lock = NULL;

	m_bInit = false;
}

// 重置计数
void ZBCounter::Reset()
{
	if (m_bInit) {
		m_lock->Lock();
		m_count = m_begin;
		m_lock->Unlock();
	}
}
	
// 获取当前计数
int ZBCounter::GetCount()
{
	int count = 0;
	if (m_bInit) {
		m_lock->Lock();
		count = m_count;
		m_lock->Unlock();
	}
	return count;
}

// 设置步长
void ZBCounter::SetStep(int step)
{
	if (m_bInit) {
		m_lock->Lock();
		m_step = step;
		m_lock->Unlock();
	}
}

// 获取步长
int ZBCounter::GetStep()
{
	int step = 0;
	if (m_bInit) {
		m_lock->Lock();
		step = m_step;
		m_lock->Unlock();
	}
	return step;
}

// 获取计数并加步长
int ZBCounter::GetAndIncrement()
{
	int count = 0;
	if (m_bInit) {
		m_lock->Lock();
		count = m_count;
		m_count += m_step;
		if (m_count < 0) {
			m_count = m_count * (-1);
		}
		m_lock->Unlock();
	}
	return count;
}

// 获取计数并减步长
int ZBCounter::GetAndDecrement()
{
	int count = 0;
	if (m_bInit) {
		m_lock->Lock();
		count = m_count;
		m_count -= m_step;
		if (m_count < 0) {
			m_count = m_count * (-1);
		}
		m_lock->Unlock();
	}
	return count;
}

// 加步长并获取计数
int ZBCounter::IncrementAndGet()
{
	int count = 0;
	if (m_bInit) {
		m_lock->Lock();
		m_count += m_step;
		if (m_count < 0) {
			m_count = m_count * (-1);
		}
		count = m_count;
		m_lock->Unlock();
	}
	return count;
}

// 减步长并获取计数
int ZBCounter::DecrementAndGet()
{
	int count = 0;
	if (m_bInit) {
		m_lock->Lock();
		m_count -= m_step;
		if (m_count < 0) {
			m_count = m_count * (-1);
		}
		count = m_count;
		m_lock->Unlock();
	}
	return count;
}

// 判断是否无效的值
bool ZBCounter::IsInvalidValue(int value) const
{
	return value < 0;
}

// 获取无效的值
int ZBCounter::GetInvalidValue() const
{
	return -1;
}
