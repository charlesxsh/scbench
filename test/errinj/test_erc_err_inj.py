import unittest
from errinj.pm import InjectContext, inject_call_error, inject_throw_error
from sol.utils import compile, get_the_function


class TestInjCallError(unittest.TestCase):
    def test_erc721(self):
        _, cu = compile("testdata/ZtrendZ-0xC4200952.sol")
        with open("testdata/ZtrendZ-0xC4200952.sol", "r") as f:
            lines = f.read().splitlines(True)
        f = get_the_function(cu, "ZtrendZ", fname="safeTransferFrom", fnumofargs=4)
        cls = inject_call_error(InjectContext(
            cu, f, contract=None, lines=lines
        ), 0, expect_call_fn="onERC721Received")

        self.assertEqual(len(cls), 1)
        cl = cls[0]
        self.assertEqual(cl.orig_range, (951, 965))
        self.assertEqual(cl.to_replace, ["    return true;"])

    
    def test_erc1155(self):
        _, cu = compile("testdata/W3Tour1155-0x9426c3de.sol")
        with open("testdata/W3Tour1155-0x9426c3de.sol", "r") as f:
            lines = f.read().splitlines(True)
        f = get_the_function(cu, "W3Tour1155", fname="safeTransferFrom", fnumofargs=5)
        cls = inject_call_error(InjectContext(
            cu, f, contract=None, lines=lines
        ), 0, expect_call_fn="onERC1155Received")

        self.assertEqual(len(cls), 1)
        cl = cls[0]
        self.assertEqual(cl.orig_range, (1941, 1951))
        self.assertEqual(cl.to_replace, [""])


       
class TestInjThrowError(unittest.TestCase):
    def test_throw_erc20(self):
        _, cu = compile("testdata/IterableMapping-0xc347a57f.sol")
        with open("testdata/IterableMapping-0xc347a57f.sol", "r") as f:
            lines = f.read().splitlines(True)
        f = get_the_function(cu, "Yieldilizer", fname="transferFrom", fnumofargs=3)
        cls = inject_throw_error(InjectContext(
            cu, f, contract=None, lines=lines
        ), 0, [0], True, 1)
        matched = [cl for cl in cls if cl.orig_range[0] == 406 and cl.orig_range[1] == 413]
        self.assertEqual(len(matched), 1)
