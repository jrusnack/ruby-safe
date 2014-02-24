
describe "Input:" do
  context "Environment variables" do
    it "should be tainted" do
      ENV.each_value do |var|
        var.should be_tainted, "#{var} is not tainted!"
      end
    end

    it "PATH should be tainted" do
      ENV['PATH'].should be_tainted
    end
  end

  context "File content" do
    it "should be tainted" do
      File.open ("/etc/hosts") do |file|
        file.read.should be_tainted
      end
    end
  end

  context "ARGV" do
    it "should be tainted" do
      out = %x{ruby argv.rb some argument}
      out.each_line do |line|
        arg, tainted = line.split(':')
        tainted.strip.should eql("true"), "#{arg} is not tainted!"
      end
    end
  end
end