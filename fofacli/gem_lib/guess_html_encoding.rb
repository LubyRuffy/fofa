require "guess_html_encoding/version"

# A small and simple library for guessing the encoding of HTML in Ruby 1.9.
module GuessHtmlEncoding
  # Guess the encoding of an HTML string, using HTTP headers if provided.  HTTP headers can be a string or a hash.
  def self.guess(html, headers = nil)
    html = html.to_s.dup.force_encoding("ASCII-8BIT")
    out = nil

    if headers
      headers = headers.map {|k, v| "#{k}: #{v}" }.join("\n") if headers.is_a?(Hash)
      headers = headers.dup.force_encoding("ASCII-8BIT")
      headers.split("\n").map {|i| i.split(":")}.each do |k,v|
        if k =~ /Content-Type/i && v =~ /charset=([\w\d-]+);?/i
          out = $1.upcase
          break
        end
      end
    end

    if out.nil? || out.empty? || !encoding_loaded?(out)
      if html =~ /<meta[^>]*HTTP-EQUIV=["']?Content-Type["']?[^>]*content=["']([^'"]*)["']/i && $1 =~ /charset=([\w\d-]+);?/i
        out = $1
      elsif html =~ /<meta\s+charset=["']([\w\d-]+)?/i
        out = $1
      end
      out.upcase! unless out.nil?
    end

    # Translate encodings with other names.
    if out
      out = "UTF-8" if %w[DEFAULT UTF8 UNICODE].include?(out)
      out = "CP1251" if out == "CP-1251"
      out = "ISO-8859-1" if %w[LATIN1 LATIN-1].include?(out)
      out = "WINDOWS-1250" if %w[WIN-1251 WIN1251].include?(out)
      out = "GB18030" if %w[GB2312 GB18030].include?(out) 
    end

    out
  end

  # Force an HTML string into a guessed encoding.
  def self.encode(html, headers = nil)
    html_copy = html.to_s.dup
    encoding = guess(html_copy, (headers || '').gsub(/[\r\n]+/, "\n"))
    html_copy.force_encoding(encoding_loaded?(encoding) ? encoding : "UTF-8")
    if html_copy.valid_encoding?
      html_copy
    else
      html_copy.force_encoding('ASCII-8BIT').encode('UTF-8', :undef => :replace, :invalid => :replace)
    end
  end

  # Is this encoding loaded?
  def self.encoding_loaded?(encoding)
    !!Encoding.find(encoding) rescue nil
  end
end
