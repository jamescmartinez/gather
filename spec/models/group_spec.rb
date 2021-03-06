require "rails_helper"

RSpec.describe Group, type: :model do
  it { is_expected.to have_many(:events).dependent(:destroy) }
  it { is_expected.to have_many(:memberships).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:memberships) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_presence_of(:time_zone) }
  it { is_expected.to allow_value("America/New_York").for(:time_zone) }
  it { is_expected.not_to allow_value("America/New_Yorker").for(:time_zone) }

  it "generate a new slug when created" do
    group = build(:group, name: "Slug Group")
    expect(group.slug).to be_nil
    group.save
    expect(group.slug).to eq("slug-group")
  end

  describe ".active" do
    it "returns distinct groups with events that ended in the last 30 days" do
      inactive_group = create(:inactive_event).group
      group_without_events = create(:group)

      active_group = create(:group)
      create_list(:event, 2, group: active_group)
      other_active_groups = create_list(:event, 4, :with_group).map(&:group)

      expect(Group.active).not_to include(inactive_group, group_without_events)
      expect(Group.active).to contain_exactly(active_group, *other_active_groups)
    end
  end

  describe ".with_member" do
    it "returns groups where the user is a member" do
      create(:group)
      membership = create(:membership)

      expect(Group.count).to eq(2)
      expect(Group.with_member(membership.user).count).to eq(1)
    end
  end

  describe "#image_url" do
    it "returns the group's image url" do
      group = create(:group, :with_image)
      group_image_uri = URI.parse(group.image_url)

      expect(group_image_uri).to be_a_kind_of(URI::HTTPS)
    end
  end
end
