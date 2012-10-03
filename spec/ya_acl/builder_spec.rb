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
        assert :first_assert, [:param, :param2] do
          param == param2
        end

        assert :another_assert, [:param, :param2] do
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

    acl.check!(:name, :index, [:admin]).should be_true
    acl.check!(:name, :index, [:another_admin]).should be_true
    acl.check!(:name, :index, [:operator]).should be_true

    acl.allow?(:name, :show, [:admin]).should be_true
    acl.allow?(:name, :show, [:user]).should be_false
    acl.allow?(:name, :show, [:operator]).should be_true
    acl.allow?(:name, :edit, [:operator]).should be_false
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
        assert :first, [:var] do
          var
        end

        assert :another, [:first] do
          statuses = [1, 2]
          statuses.include? first
        end

        assert :another2, [:first] do
          !!first
        end

        assert :another3, [:first] do
          statuses = [1, 2]
          statuses.include? first
        end

        assert :another4, [:first, :second] do
          first == second
        end
      end

      resources :admin do
        resource :name, [:editor, :operator] do
          privilege :create do
            assert :first, [:admin, :another_user]
          end
          privilege :update do
            assert :another, [:editor]
            assert :another2, [:editor, :operator]
            assert :another3, [:operator]
            assert :another4, [:operator]
          end
        end
      end
    end

    acl.allow?(:name, :update, [:another_user]).should be_false
    acl.allow?(:name, :update, [:editor], :first => true, :second => false).should be_false
    acl.allow?(:name, :update, [:editor], :first => false, :second => true).should be_false
    acl.allow?(:name, :update, [:editor], :first => 1, :second => true).should be_true
    acl.check!(:name, :create, [:admin], :var => 2).should be_true
    acl.allow?(:name, :update, [:editor], :first => 3, :second => false).should be_false
    acl.allow?(:name, :update, [:operator], :first => true, :second => true).should be_false
    acl.allow?(:name, :update, [:operator], :first => 1, :second => 1).should be_true
    acl.allow?(:name, :update, [:operator], :first => 3, :second => 3).should be_false
  end

  it 'should be work without global role' do
    acl = YaAcl::Builder.build do
      roles do
        role :admin
      end

      resource :name, [:admin] do
        privilege :index
      end
    end

    acl.check!(:name, :index, [:admin]).should be_true
  end
end
