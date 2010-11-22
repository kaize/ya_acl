require 'spec_helper'

describe YaAcl::Resource do
  it 'should be work allow?' do
    resource = YaAcl::Resource.new 'controller_name' do
      index :allow => [:admin, :member], :deny => [:guest]
      index :allow => [:moderator], :format => :json
    end
    resource.name.should == 'controller_name'
    resource.allow?(:index, :admin).should be_true
    resource.allow?(:index, [:nobody, :admin]).should be_true
    resource.allow?(:index, [:nobody, :another_nobody]).should be_false
    resource.allow?(:index, 'admin', :format => :xml).should be_true
    resource.allow?('index', :moderator, :format => :json).should be_true
    resource.allow?(:index, :moderator, :format => :xml).should be_true
    resource.allow?('index', 'nobody').should be_false
    resource.allow?(:index, :guest).should be_false
  end

  it 'should be work allow? with inheritance' do
    resource = YaAcl::Resource.new 'controller_name', :admin do
      index :allow => [:guest]
      empty
    end

    resource.allow?(:index, :guest).should be_true
    resource.allow?(:index, :admin).should be_true
    resource.allow?(:empty, :admin).should be_true
    resource.allow?(:empty, :guest).should be_false
  end

  it 'should be work allow? with assert' do
    resource = YaAcl::Resource.new 'controller_name', :admin do
      index :allow => [:guest], :format => 'xml' do |object_user_id, user_id|
        assert :guest do
          false if object_user_id != user_id
        end
      end
    end

    resource.allow?(:index, :guest, [3, 4]).should be_false
    resource.allow?(:index, :guest, [3, 3]).should be_true
    resource.allow?(:index, :guest, [3, 3], :format => 'xml').should be_true
    resource.allow?(:index, :guest, [], :format => 'xml').should be_true
    resource.allow?(:index, :admin, [3, 4], :format => 'xml').should be_true
  end
end