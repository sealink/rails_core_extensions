require 'spec_helper'

describe DateTime do
  subject { DateTime.parse("2010-01-01") }

  it "should allow advancing by calendar days" do
    expect(subject.advance_considering_calendar(:calendar_days, 10)).to eq DateTime.parse("2010-01-10 23:59:59")
  end

  it "should allow advancing by calendar months" do
    expect(subject.advance_considering_calendar(:calendar_months, 10)).to eq DateTime.parse("2010-10-31 23:59:59")
  end

  it "should allow advancing by calendar years" do
    expect(subject.advance_considering_calendar(:calendar_years, 10)).to eq DateTime.parse("2019-12-31 23:59:59")
  end
end
