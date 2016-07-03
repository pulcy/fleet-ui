package main

import (
	"flag"
	"fmt"
	"github.com/codegangsta/negroni"
	"github.com/gorilla/mux"
	"gopkg.in/unrolled/render.v1"
	"net/http"
	"os"
)

var (
	renderer     *render.Render
	fleetClient  FleetClient
	tempDir      string
	etcdPeer     string
	etcdPeerFlag = flag.String("etcd-peer", "172.17.42.1", "ETCD_PEER")
	bind         string
	bindFlag     = flag.String("bind", "0.0.0.0:3000", "BIND")
	prefix       string
	prefixFlag   = flag.String("prefix", "/fleet", "URL prefix")
)

func init() {
	// parse command argument
	flag.Parse()
	if v := os.Getenv("ETCD_PEER"); v != "" {
		etcdPeer = v
	} else {
		etcdPeer = *etcdPeerFlag
	}
	if v := os.Getenv("BIND"); v != "" {
		bind = v
	} else {
		bind = *bindFlag
	}
	prefix = *prefixFlag

	// init global variables
	renderer = render.New(render.Options{})
	fleetClient = NewClientCLIWithPeer(fmt.Sprintf("%s", etcdPeer))
	tempDir = "./tmp"
	if _, err := os.Stat(tempDir); os.IsNotExist(err) {
		os.Mkdir(tempDir, 0755)
	}
}

func main() {
	r := mux.NewRouter().StrictSlash(false)
	if prefix != "" {
		fmt.Printf("Using prefix '%s'\n", prefix)
		r = r.PathPrefix(prefix).Subrouter()
	}

	api := r.PathPrefix("/api/v1").Subrouter()

	// routing machines collection
	machines := api.Path("/machines").Subrouter()
	machines.Methods("GET").HandlerFunc(machineAllHandler)

	// routing units collection
	units := api.Path("/units").Subrouter()
	units.Methods("GET").HandlerFunc(statusAllHandler)
	units.Methods("POST").HandlerFunc(submitUnitHandler)
	api.Path("/units/upload").Methods("POST").HandlerFunc(uploadUnitHandler)

	// routing units singular
	unit := api.PathPrefix("/units/{id}").Subrouter()
	unit.Methods("GET").HandlerFunc(statusHandler)
	unit.Methods("DELETE").HandlerFunc(destroyHandler)
	unit.Path("/start").Methods("POST").HandlerFunc(startHandler)
	unit.Path("/stop").Methods("POST").HandlerFunc(stopHandler)
	unit.Path("/load").Methods("POST").HandlerFunc(loadHandler)

	// routing websocket
	r.Path("/ws/journal/{id}").HandlerFunc(wsHandler)

	static := negroni.NewStatic(http.Dir("public"))
	static.Prefix = prefix
	n := negroni.New(negroni.NewRecovery(), negroni.NewLogger(), static)
	n.UseHandler(r)

	n.Run(bind)
}
