package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
	"github.com/goadesign/goa"
)

// CityController implements the City resource.
type CityController struct {
	*goa.Controller
}

// NewCityController creates a City controller.
func NewCityController(service *goa.Service) *CityController {
	return &CityController{Controller: service.NewController("CityController")}
}

// Create runs the create action.
func (c *CityController) Create(ctx *app.CreateCityContext) error {
	// CityController_Create: start_implement

	id, err := sql.Create(sql.NewCity(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.CityMediaTiny{id.(int)})

	// CityController_Create: end_implement
}

// Delete runs the delete action.
func (c *CityController) Delete(ctx *app.DeleteCityContext) error {
	// CityController_Delete: start_implement

	err := sql.Delete(sql.NewCity(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.CityMediaTiny{ctx.ID})

	// CityController_Delete: end_implement
}

// List runs the list action.
func (c *CityController) List(ctx *app.ListCityContext) error {
	// CityController_List: start_implement

	collection, err := sql.List(sql.NewCity(ctx.Page))
	if err != nil {
		return err
	}
	return ctx.OKPaging(collection.(*app.CityMediaPaging))

	// CityController_List: end_implement
}

// Show runs the show action.
func (c *CityController) Show(ctx *app.ShowCityContext) error {
	// CityController_Show: start_implement

	collection, err := sql.Read(sql.NewCity(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.CityMediaCollection))

	// CityController_Show: end_implement
}

// Update runs the update action.
func (c *CityController) Update(ctx *app.UpdateCityContext) error {
	// CityController_Update: start_implement

	rec, err := sql.Update(sql.NewCity(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(rec.(*app.CityMedia))

	// CityController_Update: end_implement
}
