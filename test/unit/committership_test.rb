# encoding: utf-8
#--
#   Copyright (C) 2009 Johan Sørensen <johan@johansorensen.com>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++


require File.dirname(__FILE__) + '/../test_helper'

class CommittershipTest < ActiveSupport::TestCase
  
  should_validate_presence_of :repository_id, :committer_type, :committer_id
  
  should " have a creator" do
    committership = new_committership
    assert_equal users(:johan), committership.creator
  end
  
  should "have a polymorphic committer" do
    c = new_committership(:committer => users(:johan))
    assert_equal users(:johan), c.committer
    
    c = new_committership(:committer => groups(:team_thunderbird))
    assert_equal groups(:team_thunderbird), c.committer
  end
  
  should "have a members attribute that's the user if the committer is a user" do
    c = new_committership(:committer => users(:johan))
    assert_equal [users(:johan)], c.members
  end
  
  should 'notify all admin committers in the repository when a new committership is added' do
    # raise repositories(:johans).committerships.inspect
    # Find repository#owner. If group: notify each group member, else notify owner
    owner = users(:johan)
    assert_incremented_by(owner.received_messages, :count, 1) do
      c = new_committership(:committer => groups(:team_thunderbird))
      c.save
    end
  end
  
  should "have a members attribute that's the group members if the committer is a Group" do
    c = new_committership(:committer => groups(:team_thunderbird))
    assert_equal groups(:team_thunderbird).members, c.members
  end
  
  should "have a named scope for only getting groups" do
    Committership.delete_all
    c1 = new_committership(:committer => groups(:team_thunderbird))
    c2 = new_committership(:committer => users(:johan))
    [c1, c2].each(&:save)
    repo = repositories(:johans)
    
    assert_equal [c1], repo.committerships.groups
    assert_equal [c2], repo.committerships.users
  end
  
  def new_committership(opts = {})
    Committership.new({
      :repository => repositories(:johans),
      :committer => groups(:team_thunderbird),
      :creator => users(:johan)
    }.merge(opts))
  end
  
end
