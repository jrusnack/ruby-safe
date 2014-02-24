
describe "Proc:" do
  context "safe level 0" do
    it "should be default for new threads" do
      Proc.new {
        $SAFE.should be 0
      }
    end
  end

  context "new thread" do
    it "should inherit parent`s SAFE level" do
      Proc.new {
        $SAFE = 1
        Thread.start{
          $SAFE.should be 1
        }.join
        $SAFE.should be 1
      }
    end

    it "cannot decrease safe level" do
      Proc.new {
        $SAFE = 1
        Proc.new {
          expect { $SAFE=0 }.to raise_error
        }
      }
    end

    it "inherits taintedness of objects" do
      obj = Object.new
      obj.should_not be_tainted
      obj.taint
      obj.should be_tainted
      Proc.new {
        obj.should be_tainted
      }
    end

    it "inherits trustedness of objects" do
      # works only for SAFE level 3
      Proc.new {
        trusted = Object.new
        trusted.should_not be_untrusted
        $SAFE = 3
        untrusted = Object.new
        untrusted.should be_untrusted
        Thread.start {
          trusted.should_not be_untrusted
          untrusted.should be_untrusted
        }
      }
    end

    it "inherits untrustedness of objects" do
      trusted = Object.new
      trusted.should_not be_untrusted
      untrusted = Object.new
      untrusted.untrust
      untrusted.should be_untrusted
      Proc.new {
        trusted.should_not be_untrusted
        untrusted.should be_untrusted
      }
    end
  end
end