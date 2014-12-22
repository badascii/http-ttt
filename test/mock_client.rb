class MockClient

  def initialize
    @lines = "Host: localhost:2000\nConnection: keep-alive\nContent-Length: 17\nCache-Control: max-age=0\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\nOrigin: http://localhost:2000\nUser-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36\nContent-Type: application/x-www-form-urlencoded\nReferer: http://localhost:2000/index.html\nAccept-Encoding: gzip, deflate\nAccept-Language: en-US,en;q=0.8\n\nmode=cpu&size=3x3"
  end

  def readline
    line   = @lines.lines.to_a.shift
    @lines = @lines.lines.to_a[1..-1].join
    return line
  end

  def read(arg)
    'mode=cpu&size=3x3'
  end

  def print(string)
    string
  end

  def write(data)
    17
  end
end
