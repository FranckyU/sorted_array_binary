require 'rspec'
require 'spec_helper'
require 'sorted_array_binary'

describe SortedArrayBinary do
  before :each do
    @ar = SortedArrayBinary.new
  end

  # {{{2 self._check_for_nil
  context 'self._check_for_nil' do
    it "raises exception if there's nil in passed objs" do
      expect {
	SortedArrayBinary._check_for_nil 'a', nil
      }.to raise_error ArgumentError
    end

    it "doesn't raise exception if there's no nil in passed objs" do
      expect {
	SortedArrayBinary._check_for_nil 'a', 'b'
      }.not_to raise_error
    end
  end

  # {{{2 self.new
  context 'self.new' do
    it 'if passed size and obj, fills it' do
      @ar = SortedArrayBinary.new 5, 'a'
      @ar.should == ['a']*5
    end

    context 'if passed array,' do
      it 'sorts it' do
	@ar = SortedArrayBinary.new ['b', 'a']
	@ar.should == ['a', 'b']
      end

      it 'raises exception if nil found in passed array' do
	expect { SortedArrayBinary.new [nil] }.to raise_error ArgumentError
      end
    end

    it 'if passed size and block, fills it and sorts it' do
      @ar = SortedArrayBinary.new(5) { |i| i == 0 ? 10 : i }
      @ar.should == [1, 2, 3, 4, 10]
    end

    it 'if passed sorting block, resulting array is sorted using it' do
      @ar = SortedArrayBinary.new { |a, b| b <=> a }
      @ar.push 'a', 'b'
      @ar.should == ['b', 'a']
    end
  end

  # {{{2 Not implemented
  context 'raises NotImplementedError exception when called' do
    it '#[]=' do
      expect { @ar[0] = 'a' }.to raise_error NotImplementedError
    end

    it '#fill' do
      expect { @ar.fill nil }.to raise_error NotImplementedError
    end

    [:insert, :reverse!, :rotate!, :shuffle!, :sort!, :unshift].
    each { |m|
      it "##{m}" do
	expect { @ar.send m }.to raise_error NotImplementedError
      end
    }
  end

  # {{{2 #collect!
  [:collect!, :map!].each { |method|
    context "##{method}" do
      it 'after it, array is sorted' do
	@ar.push 'a', 'b', 'c'
	@ar.send(method) { |el|
	  case el
	  when 'a' then 9
	  when 'b' then 3
	  when 'c' then 1
	  end
	}
	@ar.should == [1, 3, 9]
      end

      it 'raises exception if one of resulting elements is nil' do
	@ar.push 'a'
	expect { @ar.send(method) { nil } }.to raise_error ArgumentError
	@ar.should == ['a']
      end
    end
  }

  # {{{2 #concat
  it '#concat adds another array and everything is sorted' do
    @ar.push 'c'
    @ar.concat ['a', 'b']
    @ar.should == ['a', 'b', 'c']
  end

  # {{{2 #flatten!
  context '#flatten!' do
    it 'flattens array' do
      @ar.push [1, 2], [4, 3]
      @ar.flatten!
      @ar.should == [1, 2, 3, 4]
    end

    it 'raises exception if resulting array contains nil' do
      @ar.push [nil, 1]
      expect { @ar.flatten! }.to raise_error ArgumentError
      @ar.should == [[nil, 1]]
    end
  end

  # {{{2 #push
  [:<<, :push].each { |method|
    context "##{method}" do
      it 'adds an element to array' do
	@ar.send method, 'a'
	@ar.should == ['a']
      end

      it 'adds 2 elements to array' do
	@ar.send method, 'a', 'b'
	@ar.should == ['a', 'b']
      end

      it 'adds elements in random order, but the result is sorted' do
	@ar.send method, 'b', 'a', 'd', 'c'
	@ar.should == ['a', 'b', 'c', 'd']
	@ar.send method, 'e'
	@ar.should == ['a', 'b', 'c', 'd', 'e']
      end

      it 'adds element in random order, but sorting is done via sort block' do
	@ar = SortedArrayBinary.new { |a, b| b <=> a }
	@ar.push 'c', 'd'
	@ar.push 'a', 'b'
	@ar.should == ['d', 'c', 'b', 'a']
      end

      it 'raises exception if nil is passed' do
	expect { @ar.send method, nil }.to raise_error ArgumentError
      end
    end
  }

  # {{{2 #replace
  it '#replace replaces array, the resulting array is sorted' do
    @ar.push 'a'
    @ar.replace ['c', 'b']
    @ar.should == ['b', 'c']
  end

  # {{{2 #_compare
  context '#_compare' do
    context 'sort block not given' do
      it 'returns :equal if arguments are equal' do
	@ar._compare(1, 1).should == :equal
      end

      it 'returns :less if arg1 < arg2' do
	@ar._compare(1, 2).should == :less
      end

      it 'returns :greater if arg1 > arg2' do
	@ar._compare(2, 1).should == :greater
      end
    end

    context 'sort block given' do
      before :each do
	@ar = SortedArrayBinary.new { |a, b| b <=> a }
      end

      it 'returns :equal if arguments are equal' do
	@ar._compare(1, 1).should == :equal
      end

      it 'returns :less if arg1 < arg2' do
	@ar._compare(2, 1).should == :less
      end

      it 'returns :greater if arg1 > arg2' do
	@ar._compare(1, 2).should == :greater
      end

      it 'raises exception if block returns value outside of -1, 0, 1' do
	@ar = SortedArrayBinary.new { 'a' }
	expect {
	  @ar.push 1, 2
	}.to raise_error SortedArrayBinary::InvalidSortBlock
      end
    end
  end

  # {{{2 #_find_insert_position
  context '#_find_insert_position' do
    it 'returns 0 if array is empty' do
      @ar._find_insert_position('a').should == 0
    end

    context 'and array contains single element,' do
      it 'returns 1 if the first element is less than the passed elementt' do
	@ar.push 'a'
	@ar._find_insert_position('b').should == 1
      end

      it 'returns 0 if the first element is greater than the passed elementt' do
	@ar.push 'b'
	@ar._find_insert_position('a').should == 0
      end

      it 'returns 1 if the first element is equal to the passed elementt' do
	@ar.push 'a'
	@ar._find_insert_position('a').should == 1
      end
    end

    context 'and array contains 2 elements,' do
      it 'returns 2 if passed element is greater than 2nd element' do
	@ar.push 'a', 'b'
	@ar._find_insert_position('c').should == 2
      end

      it 'returns 1 if passed element is less than 2nd element' do
	@ar.push 'a', 'c'
	@ar._find_insert_position('b').should == 1
      end

      it 'returns 0 if passed element is less than 1st element' do
	@ar.push 'b', 'c'
	@ar._find_insert_position('a').should == 0
      end
    end

    context 'and array context 4 elements,' do
      it 'returns 1 if passed element is greater than 1st element' do
	@ar.push 'a', 'c', 'd'
	@ar._find_insert_position('b').should == 1
      end
    end
  end

  # {{{2 #_middle_element_index
  context '_middle_element_index' do
    it "returns first element index if there's one element" do
      @ar._middle_element_index(0, 0).should == 0
      @ar._middle_element_index(1, 1).should == 1
    end

    it 'returns 0 if there are 2 elements in the array' do
      @ar._middle_element_index(0, 1).should == 0
    end

    it 'returns 1 if there are 3 elements in the array' do
      @ar._middle_element_index(0, 2).should == 1
    end

    it 'returns 1 if there are 4 elements in the array' do
      @ar._middle_element_index(0, 3).should == 1
    end
  end

  # {{{2 #_left_boundary, #_right_boundary
  context '#_left_boundary, #_right_boundary' do
    context 'left' do
      it "returns true if it's left boundary?" do
	@ar.push 'a' 
	@ar._left_boundary?(0).should == true
      end

      it "returns false if it's not left boundary?" do
	@ar.push 'a' 
	@ar._left_boundary?(1).should == false
      end

      it 'raises exception if array is empty' do
	expect {
	  @ar._left_boundary?(0)
	}.to raise_error SortedArrayBinary::BoundaryError
      end
    end

    context 'right' do
      it "returns true if it's right boundary?" do
	@ar.push 'a', 'b'
	@ar._right_boundary?(1).should == true
      end

      it "returns false if it's not right boundary?" do
	@ar.push 'a', 'b'
	@ar._right_boundary?(0).should == false
      end

      it 'raises exception if array is empty' do
	expect {
	  @ar._right_boundary?(0)
	}.to raise_error SortedArrayBinary::BoundaryError
      end
    end
  end
  # }}}2
end
