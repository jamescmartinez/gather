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

  describe "#url" do
    it "returns the group URL using the slug" do
      group = create(:group, slug: "futurama-brain-slug")
      group_uri = URI.parse(group.url)

      expect(group.url).to eq("http://localhost:3000/futurama-brain-slug")
      expect(group_uri).to be_a_kind_of(URI::HTTP)
    end
  end

  describe "#image_url" do
    it "returns the group's image url" do
      group = create(:group, :with_image)
      group_image_uri = URI.parse(group.image_url)

      expect(group_image_uri).to be_a_kind_of(URI::HTTP)
    end
  end
end
