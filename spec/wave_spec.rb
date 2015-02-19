require 'spec_helper'
require 'tempfile'

WAV_IN  = 'spec/audio/basic-5s.wav'
WAV_EX  = 'does-not-exist.wav'

WAV_EMPTY_HDR = { chunk_id: 'RIFF',
                   chunk_size: 40,
                   format: 'WAVE' }

WAV_DEF_FMT = { audio_format: 1,
                  channels: 2,
                  sample_rate: 44_100,
                  byte_rate: 176_400,
                  block_align: 4,
                  bits_per_sample: 16 }

WAV_IN_DATA_SIZE = 882000

describe Zappa::Wave do
  before :each do
    @file = File.open(WAV_IN, 'rb')
    @wav = Zappa::Wave.new
    @wav.unpack(@file)
  end


  describe '#initialize' do
    it 'has a default wave header' do
      w = Zappa::Wave.new
      WAV_EMPTY_HDR.each { |h| expect(h[1]).to eq(w.header.send(h[0])) }
      WAV_DEF_FMT.each { |h| expect(h[1]).to eq(w.format.send(h[0])) }
      expect(w.data).to eq(nil)
      expect(w.data_size).to eq(0)
    end

    pending 'has an empty fmt and data header'
  end


  describe '#unpack' do
    it 'reads format headers correctly' do
      WAV_DEF_FMT.each do |h|  
        expect(h[1]).to eq(@wav.format.send(h[0]))
      end
    end

    it 'reads data size correctly' do
      expect(@wav.data_size).to eq(WAV_IN_DATA_SIZE)
    end
    
    pending 'verify the data somehow'
    pending 'preserves optional subchunks'
  end


  describe '#pack' do
    it 'packs itself into a data string' do
      expect(@wav.pack.bytesize)
        .to eq(File.read(WAV_IN).bytesize)
    end

    pending 'verify the data somehow'
    pending 'it preserves optional data chunks'
  end


  describe '#update_data' do
    SLICE_LENGTH = 4

    before :each do
      @new_data = @wav.data.byteslice(0, SLICE_LENGTH)
      @wav.update_data(@new_data)
    end

    it 'updates the wav data correctly' do
      expect(@wav.data).to eq(@new_data)
    end

    it 'updates header data correctly' do
      expect(@wav.header.chunk_size).to eq(40)
      expect(@wav.data_size).to eq(SLICE_LENGTH)
    end
  end


  describe '#==' do
    it 'is equal to a wave with identical data' do
    end

    it 'is equal to a wave with different fmt data' do
    end

    it 'is not equal to a wave with different data' do
    end 

    pending 'is equal to a wave with different opt chunks'
  end


  describe '#parse_file' do
    it 'returns the object, if it is a file' do
      expect(subject.parse_file(@file)).to eq(@file.path)
    end

    it 'returns the File at path (string), if it is a string' do
      expect(subject.parse_file(WAV_IN)).to eq(WAV_IN)
    end
  end


  describe '#slice_samples' do
    it 'fails if the beginning is larger than the end' do
      expect { subject.slice_samples(5,2) }.to raise_error(RuntimeError)
    end

    it 'fails if the beginning is negative' do
      expect { subject.slice_samples(-1,2) }.to raise_error(RuntimeError)
    end

    it 'fails if the end is larger than the total size' do
      expect { subject.slice_samples(WAV_IN_DATA_SIZE,WAV_IN_DATA_SIZE+1) }
        .to raise_error(RuntimeError)
    end

    it 'returns the sample slice as a string' do
      slice = @wav.slice_samples(0,4)
      expect(slice.bytesize).to eq(16)
    end

    pending 'verify the data somehow'
  end
end