import random, unittest, time
from ellipticcurve import AffineCurvePoint, ProjectiveCurvePoint, FieldInt

# Parameters for secp256k1 curve
A = 0
B = 7
MOD = 2**256 - 2**32 - 977
GA = AffineCurvePoint(
	FieldInt(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798, MOD),
	FieldInt(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8, MOD),
	FieldInt(A, MOD), FieldInt(B, MOD), MOD)
GP = GA.to_projective_point()
ORDER = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141


def test_benchmark():
	private_key = 0x29EE955FEDA1A85F87ED4004958479706BA6C71FC99A67697A9A13D9D08C618E
	pubx = 0xF979F942AE743F27902B62CA4E8A8FE0F8A979EE3AD7BD0817339A665C3E7F4F
	puby = 0xB8CF959134B5C66BCC333A968B26D0ADACCFAD26F1EA8607D647E5B679C49184
	start_time = time.time()
	public_key = GA * private_key
	total_time = time.time() - start_time
	print('Affine coordinates took: {}'.format(total_time))
	assert public_key.x.value == pubx
	assert public_key.y.value == puby



	start_time = time.time()
	public_key = GP * private_key
	public_key = public_key.to_affine_point()
	total_time = time.time() - start_time
	print('Proj coordinates took: {}'.format(total_time))
	assert public_key.x.value == pubx
	assert public_key.y.value == puby

def test_benchmark_many():
	coordinates = [GA, GP]
	results = []
	count = 1000
	for c in range(0, 2):
		G = coordinates[c]
		result = []
		start_time = time.time()
		for i in range(0, count):
			x = G * (MOD-(i-1))
			if c == 1:
				x = x.to_affine_point()
			result.append(x)
		results.append(result)
		total_time = time.time() - start_time
		print('Coordinates: {}'.format(total_time))	

	print('len(results): `{}`'.format(len(results)))
	for i in range(0, count):
		a = results[0][i]
		b = results[1][i]
		assert a.x.value == b.x.value

test_benchmark_many()