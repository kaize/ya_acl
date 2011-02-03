require 'spec_helper'

describe YaAcl::Acl do

  before do
    @acl = YaAcl::Acl.new
    @acl.add_resource(YaAcl::Resource.new(:name))

    @acl.add_role YaAcl::Role.new(:admin)
    @acl.add_role YaAcl::Role.new(:moderator)
    @acl.add_role YaAcl::Role.new(:editor)
    @acl.add_role YaAcl::Role.new(:member)
    @acl.add_role YaAcl::Role.new(:guest)

    assert = YaAcl::Assert.new :assert, [:object_user_id, :user_id] do
      object_user_id == user_id
    end
    
    @acl.add_assert assert
  end

  it 'should be work allow?' do
    @acl.allow :name, :index, :admin
    @acl.allow :name, :index, :member
    @acl.allow :name, :update, :admin

    @acl.allow?(:name, :index, [:admin]).should be_true
    @acl.allow?(:name, :index, [:nobody, :admin]).should be_true
    @acl.allow?(:name, :index, [:nobody, :another_nobody]).should be_false
    @acl.allow?(:name, 'index', ['nobody']).should be_false
    @acl.allow?(:name, :index, [:guest]).should be_false
  end

  it 'should be work allow? with assert' do
    @acl.allow :name, :index, :admin
    @acl.allow :name, :index, :guest, :assert
    @acl.allow :name, :index, :member, :assert


    @acl.allow?(:name, :index, [:guest], :object_user_id => 3, :user_id => 4).should be_false
    @acl.allow?(:name, :index, [:guest], :object_user_id => 3, :user_id => 3).should be_true
  end

  it 'should be work with roles' do
    assert = YaAcl::Assert.new :another_assert, [:var] do
      var
    end
    @acl.add_assert assert
    @acl.allow :name, :index, :admin
    @acl.allow :name, :empty, :admin
    @acl.allow :name, :index, :guest, :another_assert

    @acl.allow?(:name, :empty, [:guest, :admin]).should be_true
    @acl.allow?(:name, :index, [:guest, :admin], :var => false).should be_true
  end
end