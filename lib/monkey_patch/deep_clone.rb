class Object
  
  # Make sure there are no references left over
  def deep_clone
    Marshal.load(Marshal.dump(self))
  end

  # It's annoying to raise an error if an object can't
  # be cloned, like in the case of symbols, It is much
  # more friendly, and less surprising too, just to
  # return the same object so you can go about your work.
  # The only reason I clone is to protect the values, if
  # the values don't need to be protected I don't want an
  # annoying error message hosing up my whole day. </rant>
  #
  # Note: this is needed so deep_clone can work properly... don't get me started.
  alias :__stupid_clone__ :clone
  def clone
    # I wonder what this will break...
    begin
      self.__stupid_clone__
    rescue
      self
    end
  end

end