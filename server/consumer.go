package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
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

	id, err := sql.Create(sql.NewConsumer(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.ConsumerMediaTiny{id.(int)})

	// ConsumerController_Create: end_implement
}

// Delete runs the delete action.
func (c *ConsumerController) Delete(ctx *app.DeleteConsumerContext) error {
	// ConsumerController_Delete: start_implement

	err := sql.Delete(sql.NewConsumer(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.ConsumerMediaTiny{ctx.ID})

	// ConsumerController_Delete: end_implement
}

// List runs the list action.
func (c *ConsumerController) List(ctx *app.ListConsumerContext) error {
	// ConsumerController_List: start_implement

	collection, err := sql.List(sql.NewConsumer(nil))
	if err != nil {
		return err
	}
	return ctx.OK(collection.([]*app.ConsumerItem))

	// ConsumerController_List: end_implement
}

// Page runs the page action.
func (c *ConsumerController) Page(ctx *app.PageConsumerContext) error {
	// ConsumerController_Page: start_implement

	collection, err := sql.Page(sql.NewConsumer(ctx.Page))
	if err != nil {
		return err
	}
	return ctx.OKPaging(collection.(*app.ConsumerMediaPaging))

	// ConsumerController_Page: end_implement
}

// Query runs the query action.
func (c *ConsumerController) Query(ctx *app.QueryConsumerContext) error {
	// ConsumerController_Query: start_implement

	collection, err := sql.Query(sql.NewConsumer(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OKPaging(collection.(*app.ConsumerMediaPaging))

	// ConsumerController_Query: end_implement
}

// Update runs the update action.
func (c *ConsumerController) Update(ctx *app.UpdateConsumerContext) error {
	// ConsumerController_Update: start_implement

	rec, err := sql.Update(sql.NewConsumer(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(rec.(*app.ConsumerMedia))

	// ConsumerController_Update: end_implement
}
