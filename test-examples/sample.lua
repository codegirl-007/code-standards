-- Sample Lua code for testing code-improver plugin

function processData(data)
    local result = {}
    for i = 1, #data do
        if data[i] ~= nil then
            if data[i] > 0 then
                result[#result + 1] = data[i] * 2
            end
        end
    end
    return result
end

function calculateAverage(numbers)
    local sum = 0
    for i = 1, #numbers do
        sum = sum + numbers[i]
    end
    return sum / #numbers
end

-- Global variable (not recommended)
counter = 0

function incrementCounter()
    counter = counter + 1
    return counter
end

