require 'spec_helper'

describe YaAcl::Resource do
  it 'should be work allow?' do
    resource = YaAcl::Resource.new 'controller_name'
    resource.allow :index, [:admin, :member]
    resource.deny :index, [:guest]
    resource.allow :index, [:moderator], :format => 'json'
    resource.allow :update, [:editor], :format => 'json'
    resource.allow :update, [:admin]

    resource.name.should == 'controller_name'
    resource.allow?('index', :moderator, [], :format => 'json').should be_true
    resource.allow?(:index, :moderator, [], :format => :xml).should be_false
    resource.allow?(:index, :admin).should be_true
    resource.allow?(:index, [:nobody, :admin]).should be_true
    resource.allow?(:index, [:nobody, :another_nobody]).should be_false
    resource.allow?(:index, 'admin', [], :format => :xml).should be_true
    resource.allow?('index', 'nobody').should be_false
    resource.allow?(:index, :guest).should be_false
  end

  it 'should be work allow? with inheritance' do
    resource = YaAcl::Resource.new 'controller_name'
    resource.allow :index, [:admin, :guest]
    resource.allow :empty, [:admin]

    resource.allow?(:index, :guest).should be_true
    resource.allow?(:index, :admin).should be_true
    resource.allow?(:empty, :admin).should be_true
    resource.allow?(:empty, :guest).should be_false
  end

  it 'should be work allow? with assert' do
    resource = YaAcl::Resource.new 'controller_name'
    resource.allow :index, [:admin, :guest], :format => 'xml' do |object_user_id, user_id|
      assert [:guest], lambda {
        object_user_id == user_id ? true : false
      }
    end

    resource.allow?(:index, :guest, [3, 4]).should be_false
    resource.allow?(:index, :guest, [3, 3]).should be_false
    resource.allow?(:index, :guest, [3, 3], :format => 'xml').should be_true
    resource.allow?(:index, :guest, [3, 4], :format => 'xml').should be_false
    resource.allow?(:index, :guest, [], :format => 'xml').should be_true
    resource.allow?(:index, :admin, [3, 4], :format => 'xml').should be_true
  end

  it 'should be raise ArgumentError with assert' do
    resource = YaAcl::Resource.new 'controller_name'
    resource.allow :index, [:admin, :guest] do |object_user_id, user_id|
      assert [:guest], lambda {
        object_user_id == user_id ? true : false
      }
    end

    resource.allow?(:index, :guest)
  end
end