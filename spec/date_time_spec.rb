require 'spec_helper'

describe DateTime do

  before do
    @date_time = DateTime.parse("2010-01-01")
  end

  it "should allow advancing by calendar days" do
    @date_time.advance_considering_calendar(:calendar_days, 10).should eql DateTime.parse("2010-01-10 23:59:59")
  end

  it "should allow advancing by calendar months" do
    @date_time.advance_considering_calendar(:calendar_months, 10).should eql DateTime.parse("2010-10-31 23:59:59")
  end

  it "should allow advancing by calendar years" do
    @date_time.advance_considering_calendar(:calendar_years, 10).should eql DateTime.parse("2019-12-31 23:59:59")
  end

end
