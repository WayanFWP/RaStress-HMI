import serial
import time
import sys

class RadarConnection:
    def __init__(self, cli_port='/dev/ttyUSB0', data_port='/dev/ttyUSB1'):
        self.cli_port_name = cli_port
        self.data_port_name = data_port
        self.cli_serial = None
        self.data_serial = None

    def connect(self):
        try:
            # Standard baud rates for TI mmWave
            self.cli_serial = serial.Serial(self.cli_port_name, 115200)
            self.data_serial = serial.Serial(self.data_port_name, 921600)
            self.data_serial.reset_input_buffer()
            print(f"[INFO] Connected to {self.cli_port_name} and {self.data_port_name}")
        except serial.SerialException as e:
            print(f"[ERROR] Could not open serial ports: {e}")
            sys.exit(1)

    def send_configuration(self, config_lines):
        """Sends the configuration commands line by line to the sensor."""
        if not self.cli_serial:
            return

        print("[INFO] Sending Configuration...")
        for line in config_lines:
            self.cli_serial.write((line + '\n').encode())
            time.sleep(0.03) # Small delay to let sensor process
        print("[INFO] Configuration Sent.")

    def read_into_buffer(self):
        """Reads all available bytes from data port."""
        if self.data_serial and self.data_serial.in_waiting > 0:
            return self.data_serial.read(self.data_serial.in_waiting)
        return b''

    def stop_sensor(self):
        if self.cli_serial:
            self.cli_serial.write(('sensorStop\n').encode())
            print("[INFO] Sensor Stopped")

    def close(self):
        if self.cli_serial: self.cli_serial.close()
        if self.data_serial: self.data_serial.close()
