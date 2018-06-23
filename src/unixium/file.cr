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
    if (stat_path.st_mode & LibC::S_IFMT) == LibC::S_IFLNK
      return false
    end

    parent = File.real_path(File.join(path, ".."))
    begin
      stat_parent = stat(parent, follow_symlinks: false)
    rescue Errno
      return false
    end

    # Parent path on a different device to path
    if stat_path.st_dev != stat_parent.st_dev
      return true
    end

    # Parent path is the same i-node as path
    if stat_path.st_ino == stat_parent.st_ino
      return true
    end

    return false
  end

  # Given a list of path names, returns the longest common leading component
  def self.common_prefix(paths : Array(Array(String))) : Array(String)
    if paths.empty?
      return [] of String
    end

    path_min = paths.min
    path_max = paths.max

    path_min.each_with_index do |path, index|
      if path != path_max[index]
        return path_min[0, index]
      end
    end

    return path_min
  end

  # Return a relative version of a path
  def self.relative_path(path : String, start : Nil | String = nil)
    current_dir = "."
    parent_dir = ".."

    start = current_dir unless start

    # Ensure both paths are absolute
    unless path.starts_with?(File::SEPARATOR)
      path = File.join(Dir.current, path)
    end
    path = File.expand_path(path)

    unless start.starts_with?(File::SEPARATOR)
      start = File.join(Dir.current, start)
    end
    start = File.expand_path(start)

    # Break up paths into their parts (ensuring no empty parts)
    path_parts = path.split(File::SEPARATOR).reject { |p| p.empty? }
    start_parts = start.split(File::SEPARATOR).reject { |p| p.empty? }

    # Work out how much of the file path is shared by start and path
    index = common_prefix([start_parts, path_parts]).size
    relative_parts = [parent_dir] * (start_parts.size - index) + path_parts[index..-1]

    if relative_parts.empty?
      return current_dir
    end

    return File.join(relative_parts)
  end
end
