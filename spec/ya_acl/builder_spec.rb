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
      roles do
        role :admin
        role :another_admin
        role :user
      end
      resources :admin do
        resource resource_name, [:another_admin] do
          index :allow => [:operator]
          show :allow => (roles - [:user])
        end
      end
    end
    acl.check!(resource_name, :index, :admin).should be_true
    acl.check!(resource_name, :index, :another_admin).should be_true
    acl.check!(resource_name, :index, :operator).should be_true

    acl.allow?(resource_name, :show, :admin).should be_true
    acl.allow?(resource_name, :show, :user).should be_false
    acl.allow?(resource_name, :show, :operator).should be_false
    acl.allow?('no_exists', :show, :operator).should be_false
  end
end