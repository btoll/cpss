package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
	"github.com/goadesign/goa"
)

// TimeEntryController implements the TimeEntry resource.
type TimeEntryController struct {
	*goa.Controller
}

// NewTimeEntryController creates a TimeEntry controller.
func NewTimeEntryController(service *goa.Service) *TimeEntryController {
	return &TimeEntryController{Controller: service.NewController("TimeEntryController")}
}

// Create runs the create action.
func (c *TimeEntryController) Create(ctx *app.CreateTimeEntryContext) error {
	// TimeEntryController_Create: start_implement

	id, err := sql.Create(sql.NewTimeEntry(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.TimeEntryMediaTiny{id.(int)})

	// TimeEntryController_Create: end_implement
}

// Delete runs the delete action.
func (c *TimeEntryController) Delete(ctx *app.DeleteTimeEntryContext) error {
	// TimeEntryController_Delete: start_implement

	err := sql.Delete(sql.NewTimeEntry(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.TimeEntryMediaTiny{ctx.ID})

	// TimeEntryController_Delete: end_implement
}

// List runs the list action.
func (c *TimeEntryController) List(ctx *app.ListTimeEntryContext) error {
	// TimeEntryController_List: start_implement

	collection, err := sql.List(sql.NewTimeEntry(nil))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.TimeEntryMediaCollection))

	// TimeEntryController_List: end_implement
}

// Page runs the page action.
func (c *TimeEntryController) Page(ctx *app.PageTimeEntryContext) error {
	// TimeEntryController_Page: start_implement

	collection, err := sql.Page(sql.NewTimeEntry(ctx.Page))
	if err != nil {
		return err
	}
	return ctx.OKPaging(collection.(*app.TimeEntryMediaPaging))

	// TimeEntryController_Page: end_implement
}

// Update runs the update action.
func (c *TimeEntryController) Update(ctx *app.UpdateTimeEntryContext) error {
	// TimeEntryController_Update: start_implement

	rec, err := sql.Update(sql.NewTimeEntry(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(rec.(*app.TimeEntryMedia))

	// TimeEntryController_Update: end_implement
}
