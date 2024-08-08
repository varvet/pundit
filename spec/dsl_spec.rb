require "spec_helper"

RSpec.describe "Pundit RSpec DSL" do
  let(:fake_rspec) do
    double = class_double(RSpec::ExampleGroups)
    double.extend(::Pundit::RSpec::DSL)
    allow(double).to receive(:describe).and_yield
    double
  end
  let(:block) { proc { "block content" } }

  it "calls describe with the correct metadata and without :focus" do
    expect { |block| fake_rspec.permissions(:item1, :item2, &block) }.to yield_control

    expected_metadata = { permissions: %i[item1 item2], caller: instance_of(Array) }
    expect(fake_rspec).to receive(:describe).with("item1 and item2", match(expected_metadata)) do |&block|
      expect(block.call).to eq("block content")
    end

    fake_rspec.permissions(:item1, :item2, &block)
  end

  it "calls describe with the correct metadata and with :focus" do
    expect { |block| fake_rspec.permissions(&block) }.to yield_control

    expected_metadata = { permissions: %i[item1 item2], caller: instance_of(Array), focus: true }
    expect(fake_rspec).to receive(:describe).with("item1 and item2", match(expected_metadata)) do |&block|
      expect(block.call).to eq("block content")
    end

    fake_rspec.permissions(:item1, :item2, :focus, &block)
  end
end
