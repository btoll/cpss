//go:generate goagen bootstrap -d github.com/btoll/cpss/server/design

package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/goadesign/goa"
	"github.com/goadesign/goa/middleware"
)

func main() {
	// Create service
	service := goa.New("cpss")

	// Mount middleware
	service.Use(middleware.RequestID())
	service.Use(middleware.LogRequest(true))
	service.Use(middleware.ErrorHandler(service, true))
	service.Use(middleware.Recover())

	// Mount "Specialist" controller
	c := NewSpecialistController(service)
	app.MountSpecialistController(service, c)
	d := NewBillSheetController(service)
	app.MountBillSheetController(service, d)
	e := NewConsumerController(service)
	app.MountConsumerController(service, e)

	// Start service
	if err := service.ListenAndServe(":8080"); err != nil {
		service.LogError("startup", "err", err)
	}
}
