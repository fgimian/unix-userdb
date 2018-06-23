lib LibC
  # Constants required specifically for getting the window size
  STDOUT_FILENO = 1          # standard output file descriptor
  TIOCGWINSZ    = 0x40087468 # get window size

  struct WinSize
    ws_row    : LibC::UShort # rows (characters)
    ws_col    : LibC::UShort # columns (characters)
    ws_xpixel : LibC::UShort # horizontal size (pixels)
    ws_ypixel : LibC::UShort # vertical size (pixels)
  end

  fun ioctl(fd : LibC::Int, request : LibC::ULong, data : Void*) : LibC::Int
end

module Unixium::Terminal
  record TerminalSize, rows : UInt16, columns : UInt16

  def self.size
    winsize = LibC::WinSize.new
    if LibC.ioctl(LibC::STDOUT_FILENO, LibC::TIOCGWINSZ, pointerof(winsize).as(Void*)) == 0
      return TerminalSize.new(rows: winsize.ws_row, columns: winsize.ws_col)
    end
    raise Errno.new("Error obtaining terminal size")
  end
end
