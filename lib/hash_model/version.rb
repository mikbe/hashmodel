class HashModel
  module VERSION # :nodoc:
    MAJOR  = 0
    MINOR  = 3
    TINY   = 0
    PRE    = "beta3"

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

    SUMMARY = "HashModel #{STRING}"
  end
end
