import hashlib
import binascii

p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
G = (0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798, 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)

def class_name(v):
    return type(v).__name__

def debug(value, variable_name):
	value_print_friendly = value
	if isinstance(value, bytes):
		value_print_friendly = 'hex=`{}`, int=`{}`'.format(str(binascii.hexlify(value), 'utf-8'), int.from_bytes(value, byteorder="big"))

	print('`{}`: `{}` = value=`{}`'.format(variable_name, class_name(value), value_print_friendly))



def point_add(p1, p2):
    if (p1 is None):
        return p2
    if (p2 is None):
        return p1
    if (p1[0] == p2[0] and p1[1] != p2[1]):
        return None
    if (p1 == p2):
        lam = (3 * p1[0] * p1[0] * pow(2 * p1[1], p - 2, p)) % p
    else:
        lam = ((p2[1] - p1[1]) * pow(p2[0] - p1[0], p - 2, p)) % p
    x3 = (lam * lam - p1[0] - p2[0]) % p
    return (x3, (lam * (p1[0] - x3) - p1[1]) % p)

def point_mul(p, n):
    r = None
    for i in range(256):
        if ((n >> i) & 1):
            r = point_add(r, p)
        p = point_add(p, p)
    return r

def bytes_point(p):
    return (b'\x03' if p[1] & 1 else b'\x02') + p[0].to_bytes(32, byteorder="big")

def sha256(b):

	# hexlified = binascii.hexlify(b)
	# hexstring = str(hexlified, 'utf-8')
	# encoded = hexstring.encode('utf-8')

	# return int.from_bytes(hashlib.sha256(encoded).digest(), byteorder="big")

	return int.from_bytes(hashlib.sha256(b).digest(), byteorder="big")

def on_curve(point):
    return (pow(point[1], 2, p) - pow(point[0], 3, p)) % p == 7

