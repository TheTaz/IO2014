({
    taskParams: {
        number: 39916800,
        begin: 2,
        end: 39916800
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

    taskMerge: function(chunkData) {
        var factorialsSet = {};

        chunkData.forEach(function(data) {
            data.output.forEach(function(factorial) {
                factorialsSet[factorial] = true;
            });
        });

        var factorials = [];
        for(val in factorialsSet)
            factorials.push(val);

        return {
            input: null, // we don't need task params during and after merging
            output: factorials
        }
    }
})
