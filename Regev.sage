from sage.stats.distributions.discrete_gaussian_polynomial import DiscreteGaussianDistributionPolynomialSampler

dimension = 512      # degree of polynomials
modulus = 25601      # modulus
sigma = 8/sqrt(2*pi) # sigma

# Quotient polynomial ring
R.<X> = PolynomialRing(GF(modulus))     # Gaussian field of integers
Y.<x> = R.quotient(X^(dimension) + 1)   # Cyclotomic field

def generate_error():
    # dimension = 5 (enough for error polynomial);  variance = sigma
    f = DiscreteGaussianDistributionPolynomialSampler(ZZ['x'], 5, sigma)()
    return Y(f)

def generate_polynomial():
    # uniformly sampled from Quotient Polynomial Ring in x over Finite Field
    return Y.random_element()

def regev_reconcile(poly):
    coefficients = poly.list()
    key = []

    value_1 = modulus / 4
    value_2 = 3.0 * modulus / 4

    for coefficient in coefficients:
        coefficient = RR(coefficient)

        if coefficient in range(value_1, value_2):
            key.append(1)
        else:
            key.append(0)

    return "".join(map(str, key))


# Shared matrix (A)
shared = generate_polynomial()

# Alice values
alice_secret = generate_error() # secret generated from error distribution
alice_error = generate_error()
alice_value = shared * alice_secret + alice_error

# Bob values
bob_secret = generate_error()   # secret generated from error distribution
bob_error = generate_error()
bob_value = shared * bob_secret + bob_error

# Bob key
bob_key = alice_value * bob_secret
bob_key_binary = regev_reconcile(bob_key)

# Alice key
alice_key = bob_value * alice_secret
alice_key_binary = regev_reconcile(alice_key)

if (alice_key_binary == bob_key_binary):
    print "Keys match!"
    print hex(int(alice_key_binary, 2))
else:
    print "Keys do not match!", "\n", "alice:\t", hex(int(alice_key_binary, 2)), "\n", "bob:\t", hex(int(bob_key_binary, 2))
    
