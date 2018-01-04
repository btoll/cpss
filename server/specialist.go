package main

import (
	"strconv"

	"github.com/btoll/cpss/server/app"
	"github.com/goadesign/goa"
)

func fakeData() app.SpecialistMediaCollection {
	data := [][]string{
		{"btoll", "****", "Ben", "Toll", "ben@foo"},
		{"gtoll", "****", "Ginger", "Toll", "ginger@foo"},
		{"fmoseley", "****", "Fred", "Moseley", "fred@foo"},
		{"tnelson", "****", "Trey", "Nelson", "trey@foo"},
	}
	res := make(app.SpecialistMediaCollection, len(data))
	for i, d := range data {
		res[i] = &app.SpecialistMedia{
			ID:        strconv.Itoa(i),
			Username:  d[0],
			Password:  d[1],
			Firstname: d[2],
			Lastname:  d[3],
			Email:     d[4],
		}
	}
	return res
}

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

	// Put your logic here

	// SpecialistController_Create: end_implement
	res := &app.SpecialistMediaTiny{}
	return ctx.OKTiny(res)
}

// Delete runs the delete action.
func (c *SpecialistController) Delete(ctx *app.DeleteSpecialistContext) error {
	// SpecialistController_Delete: start_implement

	// Put your logic here

	// SpecialistController_Delete: end_implement
	return nil
}

// List runs the list action.
func (c *SpecialistController) List(ctx *app.ListSpecialistContext) error {
	// SpecialistController_List: start_implement

	return ctx.OK(fakeData())

	// SpecialistController_List: end_implement
}
