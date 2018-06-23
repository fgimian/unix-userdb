lib LibC
  fun chflags(path : LibC::Char*, flags : LibC::ULong) : LibC::Int
  fun lchflags(path : LibC::Char*, flags : LibC::ULong) : LibC::Int
end

module Unixium::File
  # Adapted from the stdlib File.info function
  def self.stat(path : String, follow_symlinks = true) : LibC::Stat
    stat = uninitialized LibC::Stat
    if follow_symlinks
      ret = LibC.stat(path.check_no_null_byte, pointerof(stat))
    else
      ret = LibC.lstat(path.check_no_null_byte, pointerof(stat))
    end

    if ret == 0
      stat
    else
      raise Errno.new("Unable to get info for '#{path}'")
    end
  end

  def self.mount?(path)
    begin
      stat_path = stat(path, follow_symlinks: false)
    rescue Errno
      # It doesn't exist so not a mount point
      return false
    end

    # A symlink can never be a mount point
    return false if stat_path.st_mode & LibC::S_IFMT == LibC::S_IFLNK

    parent = File.real_path(File.join(path, ".."))
    begin
      stat_parent = stat(parent, follow_symlinks: false)
    rescue Errno
      return false
    end

    # Parent path on a different device to path
    return true if stat_path.st_dev != stat_parent.st_dev

    # Parent path is the same i-node as path
    return true if stat_path.st_ino == stat_parent.st_ino

    false
  end

  # Given a list of path names, returns the longest common leading component
  def self.common_prefix(paths : Array(Array(String))) : Array(String)
    return [] of String if paths.empty?

    path_min = paths.min
    path_max = paths.max

    path_min.each_with_index do |path, index|
      return path_min[0, index] unless path == path_max[index]
    end

    path_min
  end

  # Return a relative version of a path
  def self.relative_path(path : String, start : Nil | String = nil)
    current_dir = "."
    parent_dir = ".."

    start = current_dir unless start

    # Ensure both paths are absolute
    path = File.join(Dir.current, path) unless path.starts_with?(File::SEPARATOR)
    path = File.expand_path(path)

    start = File.join(Dir.current, start) unless start.starts_with?(File::SEPARATOR)
    start = File.expand_path(start)

    # Break up paths into their parts (ensuring no empty parts)
    path_parts = path.split(File::SEPARATOR).reject { |p| p.empty? }
    start_parts = start.split(File::SEPARATOR).reject { |p| p.empty? }

    # Work out how much of the file path is shared by start and path
    index = common_prefix([start_parts, path_parts]).size
    relative_parts = [parent_dir] * (start_parts.size - index) + path_parts[index..-1]

    return current_dir if relative_parts.empty?

    File.join(relative_parts)
  end
end
