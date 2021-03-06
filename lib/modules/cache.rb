# Determines file names for cached and original files.
module Cache
  
  @parameter_file_name_separator = '_'
  
  public
  
  #original audio
  
  # get the file name for an original audio file
  def self.original_audio_file(modify_parameters = {})
    file_name = self.build_parameters [ :id, :date, :time, :original_format ], modify_parameters
    file_name
  end
  
  # get all the storage paths for original audio
  def self.original_audio_storage_paths()
    storage_paths = SharedSettings.settings[:original_audio_paths]
    storage_paths
  end
  
  # cached audio

  # get the file name for a cached audio file
  def self.cached_audio_file(modify_parameters = {})
    file_name = self.build_parameters [ :id, :start_offset, :end_offset, :channel, :sample_rate, :format ], modify_parameters
    file_name
  end
  
  # get all the storage paths for cached audio
  def self.cached_audio_storage_paths()
    storage_paths = SharedSettings.settings[:cached_audio_paths]
    storage_paths
  end
  
  def self. cached_audio_defaults()
    cache_defaults = SharedSettings.settings[:cached_audio_defaults]
    cache_defaults
  end
  
   def self. cached_spectrogram_defaults()
    cache_defaults = SharedSettings.settings[:cached_spectrogram_defaults]
    cache_defaults
  end
  
  # cached spectrograms
    
  # get the file name for a cached spectrogram
  def self.cached_spectrogram_file(modify_parameters = {})
    # don't use format here, as we know that spectrograms will be cached in png
    file_name = self.build_parameters [ :id, :start_offset, :end_offset, :channel, :sample_rate, :window, :colour ], modify_parameters
    file_name += '.png'
    file_name
  end
  
  # get all the storage paths for cached spectrograms
  def self.cached_spectrogram_storage_paths()
    storage_paths = SharedSettings.settings[:cached_spectrogram_paths]
    storage_paths
  end
  
  # get all possible full paths for a file
  def self.possible_paths(storage_paths, file_name)

    possible_paths = storage_paths.collect { |path| File.join(path, build_subfolder(file_name), file_name) }
    possible_paths
  end
  
  # get the full paths for all existing files that match a file name
  def self.existing_paths(storage_paths, file_name)
    existing_paths = possible_paths(storage_paths, file_name).find_all {|file| File.exists? file }
    existing_paths
  end
  
  private

  def self.build_subfolder(file_name)
    # assume that the file name starts with the uuid, get the first two chars as the sub folder
    file_name[0,2]
  end

  def self.build_parameters(parameter_names = [], modify_parameters = {})

    file_name = ''
    
    parameter_names.each do |param| 
      if param == :id
        file_name += get_parameter(:id, modify_parameters, false)
      elsif param == :format
        file_name += '.'+get_parameter(:format, modify_parameters, false).reverse.chomp('.').reverse
      elsif param == :original_format
        file_name += '.'+get_parameter(:original_format, modify_parameters, false).reverse.chomp('.').reverse
      elsif [:start_offset, :end_offset].include? param
        file_name += get_parameter(param, modify_parameters, true, :float)
      elsif [:channel, :sample_rate, :window].include? param
        file_name += get_parameter(param, modify_parameters, true, :int)
      else
        file_name += get_parameter(param, modify_parameters)
      end
    end
    
    file_name
  end
  
  def self.get_parameter(parameter, modify_parameters, include_separator = true, format = :string)
    # need to cater for the situation where modify_parameters contains strings (we want symbols)
    modify_parameters.keys.each do |key|
      modify_parameters[(key.to_sym rescue key) || key] = modify_parameters.delete(key)
    end
    
    # need to cater for the situation where parameter is a string (we want a symbol)
    parameter = parameter.to_s.to_sym

    raise ArgumentError, "Parameters must include #{parameter}." unless modify_parameters.include? parameter
    result_name = ''
    
    if modify_parameters.include? parameter
      result_name = modify_parameters[parameter].to_s

      case format
        when :int
          result_name = result_name.to_i.to_s
        when :float
          result_name = result_name.to_f.to_s
        else
          # noop
      end

      
      #if parameter == :format
        #result_name = result_name.trim '.', ''
      #end
      
      if include_separator
        result_name = @parameter_file_name_separator+result_name
      end
    end
    
    result_name
  end
  
end