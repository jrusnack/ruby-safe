
describe "Threads:" do
  context "safe level 0" do
    it "should be default for new threads" do
      Thread.start {
        $SAFE.should be 0
      }.join
    end
  end

  context "new thread" do
    it "should inherit parent`s SAFE level" do
      Thread.start {
        $SAFE = 1
        Thread.start{
          $SAFE.should be 1
        }.join
        $SAFE.should be 1
      }.join
    end

    it "cannot decrease safe level" do
      Thread.start {
        $SAFE = 1
        Thread.start {
          expect { $SAFE=0 }.to raise_error SecurityError
        }.join
      }.join
    end

    it "inherits taintedness of objects" do
      obj = Object.new
      obj.should_not be_tainted
      obj.taint
      obj.should be_tainted
      Thread.start {
        obj.should be_tainted
      }.join
    end

    it "inherits trustedness of objects" do
      # works only for SAFE level 3
      Thread.start {
        trusted = Object.new
        trusted.should_not be_untrusted
        $SAFE = 3
        untrusted = Object.new
        untrusted.should be_untrusted
        Thread.start {
          trusted.should_not be_untrusted
          untrusted.should be_untrusted
        }.join
      }.join
    end

    it "inherits untrustedness of objects" do
      trusted = Object.new
      trusted.should_not be_untrusted
      untrusted = Object.new
      untrusted.untrust
      untrusted.should be_untrusted
      Thread.start {
        trusted.should_not be_untrusted
        untrusted.should be_untrusted
      }.join
    end

  end
end
