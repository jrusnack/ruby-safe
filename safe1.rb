

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

  context "exec" do
    it "%x{} should not execute tainted string" do
      Thread.start {
        $SAFE = 1
        cmd = "exploit".taint
        expect{ %x{#{cmd}} }.to raise_error SecurityError
      }.join
    end

    it "`` should not execute tainted string" do
      Thread.start {
        $SAFE = 1
        cmd = "exploit".taint
        expect{ `#{cmd}` }.to raise_error SecurityError
      }.join
    end

    it "Kernel.exec should not execute tainted string" do
      Thread.start {
        $SAFE = 1
        cmd = "exploit".taint
        expect{ Kernel.exec cmd }.to raise_error SecurityError
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

  pending "$PATH with world writable dir" do
    it "should not be allowed to start processes" do
      # when $PATH containts /tmp, %x{ls} should raise SecurityError
    end
  end

  context "directory" do
    it "cannot be changed to a tainted string" do
      directory = "/tainted".taint
      Thread.start {
        $SAFE = 1
        expect { Dir.chdir(directory)}.to raise_error SecurityError
      }.join
    end

    it "cannot glob tainted string" do 
      pattern = "*".taint
      Thread.start {
        $SAFE = 1
        expect { Dir.glob(pattern)}.to raise_error SecurityError
      }.join
    end

    it " current directory should not be included in $LOAD_PATH" do
      Thread.start {
        $SAFE = 1
        $LOAD_PATH.should_not include('.')
        $LOAD_PATH.should_not include(Dir.pwd)
      }.join
    end
  end

  context "command line options" do
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

    it "-r should not be allowed" do
      Open3.popen3('ruby', '-T1', '-r') do |i, o, e, t|
        e.read.strip.should be_eql("ruby: no -r allowed in tainted mode (SecurityError)")
      end
    end

    it "-s should not be allowed" do
      Open3.popen3('ruby', '-T1', '-s') do |i, o, e, t|
        e.read.strip.should be_eql("ruby: no -s allowed in tainted mode (SecurityError)")
      end
    end

    it "-S should not be allowed" do
      Open3.popen3('ruby', '-T1', '-S') do |i, o, e, t|
        e.read.strip.should be_eql("ruby: no -S allowed in tainted mode (SecurityError)")
      end
    end

    it "program input from stdin should not be allowed" do
      Open3.popen3('ruby', '-T1') do |i, o, e, t|
        e.read.strip.should be_eql("ruby: no program input from stdin allowed in tainted mode (SecurityError)")
      end
    end
  end


end