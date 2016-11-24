from sage.stats.distributions.discrete_gaussian_polynomial import DiscreteGaussianDistributionPolynomialSampler
from sage.modules.free_module_integer import IntegerLattice
import itertools, numpy
from sage.modules.diamond_cutting import calculate_voronoi_cell

dimension = 1024 # degree of polynomials
modulus = 40961  # modulus
sigma = 8/sqrt(2*pi) # sigma

# Quotient polynomial ring
R.<X> = PolynomialRing(GF(modulus))
Y.<x> = R.quotient(X^(dimension) + 1)   # cyclotomic field

sub_dimension = 4 # reconciliation sub dimension

# helper function
def grouped(iterable, n):
	return zip(*[iter(iterable)]*n)

def initialize():
	half_vector = [1/2 for i in range(sub_dimension)]
	raw_basis = Matrix([[1 if i == j else 0 for j in range(sub_dimension)] if i < sub_dimension -1 else half_vector for i in range(sub_dimension)])
	correct_basis = Matrix(raw_basis).echelon_form()  # convert (1/2, 1/2, ..., 1/2) to (0, 0, ..., 1)

	integer_lattice = IntegerLattice(correct_basis)
	main_polyhedron = calculate_voronoi_cell(raw_basis).translation(half_vector)

	return (integer_lattice, main_polyhedron)

def dbl(coefficient_vector):
	return coefficient_vector + vector( numpy.random.choice([0, 1], p=[0.5, 0.5]) * vector([1/(2*modulus) for i in range(sub_dimension)]) )

def generate_error():
	# dimension = 5 (enough for error polynomial) ;  variance = sigma
	f = DiscreteGaussianDistributionPolynomialSampler(ZZ['x'], 5, sigma)()
	return Y(f)

def generate_polynomial():
	# dimension = dimension ; variance = sigma
	f = DiscreteGaussianDistributionPolynomialSampler(ZZ['x'], dimension, sigma)()
	return Y(f)

def newhope_generate_signal(poly):
	coefficients = [RR(coefficient) / modulus for coefficient in poly.list()]

	distances = []

	for v in grouped(coefficients, sub_dimension):
		v = dbl(vector(v))

		if main_polyhedron.contains(vector(v)):
			distance = main_polyhedron.center() - v
		else:
			distance = integer_lattice.closest_vector(v) - v

		distances.append(distance)

	return distances

def newhope_reconcile(poly, w):
	coefficients = [RR(coefficient) / modulus for coefficient in poly.list()]
	key = []

	for difference, v in zip(w, grouped(coefficients, sub_dimension)):
		v = dbl(vector(v))
		coordinate = vector([round(p, 1) for p in (v + difference) ])

		if coordinate == main_polyhedron.center():
			key.append(1)
		else:
			key.append(0)

	return "".join(map(str, key))


(integer_lattice, main_polyhedron) = initialize()


# Shared matrix (A)
shared = generate_polynomial()

# Alice values
alice_secret = generate_polynomial()
alice_error = generate_error()
alice_value = shared * alice_secret +  2 * alice_error

# Bob values
bob_secret = generate_polynomial()
bob_error = generate_error()
bob_value = shared * bob_secret + 2 * bob_error

# Bob key
temp_error = generate_error()
bob_key = alice_value * bob_secret + 2 * temp_error
w = newhope_generate_signal(bob_key)
bob_key_binary = newhope_reconcile(bob_key, w)

# Alice key
temp_error = generate_error()
alice_key = bob_value * alice_secret + 2 * temp_error
alice_key_binary = newhope_reconcile(alice_key, w)

if (alice_key_binary == bob_key_binary):
	print "Keys match!"
	print hex(int(alice_key_binary, 2))
else:
	print "Keys do not match!"
