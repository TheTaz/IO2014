({
    taskParams: {
        number: 39916800,
        begin: 2,
        end: 39916800
    },

    taskProcess: function(inputObj) {
        var factorials = [];
        for(var i = inputObj.begin; i < inputObj.end; ++i)
            if(inputObj.number % i == 0)
                factorials.push(i);

        return factorials;
    },

    taskResultEquals: function(a, b) {
        if(a.length != b.length)
            return false;

        for(var i = 0; i < a.length; ++i)
            if(a[i] !== b[i])
                return false;

        return true;
    },

    taskSplit: function(inputObj, n) {
        var rangeLen = inputObj.end - inputObj.begin;
        var step = Math.max(Math.ceil(rangeLen / n), 1);

        var result = [];
        for(var i = inputObj.begin; i < inputObj.end; i += step) {
            end = Math.min(inputObj.end, i + step);
            result.push({number: inputObj.number, begin: i, end: end});
        }

        return result;
    },

})
