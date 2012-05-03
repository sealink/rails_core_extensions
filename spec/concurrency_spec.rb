require 'spec_helper'


class TestConcurrencyCache
  @@cache = {}
  
  def self.read(key)
    @@cache[key]
  end
  
  def self.write(key, value)
    @@cache[key] = value
  end
  
  def self.delete(key)
    @@cache.delete(key)
  end
  
  def self.clear
    @@cache = {}
  end
end


describe Concurrency do
  
  before :each do
    TestConcurrencyCache.clear
    
    class ConcurrencyTest
      include Concurrency
      
      self.concurrency_cache = TestConcurrencyCache
      
      
      def self.class_test_method
        sleep(1)
      end
      
      
      def instance_test_method
        sleep(1)
      end
      
      def self.both_instance_and_class_test_method; end
      def both_instance_and_class_test_method; end
    end
  end
  
  after :each do
    Object.send(:remove_const, :ConcurrencyTest)
  end

  
  it "should allow specifying which methods should implement the concurrency check" do
    lambda { ConcurrencyTest.send(:concurrency_safe, :instance_test_method) }.should_not raise_error
    lambda { ConcurrencyTest.send(:concurrency_safe, :class_test_method) }.should_not raise_error
    lambda { ConcurrencyTest.send(:concurrency_safe, :both_instance_and_class_test_method) }.should raise_error(Concurrency::AmbiguousMethodException)
    lambda { ConcurrencyTest.send(:concurrency_safe, :both_instance_and_class_test_method, :type => :instance) }.should_not raise_error
    lambda { ConcurrencyTest.send(:concurrency_safe, :both_instance_and_class_test_method, :type => :class) }.should_not raise_error
    lambda { ConcurrencyTest.send(:concurrency_safe, :unknown_method) }.should raise_error(Concurrency::NoMethodException)
  end
  
  it "should allow identyfying the type of a method" do
    ConcurrencyTest.send(:method_types, :class_test_method).should eql ['class']
    ConcurrencyTest.send(:method_types, :instance_test_method).should eql ['instance']
    ConcurrencyTest.send(:method_types, :both_instance_and_class_test_method).should eql ['class','instance']
    ConcurrencyTest.send(:method_types, :unknown_method).should be_blank
    ConcurrencyTest.send(:method_type, :class_test_method).should eql 'class'
    ConcurrencyTest.send(:method_type, :instance_test_method).should eql 'instance'
    lambda { ConcurrencyTest.send(:method_type, :both_instance_and_class_test_method) }.should raise_error(Concurrency::AmbiguousMethodException)
    lambda { ConcurrencyTest.send(:method_type, :unknown_method) }.should raise_error(Concurrency::NoMethodException)
  end
  
  it "should allow checking the concurrency lock for specified class methods" do
    ConcurrencyTest.send(:concurrency_safe, :class_test_method)
    started = false
    thread = Thread.new { ConcurrencyTest.send(:class_test_method); started = true }
    ConcurrencyTest.concurrency_safe_method_locked?(:class_test_method).should be_false
    thread.join
    ConcurrencyTest.concurrency_safe_method_locked?(:class_test_method).should be_true until started
  end
  
  it "should allow checking the concurrency lock for specified class methods" do
    ConcurrencyTest.send(:concurrency_safe, :class_test_method)
    instance = ConcurrencyTest.new
    started = false
    thread = Thread.new { instance.send(:instance_test_method); started = true }
    instance.concurrency_safe_method_locked?(:instance_test_method).should be_false
    thread.join
    instance.concurrency_safe_method_locked?(:instance_test_method).should be_true until started
  end
  
  it "should implement the concurrency check for specified class methods" do
    ConcurrencyTest.send(:concurrency_safe, :class_test_method)
    threads = 2.times.map { Thread.new { ConcurrencyTest.send(:class_test_method) } }
    lambda { threads.each(&:join) }.should raise_error(Concurrency::ConcurrentCallException)
  end
  
  it "should implement the concurrency check for specified instance methods" do
    ConcurrencyTest.send(:concurrency_safe, :instance_test_method)
    instance = ConcurrencyTest.new
    threads = 2.times.map { Thread.new { instance.send(:instance_test_method) } }
    lambda { threads.each(&:join) }.should raise_error(Concurrency::ConcurrentCallException)
  end
  
end
