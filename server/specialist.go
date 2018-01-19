package main

import (
	"strconv"

	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
	_ "github.com/go-sql-driver/mysql"
	"github.com/goadesign/goa"
)

// SpecialistController implements the Specialist resource.
type SpecialistController struct {
	*goa.Controller
}

// NewSpecialistController creates a Specialist controller.
func NewSpecialistController(service *goa.Service) *SpecialistController {
	return &SpecialistController{Controller: service.NewController("SpecialistController")}
}

// Create runs the create action.
func (c *SpecialistController) Create(ctx *app.CreateSpecialistContext) error {
	// SpecialistController_Create: start_implement

	res, err := sql.Create(sql.NewSpecialist(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(res.(*app.SpecialistMedia))

	// SpecialistController_Create: end_implement
}

// Delete runs the delete action.
func (c *SpecialistController) Delete(ctx *app.DeleteSpecialistContext) error {
	// SpecialistController_Delete: start_implement

	err := sql.Delete(sql.NewSpecialist(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.SpecialistMediaTiny{ctx.ID})

	// SpecialistController_Delete: end_implement
}

// List runs the list action.
func (c *SpecialistController) List(ctx *app.ListSpecialistContext) error {
	// SpecialistController_List: start_implement

	collection, err := sql.List(sql.NewSpecialist(nil))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.SpecialistMediaCollection))

	// SpecialistController_List: end_implement
}

// Update runs the update action.
func (c *SpecialistController) Update(ctx *app.UpdateSpecialistContext) error {
	// SpecialistController_Update: start_implement

	err := sql.Update(sql.NewSpecialist(ctx.Payload))
	if err != nil {
		return err
	}
	id, err := strconv.Atoi(ctx.ID)
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.SpecialistMediaTiny{id})

	// SpecialistController_Update: end_implement
}
