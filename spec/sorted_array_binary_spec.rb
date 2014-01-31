require 'rspec'
require 'spec_helper'
require 'sorted_array_binary'

def new_array_with_block
  SortedArrayBinary.new { |a, b| b <=> a }
end

# {{{1 SortedArrayBinary
describe SortedArrayBinary do
  before :each do
    @ar = SortedArrayBinary.new
  end

  # {{{2 self.new
  context 'self.new' do
    it 'if passed size and obj, fills it' do
      @ar = SortedArrayBinary.new 5, 'a'
      @ar.should == ['a']*5
    end

    it 'if passed single non-numeric argument, calls Array#new' do
      expect { SortedArrayBinary.new 'a' }.to raise_error TypeError
    end

    it 'if passed array, it sorts it' do
      @ar = SortedArrayBinary.new ['b', 'a']
      @ar.should == ['a', 'b']
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

    [:insert, :reverse!, :rotate!, :shuffle!].
    each { |m|
      it "##{m}" do
	expect { @ar.send m }.to raise_error NotImplementedError
      end
    }
  end

  # {{{2 #collect!
  [:collect!, :map!].each { |method|
    context "##{method}" do
      [false, true].each { |sort_block_given|
	it 'after it, array is sorted' do
	  @ar = new_array_with_block if sort_block_given
	  @ar.push 'a', 'b', 'c'
	  @ar.send(method) { |el|
	    case el
	    when 'a' then 9
	    when 'b' then 3
	    when 'c' then 1
	    end
	  }
	  if sort_block_given
	    @ar.should == [9, 3, 1]
	  else
	    @ar.should == [1, 3, 9]
	  end
	end
      }
    end
  }

  # {{{2 #concat
  context '#concat' do
    [false, true].each { |sort_block_given|
      it '#concat adds another array and everything is sorted' do
	@ar = new_array_with_block if sort_block_given
	@ar.push 'c'
	@ar.concat ['a', 'b']
	if sort_block_given
	  @ar.should == ['c', 'b', 'a']
	else
	  @ar.should == ['a', 'b', 'c']
	end
      end
    }
  end

  # {{{2 #flatten!
  context '#flatten!' do
    [false, true].each { |sort_block_given|
      it 'flattens array and the result is sorted' do
	@ar = new_array_with_block if sort_block_given
	@ar.push [1, 2], [4, 3]
	@ar.flatten!
	if sort_block_given
	  @ar.should == [4, 3, 2, 1]
	else
	  @ar.should == [1, 2, 3, 4]
	end
      end
    }
  end

  # {{{2 #push
  [:<<, :push, :unshift].each { |method|
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
    end
  }

  # {{{2 #replace
  context '#replace' do
    [false, true].each { |sort_block_given|
      it '#replace replaces array, the resulting array is sorted' do
	@ar = new_array_with_block if sort_block_given
	@ar.push 'a'
	@ar.replace ['c', 'b']
	if sort_block_given
	  @ar.should == ['c', 'b']
	else
	  @ar.should == ['b', 'c']
	end
      end
    }
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
  # }}}2
end
