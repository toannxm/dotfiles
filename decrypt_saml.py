#!/usr/bin/env python3
"""
SAML Assertion Decryption Script

This script decrypts encrypted SAML assertions from a SAML response XML.
It requires:
1. The SAML response XML file
2. Your private key file (PEM format)
3. Optional: passphrase if private key is encrypted

Usage:
    python decrypt_saml.py <saml_response.xml> <private_key.pem>
    python decrypt_saml.py <saml_response.xml> <private_key.pem> --passphrase "your_passphrase"
"""

import sys
import argparse
import base64
from xml.etree import ElementTree as ET
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend


def load_private_key(key_file, passphrase=None):
    """Load private key from PEM file."""
    with open(key_file, 'rb') as f:
        key_data = f.read()
    
    password = passphrase.encode() if passphrase else None
    
    try:
        private_key = serialization.load_pem_private_key(
            key_data,
            password=password,
            backend=default_backend()
        )
        return private_key
    except Exception as e:
        print(f"Error loading private key: {e}", file=sys.stderr)
        sys.exit(1)


def parse_saml_response(xml_file):
    """Parse SAML response and extract encrypted data."""
    try:
        tree = ET.parse(xml_file)
        root = tree.getroot()
        
        # Namespace definitions
        namespaces = {
            'saml2': 'urn:oasis:names:tc:SAML:2.0:assertion',
            'saml2p': 'urn:oasis:names:tc:SAML:2.0:protocol',
            'xenc': 'http://www.w3.org/2001/04/xmlenc#',
            'ds': 'http://www.w3.org/2000/09/xmldsig#'
        }
        
        # Find encrypted key (the session key encrypted with RSA)
        encrypted_key_elem = root.find('.//xenc:EncryptedKey/xenc:CipherData/xenc:CipherValue', namespaces)
        if encrypted_key_elem is None:
            print("Error: Could not find EncryptedKey CipherValue", file=sys.stderr)
            sys.exit(1)
        
        encrypted_key_b64 = encrypted_key_elem.text.strip()
        encrypted_key = base64.b64decode(encrypted_key_b64)
        
        # Find encrypted data (the assertion encrypted with AES)
        encrypted_data_elem = root.find('.//xenc:EncryptedData/xenc:CipherData/xenc:CipherValue', namespaces)
        if encrypted_data_elem is None:
            print("Error: Could not find EncryptedData CipherValue", file=sys.stderr)
            sys.exit(1)
        
        encrypted_data_b64 = encrypted_data_elem.text.strip()
        encrypted_data = base64.b64decode(encrypted_data_b64)
        
        # Get encryption method
        enc_method_elem = root.find('.//xenc:EncryptedData/xenc:EncryptionMethod', namespaces)
        encryption_algorithm = enc_method_elem.get('Algorithm') if enc_method_elem is not None else None
        
        return {
            'encrypted_key': encrypted_key,
            'encrypted_data': encrypted_data,
            'algorithm': encryption_algorithm
        }
    
    except ET.ParseError as e:
        print(f"Error parsing XML: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


def decrypt_session_key(encrypted_key, private_key):
    """Decrypt the session key using RSA-OAEP."""
    try:
        # RSA-OAEP with SHA1 (as specified in the SAML response)
        session_key = private_key.decrypt(
            encrypted_key,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA1()),
                algorithm=hashes.SHA1(),
                label=None
            )
        )
        return session_key
    except Exception as e:
        print(f"Error decrypting session key: {e}", file=sys.stderr)
        print("Make sure you're using the correct private key that matches the certificate in the SAML response.", file=sys.stderr)
        sys.exit(1)


def decrypt_assertion(encrypted_data, session_key):
    """Decrypt the assertion using AES-256-CBC."""
    try:
        # AES-256-CBC uses 16 bytes IV
        iv = encrypted_data[:16]
        ciphertext = encrypted_data[16:]
        
        # Create cipher
        cipher = Cipher(
            algorithms.AES(session_key),
            modes.CBC(iv),
            backend=default_backend()
        )
        decryptor = cipher.decryptor()
        
        # Decrypt
        plaintext = decryptor.update(ciphertext) + decryptor.finalize()
        
        # Remove PKCS7 padding
        padding_length = plaintext[-1]
        plaintext = plaintext[:-padding_length]
        
        return plaintext.decode('utf-8')
    except Exception as e:
        print(f"Error decrypting assertion: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='Decrypt SAML encrypted assertions',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument('xml_file', help='SAML response XML file')
    parser.add_argument('key_file', help='Private key file (PEM format)')
    parser.add_argument('--passphrase', help='Passphrase for encrypted private key')
    parser.add_argument('--output', '-o', help='Output file for decrypted assertion (default: stdout)')
    
    args = parser.parse_args()
    
    print("Loading private key...", file=sys.stderr)
    private_key = load_private_key(args.key_file, args.passphrase)
    
    print("Parsing SAML response...", file=sys.stderr)
    encrypted_data = parse_saml_response(args.xml_file)
    
    print(f"Encryption algorithm: {encrypted_data['algorithm']}", file=sys.stderr)
    print("Decrypting session key...", file=sys.stderr)
    session_key = decrypt_session_key(encrypted_data['encrypted_key'], private_key)
    
    print("Decrypting assertion...", file=sys.stderr)
    decrypted_assertion = decrypt_assertion(encrypted_data['encrypted_data'], session_key)
    
    print("\n" + "="*80, file=sys.stderr)
    print("DECRYPTED ASSERTION:", file=sys.stderr)
    print("="*80 + "\n", file=sys.stderr)
    
    if args.output:
        with open(args.output, 'w') as f:
            f.write(decrypted_assertion)
        print(f"\nDecrypted assertion saved to: {args.output}", file=sys.stderr)
    else:
        print(decrypted_assertion)


if __name__ == '__main__':
    main()
