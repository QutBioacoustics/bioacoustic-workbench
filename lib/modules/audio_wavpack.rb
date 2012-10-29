module AudioWavpack
  include OS
  @wvunpack_path = if OS.windows? then "./vendor/bin/wavpack/windows/wvunpack.exe" else "wvunpack" end

  # public methods
  public

  # @return [array] contains info and error arrays
  def self.info_wavpack(source)
    info = []
    error = []

    wvunpack_arguments_info = "-s"
    wvunpack_command = "#{@wvunpack_path.to_s} #{wvunpack_arguments_info} \"#{source}\"" # commands to get info from audio file
    wvunpack_stdout_str, wvunpack_stderr_str, wvunpack_status = Open3.capture3(wvunpack_command) # run the commands and wait for the result

    Rails.logger.debug "Wavpack info return status #{wvunpack_status.exitstatus}. Command: #{wvunpack_command}"

    if wvunpack_status.exitstatus == 0
      # wvunpack std out contains info (separate on first colon(:))
      wvunpack_stdout_str.strip.split(/\r?\n|\r/).each do |line|
        line.strip!
        current_key = line[0,line.index(':')].strip
        current_value = line[line.index(':')+1,line.length].strip
        info.push [ 'WVUNPACK ' + current_key, current_value ]
      end

      # wvunpack_stderr_str contains human-formatted info and errors
    else
      info.push [ 'WVUNPACK ERROR', wvunpack_stderr_str.strip!.split(/\r?\n|\r/).last ]
    end

    [info, error]
  end

  # wvunpack converts .wv files to .wav, optionally segmenting them
  # target should be calculated based on modify_parameters by cache module
  # modify_parameters can contain start_offset (fractions of seconds from start) and/or end_offset (fractions of seconds from start)
  def self.modify_wavpack(source, target, modify_parameters = {})
    raise ArgumentError, "Source is not a wavpack file: #{File.basename(source)}" unless source.match(/\.wv$/)
    raise ArgumentError, "Target is not a wav file: : #{File.basename(target)}" unless target.match(/\.wav$/)
    raise ArgumentError, "Source does not exist: #{File.basename(source)}" unless File.exists? source
    raise ArgumentError, "Target exists: #{File.basename(target)}" unless !File.exists? source

    info = []
    error = []

    # formatted time: hh:mm:ss.ss
    arguments = '-t -q'
    if modify_parameters.include? :start_offset
      start_offset_formatted = Time.at(modify_parameters[:start_offset]).utc.strftime('%H:%M:%S.%2N')
      arguments += " --skip=#{start_offset_formatted}"
    end

    if modify_parameters.include? :end_offset
      end_offset_formatted = Time.at(modify_parameters[:start_offset]).utc.strftime('%H:%M:%S.%2N')
      arguments += " --until=#{end_offset_formatted}"
    end

    wvunpack_command = "#{@wvunpack_path.to_s} #{arguments} \"#{source}\" \"#{target}\"" # commands to get info from audio file
    wvunpack_stdout_str, wvunpack_stderr_str, wvunpack_status = Open3.capture3(wvunpack_command) # run the commands and wait for the result

    if wvunpack_status.exitstatus == 0
      raise "Wvunpack exited with an error: #{wvunpack_stderr_str}"
    end

    [info, error]
  end
end
