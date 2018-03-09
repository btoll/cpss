package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
	"github.com/goadesign/goa"
)

// ServiceCodeController implements the ServiceCode resource.
type ServiceCodeController struct {
	*goa.Controller
}

// NewServiceCodeController creates a ServiceCode controller.
func NewServiceCodeController(service *goa.Service) *ServiceCodeController {
	return &ServiceCodeController{Controller: service.NewController("ServiceCodeController")}
}

// Create runs the create action.
func (c *ServiceCodeController) Create(ctx *app.CreateServiceCodeContext) error {
	// ServiceCodeController_Create: start_implement

	res, err := sql.Create(sql.NewServiceCode(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(res.(*app.ServiceCodeMedia))

	// ServiceCodeController_Create: end_implement
}

// Delete runs the delete action.
func (c *ServiceCodeController) Delete(ctx *app.DeleteServiceCodeContext) error {
	// ServiceCodeController_Delete: start_implement

	err := sql.Delete(sql.NewServiceCode(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.ServiceCodeMediaTiny{ctx.ID})

	// ServiceCodeController_Delete: end_implement
}

// List runs the list action.
func (c *ServiceCodeController) List(ctx *app.ListServiceCodeContext) error {
	// ServiceCodeController_List: start_implement

	collection, err := sql.List(sql.NewServiceCode(nil))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.ServiceCodeMediaCollection))

	// ServiceCodeController_List: end_implement
}

// Update runs the update action.
func (c *ServiceCodeController) Update(ctx *app.UpdateServiceCodeContext) error {
	// ServiceCodeController_Update: start_implement

	rec, err := sql.Update(sql.NewServiceCode(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(rec.(*app.ServiceCodeMedia))

	// ServiceCodeController_Update: end_implement
}
