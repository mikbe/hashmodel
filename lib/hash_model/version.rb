class HashModel
  module VERSION # :nodoc:
    MAJOR  = 0
    MINOR  = 3
    TINY   = 1
    PRE    = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

    SUMMARY = "HashModel #{STRING}"
  end
end
