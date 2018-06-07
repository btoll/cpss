package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
	"github.com/goadesign/goa"
)

// CountyController implements the County resource.
type CountyController struct {
	*goa.Controller
}

// NewCountyController creates a County controller.
func NewCountyController(service *goa.Service) *CountyController {
	return &CountyController{Controller: service.NewController("CountyController")}
}

// List runs the list action.
func (c *CountyController) List(ctx *app.ListCountyContext) error {
	// CountyController_List: start_implement

	collection, err := sql.List(sql.NewCounty(nil))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.CountyMediaCollection))

	// CountyController_List: end_implement
}
