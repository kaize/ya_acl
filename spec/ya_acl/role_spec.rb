require 'spec_helper'

describe YaAcl::Role do
  it 'should be instance' do
    options = {:name => 'Administrator'}
    role = YaAcl::Role.new :admin, options
    role.name.should == :admin
    role.options.should == options
  end
end