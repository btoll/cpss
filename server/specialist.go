package main

import (
	"strconv"

	"github.com/btoll/cpss/server/app"
	"github.com/goadesign/goa"
)

func fakeData() app.SpecialistMediaCollection {
	data := [][]string{
		{"btoll", "****", "Ben", "Toll", "ben@foo", "10.00"},
		{"gtoll", "****", "Ginger", "Toll", "ginger@foo", "11.34"},
		{"fmoseley", "****", "Fred", "Moseley", "fred@foo", "66.66"},
		{"tnelson", "****", "Trey", "Nelson", "trey@foo", "17.42"},
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
			Payrate:   toFloat(d[5]),
		}
	}
	return res
}

func toFloat(s string) float64 {
	f, err := strconv.ParseFloat(s, 32)
	if err != nil {
		return 0.00
	}
	return f
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
