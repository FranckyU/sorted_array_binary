# Copyright (C) 2014 by Dmitry Maksyoma <ledestin@gmail.com>

require 'bsearch20'

# Automatically sorted array (by using binary search). Nils aren't allowed.
# Methods that reorder elements are not implemented, as well as #[]= and #fill.
#
# = Example
#   require 'sorted_array_binary'
#
#   # Use standard sorting via <=>.
#   array = SortedArrayBinary.new
#   array.push 'b', 'a' #=> ['a', 'b']
#
#   # Use custom sorting block.
#   array = SortedArrayBinary.new { |a, b| b <=> a }
#   array.push 'a', 'b' #=> ['b', 'a']
class SortedArrayBinary < Array
  alias :old_insert :insert
  private :old_insert
  alias :old_sort! :sort!
  private :old_sort!

  def initialize *args, &b
    @sort_block = proc { |a, b| a <=> b }

    # Passed sort block.
    if args.size == 0 && block_given?
      @sort_block = b
      super
      return
    end

    if args.size == 1
      # Passed initial array.
      if args.first.respond_to? :each
	      super(*args)
	      old_sort!
	      return
      end

      # Passed size and block.
      if block_given?
    	  super(*args, &b)
    	  old_sort!
    	  return
      end
    end

    super
  end

  # Not implemented methods.
  #
  # The following methods are not implemented mostly because they change order
  # of elements. The rest ([]= and fill) arguably aren't useful on a sorted
  # array.
  def _not_implemented *args #:nodoc:
    raise NotImplementedError
  end

  [:[]=, :fill, :insert, :reverse!, :rotate!, :shuffle!].
  each { |m|
    alias_method m, :_not_implemented
  }

  def collect!(&b) #:nodoc:
    replace(collect(&b))
  end
  alias :map! :collect!

  def concat other_ary #:nodoc:
    _add(*other_ary)
  end

  def flatten! *args #:nodoc:
    replace(flatten(*args))
  end

  # Add objects to array, automatically placing them according to sort order
  # (via <=> by default).
  def push *objs
    _add(*objs)
  end
  alias :<< :push
  alias :unshift :push

  def replace other_ary #:nodoc:
    super
    old_sort!(&@sort_block)
    self
  end

  def sort! #:nodoc:
  end

  #private
  # Name the following methods starting with underscore so as not to pollute
  # Array namespace. They are considered private, but for testing purposes are
  # left public.

  def _add *objs #:nodoc:
    objs.each { |obj|
      old_insert _find_insert_position(obj), obj
    }
    self
  end

  def _find_insert_position element_to_place #:nodoc:
    bsearch_upper_boundary { |el| @sort_block.call el, element_to_place }
  end
end
