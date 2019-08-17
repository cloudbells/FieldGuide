local _, FieldGuide = ...

FieldGuide.pinPool = {}

function FieldGuide:getPin()
    for _, pin in pairs(FieldGuide.pinPool) do
        if not pin.used then
            pin.used = true
            return pin
        end
    end
    FieldGuide.pinPool[#FieldGuide.pinPool + 1] = CreateFrame("Button", nil, nil, "FieldGuidePinTemplate")
    local pin = FieldGuide.pinPool[#FieldGuide.pinPool]
    pin.used = true
    return pin
end

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

