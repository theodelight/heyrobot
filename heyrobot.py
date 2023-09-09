
from flask import Flask, jsonify, request

import usb.core
import usb.util

ARM_VENDOR = 0x1267
ARM_PRODUCT = 0
CMD_DATALEN = 3

def find_arm():
	# Find the device
	arm = usb.core.find(idVendor=ARM_VENDOR, idProduct=ARM_PRODUCT)

	if arm is None:
		raise ValueError('Arm not found')

	if arm.is_kernel_driver_active(0):
		arm.detach_kernel_driver(0)

	return arm

def send_command(arm, command):
	assert len(command) == CMD_DATALEN, "Command length not valid"

	arm.ctrl_transfer(0x40, 6, 0x100, 0, command, CMD_DATALEN)

app = Flask(__name__)
arm = find_arm()

@app.route('/go', methods=['POST'])
def command():
	try:
		cmd = request.json.get('go')
		cmd_bytes = [int(x, 10) for x in cmd]
		send_command(arm, cmd_bytes)
		return jsonify({"message": "Command sent OK"}), 200
	except Exception as e:
		return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
	app.run(debug=True)

