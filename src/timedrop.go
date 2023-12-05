package timedrop

import (
	"crypto/rand"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"
)

var (
	timeCompleteStr string
	listenPort      string
)

func RunServer() {
	// Debug mode - for testing purposes
	debugMode := false

	fmt.Println("timedrop service starting up ...")
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {

		// Pass any cmd arguments to the cmdHandler() func
		theCmd := r.URL.Query().Get("cmd")
		cmdHandler(w, r, theCmd)
	})

	if debugMode {
		listenPort = "localhost:9999"
	} else {
		listenPort = "localhost:9987"
	}
	err := http.ListenAndServe(listenPort, nil)

	if err != nil {
		fmt.Println("Error starting timedrop server:", err)
		os.Exit(1)
	}
	fmt.Println("timedrop service started at: ", listenPort)
}

// Func to handle commands
func cmdHandler(w http.ResponseWriter, r *http.Request, theCmd string) {

	switch theCmd {
	case "time":
		//	WriteToFile(timeFile, time.Now().Format(time.UnixDate))
		//localTime := time.Now().Format(time.UnixDate)
		//timeCompleteStr := "local: " + localTime

		timeCompleteStr = "{"
		for _, name := range []string{
			"",                 // UTC
			"America/Chicago",  // Local
			"Asia/Kabul",       // Afghanistan
			"Africa/Bamako",    // Mali
			"Africa/Niamey",    // Niger
			"Africa/Tunis",     // Tunisia
			"Africa/Tripoli",   // Libya
			"Asia/Damascus",    // Syria
			"Asia/Baghdad",     // Iraq
			"Africa/Mogadishu", //Somalia
			"Asia/Aden",        //Yemen
		} {
			t, err := TimeIn(time.Now(), name)
			if err == nil {
				timeCompleteStr = timeCompleteStr + "\"" + t.Location().String() + "\":" + "\"" + t.Format(time.UnixDate) + "\","
			} else {
				timeCompleteStr = timeCompleteStr + "\"" + name + "\":" + "\"" + "<time unknown>" + "\","
			}
		}
		timeCompleteStr = strings.TrimSuffix(timeCompleteStr, ",") + "}"
		bodyContent(w, r, timeCompleteStr)
	default:
	}

}

func bodyContent(w http.ResponseWriter, r *http.Request, msg string) {
	theFile := "/tmp/timedrop__" + randString() + ".html"
	file, _ := os.Create(theFile)
	file.WriteString(msg + "\n")
	file.Close()
	http.ServeFile(w, r, theFile)
	var err2 = os.Remove(theFile)
	if err2 != nil {
		return
	}

}

// Func to write to a file
func WriteToFile(thefile string, thetext string) {
	f, err := os.Create(thefile)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	_, err2 := f.WriteString(thetext)
	if err2 != nil {
		log.Fatal(err2)
	}

}
func randString() string {
	n := 5
	b := make([]byte, n)
	if _, err := rand.Read(b); err != nil {
		panic(err)
	}
	s := fmt.Sprintf("%X", b)
	return s
}

func TimeIn(t time.Time, name string) (time.Time, error) {
	loc, err := time.LoadLocation(name)
	if err == nil {
		t = t.In(loc)
	}

	//	timeDST := isTimeDST(t)
	//	fmt.Println("Time in DST: %s", isDST(t))
	//	if timeDST {
	// Time is Daylight Savings Time. Let's subtract 3600 seconds (1hr)
	//		fmt.Println(" Time IS in DST")
	//		t = t.Add(-3600)
	//	} else {
	//		t = t
	//	}
	return t, err
}

func isTimeDST(t time.Time) bool {
	hh, mm, _ := t.UTC().Clock()
	tClock := hh*60 + mm
	for m := -1; m > -12; m-- {
		hh, mm, _ := t.AddDate(0, m, 0).UTC().Clock()
		clock := hh*60 + mm
		if clock != tClock {
			if clock > tClock {
				// std to dst
				return true
			}
			// dst to std
			return false
		}
	}
	// assume no dst
	return false
}

func isDST(t time.Time) bool {
	_, tOffset := t.Zone()

	// Jan 1
	janYear := t.Year()
	if t.Month() > 6 {
		janYear = janYear + 1
	}
	jan1Location := time.Date(janYear, 1, 1, 0, 0, 0, 0, t.Location())
	_, janOffset := jan1Location.Zone()

	// July 1
	jul1Location := time.Date(t.Year(), 7, 1, 0, 0, 0, 0, t.Location())
	_, julOffset := jul1Location.Zone()

	if tOffset == janOffset {
		return janOffset > julOffset
	}

	return julOffset > janOffset
}
