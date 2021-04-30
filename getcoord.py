# importing the module
import cv2,sys

v = 0

# function to display the coordinates of
# of the points clicked on the image
def click_event(event, x, y, flags, params):
	global v
	if(v==10):
		sys.exit(0)
	# checking for left mouse clicks
	if event == cv2.EVENT_LBUTTONDOWN:

		# displaying the coordinates
		# on the Shell
		
		fh = open('data.txt', 'a')
		print(x, ' ', y)
		fh.write('$ns at 0.0 "$node(' + str(v) + ') setdest ' + str(x) + ' ' + str(y) + ' 3000.0"\n')
		fh.close()
		# displaying the coordinates
		# on the image window
		font = cv2.FONT_HERSHEY_SIMPLEX
		cv2.putText(img, str(x) + ',' +
					str(y), (x,y), font,
					1, (255, 0, 0), 2)
		cv2.imshow('image', img)
		v += 1

		

	# checking for right mouse clicks	
	if event==cv2.EVENT_RBUTTONDOWN:
		
		# displaying the coordinates
		# on the Shell
		fh = open('data.txt', 'a')
		print(x, ' ', y)
		fh.write('$ns at 0.0 "$node(' + str(v) + ') setdest ' + str(x) + ' ' + str(y) + ' 3000.0"\n')
		fh.close()
		# displaying the coordinates
		# on the image window
		font = cv2.FONT_HERSHEY_SIMPLEX
		b = img[y, x, 0]
		g = img[y, x, 1]
		r = img[y, x, 2]
		# img = cv2.circle(img, (x, y), 5, (255, 88, 77), 1)
		cv2.putText(img, str(b) + ',' +
					str(g) + ',' + str(r),
					(x,y), font, 1,
					(255, 255, 0), 2)
		cv2.imshow('image', img)
		v += 1

		

# driver function
if __name__=="__main__":

	# reading the image
	img = cv2.imread('sample.jpg', 1); fh = open('data.txt', 'w'); fh.write(''); fh.close()
	# displaying the image
	cv2.imshow('image', img)

	# setting mouse hadler for the image
	# and calling the click_event() function
	cv2.setMouseCallback('image', click_event)

	# wait for a key to be pressed to exit
	cv2.waitKey(0)

	# close the window
	cv2.destroyAllWindows()
