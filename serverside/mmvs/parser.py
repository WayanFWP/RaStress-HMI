import numpy as np
import struct

class DataParser:
    def __init__(self):
        # Constants
        self.MAGIC_WORD = np.array([2, 1, 4, 3, 6, 5, 8, 7], dtype='uint8')
        self.MAX_BUFFER_SIZE = 2 ** 15
        
        # Message Types
        self.MMWDEMO_UART_MSG_DETECTED_POINTS = 1
        self.MMWDEMO_UART_MSG_RANGE_PROFILE = 2
        self.MMWDEMO_UART_MSG_VITALSIGN = 6

        # Buffer State
        self.byte_buffer = np.zeros(self.MAX_BUFFER_SIZE, dtype='uint8')
        self.byte_buffer_len = 0

    def parse_stream(self, raw_data):
        """
        Ingests raw bytes, looks for frames, and returns a vitals dictionary if a frame is found.
        """
        byte_vec = np.frombuffer(raw_data, dtype='uint8')
        byte_count = len(byte_vec)
        
        if (self.byte_buffer_len + byte_count) < self.MAX_BUFFER_SIZE:
            self.byte_buffer[self.byte_buffer_len:self.byte_buffer_len + byte_count] = byte_vec
            self.byte_buffer_len += byte_count

        if self.byte_buffer_len < 16:
            return None

        possible_locs = np.where(self.byte_buffer == self.MAGIC_WORD[0])[0]
        start_idx = -1
        
        for loc in possible_locs:
            if loc + 8 > self.byte_buffer_len: break
            check = self.byte_buffer[loc:loc + 8]
            if np.all(check == self.MAGIC_WORD):
                start_idx = loc
                break

        # Align Buffer
        if start_idx >= 0:
            if start_idx > 0:
                self.byte_buffer[:self.byte_buffer_len - start_idx] = self.byte_buffer[start_idx:self.byte_buffer_len]
                self.byte_buffer_len -= start_idx
            
            if self.byte_buffer_len < 12 + 4: return None # Header incomplete
            
            total_packet_len = int.from_bytes(self.byte_buffer[12:16], byteorder='little')
            
            if self.byte_buffer_len >= total_packet_len:
                # We have a full frame! Process it.
                frame_data = self._decode_frame(total_packet_len)
                
                self.byte_buffer[:self.byte_buffer_len - total_packet_len] = self.byte_buffer[total_packet_len:self.byte_buffer_len]
                self.byte_buffer_len -= total_packet_len
                
                return frame_data
        return None

    def _decode_frame(self, total_len):
        idx = 0
        idx += 8 
        idx += 4 
        idx += 4 
        idx += 4 
        frame_number = int.from_bytes(self.byte_buffer[idx:idx + 4], byteorder='little')
        idx += 4
        idx += 4 
        num_detected_obj = int.from_bytes(self.byte_buffer[idx:idx + 4], byteorder='little')
        idx += 4
        num_tlvs = int.from_bytes(self.byte_buffer[idx:idx + 4], byteorder='little')
        idx += 4
        idx += 4 
        vitals = {"frame": frame_number}

        for _ in range(num_tlvs):
            tlv_type = int.from_bytes(self.byte_buffer[idx:idx + 4], byteorder='little')
            idx += 4
            tlv_len = int.from_bytes(self.byte_buffer[idx:idx + 4], byteorder='little')
            idx += 4
            
            if tlv_type == self.MMWDEMO_UART_MSG_VITALSIGN:
                vitals.update(self._parse_vital_tlv(idx))
            
            elif tlv_type == self.MMWDEMO_UART_MSG_RANGE_PROFILE:
                vitals["RangeProfile"] = self._parse_range_profile(idx, tlv_len)
            
            idx += tlv_len

        return vitals

    def _parse_vital_tlv(self, idx):
        v = {}
        # Parsing based on struct definition in docs/C code
        v["rangeBinIndexMax"] = int.from_bytes(self.byte_buffer[idx:idx+2], byteorder='little')
        v["rangeBinIndexPhase"] = int.from_bytes(self.byte_buffer[idx+2:idx+4], byteorder='little')
        v["maxVal"] = struct.unpack('<f', self.byte_buffer[idx+4:idx+8])[0]
        v["processingCyclesOut"] = int.from_bytes(self.byte_buffer[idx+8:idx+12], byteorder='little')
        v["rangeBinStartIndex"] = int.from_bytes(self.byte_buffer[idx+12:idx+14], byteorder='little')
        v["rangeBinEndIndex"] = int.from_bytes(self.byte_buffer[idx+14:idx+16], byteorder='little')
        v["unwrapPhasePeak_mm"] = struct.unpack('<f', self.byte_buffer[idx+16:idx+20])[0]
        v["outputFilterBreathOut"] = struct.unpack('<f', self.byte_buffer[idx+20:idx+24])[0]
        v["outputFilterHeartOut"] = struct.unpack('<f', self.byte_buffer[idx+24:idx+28])[0]
        v["heartRateEst_FFT"] = struct.unpack('<f', self.byte_buffer[idx+28:idx+32])[0]
        v["heartRateEst_FFT_4Hz"] = struct.unpack('<f', self.byte_buffer[idx+32:idx+36])[0] / 2
        v["heartRateEst_xCorr"] = struct.unpack('<f', self.byte_buffer[idx+36:idx+40])[0]        
        v["breathingRateEst_FFT"] = struct.unpack('<f', self.byte_buffer[idx+44:idx+48])[0]
        v["sumEnergyBreathWfm"] = struct.unpack('<f', self.byte_buffer[idx+76:idx+80])[0]
        v["sumEnergyHeartWfm"] = struct.unpack('<f', self.byte_buffer[idx+80:idx+84])[0]
        
        return v

    def _parse_range_profile(self, idx, length):
        # Range profile is array of 16-bit complex numbers (Real(2) + Imag(2) = 4 bytes per bin)
        num_bins = length // 4
        profile = []
        current = idx
        for _ in range(num_bins):
            real = int.from_bytes(self.byte_buffer[current:current+2], byteorder='big', signed=True) # Usually big endian for TI DSP data
            current += 2
            imag = int.from_bytes(self.byte_buffer[current:current+2], byteorder='big', signed=True)
            current += 2
            profile.append((real**2 + imag**2)**0.5)
        return profile