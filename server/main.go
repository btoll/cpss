//go:generate goagen bootstrap -d github.com/btoll/cpss/server/design

package main

import (
	"context"
	"net/http"
	"strconv"
	"strings"

	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
	"github.com/goadesign/goa"
	"github.com/goadesign/goa/middleware"
)

func CheckSession() goa.Middleware {
	return func(h goa.Handler) goa.Handler {
		return func(ctx context.Context, rw http.ResponseWriter, req *http.Request) error {
			// If parts[3] == "list" then the endpoint is "/cpss/specialist/list" which we want to ignore.
			// We're only interested in GET requests for a particular specialist ID, such as "/cpss/specialist/117".
			if parts := strings.SplitN(req.URL.String(), "/", -1); req.Method == "GET" && parts[3] != "list" {
				n, err := strconv.Atoi(parts[3])
				if err != nil {
					return err
				}
				err = sql.CheckSession(n)
				if err != nil {
					return err
				}
			}
			h(ctx, rw, req)
			return nil
		}
	}
}

func main() {
	// Create service
	service := goa.New("cpss")

	// Mount middleware
	service.Use(middleware.RequestID())
	service.Use(middleware.LogRequest(true))
	service.Use(middleware.ErrorHandler(service, true))
	service.Use(middleware.Recover())
	service.Use(CheckSession())

	// Mount "Specialist" controller
	c := NewSpecialistController(service)
	app.MountSpecialistController(service, c)
	d := NewBillSheetController(service)
	app.MountBillSheetController(service, d)
	e := NewConsumerController(service)
	app.MountConsumerController(service, e)
	f := NewSessionController(service)
	app.MountSessionController(service, f)
	g := NewStatusController(service)
	app.MountStatusController(service, g)
	h := NewCountyController(service)
	app.MountCountyController(service, h)
	j := NewServiceCodeController(service)
	app.MountServiceCodeController(service, j)
	k := NewDIAController(service)
	app.MountDIAController(service, k)
	l := NewFundingSourceController(service)
	app.MountFundingSourceController(service, l)
	m := NewPayHistoryController(service)
	app.MountPayHistoryController(service, m)

	// Start service
	if err := service.ListenAndServe(":8080"); err != nil {
		service.LogError("startup", "err", err)
	}
}
