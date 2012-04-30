require 'spec_helper'

describe Date do
  
  before do
    @date = Date.parse("2010-01-01")
  end
  
  it "should convert to time in time zone" do
    Time.zone = ActiveSupport::TimeZone["Adelaide"]
    converted = @date.to_time_in_time_zone
    converted.year.should eql @date.year
    converted.month.should eql @date.month
    converted.day.should eql @date.day
    converted.time_zone.should eql Time.zone
  end
  
end

