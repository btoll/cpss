package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/goadesign/goa"
)

// FooController implements the Foo resource.
type FooController struct {
	*goa.Controller
}

// NewFooController creates a Foo controller.
func NewFooController(service *goa.Service) *FooController {
	return &FooController{Controller: service.NewController("FooController")}
}

// List runs the list action.
func (c *FooController) List(ctx *app.ListFooContext) error {
	// FooController_List: start_implement

	// Put your logic here

	// FooController_List: end_implement
	res := app.FooMediaCollection{}
	return ctx.OK(res)
}
