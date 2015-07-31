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
    expect { ConcurrencyTest.send(:concurrency_safe, :instance_test_method) }
      .to_not raise_error
    expect { ConcurrencyTest.send(:concurrency_safe, :class_test_method) }
      .to_not raise_error
    expect { ConcurrencyTest.send(:concurrency_safe, :both_instance_and_class_test_method) }
      .to raise_error(Concurrency::AmbiguousMethodException)
    expect { ConcurrencyTest.send(:concurrency_safe, :both_instance_and_class_test_method, type: :instance) }
      .to_not raise_error
    expect { ConcurrencyTest.send(:concurrency_safe, :both_instance_and_class_test_method, type: :class) }
      .to_not raise_error
    expect { ConcurrencyTest.send(:concurrency_safe, :unknown_method) }
      .to raise_error(Concurrency::NoMethodException)
  end

  it "should allow identyfying the type of a method" do
    expect(ConcurrencyTest.send(:method_types, :class_test_method)).to eq ['class']
    expect(ConcurrencyTest.send(:method_types, :instance_test_method)).to eq ['instance']
    expect(ConcurrencyTest.send(:method_types, :both_instance_and_class_test_method)).to eq ['class','instance']
    expect(ConcurrencyTest.send(:method_types, :unknown_method)).to be_blank
    expect(ConcurrencyTest.send(:method_type, :class_test_method)).to eq 'class'
    expect(ConcurrencyTest.send(:method_type, :instance_test_method)).to eq 'instance'
    expect { ConcurrencyTest.send(:method_type, :both_instance_and_class_test_method) }
      .to raise_error(Concurrency::AmbiguousMethodException)
    expect { ConcurrencyTest.send(:method_type, :unknown_method) }
      .to raise_error(Concurrency::NoMethodException)
  end

  it "should allow checking the concurrency lock for specified class methods" do
    ConcurrencyTest.send(:concurrency_safe, :class_test_method)
    started = false
    expect(ConcurrencyTest.concurrency_safe_method_locked?(:class_test_method)).to be false
    thread = Thread.new { ConcurrencyTest.send(:class_test_method); started = true }
    thread.join
    expect(ConcurrencyTest.concurrency_safe_method_locked?(:class_test_method)).to be true until started
  end

  it "should allow checking the concurrency lock for specified instance methods" do
    ConcurrencyTest.send(:concurrency_safe, :class_test_method)
    instance = ConcurrencyTest.new
    started = false
    expect(instance.concurrency_safe_method_locked?(:instance_test_method)).to be false
    thread = Thread.new { instance.send(:instance_test_method); started = true }
    thread.join
    expect(instance.concurrency_safe_method_locked?(:instance_test_method)).to be true until started
  end

  it "should implement the concurrency check for specified class methods" do
    ConcurrencyTest.send(:concurrency_safe, :class_test_method)
    threads = 2.times.map { Thread.new { ConcurrencyTest.send(:class_test_method) } }
    expect { threads.each(&:join) }
      .to raise_error(Concurrency::ConcurrentCallException)
  end

  it "should implement the concurrency check for specified instance methods" do
    ConcurrencyTest.send(:concurrency_safe, :instance_test_method)
    instance = ConcurrencyTest.new
    threads = 2.times.map { Thread.new { instance.send(:instance_test_method) } }
    expect { threads.each(&:join) }
      .to raise_error(Concurrency::ConcurrentCallException)
  end
end