def jacobi(x):
    return pow(x, (p - 1) // 2, p)

def assert_is_bytes(variable, variable_name):
	if not isinstance(variable, bytes):
		errorType = 'Expected `{}` to have type `{}`'.format(variable_name, type(variable).__name__)
		raise TypeError(errorType)

def schnorr_sign(msg, seckey):
	k = sha256(seckey.to_bytes(32, byteorder="big") + msg)
	R = point_mul(G, k)
	if jacobi(R[1]) != 1:
	    k = n - k
	e = sha256(R[0].to_bytes(32, byteorder="big") + bytes_point(point_mul(G, seckey)) + msg)
	signature = R[0].to_bytes(32, byteorder="big") + ((k + e * seckey) % n).to_bytes(32, byteorder="big")
	return signature

def schnorr_verify(msg, pubkey_point, sig):
	if (not on_curve(pubkey_point)):
		print('NOT ON CURVE')
		return False
	
	r = int.from_bytes(sig[0:32], byteorder="big")
	s = int.from_bytes(sig[32:64], byteorder="big")

	debug(hex(r), 'hex(r)')
	debug(hex(s), 'hex(s)')
	
	if r >= p or s >= n:
		print('r or s to big')
		return False

	pubkey_compressed_bytes = bytes_point(pubkey_point)
	debug(sig[0:32], 'sig[0:32] (a.k.a. `e.0`)')
	debug(pubkey_compressed_bytes, 'pubkey_compressed_bytes (a.k.a. e.1)')
	debug(msg, 'msg (a.k.a. e.2)')

	e = sha256(sig[0:32] + pubkey_compressed_bytes + msg)

	debug(hex(e), 'hex(e)')

	R = point_add(point_mul(G, s), point_mul(pubkey_point, n - e))
	
	debug(R[0], 'R[0]')
	debug(R[1], 'R[1]')

	if R is None:
		assert True == False, "R should not be none"
	if jacobi(R[1]) != 1:
		debug(R[1], 'R[1]')
		assert True == False, "jacobi shhould be 1"
	if R[0] != r:
		assert True == False, "R.x should be r"
		print('R.x neq r')
		return False
	return True

def debug_assert_equal(lhs, rhs):
	lhs_print_friendly = lhs
	if isinstance(lhs, bytes):
		lhs_print_friendly = binascii.hexlify(bytes_point(lhs)).decode("utf-8")

	rhs_print_friendly = rhs
	if isinstance(rhs, bytes):
		rhs_print_friendly = binascii.hexlify(bytes_point(rhs)).decode("utf-8")

	assert lhs == rhs, 'Expected `{}`({}) to equal `{}`({})'.format(lhs_print_friendly, class_name(lhs), rhs_print_friendly, class_name(rhs))

def test_vector(private_key, expected_public_key, message, signature):
	if not isinstance(private_key, str):
		raise TypeError("`private_key` should be `str`, was: `{}`".format(class_name(private_key)))
	if not isinstance(expected_public_key, str):
		raise TypeError("`expected_public_key` should be `str`, was: `{}`".format(class_name(expected_public_key)))
	if not isinstance(message, str):
		raise TypeError("`message` should be `str`, was: `{}`".format(class_name(message)))
	if not isinstance(signature, str):
		raise TypeError("`signature` should be `str`, was: `{}`".format(class_name(signature)))

	private_key = int(private_key, 16)
	pubkey_point = point_mul(G, private_key)

	debug_assert_equal(
		expected_public_key,
		binascii.hexlify(bytes_point(pubkey_point)).decode("utf-8").upper()
	)

	message = bytes.fromhex(message)
	signature = bytes.fromhex(signature)


	calculated_signature = schnorr_sign(message, private_key)
	debug(calculated_signature, 'calculated_signature')
	debug_assert_equal(
		signature,
		calculated_signature
	)
	print("TEST SIGNING PASSED")

	debug_assert_equal(
		True,
		schnorr_verify(message, pubkey_point, signature)
	)
	print("TEST VERIFYING PASSED")

	return True

def test_vector1():
	test_vector(
		private_key = '0000000000000000000000000000000000000000000000000000000000000001',
		expected_public_key = '0279BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798',
		message = '0000000000000000000000000000000000000000000000000000000000000000',
		# signature = '0582344958B04A9B2BCC63C09222F0540167C846512143B37B1978269737EAE16A7DFD9B9D2F751E99FEDC934E8EC5000AEEC240AFAD10A6A6D9F5D104247A99'
		signature = '787A848E71043D280C50470E8E1532B2DD5D20EE912A45DBDD2BD1DFBF187EF67031A98831859DC34DFFEEDDA86831842CCD0079E1F92AF177F7F22CC1DCED05'
	)
	print("TEST VECTOR 1 PASSED")

def test_vector2():
	test_vector(
		private_key = 'B7E151628AED2A6ABF7158809CF4F3C762E7160F38B4DA56A784D9045190CFEF',
		expected_public_key = '02DFF1D77F2A671C5F36183726DB2341BE58FEAE1DA2DECED843240F7B502BA659',
		message = '243F6A8885A308D313198A2E03707344A4093822299F31D0082EFA98EC4E6C89',
		# signature = 'EB3D32A4DEF40C1CB6F6182BC14CEF27F5BFE8BF649C83DC842E90EE7B380F0AFBB45E1B4A98F564DE7DB8286FAA162258398885DF55007C9D4928BB2AF68196'
		signature = '2A298DACAE57395A15D0795DDBFD1DCB564DA82B0F269BC70A74F8220429BA1D1E51A22CCEC35599B8F266912281F8365FFC2D035A230434A1A64DC59F7013FD'
	)
	print("TEST VECTOR 2 PASSED")

def test_vector3():
	test_vector(
		private_key = 'C90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B14E5C7',
		expected_public_key = '03FAC2114C2FBB091527EB7C64ECB11F8021CB45E8E7809D3C0938E4B8C0E5F84B',
		message = '5E2D58D8B3BCDF1ABADEC7829054F90DDA9805AAB56C77333024B9D0A508B75C',
		# signature = '002A4FE22683AF06767E083B84A47495A66811EC3706FB54AD17DCD50CD8F9B413188B94DDDD8A406089DEBD22B6EE7B5EF0B0EFBCBC9E59A8A9978CE932941B'
		signature = '00DA9B08172A9B6F0466A2DEFD817F2D7AB437E0D253CB5395A963866B3574BE00880371D01766935B92D2AB4CD5C8A2A5837EC57FED7660773A05F0DE142380'
	)
	print("TEST VECTOR 3 PASSED")

# OTHER Test Vector source: https://gist.github.com/kallewoof/5d623445802a84f17cc7ff5572109074
def test_vector4():
	test_vector(
		private_key = '0E891B9DFF485000C7D1DC22ECF3A583CC50328684321D61947A86E57CF6C638',
		expected_public_key = '034AE47910D58B9BDE819C3CFFA8DE4441955508DB00AA2540DB8E6BF6E99ABC1B',
		message = '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000019CA91EB535FB92FDA5094110FDAEB752EDB9B039034ae47910d58b9bde819c3cffa8de4441955508db00aa2540db8e6bf6e99abc1b000000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000010000000000000000',
		signature = '58A1D11298C80452B91AB3E562BC7160BEA8DD49A877885D48A17F3AD4D886D6B94A4413A88630686068485588E80A4CAE088FA330ED6A657CF134907157AA64'
	)
	print("TEST VECTOR 4 NOT IMPLEMENTED YET")

# https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#Test_vectors
def run_all_tests():
	test_vector1()
	test_vector2()
	test_vector3()
	test_vector4()
	print("ALL TESTS PASSED :D")

run_all_tests()