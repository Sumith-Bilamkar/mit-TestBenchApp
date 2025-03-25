package main

import (
	"fmt"
	"log"
	"net/http"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, World!")
}

func main() {
	http.HandleFunc("/", helloHandler)
	port := ":8085"
	fmt.Println("Starting server on", port)
	log.Fatal(http.ListenAndServe(port, nil))
}
