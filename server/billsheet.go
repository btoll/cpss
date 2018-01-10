package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/goadesign/goa"
)

// BillSheetController implements the BillSheet resource.
type BillSheetController struct {
	*goa.Controller
}

// NewBillSheetController creates a BillSheet controller.
func NewBillSheetController(service *goa.Service) *BillSheetController {
	return &BillSheetController{Controller: service.NewController("BillSheetController")}
}

// Create runs the create action.
func (c *BillSheetController) Create(ctx *app.CreateBillSheetContext) error {
	// BillSheetController_Create: start_implement

	// Put your logic here

	// BillSheetController_Create: end_implement
	res := &app.BillSheetMediaTiny{}
	return ctx.OKTiny(res)
}

// Delete runs the delete action.
func (c *BillSheetController) Delete(ctx *app.DeleteBillSheetContext) error {
	// BillSheetController_Delete: start_implement

	// Put your logic here

	// BillSheetController_Delete: end_implement
	return nil
}

// List runs the list action.
func (c *BillSheetController) List(ctx *app.ListBillSheetContext) error {
	// BillSheetController_List: start_implement

	// Put your logic here

	// BillSheetController_List: end_implement
	res := app.BillSheetMediaCollection{}
	return ctx.OK(res)
}
