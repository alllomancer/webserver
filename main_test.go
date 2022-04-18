package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHandler(t *testing.T) {

	req, err := http.NewRequest("GET", buildUrl("/health"), nil)
	if err != nil {
		t.Fatal(err)
	}

	res := httptest.NewRecorder()

	health(res, req)

	if res.Code != http.StatusOK {
		t.Errorf("Health Response code was %v; want 200", res.Code)
	}

	req, err = http.NewRequest("GET", buildUrl("/me"), nil)
	if err != nil {
		t.Fatal(err)
	}

	me(res, req)

	if res.Code != http.StatusOK {
		t.Errorf("Me Response code was %v; want 200", res.Code)
	}

}

func buildUrl(path string) string {
	return urlFor("http", "80", path)
}

func urlFor(scheme string, serverPort string, path string) string {
	return scheme + "://localhost:" + serverPort + path
}
