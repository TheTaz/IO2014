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
