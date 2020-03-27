# Generates the memory configuration to be stored in block ram, corresponding to the DVD screensaver image.
# Converts each pixels of the sample image to a single bit, '1' for the background and '0' for the colour 
# Opens a sample image of the dvd logo (obtained from google images), downsample to 144*78 pixels (keeping aspect ratio the same)
# assign pixel value based off colour, then write to file.

from PIL import Image
import numpy as np

image_width = 144
image_height = 78

img = Image.open('dvd_logo.jpg')
img = img.convert('L')
img = img.resize((image_width, image_height), Image.ANTIALIAS) 
# img.show()

img_arr = np.array(img)


data = np.zeros((image_height, image_width) ,dtype=np.int8)
data[img_arr > 137] = 1 

#based on inspection of image - change these individual pixels
#fix 'E'
data[54,83] = 0
data[52,80] = 1
#fix 'O'
data[54, 98:102] = 0
data[55, 97:103] = 0
data[60,104] = 0
#fix 'D'
data[52,71] = 1
#fix semicircle
data[47,:] = 1;

data = np.flip(data,1)
np.savetxt("data.txt", data, fmt='%s', delimiter='')







