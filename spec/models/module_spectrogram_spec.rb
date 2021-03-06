require 'spec_helper'

describe Spectrogram do
  it "should ensure source and destination files exist" do

    audio = 'TorresianCrow.wav'
    image = 'TorresianCrow.png'
    
    input_audio = AudioHelpers::get_source_audio_file_path audio
    output_image = AudioHelpers::get_temp_file_path image

    # delete any existing generated spectrogram
    AudioHelpers::delete_if_exists output_image

    assert File.exists?(input_audio), "Source audio file does not exist: #{input_audio}"

    result = Spectrogram::generate(input_audio, output_image, {})

    assert File.exists?(output_image), "Target image does not exist: #{output_image}, #{result}"

    # ensure the input audio has content
    file_size_in = File.size? input_audio
    assert_operator file_size_in, :>=, 1300000
    
    # ensure the output image has content
    file_size_out = File.size? output_image
    assert_operator file_size_out, :>, 100000
    
    #tidy up
    AudioHelpers::delete_if_exists output_image
  end

  it "should test using an invalid source file" do
    audio = 'not-an-audio-file.wav'
    image = 'TorresianCrow.png'

    input_audio = AudioHelpers::get_source_audio_file_path audio
    output_image = AudioHelpers::get_temp_file_path image

    # delete any existing generated spectrogram
    AudioHelpers::delete_if_exists output_image

    assert File.exists?(input_audio), "Source audio file does not exist: #{input_audio}"

    exception = assert_raise(ArgumentError) { Spectrogram::generate(input_audio, output_image, {}) }
    assert_equal( "Source file was not a valid audio file: #{input_audio}.", exception.message )

    #tidy up
    AudioHelpers::delete_if_exists output_image
  end

  it "should ensure target file already exists" do
    audio = 'TorresianCrow.wav'
    image = 'TorresianCrow.png'

    input_audio = AudioHelpers::get_source_audio_file_path audio
    output_image = AudioHelpers::get_temp_file_path image

    # delete any existing generated spectrogram
    AudioHelpers::delete_if_exists output_image

    # ensure source file exists
    assert File.exists?(input_audio), "Source audio file does not exist: #{input_audio}"

    # generate the spectrogram
    result = Spectrogram::generate(input_audio, output_image, {})

    # ensure target file exists
    assert File.exists?(output_image), "Target image does not exist: #{output_image}"

    #generate spectrogram again to test that it does not overwrite
    exception = assert_raise(ArgumentError) { Spectrogram::generate(input_audio, output_image, []) }
    assert_equal( "Target path for spectrogram generation already exists: #{output_image}.", exception.message )

    #tidy up
    AudioHelpers::delete_if_exists output_image
  end
end