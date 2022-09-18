local _, FieldGuide = ...

function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
    end
    return iter
  end

function getTableSize(t)
    local count = 0

    if t ~= nil then
        for a,b in pairsByKeys(t) do
            count = count + 1
        end
    end

    return count
end
