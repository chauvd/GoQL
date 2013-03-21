package main

import (
	"crypto/rand"
	"crypto/rsa"
	//"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"flag"
	"fmt"
	"log"
	"math/big"
	"net"
	"os"
	"time"
)

var dest = flag.String("dest", "localhost:8888", "destination address")
var reset = flag.Bool("reset", false, "reset certificates")

func checkError(msg string, err error) {
	if err != nil {
		if msg != "" {
			log.Fatalf("%v: %v", msg, err)
		} else {
			log.Fatalf("%v", err)
		}
	}

	return
}

// http://golang.org/src/pkg/crypto/tls/generate_cert.go
func configure(host string) {
	now := time.Now()

	template := x509.Certificate{
		SerialNumber:          new(big.Int).SetInt64(0),
		Subject:               pkix.Name{CommonName: host},
		NotBefore:             now.Add(-24 * time.Hour).UTC(),
		NotAfter:              now.AddDate(1, 0, 0).UTC(),
		KeyUsage:              x509.KeyUsageKeyEncipherment | x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign,
		BasicConstraintsValid: true,
		MaxPathLen:            1,
		IsCA:                  true,
		SubjectKeyId:          []byte{1, 2, 3, 4},
		Version:               2,
	}

	priv, err := rsa.GenerateKey(rand.Reader, 1024)
	checkError("Failed to gen private key", err)

	der, err := x509.CreateCertificate(rand.Reader, &template, &template, &priv.PublicKey, priv)
	checkError("Failed to create CA certificate", err)

	cert, err := x509.ParseCertificate(der)
	checkError("Error parsing certificate", err)

	opts := x509.VerifyOptions{DNSName: host, Roots: x509.NewCertPool()}
	opts.Roots.AddCert(cert)

	_, err = cert.Verify(opts)
	checkError("Unable to verify certificate options", err)

	log.Println("Writing Certificate to cert.pem...")
	certOut, err := os.Create("cert.pem")
	checkError("Failed to open cert.pem for writing", err)
	pem.Encode(certOut, &pem.Block{Type: "CERTIFICATE", Bytes: der})
	certOut.Close()

	log.Println("Writing RSA Private Key to key.pem...")
	keyOut, err := os.OpenFile("key.pem", os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0600)
	checkError("Failed to open key.pem for writing", err)
	pem.Encode(keyOut, &pem.Block{Type: "RSA PRIVATE KEY", Bytes: x509.MarshalPKCS1PrivateKey(priv)})
	keyOut.Close()

	return
}

func main() {
	flag.Parse()

	host, err := os.Hostname()
	checkError("Can not retrieve host name", err)

	adr, err := net.LookupHost(host)
	checkError("Could not look up host address", err)

	fmt.Printf("\nHost:\t\t%v\nAddress:\t%v[:8888]\nDestination:\t%v\n\n", host, adr[2], *dest)

	_, certExists := os.Stat("cert.pem")
	_, keyExists := os.Stat("key.pem")
	if os.IsNotExist(certExists) || os.IsNotExist(keyExists) || *reset {
		configure(adr[2])
	}

	cert, err := tls.LoadX509KeyPair("cert.pem", "key.pem")
	checkError("Unable to load certificates from file", err)

	config := tls.Config{Certificates: []tls.Certificate{cert}, ClientAuth: tls.RequireAnyClientCert}

}
