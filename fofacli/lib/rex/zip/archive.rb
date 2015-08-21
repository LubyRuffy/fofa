# -*- coding: binary -*-

module Rex
module Zip

#
# This represents an entire archive.
#
class Archive

  # An array of the Entry objects stored in this Archive.
  attr_reader :entries


  def initialize(compmeth=CM_DEFLATE)
    @compmeth = compmeth
    @entries = []
  end

  #
  # Recursively adds a directory of files into the archive.
  #
  def add_r(dir)
    path = File.dirname(dir)
    Dir[File.join(dir, "**", "**")].each do |file|
      relative = file.sub(/^#{path.chomp('/')}\//, '')
      if File.directory?(file)
        @entries << Entry.new(relative.chomp('/') + '/', '', @compmeth, nil, EFA_ISDIR, nil, nil)
      else
        contents = File.read(file, mode: 'rb')
        @entries << Entry.new(relative, contents, @compmeth, nil, nil, nil, nil)
      end
    end
  end

  #
  # Create a new Entry and add it to the archive.
  #
  # If fdata is set, the file is populated with that data
  # from the calling method. If fdata is nil, then the
  # fs is checked for the file. If central_dir_name is set
  # it will be used to spoof the name at the Central Directory
  # at packing time.
  #
  def add_file(fname, fdata=nil, xtra=nil, comment=nil, central_dir_name=nil)
    if (not fdata)
      begin
        st = File.stat(fname)
      rescue
        return nil
      end

      ts = st.mtime
      if (st.directory?)
        attrs = EFA_ISDIR
        fdata = ''
        unless fname[-1,1] == '/'
          fname += '/'
        end
      else
        f = File.open(fname, 'rb')
        fdata = f.read(f.stat.size)
        f.close
      end
    end

    @entries << Entry.new(fname, fdata, @compmeth, ts, attrs, xtra, comment, central_dir_name)
  end


  def set_comment(comment)
    @comment = comment
  end


  #
  # Write the compressed file to +fname+.
  #
  def save_to(fname)
    f = File.open(fname, 'wb')
    f.write(pack)
    f.close
  end


  #
  # Compress this archive and return the resulting zip file as a String.
  #
  def pack
    ret = ''

    # save the offests
    offsets = []

    # file 1 .. file n
    @entries.each { |ent|
      offsets << ret.length
      ret << ent.pack
    }

    # archive decryption header (unsupported)
    # archive extra data record (unsupported)

    # central directory
    cfd_offset = ret.length
    idx = 0
    @entries.each { |ent|
      cfd = CentralDir.new(ent, offsets[idx])
      ret << cfd.pack
      idx += 1
    }

    # zip64 end of central dir record (unsupported)
    # zip64 end of central dir locator (unsupported)

    # end of central directory record
    cur_offset = ret.length - cfd_offset
    ret << CentralDirEnd.new(@entries.length, cur_offset, cfd_offset, @comment).pack

    ret
  end

  def inspect
    "#<#{self.class} entries = [#{@entries.map{|e| e.name}.join(",")}]>"
  end

end

end
end
