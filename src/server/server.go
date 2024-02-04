package main

import (
	"fmt"

	timedrop "github.com/erock530/timedrop/src"
)

//import "flag"

var (
	sha1ver   string // sha1 revision used to build the app
	buildTime string // when the exe was built
	Version   string // application version
)

func main() {
	//	flag.Usage = flagUsage
	//	debugMode := flag.Bool("debug", false, "Debug Mode")
	//	isContainerized := flag.Bool("container", false, "App is a container. This removes the /time endpoint directly from the app.")
	//	flag.Parse()

	fmt.Println("timedrop v" + Version + " starting up ...")
	timedrop.RunServer()
}
