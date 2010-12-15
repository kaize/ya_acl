require 'spec_helper'

describe YaAcl::Builder do
  it 'should be add role' do
    YaAcl::Builder.build do
      roles do
        role :admin, :name => 'Administrator'
      end
    end
    
    YaAcl::Acl.instance.roles.first.name.should == :admin
  end

  it 'should be add resource' do
    resource_name = 'controller_name'
    acl = YaAcl::Builder.build do
      roles do
        role :admin
        role :another_admin
        role :user
        role :operator
      end
      resources :admin do
        resource resource_name, [:another_admin] do
          index :allow => [:operator]
          privilege :show, :allow => [:operator]
          edit
          update :allow => [:operator], :format => 'json'
        end
      end
    end
    
    acl.check!(resource_name, :index, :admin).should be_true
    acl.check!(resource_name, :index, :another_admin).should be_true
    acl.check!(resource_name, :index, :operator).should be_true

    acl.allow?(resource_name, :show, :admin).should be_true
    acl.allow?(resource_name, :show, :user).should be_false
    acl.allow?(resource_name, :show, :operator).should be_true
    acl.allow?(resource_name, :edit, :operator).should be_false

    acl.allow?(resource_name, :update, :operator).should be_false
    acl.allow?(resource_name, :update, :operator, [], :format => 'json').should be_true
  end

  it 'should be raise exception for unknown role in privilegy' do
    lambda {
      YaAcl::Builder.build do
        roles do
          role :admin, :name => 'Administrator'
        end
        resources :admin do
          resource 'resource' do
            index :allow => [:operator]
          end
        end
      end
    }.should raise_exception(ArgumentError)
  end

  it 'should be raise exception for unknown role in resource' do
    lambda {
      YaAcl::Builder.build do
        roles do
          role :admin, :name => 'Administrator'
          role :operator
        end

        resources :admin do
          resource 'resource', [:another_admin] do
            index :allow => [:opeartor]
          end
        end
      end
    }.should raise_exception(ArgumentError)
  end

  it 'should be work with asserts' do
    resource_name = 'name'
    acl = YaAcl::Builder.build do
      roles do
        role :admin
        role :another_user
        role :editor
        role :operator
      end
      resources :admin do
        resource resource_name, [:another_user, :editor, :operator] do
          create do |var|
            assert [:admin, :another_user], lambda { var }
          end
          update :deny => [:another_user] do |first, second|
            assert [:editor], lambda {
              statuses = [1, 2]
              statuses.include? first
            }
            assert [:editor, :operator], lambda {
              !!first
            }
            assert [:operator], lambda {
              statuses = [1, 2]
              statuses.include? first
            }
            assert [:operator], lambda {
              first == second
            }
          end
        end
      end
    end

    acl.allow?(resource_name, :update, :editor, [true, false]).should be_false
    
#    acl.allow?(resource_name, :update, :editor, [false, true]).should be_false
#    acl.allow?(resource_name, :update, :editor, [1, true]).should be_true
#
#    acl.check!(resource_name, :create, :admin, [2]).should be_true
#    acl.allow?(resource_name, :update, :another_user).should be_false
#
#
#    acl.allow?(resource_name, :update, :editor, [3, false]).should be_false
#
#    acl.allow?(resource_name, :update, :operator, [true, true]).should be_false
#    acl.allow?(resource_name, :update, :operator, [1, 1]).should be_true
#    acl.allow?(resource_name, :update, :operator, [3, 3]).should be_false
  end
end