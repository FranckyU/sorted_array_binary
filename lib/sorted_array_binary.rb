class SortedArrayBinary < Array
  class BoundaryError < RuntimeError; end

  def self._check_for_nil *objs
    raise ArgumentError, "nil can't be sorted" if objs.include?(nil)
  end

  def self._equal? comparison_state
    comparison_state == 0
  end

  def self._less? comparison_state
    comparison_state == -1
  end

  def self.new *args, &b
    return super *args if args.size == 0 || args.size == 2
      
    # Passed array.
    if args.first.respond_to? :each
      _check_for_nil args.first
      ar = super *args
      ar.old_sort!
      return ar
    end

    # Passed size and block.
    if block_given?
      ar = super *args, b
      _check_for_nil *ar
      ar.old_sort!
      return ar
    end
  end

  alias :old_insert :insert
  alias :old_sort! :sort!

  def _not_implemented *args
    raise NotImplementedError
  end

  # Not implemented methods.
  #
  # The following methods are not implemented mostly because they change order
  # of elements. The rest ([]= and fill) arguably aren't useful on a sorted
  # array.
  [:[]=, :fill, :insert, :reverse!, :rotate!, :shuffle!, :sort!, :unshift].
  each { |m|
    alias_method m, :_not_implemented
  }

  # If the resulting array contains nil, throw an exception. This operation is
  # atomic, i.e. the array won't be mutated in case of exception.
  def collect! &b
    ar = collect &b
    self.class._check_for_nil *ar
    replace ar
  end
  alias :map! :collect!

  def concat other_ary
    _add *other_ary
  end

  def flatten! *args
    ar = flatten *args
    self.class._check_for_nil *ar
    replace ar
  end

  def push *objs
    _add *objs
  end
  alias :<< :push

  def replace other_ary
    super
    old_sort!
    self
  end

  #private

  def _add *objs
    self.class._check_for_nil *objs
    objs.each { |obj|
      old_insert _find_insert_position(obj), obj
    }
    self
  end

  def _check_can_calc_boundary?
    raise BoundaryError, 'no boundary? on empty array' if empty?
  end

  def _find_insert_position arg
    return 0 if empty?

    # At this point, there must be >1 elements in the array.
    start, ending = 0, size - 1
    loop {
      middle_idx = _middle_element_index(start, ending)
      middle_el = self[middle_idx]
      after_middle_idx = middle_idx + 1

      comparison_state = arg <=> middle_el

      # 1. Equals to the middle element. Insert after el.
      return after_middle_idx if self.class._equal?(comparison_state)

      # 2. Less than the middle element.
      if self.class._less?(comparison_state)
	# There's nothing to the left. So insert it as the first element.
	return 0 if _left_boundary? middle_idx

	ending = middle_idx
	next
      end

      # 3. Greater than the middle element.
      #
      # Right boundary? Put arg after the last (middle) element.
      return after_middle_idx if _right_boundary? middle_idx

      # Less than after middle element? Put it right before it!
      after_middle_el = self[after_middle_idx]
      return after_middle_idx if arg <= after_middle_el

      # Proceeed to divide the right part.
      start = after_middle_idx
    }
  end

  def _left_boundary? idx
    _check_can_calc_boundary?
    idx == 0
  end

  def _middle_element_index start, ending
    start + (ending - start)/2
  end

  def _right_boundary? idx
    _check_can_calc_boundary?
    idx == size - 1
  end
end
