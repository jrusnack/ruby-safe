

describe "Safe level 1:" do
  context "eval" do
    it "should not evaluate tainted string" do
      Thread.start {
        $SAFE = 1
        string = "rm -rf *".taint
        expect { eval string }.to raise_error SecurityError
      }.join
    end
  end

  context "require" do
    it "should not load library with tainted name" do
      lib = "exploit".taint
      Thread.start {
        $SAFE = 1
        expect { require lib }.to raise_error SecurityError
      }.join
    end
  end

  context "File.open" do
    it "should not open tainted filename" do
      filename = "exploit".taint
      Thread.start {
        $SAFE = 1
        expect { File.open(filename) }.to raise_error SecurityError
      }.join
    end
  end

  context "Socket.open" do
    require 'socket'
    it "should not open socket with tainted hostname" do 
      hostname = "exploit.example.com".taint
      Thread.start {
        $SAFE = 1 
        expect { TCPSocket.open(hostname, 1) }.to raise_error SecurityError
      }.join
    end
  end

  context "trap" do
    it "should not be allowed to run with tainted argument" do
      signal = "SIGKILL".taint
      Thread.start {
        $SAFE = 1
        signal.should be_tainted
        expect { trap(signal) { puts 'foo'}}.to raise_error SecurityError
      }.join
    end
  end

  context "current directory" do
    it "should not be included in $LOAD_PATH" do
      $LOAD_PATH.should_not include(".")
      $LOAD_PATH.should_not include(Dir.pwd)
    end
  end

  context "command line option" do
    require 'open3'

    # -e allows to specify ruby command to execute from commandline
    it "-e should not be allowed" do
      Open3.popen3('ruby', '-T1', '-e', '"puts Time.now"') do |i, o, e, t|
        e.read.strip.should be_eql("ruby: no -e allowed in tainted mode (SecurityError)")
      end
    end

    it "-i should not be allowed" do
      Open3.popen3('ruby', '-p', '-T1', '-i.bak', '"$_.upcase!"','/tmp/junk') do |i, o, e, t|
        e.read.strip.should be_eql("ruby: no -i allowed in tainted mode (SecurityError)")
      end
    end

    it "-I should not be allowed" do
      Open3.popen3('ruby', '-T1', '-I', '/tmp', '/tmp/junk') do |i, o, e, t|
        e.read.strip.should be_eql("ruby: no -I allowed in tainted mode (SecurityError)")
      end
    end
  end
end