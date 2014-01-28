class SortedArrayBinary < Array
  class BoundaryError < RuntimeError #:nodoc:
  end
  class InvalidSortBlock < RuntimeError #:nodoc:
  end

  def self._check_for_nil *objs #:nodoc:
    raise ArgumentError, "nil can't be sorted" if objs.include?(nil)
  end

  alias :old_insert :insert
  private :old_insert
  alias :old_sort! :sort!
  private :old_sort!

  def initialize *args, &b
    # Passed sort block.
    if args.size == 0 && block_given?
      @sort_block = b
      super()
      return
    end

    if args.size == 1
      # Passed array.
      if args.first.respond_to? :each
	self.class._check_for_nil *args.first
	super *args
	old_sort!
	return
      end

      # Passed size and block.
      if block_given?
	super *args, &b
	self.class._check_for_nil *self
	old_sort!
	return
      end

      # Passed size, but not obj, which means fill with nils.
      raise ArgumentError, "can't fill array with nils" \
	if args.first.is_a? Numeric
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

  def _add *objs #:nodoc:
    self.class._check_for_nil *objs
    objs.each { |obj|
      old_insert _find_insert_position(obj), obj
    }
    self
  end

  def _check_can_calc_boundary? #:nodoc:
    raise BoundaryError, 'no boundary? on empty array' if empty?
  end

  def _compare a, b #:nodoc:
    case state = @sort_block ? @sort_block.call(a, b) : a <=> b
    when -1
      :less
    when 0
      :equal
    when 1
      :greater
    else
      raise InvalidSortBlock, "sort block returned invalid value: #{state}"
    end
  end

  def _find_insert_position arg #:nodoc:
    return 0 if empty?

    # At this point, there must be >1 elements in the array.
    start, ending = 0, size - 1
    loop {
      middle_idx = _middle_element_index(start, ending)
      middle_el = self[middle_idx]
      after_middle_idx = middle_idx + 1

      comparison_state = _compare(arg, middle_el)

      # 1. Equals to the middle element. Insert after el.
      return after_middle_idx if comparison_state == :equal

      # 2. Less than the middle element.
      if comparison_state == :less
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
      ret = _compare(arg, after_middle_el)
      return after_middle_idx if ret == :equal || ret == :less

      # Proceeed to divide the right part.
      start = after_middle_idx
    }
  end

  def _left_boundary? idx #:nodoc:
    _check_can_calc_boundary?
    idx == 0
  end

  def _middle_element_index start, ending #:nodoc:
    start + (ending - start)/2
  end

  def _right_boundary? idx #:nodoc:
    _check_can_calc_boundary?
    idx == size - 1
  end
end
