import serial

ser = serial.Serial("COM4", 9600, timeout = 1)
key = "edfdb257cb37cdf182c5455b0c0efebb"
plaintext = "1695fe475421cace3557daca01f445ff"

ser.write(bytearray.fromhex(key))
ser.write(bytearray.fromhex(plaintext))

ciphertext = ser.read(16)
print(ciphertext.hex())
# 7888beae6e7a426332a7eaa2f808e637
ser.close()