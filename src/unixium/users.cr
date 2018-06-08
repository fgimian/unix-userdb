lib LibC
  struct Passwd
    pw_name : LibC::Char*
    pw_passwd : LibC::Char*
    pw_uid : LibC::UInt
    pw_gid : LibC::UInt
    pw_change : LibC::Long
    pw_class : LibC::Char*
    pw_gecos : LibC::Char*
    pw_dir : LibC::Char*
    pw_shell : LibC::Char*
    pw_expire : LibC::Long
  end

  fun getpwuid(uid : LibC::UInt) : Passwd*
  fun getpwnam(name : LibC::Char*) : Passwd*
  fun getpwent : Passwd*
  fun setpwent
  fun endpwent
end

module Unixium::Users
  alias User = {name: String, passwd: String, uid: UInt32, gid: UInt32, gecos: String,
                dir: String, shell: String}

  class UserNotFoundError < Exception
  end

  private def self.from_ptr(user : Pointer(LibC::Passwd)) : User
    return User.new(
      name: String.new(user.value.pw_name),
      passwd: String.new(user.value.pw_passwd),
      uid: UInt32.new(user.value.pw_uid),
      gid: UInt32.new(user.value.pw_gid),
      gecos: String.new(user.value.pw_gecos),
      dir: String.new(user.value.pw_dir),
      shell: String.new(user.value.pw_shell)
    )
  end

  def self.all
    users = [] of User

    LibC.setpwent
    while user = LibC.getpwent
      users << from_ptr(user)
    end
    LibC.endpwent

    return users
  end

  def self.get(name : String)
    user = LibC.getpwnam(name)
    if user.null?
      raise UserNotFoundError.new("User with name #{name} not found")
    end

    return from_ptr(user)
  end

  def self.get(uid : UInt32)
    user = LibC.getpwuid(uid)
    if user.null?
      raise UserNotFoundError.new("User with uid #{uid} not found")
    end

    return from_ptr(user)
  end

  def self.get(uid : Int32)
    return get(uid.to_u32)
  end
end
