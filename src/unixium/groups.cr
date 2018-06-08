lib LibC
  struct Group
    gr_name : LibC::Char*
    gr_passwd : LibC::Char*
    gr_gid : LibC::UInt
    gr_mem : LibC::Char**
  end

  fun getgrgid(gid : LibC::UInt) : Group*
  fun getgrnam(name : LibC::Char*) : Group*
  fun getgrent : Group*
  fun setgrent
  fun endgrent
end

module Unixium::Groups
  alias Group = {name: String, passwd: String, gid: UInt32, members: Array(String)}

  class GroupNotFoundError < Exception
  end

  private def self.from_ptr(group : Pointer(LibC::Group)) : Group
    members = [] of String
    iterator = group.value.gr_mem
    while iterator.value
      members << String.new(iterator.value)
      iterator += 1
    end

    return Group.new(
      name: String.new(group.value.gr_name),
      passwd: String.new(group.value.gr_passwd),
      gid: UInt32.new(group.value.gr_gid),
      members: members
    )
  end

  def self.all
    groups = [] of Group

    LibC.setgrent
    while group = LibC.getgrent
      groups << from_ptr(group)
    end
    LibC.endgrent

    return groups
  end

  def self.get(name : String)
    group = LibC.getgrnam(name)
    unless group
      raise GroupNotFoundError.new("Group with name #{name} not found")
    end

    return from_ptr(group)
  end

  def self.get(gid : UInt32)
    group = LibC.getgrgid(gid)
    unless group
      raise GroupNotFoundError.new("Group with gid #{gid} not found")
    end

    return from_ptr(group)
  end

  def self.get(gid : Int32)
    return get(gid.to_u32)
  end
end
