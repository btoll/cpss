package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/goadesign/goa"
)

// StatusController implements the Status resource.
type StatusController struct {
	*goa.Controller
}

// NewStatusController creates a Status controller.
func NewStatusController(service *goa.Service) *StatusController {
	return &StatusController{Controller: service.NewController("StatusController")}
}

// Create runs the create action.
func (c *StatusController) Create(ctx *app.CreateStatusContext) error {
	// StatusController_Create: start_implement

	// Put your logic here

	// StatusController_Create: end_implement
	res := &app.StatusMedia{}
	return ctx.OK(res)
}

// Delete runs the delete action.
func (c *StatusController) Delete(ctx *app.DeleteStatusContext) error {
	// StatusController_Delete: start_implement

	// Put your logic here

	// StatusController_Delete: end_implement
	res := &app.StatusMediaTiny{}
	return ctx.OKTiny(res)
}

// List runs the list action.
func (c *StatusController) List(ctx *app.ListStatusContext) error {
	// StatusController_List: start_implement

	// Put your logic here

	// StatusController_List: end_implement
	res := app.StatusMediaCollection{}
	return ctx.OK(res)
}
