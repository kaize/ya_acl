require 'spec_helper'

describe YaAcl::Builder do
  it 'should be add role' do
    acl = YaAcl::Builder.build do
      roles do
        role :admin, :name => 'Administrator'
      end
    end
    
    acl.role(:admin).should_not be_nil
  end

  it 'should be add resource' do
    acl = YaAcl::Builder.build do
      roles do
        role :admin
        role :another_admin
        role :user
        role :operator
      end

      asserts do
        assert :first_assert do |param, param2|
          param == param2
        end

        assert :another_assert do |param, param2|
          param != param2
        end
      end

      resources :admin do
        resource :name, [:another_admin] do
          privilege :index, [:operator]
          privilege :show, [:operator]
          privilege :edit
          privilege :with_assert, [:operator] do
            assert :first_assert
            assert :another_assert, [:admin]
          end
        end
      end
    end
    
    acl.allow?(:name, :update, [:operator]).should be_false
    acl.check!(:name, :index, [:admin]).should be_true
    acl.check!(:name, :index, [:another_admin]).should be_true
    acl.check!(:name, :index, [:operator]).should be_true

    acl.allow?(:name, :show, [:admin]).should be_true
    acl.allow?(:name, :show, [:user]).should be_false
    acl.allow?(:name, :show, [:operator]).should be_true
    acl.allow?(:name, :edit, [:operator]).should be_false

    acl.allow?(:name, :update, [:operator]).should be_false
  end

  it 'should be raise exception for unknown role in privilegy' do
    lambda {
      YaAcl::Builder.build do
        roles do
          role :admin, :name => 'Administrator'
        end
        resources :admin do
          resource 'resource' do
            privilege :index, [:operator]
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
            privilege :index, [:opeartor]
          end
        end
      end
    }.should raise_exception(ArgumentError)
  end

  it 'should be work with asserts' do
    acl = YaAcl::Builder.build do
      roles do
        role :admin
        role :another_user
        role :editor
        role :operator
      end

      asserts do
        assert :first do |var|
          var
        end

        assert :another do |first, second|
          statuses = [1, 2]
          statuses.include? first
        end

        assert :another2 do |first, second|
          !!first
        end

        assert :another3 do |first, second|
          statuses = [1, 2]
          statuses.include? first
        end

        assert :another4 do |first, second|
          first == second
        end
      end

      resources :admin do
        resource :name, [:editor, :operator] do
          privilege :create do |var|
            assert :first, [:admin, :another_user]
          end
          privilege :update do |first, second|
            assert :another, [:editor]
            assert :another2, [:editor, :operator]
            assert :another3, [:operator]
            assert :another4, [:operator]
          end
        end
      end
    end

    acl.allow?(:name, :update, [:another_user]).should be_false
    acl.allow?(:name, :update, [:editor], [true, false]).should be_false
    acl.allow?(:name, :update, [:editor], [false, true]).should be_false
    acl.allow?(:name, :update, [:editor], [1, true]).should be_true
    acl.check!(:name, :create, [:admin], [2]).should be_true
    acl.allow?(:name, :update, [:editor], [3, false]).should be_false
    acl.allow?(:name, :update, [:operator], [true, true]).should be_false
    acl.allow?(:name, :update, [:operator], [1, 1]).should be_true
    acl.allow?(:name, :update, [:operator], [3, 3]).should be_false
  end
end