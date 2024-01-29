# -*- coding: utf-8 -*-

import sys
from .util import bh2u

try:
    from blspy import BasicSchemeMPL, G1Element, G2Element

    import_success = True
    load_libdashbls = False
except ImportError:
    import_success = False
    load_libdashbls = True


if load_libdashbls:
    import ctypes
    from ctypes import cdll, create_string_buffer, byref, c_bool

    if sys.platform == 'darwin':
        name = '/Users/pshenmic/WebstormProjects/electrum-dash/electrum_dash/libdashbls.dylib'
    elif sys.platform in ('windows', 'win32'):
        name = 'libdashbls-0.dll'
    else:
        name = 'libdashbls.so'

    try:
      ldashbls = cdll.LoadLibrary(name)

      ldashbls.bls_basic_verify.argtypes = [ctypes.c_char_p, ctypes.c_bool, ctypes.c_char_p, ctypes.c_char_p]
      ldashbls.bls_basic_verify.restype = ctypes.c_bool
    except:
      load_libdashbls = False

if load_libdashbls:

    class BasicSchemeMPL:
        def verify(g1element, message, g2element):
            return ldashbls.bls_basic_verify(g1element.bytes, g1element.isLegacy, g2element.bytes, message)

    class G1Element:
        bytes = b""
        isLegacy = False

        def __init__(self, bytes, isLegacy):
            self.bytes = bytes
            self.isLegacy = isLegacy

        def from_bytes(bytes, isLegacy):
            return G1Element(bytes, isLegacy)

    class G2Element:
        bytes = b""

        def __init__(self, bytes):
            self.bytes = bytes

        def from_bytes(bytes):
            return G2Element(bytes)

if not import_success and not load_libdashbls:
    raise ImportError('Can not import blspy')
