module AudioMp3splt
  include OS, Logging
  @mp3splt_path = if OS.windows? then "./vendor/bin/mp3splt/windows/mp3splt.exe" else "mp3splt" end

  # public methods
  public

  # @param [file path] source
  # @param [file path] target
  # @param [hash] modify_parameters
  # mp3splt can only segment (mp3 to mp3), can't change any other parameters
  def self.modify_mp3splt(source, target, modify_parameters = {})
    raise ArgumentError, "Source is not a mp3 file: #{File.basename(source)}" unless source.match(/\.mp3$/)
    raise ArgumentError, "Target is not a mp3 file: : #{File.basename(target)}" unless target.match(/\.mp3$/)
    raise ArgumentError, "Source does not exist: #{File.basename(source)}" unless File.exists? source
    raise ArgumentError, "Target exists: #{File.basename(target)}" if File.exists? target
    raise ArgumentError "Source and Target are the same file: #{File.basename(target)}" unless source != target

    # mp3splt needs the file extension removed
    target_dirname = File.dirname target
    target_no_ext = File.basename(target, File.extname(target))
    arguments = " -d \"#{target_dirname}\" -o \"#{target_no_ext}\" \"#{source}\""

    # WARNING: can't get more than an hour, since minutes only goes to 59.
    # formatted time: mm.ss.ss
    start_offset_num = 0.0
    if modify_parameters.include?(:start_offset) && modify_parameters[:start_offset].to_f > 0
      start_offset = modify_parameters[:start_offset].to_f
      start_offset = ' '+(start_offset /  60.0).floor.to_s  + '.' +  ('%05.2f' % (start_offset % 60)) + ' '
      start_offset_num = modify_parameters[:start_offset].to_f
    else
      start_offset = ' 0.0 '
    end

    arguments += " #{start_offset} "

    if modify_parameters.include?(:end_offset) && modify_parameters[:end_offset].to_f > 0 && modify_parameters[:end_offset].to_f > start_offset_num
      end_offset = modify_parameters[:end_offset].to_f
      end_offset_formatted = (end_offset /  60.0).floor.to_s  + '.' +  ('%05.2f' % (end_offset % 60))
      arguments += " #{end_offset_formatted} "
    else
      arguments += ' EOF '
    end

    mp3splt_command = "#{File.basename(@mp3splt_path)}  #{arguments}" # commands to get info from audio file ( -D )
    working_dir = File.dirname(File.expand_path(@mp3splt_path, Rails.root))
    mp3splt_stdout_str, mp3splt_stderr_str, mp3splt_status = Open3.capture3(mp3splt_command, :chdir => working_dir) # run the commands and wait for the result

    Logging::logger.debug"mp3splt info return status #{mp3splt_status.exitstatus}. Command: #{mp3splt_command}"

    if mp3splt_status.exitstatus != 0 || !File.exists?(target)
      Logging::logger.error "Mp3splt exited with an error: #{mp3splt_stderr_str}"
    end

    {
        info: {
            mp3splt: {
                command: mp3splt_command,
                source: source,
                target: target,
                parameters: modify_parameters
            }
        }
    }
  end
end