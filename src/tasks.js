var findPrimesInRange = function(a, b) {
	var primes = [];
	for(var i = a; i <= b; i++) {
		var isPrime = true;
		for(var k = 2; k <= Math.sqrt(i); k++) {
			if(i%k === 0) {
        isPrime = false;
				break;
			}
		}
		if(isPrime) {
			primes.push(i);
		}
	}

	return primes;
	// return b-a;
};

module.exports = {
	'findPrimesInRange' : findPrimesInRange
};
