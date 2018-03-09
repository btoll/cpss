package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
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

	res, err := sql.Create(sql.NewStatus(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(res.(*app.StatusMedia))

	// StatusController_Create: end_implement
}

// Delete runs the delete action.
func (c *StatusController) Delete(ctx *app.DeleteStatusContext) error {
	// StatusController_Delete: start_implement

	err := sql.Delete(sql.NewStatus(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.StatusMediaTiny{ctx.ID})

	// StatusController_Delete: end_implement
}

// List runs the list action.
func (c *StatusController) List(ctx *app.ListStatusContext) error {
	// StatusController_List: start_implement

	collection, err := sql.List(sql.NewStatus(nil))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.StatusMediaCollection))

	// StatusController_List: end_implement
}

// Update runs the update action.
func (c *StatusController) Update(ctx *app.UpdateStatusContext) error {
	// StatusController_Update: start_implement

	rec, err := sql.Update(sql.NewStatus(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(rec.(*app.StatusMedia))

	// StatusController_Update: end_implement
}
