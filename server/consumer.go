package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/goadesign/goa"
)

// ConsumerController implements the Consumer resource.
type ConsumerController struct {
	*goa.Controller
}

// NewConsumerController creates a Consumer controller.
func NewConsumerController(service *goa.Service) *ConsumerController {
	return &ConsumerController{Controller: service.NewController("ConsumerController")}
}

// Create runs the create action.
func (c *ConsumerController) Create(ctx *app.CreateConsumerContext) error {
	// ConsumerController_Create: start_implement

	// Put your logic here

	// ConsumerController_Create: end_implement
	res := &app.ConsumerMediaTiny{}
	return ctx.OKTiny(res)
}

// Delete runs the delete action.
func (c *ConsumerController) Delete(ctx *app.DeleteConsumerContext) error {
	// ConsumerController_Delete: start_implement

	// Put your logic here

	// ConsumerController_Delete: end_implement
	res := &app.ConsumerMediaTiny{}
	return ctx.OKTiny(res)
}

// List runs the list action.
func (c *ConsumerController) List(ctx *app.ListConsumerContext) error {
	// ConsumerController_List: start_implement

	// Put your logic here

	// ConsumerController_List: end_implement
	res := app.ConsumerMediaCollection{}
	return ctx.OK(res)
}
