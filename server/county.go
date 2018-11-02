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

// Create runs the create action.
func (c *CountyController) Create(ctx *app.CreateCountyContext) error {
	// CountyController_Create: start_implement

	id, err := sql.Create(sql.NewCounty(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.CountyMediaTiny{id.(int)})

	// CountyController_Create: end_implement
}

// Delete runs the delete action.
func (c *CountyController) Delete(ctx *app.DeleteCountyContext) error {
	// CountyController_Delete: start_implement

	err := sql.Delete(sql.NewCounty(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.CountyMediaTiny{ctx.ID})

	// CountyController_Delete: end_implement
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

// Page runs the page action.
func (c *CountyController) Page(ctx *app.PageCountyContext) error {
	// CountyController_Page: start_implement

	collection, err := sql.Page(sql.NewCounty(ctx.Page))
	if err != nil {
		return err
	}
	return ctx.OKPaging(collection.(*app.CountyMediaPaging))

	// CountyController_Page: end_implement
}

// Show runs the show action.
func (c *CountyController) Show(ctx *app.ShowCountyContext) error {
	// CountyController_Show: start_implement

	collection, err := sql.Read(sql.NewCounty(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.CountyMediaCollection))

	// CountyController_Show: end_implement
}

// Update runs the update action.
func (c *CountyController) Update(ctx *app.UpdateCountyContext) error {
	// CountyController_Update: start_implement

	rec, err := sql.Update(sql.NewCounty(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(rec.(*app.CountyMedia))

	// CountyController_Update: end_implement
}
