require 'spec_helper'

describe Date do
  before do
    @date = Date.parse("2010-01-01")
  end

  it "should convert to time in time zone" do
    Time.zone = ActiveSupport::TimeZone["Adelaide"]
    converted = @date.to_time_in_time_zone
    expect(converted.year).to eq @date.year
    expect(converted.month).to eq @date.month
    expect(converted.day).to eq @date.day
    expect(converted.time_zone).to eq Time.zone
  end
end
