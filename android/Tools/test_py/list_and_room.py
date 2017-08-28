# File: list_and_room.py
# Version: V1.0
# Author: Samson

# -------------------------------------------------------------------------------------
def room_main():
	room_test()
	room_list_test()

# test list(more, refresh, enter room, out room)
def room_list_test():
	print('testing room list!')
	for i in range(0, 1000):
		print('room list ' + str(i) + ' times')
		# more
		for k in range(0, 10):
			drag_bottom();
		MonkeyRunner.sleep(2)
		# refresh
		for k in range(0, 10):
			drag_top();
		MonkeyRunner.sleep(1)
		# enter room
		enter_room()
		# leave room
		leave_room()
		
# test room(enter room, favorite, send text message, send pop message, send gift, send big gift, out room)
def room_test():
	print('testing room!')
	for i in range(0, 1000):
		print('---- room ' + str(i) + ' times')
		enter_room()
		room_send_big_gift()
		room_send_gift()
		room_send_favorite()
		room_send_text_message()
		room_send_pop_message()
		leave_room()
		
def enter_room():
	print('enter room')
	drag_bottom()
	MonkeyRunner.sleep(1)
	my_touch(500, 500, 'DOWN_AND_UP')
	MonkeyRunner.sleep(2)
	
def leave_room():
	print('leave room')
	device.press('KEYCODE_BACK', MonkeyDevice.DOWN_AND_UP) 
	MonkeyRunner.sleep(1)
	drag_top()
	drag_top()
	MonkeyRunner.sleep(1)
		
def room_send_big_gift():
	print('send big gift')
	my_touch(995, 1845, 'DOWN_AND_UP')
	MonkeyRunner.sleep(1)
	#print('drag now')
	my_drag(800, 1480, 60, 1480, 0.3, 10)
	MonkeyRunner.sleep(2)
	#print('select gitf')
	my_touch(415, 1355, 'DOWN_AND_UP')
	MonkeyRunner.sleep(1)
	#print('send gift')
	my_touch(955, 1855, 'DOWN_AND_UP')
	MonkeyRunner.sleep(1)
	#print('reset list')
	my_drag(60, 1480, 800, 1480, 0.3, 10)
	MonkeyRunner.sleep(1)
	my_touch(500, 1000, 'DOWN_AND_UP')
	MonkeyRunner.sleep(2)
	
def room_send_gift():
	print('send gift')
	my_touch(995, 1845, 'DOWN_AND_UP')
	MonkeyRunner.sleep(1)
	my_touch(405, 1355, 'DOWN_AND_UP')
	MonkeyRunner.sleep(1)
	my_touch(955, 1855, 'DOWN_AND_UP')
	MonkeyRunner.sleep(1)
	my_touch(500, 1000, 'DOWN_AND_UP')
	MonkeyRunner.sleep(2)
	
def room_send_favorite():
	print('send favorite')
	my_touch(500, 1000, 'DOWN_AND_UP')
	my_touch(500, 1000, 'DOWN_AND_UP')
	MonkeyRunner.sleep(1)
	
def room_send_text_message():
	print('send text message')
	my_touch(400, 1860, 'DOWN_AND_UP')
	MonkeyRunner.sleep(2)
	device.type('hi')
	MonkeyRunner.sleep(1)
	my_touch(930, 1070, 'DOWN_AND_UP')
	MonkeyRunner.sleep(1)
	device.press('KEYCODE_BACK', MonkeyDevice.DOWN_AND_UP)
	MonkeyRunner.sleep(1)
	
def room_send_pop_message():
	print('send pop message')
	my_touch(400, 1860, 'DOWN_AND_UP')
	MonkeyRunner.sleep(2)
	my_touch(100, 1100, 'DOWN_AND_UP')
	MonkeyRunner.sleep(1)
	device.type('pop')
	MonkeyRunner.sleep(1)
	my_touch(930, 1070, 'DOWN_AND_UP')
	MonkeyRunner.sleep(1)
	my_touch(100, 1100, 'DOWN_AND_UP')
	MonkeyRunner.sleep(1)
	device.press('KEYCODE_BACK', MonkeyDevice.DOWN_AND_UP)
	MonkeyRunner.sleep(1)
		
# ------------------------------------------------
def getCurrMonitorX(x):
	des_x = (current_monitor_x * x / design_monitor_x);
	return des_x
	
def getCurrMonitorY(y):
	des_y = (current_monitor_y * y / design_monitor_y);
	return des_y

def my_touch(x, y, opt):
	des_x = getCurrMonitorX(x);
	des_y = getCurrMonitorY(y);
	device.touch(des_x, des_y, opt)
	
def my_drag(x1, y1, x2, y2, duration, steps):
	des_x1 = getCurrMonitorX(x1);
	des_y1 = getCurrMonitorY(y1);
	des_x2 = getCurrMonitorX(x2);
	des_y2 = getCurrMonitorY(y2);
	#print('my_drag x1:' + str(des_x1) + ', y1:' + str(des_y1) + ', x2:' + str(des_x2) + ', y2:' + str(des_y2) + ', dur:' + str(duration) + ', steps:' + str(steps))
	device.drag((des_x1,des_y1) ,(des_x2,des_y2) ,duration ,steps)
	
def drag_left():
	device.drag((100,500) ,(600,500) ,0.1 ,10)
		
def drag_right():
	device.drag((600,500) ,(100,500) ,0.1 ,10)
		
def drag_top():
	device.drag((300,300) ,(300,1000) ,0.1 ,10)
		
def drag_bottom():
	device.drag((300,1000) ,(300,300) ,0.1 ,10)

# ------------------------------------------------
	
# improt Monkey module
from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice, MonkeyImage
print('import monkey module ok!')

# connect device
device = MonkeyRunner.waitForConnection()
print('connect ok!')

# define monitor size
design_monitor_x = 1080
design_monitor_y = 1920
current_monitor_x = int(device.getProperty("display.width"))
current_monitor_y = int(device.getProperty("display.height"))

# begin testing lady detail
room_main()