
describe "Safe level 0" do
  it "should be default" do
    $SAFE.should be 0
  end

  context "current directory" do
    it "should be included in $LOAD_PATH" do
      $LOAD_PATH.should include(".")
    end
  end
end