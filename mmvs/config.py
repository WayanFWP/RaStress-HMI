import math

class SensorConfig:
    def __init__(self):
        self.params = {}

    def parse_file(self, config_file_path):
        """Parses the mmWave CLI configuration file."""
        config_lines = []
        
        try:
            with open(config_file_path, 'r') as f:
                lines = f.readlines()
                config_lines = [line.strip() for line in lines if line.strip()]
        except FileNotFoundError:
            raise FileNotFoundError(f"Config file not found: {config_file_path}")

        # Default values
        numRxAnt = 4
        numTxAnt = 2
        
        for line in config_lines:
            split_words = line.split(" ")
            cmd = split_words[0]

            if "profileCfg" in cmd:
                startFreq = float(split_words[2])
                idleTime = float(split_words[3])
                rampEndTime = float(split_words[5])
                freqSlopeConst = float(split_words[8])
                numAdcSamples = int(split_words[10])
                digOutSampleRate = int(split_words[11])
                
                # Round to nearest power of 2
                numAdcSamplesRoundTo2 = 1
                while numAdcSamples > numAdcSamplesRoundTo2:
                    numAdcSamplesRoundTo2 *= 2
                    
            elif "frameCfg" in cmd:
                chirpStartIdx = int(split_words[1])
                chirpEndIdx = int(split_words[2])
                numLoops = int(split_words[3])
                # numFrames = int(split_words[4])
                # framePeriodicity = float(split_words[5])

            elif "vitalSignsCfg" in cmd:
                rangeStart = float(split_words[1])
                rangeEnd = float(split_words[2])

        if 'profileCfg' in locals():
            numChirpsPerFrame = (chirpEndIdx - chirpStartIdx + 1) * numLoops
            self.params["numDopplerBins"] = numChirpsPerFrame / numTxAnt
            self.params["numRangeBins"] = numAdcSamplesRoundTo2
            self.params["rangeResolutionMeters"] = (3e8 * digOutSampleRate * 1e3) / (
                    2 * freqSlopeConst * 1e12 * numAdcSamples)
            self.params["maxRange"] = (300 * 0.9 * digOutSampleRate) / (2 * freqSlopeConst * 1e3)
            self.params["rangeStart"] = rangeStart
            self.params["rangeEnd"] = rangeEnd
        
        return config_lines
