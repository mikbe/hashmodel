class HashModel
  module VERSION # :nodoc:
    MAJOR  = 0
    MINOR  = 4
    TINY   = 0
    PRE    = nil
    
    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

    SUMMARY = "HashModel #{STRING}"
  end
end
