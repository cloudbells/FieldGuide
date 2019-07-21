local _, FieldGuide = ...

-- Copies the given table and returns the copy. If no table is given, this returns nil.
function FieldGuide.copy(original)
    local copy = {}
    if type(original) == "table" then
        for k, v in pairs(original) do
            copy[k] = v
        end
    else
        return nil
    end
    return copy
end