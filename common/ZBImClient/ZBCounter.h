/*
 * author: alex
 *   date: 2018-03-02
 *   file: ZBCounter.h
 *   desc: 计数器（带锁）
 */

#pragma once

class IAutoLock;
class ZBCounter
{
public:
	ZBCounter(void);
	virtual ~ZBCounter(void);

public:
	// 初始化
	bool Init(int begin = 0, int step = 1);
	// 重置计数
	void Reset();
	// 获取当前计数
	int GetCount();
	// 设置步长
	void SetStep(int step);
	// 获取步长
	int GetStep();

	// 获取计数并加步长
	int GetAndIncrement();
	// 获取计数并减步长
	int GetAndDecrement();

	// 加步长并获取计数
	int IncrementAndGet();
	// 减步长并获取计数
	int DecrementAndGet();

	// 判断是否无效的
	bool IsInvalidValue(int value) const;
	// 获取无效的值
	int GetInvalidValue() const;

private:
	void Uninit();

private:
	int			m_begin;	// 起始值
	int			m_step;		// 步长
	int			m_count;	// 计数
	IAutoLock*	m_lock;		// 锁
	bool		m_bInit;	// 初始化标志
};
