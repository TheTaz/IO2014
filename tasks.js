find_primes_in_range =  function(a, b) {
	var primes = [];
	for(var i = a; i <= b; i++) {
		var is_prime = true;
		for(var k = 2; k <= Math.sqrt(i); k++) {
			if(i%k == 0) {
				is_prime = false;
				break;
			}
		}
		if(is_prime) {
			primes.push(i);
		}
	}

	return primes;
	// return b-a;
}

module.exports = {
	find_primes_in_range : find_primes_in_range

}
