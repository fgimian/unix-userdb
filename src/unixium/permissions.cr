lib LibC
  fun getuid : LibC::UidT
  fun getgid : LibC::GidT
  fun geteuid : LibC::UidT
  fun getegid : LibC::GidT

  fun setuid(uid : LibC::UidT) : LibC::Int
  fun setgid(gid : LibC::GidT) : LibC::Int
  fun seteuid(euid : LibC::UidT) : LibC::Int
  fun setegid(egid : LibC::GidT) : LibC::Int
end

module Unixium::Permissions
  class SetPermissionError < Exception
  end

  def self.euid
    LibC.geteuid
  end

  def self.euid(uid)
    if LibC.seteuid(uid) == -1
      raise SetPermissionError.new("Unable to set euid")
    end
  end

  def self.egid
    LibC.getegid
  end

  def self.egid(gid)
    if LibC.setegid(gid) == -1
      raise SetPermissionError.new("Unable to set egid")
    end
  end

  def self.uid
    LibC.getuid
  end

  def self.uid(uid)
    if LibC.setuid(uid) == -1
      raise SetPermissionError.new("Unable to set uid")
    end
  end

  def self.gid
    LibC.getgid
  end

  def self.gid(gid)
    if LibC.setgid(gid) == -1
      raise SetPermissionError.new("Unable to set gid")
    end
  end
end
