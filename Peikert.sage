import numpy
from sage.stats.distributions.discrete_gaussian_polynomial import DiscreteGaussianDistributionPolynomialSampler

dimension = 1024     # degree of polynomials
modulus = 40961      # modulus
sigma = 8/sqrt(2*pi) # sigma

# Quotient polynomial ring
R.<X> = PolynomialRing(GF(modulus))     # Gaussian field of integers
Y.<x> = R.quotient(X^(dimension) + 1)   # Cyclotomic field

temp_modulus = (2 * modulus) if is_odd(modulus) else modulus    # if modulus is odd then multiply it by 2
temp = temp_modulus / 8                 # q/8
value_1 = temp + (temp_modulus / 4)     # q/8 + q/4
value_2 = temp + (3 * temp_modulus / 4) # q/8 + 3q/4 
value_3 = temp                          # q/8    
value_4 = temp + (temp_modulus / 2)     # q/8 + q/2

def dbl(coefficient, temp_modulus):
    return  ( 2 * int( coefficient ) - numpy.random.choice([-1, 0, 1], p=[0.25, 0.5, 0.25]) ) % temp_modulus
    
def generate_error():
    # dimension = 5 (enough for error polynomial) ;  variance = sigma
    f = DiscreteGaussianDistributionPolynomialSampler(ZZ['x'], 5, sigma)()
    return Y(f)                                                            

def generate_polynomial():
    # uniformly sampled from Quotient Polynomial Ring in x over Finite Field
    return Y.random_element()

# randomized double function, notice probability of 0 => 0.5
def dbl(coefficient):
    return  ( 2 * int( coefficient ) - numpy.random.choice([-1, 0, 1], p=[0.25, 0.5, 0.25]) ) % temp_modulus

def peikert_generate_signal(poly):
    coefficients = map(dbl, poly.list())    # apply dbl function to all coefficient
    signal = []
    
    for coefficient in coefficients:
        # if coefficient [0, q/4] OR [q/2, 3q/4] then signal bit = 1 else 0
        if (coefficient) <= (temp_modulus / 4) or \
            ((coefficient) <= (3 * temp_modulus / 4) and (coefficient) >= (temp_modulus / 2)):
            signal.append(1)
        else:
            signal.append(0)

    return signal 

def peikert_reconcile(poly, w):
    coefficients = map(dbl, poly.list())    # apply dbl function to all coefficient
    key = []
    # use signal bit to reconcile
    for coefficient, bit in zip(coefficients, w):        
        if bit == 1:
            key.append(1 if coefficient >= value_1 and coefficient <= value_2 else 0)
        else:
            key.append(1 if coefficient >= value_3 and coefficient <= value_4 else 0)
    
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
temp_error = generate_error()
bob_key = alice_value * bob_secret + temp_error
w = peikert_generate_signal(bob_key)
bob_key_binary = peikert_reconcile(bob_key, w)

# Alice key
alice_key = bob_value * alice_secret
alice_key_binary = peikert_reconcile(alice_key, w)

if (alice_key_binary == bob_key_binary):
    print "Keys match!"
    print hex(int(alice_key_binary, 2))
else:
    print "Keys do not match!"
    
