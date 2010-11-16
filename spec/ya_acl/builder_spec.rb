require 'spec_helper'

describe YaAcl::Builder do
  it 'should be add role' do
    acl = YaAcl::Builder.build do
      roles do
        role :admin, :name => 'Administrator'
      end
    end
    
    acl.roles.first.name.should == :admin
  end

  it 'should be add resource' do
    resource_name = 'controller_name'
    acl = YaAcl::Builder.build do
      resources :admin do
        resource resource_name, [:another_admin] do
          index :allow => [:operator]
        end
      end
    end
    acl.check!(resource_name, :index, :admin).should be_true
    acl.check!(resource_name, :index, :another_admin).should be_true
    acl.check!(resource_name, :index, :operator).should be_true
  end
end