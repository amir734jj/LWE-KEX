from sage.stats.distributions.discrete_gaussian_polynomial import DiscreteGaussianDistributionPolynomialSampler

dimension = 1024     # degree of polynomials
modulus = 40961      # modulus
sigma = 8/sqrt(2*pi) # sigma

# Quotient polynomial ring
R.<X> = PolynomialRing(GF(modulus))     # Gaussian field of integers
Y.<x> = R.quotient(X^(dimension) + 1)   # Cyclotomic field

def generate_error():
    # dimension = 5 (enough for error polynomial) ;  variance = sigma
    f = DiscreteGaussianDistributionPolynomialSampler(ZZ['x'], 5, sigma)()
    return Y(f)                                                             

def generate_polynomial():
	# uniformly sampled from Quotient Polynomial Ring in x over Finite Field
	return Y.random_element()
    
def ding_generate_signal(poly):
    coefficients = poly.list()
    signal = []
    
    for coefficient in coefficients:                
        if coefficient in range(-floor(modulus / 4), round(modulus / 4) + 1):
            signal.append(0)
        else:
            signal.append(1)

    return signal

def ding_reconcile(poly, w):
    coefficients = poly.list()
    key = []
    
    for coefficient, bit in zip(coefficients, w):
        coefficient = RR(coefficient)
                
        bit = RR(bit)
        q = RR(modulus)
     
        key.append(((coefficient + bit * ((q - 1) / 2)) % modulus) % 2)
    
    # abs will fix the issue of -0.000...
    return "".join(map(str, map(int, map(abs, key))))
 

# Shared matrix (A)
shared = generate_polynomial()

# Alice values
alice_secret = generate_error() # secret generated from error distribution
alice_error = generate_error()
alice_value = shared * alice_secret +  2 * alice_error

# Bob values
bob_secret = generate_error()   # secret generated from error distribution
bob_error = generate_error()
bob_value = shared * bob_secret + 2 * bob_error

# Bob key
temp_error = generate_error()
bob_key = alice_value * bob_secret + 2 * temp_error
w = ding_generate_signal(bob_key)
bob_key_binary = ding_reconcile(bob_key, w)

# Alice key
temp_error = generate_error()
alice_key = bob_value * alice_secret + 2 * temp_error
alice_key_binary = ding_reconcile(alice_key, w)

if (alice_key_binary == bob_key_binary):
    print "Keys match!"
    print hex(int(alice_key_binary, 2))
else:
    print "Keys do not match!"
    
